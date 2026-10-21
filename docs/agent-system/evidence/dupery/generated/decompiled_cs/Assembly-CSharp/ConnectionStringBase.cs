using System;
using System.Collections;
using GRGLib.Coroutines;
using GRGLib.Maybe;
using Save;
using UnityEngine;
using Visual;

public abstract class ConnectionStringBase : MonoBehaviour
{
	protected bool is_base_string;

	protected CoroutineRunner connection_runner;

	protected int colour_index;

	protected Maybe<DragPin> starting_pin = new Maybe<DragPin>();

	protected Maybe<DragPin> ending_pin = new Maybe<DragPin>();

	protected Action<ConnectionStringBase> on_destroy;

	protected virtual void startStringSimulation()
	{
		refreshSimulation();
	}

	public virtual void refreshSimulation(float _sim_length = 5f)
	{
	}

	public virtual void setUp(bool _base = false)
	{
		is_base_string = _base;
		connection_runner = new CoroutineRunner(this);
	}

	public virtual void setUpFromSave(DragPin _start, DragPin _end, Color _colour, int _colour_index, Action<ConnectionStringBase> _on_delete)
	{
		is_base_string = false;
		starting_pin = _start.maybe();
		ending_pin = _end.maybe();
		_start.addString(this);
		_end.addString(this);
		setStringStartPosition(_start.transform.localPosition);
		setStringColour(_colour_index, _colour);
		recalculateString();
		refreshSimulation(0.1f);
		GameHandler.State.getCaseNotes().strings_data.addString(toSave());
		on_destroy = _on_delete;
	}

	public virtual void baseConnecting(PinsController _pins_controller, Func<Vector2> _get_mouse_pos, float _snap_dist)
	{
		connection_runner.run(tryConnectToClosest(_pins_controller.getClosestPinWithinDist, _get_mouse_pos, _snap_dist));
	}

	public abstract void setStringStartPosition(Vector2 _pos);

	public abstract void setStringEndPosition(Vector2 _pos);

	public virtual void startConnectingMouse(DragPin _pin, PinsController _pins_controller, Func<Vector2> _get_mouse_pos, float _snap_dist, Action<ConnectionStringBase> _on_delete)
	{
		setUp();
		starting_pin = _pin.maybe();
		setStringStartPosition(_pin.transform.localPosition);
		setStringEndPosition(_pin.transform.localPosition);
		startStringSimulation();
		connection_runner.run(tryConnectToClosest(_pins_controller.getClosestPinWithinDist, _get_mouse_pos, _snap_dist));
		on_destroy = _on_delete;
	}

	public virtual void startConnectingController(DragPin _pin, PinsController _pins_controller, Func<Vector2> _get_controller_pos, Action<ConnectionStringBase> _on_delete)
	{
		setUp();
		starting_pin = _pin.maybe();
		setStringStartPosition(_pin.transform.localPosition);
		setStringEndPosition(_pin.transform.localPosition);
		startStringSimulation();
		connection_runner.run(followController(_pins_controller.getClosestPinWithinDist, _get_controller_pos, 5f));
		on_destroy = _on_delete;
	}

	public abstract void setStringColour(int _colour_index, Color _colour);

	public abstract Color getStringColour();

	public void destroyStringWithScissors()
	{
		starting_pin.value.deatach(this);
		ending_pin.value.deatach(this);
		on_destroy(this);
		GameHandler.State.getCaseNotes().strings_data.removeString(starting_pin.value.pin_index, ending_pin.value.pin_index);
		retractString();
	}

	public void destroyString(DragPin _from)
	{
		if (starting_pin.value == _from)
		{
			ending_pin.value.deatach(this);
		}
		else
		{
			starting_pin.value.deatach(this);
		}
		on_destroy(this);
		GameHandler.State.getCaseNotes().strings_data.removeString(starting_pin.value.pin_index, ending_pin.value.pin_index);
		retractString();
	}

	public void destroyStringWithoutDetachment()
	{
		retractString();
	}

	protected abstract void retractString(bool destroy = true);

	public bool stopConnecting(Maybe<DragPin> _closest)
	{
		connection_runner.stop();
		if (!ending_pin.is_some)
		{
			ending_pin = _closest;
		}
		if (ending_pin.is_some)
		{
			setStringEndPosition(ending_pin.value.transform.localPosition);
			starting_pin.value.addString(this);
			ending_pin.value.addString(this);
			GameHandler.State.getCaseNotes().strings_data.addString(toSave());
			return true;
		}
		retractString();
		return false;
	}

	private IEnumerator tryConnectToClosest(Func<Vector2, float, Maybe<DragPin>, Maybe<DragPin>> _get_closest_pin, Func<Vector2> _get_mouse_pos, float _snap_dist)
	{
		Vector2 previous_mouse_pos = _get_mouse_pos();
		while (true)
		{
			Vector2 vector = _get_mouse_pos();
			if (vector != previous_mouse_pos)
			{
				previous_mouse_pos = vector;
				ending_pin = _get_closest_pin(vector, _snap_dist, starting_pin);
				setStringEndPosition(ending_pin.is_some ? ((Vector2)ending_pin.value.transform.localPosition) : vector);
				refreshSimulation();
			}
			yield return null;
		}
	}

	private IEnumerator followController(Func<Vector2, float, Maybe<DragPin>, Maybe<DragPin>> _get_closest_pin, Func<Vector2> _controller_pos, float _snap_dist)
	{
		Vector2 true_pos;
		Vector2 previous_pos = (true_pos = _controller_pos());
		CoroutineRunner string_runner = new CoroutineRunner(this);
		while (true)
		{
			Vector2 current_pos = _controller_pos();
			if (current_pos != previous_pos)
			{
				previous_pos = current_pos;
				ending_pin = _get_closest_pin(current_pos, _snap_dist, starting_pin);
				Vector2 initial_pos = true_pos;
				string_runner.run(CoroutineLibrary.doActionForTime(delegate(float _f)
				{
					true_pos = initial_pos + (current_pos - initial_pos) * _f;
					setStringEndPosition(true_pos);
				}, 0.25f).addCallback(delegate
				{
					true_pos = current_pos;
				}));
				refreshSimulation();
			}
			yield return null;
		}
	}

	public bool isSame(DragPin _other)
	{
		if (!(starting_pin.value == _other))
		{
			if (ending_pin.is_some)
			{
				return ending_pin.value == _other;
			}
			return false;
		}
		return true;
	}

	public bool isStartingPin(DragPin _other)
	{
		return starting_pin.value == _other;
	}

	public void stopFollowingMouse()
	{
		connection_runner.stop();
		retractString(destroy: false);
	}

	public StringSaveData toSave()
	{
		return new StringSaveData(starting_pin.value.pin_index, ending_pin.value.pin_index, colour_index);
	}

	public float getDistanceFromPoint(Vector2 _point)
	{
		Vector2 vector = starting_pin.value.transform.localPosition;
		Vector2 vector2 = (Vector2)ending_pin.value.transform.localPosition - vector;
		float sqrMagnitude = vector2.sqrMagnitude;
		if (sqrMagnitude == 0f)
		{
			return (_point - vector).magnitude;
		}
		float num = Mathf.Max(0f, Mathf.Min(1f, Vector2.Dot(_point - vector, vector2) / sqrMagnitude));
		Vector2 vector3 = vector + num * vector2;
		return (_point - vector3).magnitude;
	}

	public abstract void recalculateString();
}
