using System;
using System.Collections;
using System.Collections.Generic;
using GRGLib.Coroutines;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using Save;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.InputSystem;
using UnityEngine.UI;

namespace Visual;

public class StringManager : NotesToolManager, IPointerUpHandler, IEventSystemHandler, IPointerDownHandler
{
	[Header("String References")]
	[SerializeField]
	private PinsController pins_controller;

	[SerializeField]
	private PenManager pen_manager;

	[SerializeField]
	private RubberManager rubber_manager;

	[SerializeField]
	private ConnectionString base_string;

	[SerializeField]
	private Image colour_indicator;

	[SerializeField]
	private ColourWheel colour_wheel;

	[SerializeField]
	private RectTransform strings_parent;

	[SerializeField]
	private RectTransform selected_parent;

	[SerializeField]
	private RectTransform unselected_parent;

	[Header("Prefabs")]
	[SerializeField]
	private bool use_verlet_string = true;

	[SerializeField]
	private ConnectionString connection_string_standard;

	[SerializeField]
	private ConnectionStringVerlet connection_string_verlet;

	[Header("Settings")]
	[SerializeField]
	private float string_snap_distance = 50f;

	[SerializeField]
	private Vector3 unselected_position;

	[SerializeField]
	private List<Color> colours;

	private int colour_index;

	private CoroutineRunner string_colour_runner;

	private Maybe<ConnectionStringBase> current_string = new Maybe<ConnectionStringBase>();

	private List<ConnectionStringBase> placed_strings = new List<ConnectionStringBase>();

	protected override Vector3 starting_tool_position => Vector3.zero;

	protected override Vector2 tool_offset => new Vector2(0f, 0f);

	protected override void Awake()
	{
		base.Awake();
		string_colour_runner = new CoroutineRunner(this);
		base_string.setUp(_base: true);
		base_string.setStringColour(colour_index, colours[colour_index]);
	}

	protected override bool canSelect()
	{
		if (!base.tool_selected && !pen_manager.tool_selected)
		{
			return !rubber_manager.tool_selected;
		}
		return false;
	}

	public override void selectPen()
	{
		if (canSelect())
		{
			base.tool_selected = true;
			onToolSelect();
			tool_follow_runner.run(followMouse());
			if (SettingsHandler.display_tooltips)
			{
				base.active_tooltip.setUpAndStart(player_input);
			}
		}
	}

	protected override void onToolSelect()
	{
		base_string.baseConnecting(pins_controller, base.getToolPosition, string_snap_distance);
		base_string.setStringColour(colour_index, colours[colour_index]);
		string_colour_runner.run(checkColourChange());
		base.transform.SetParent(selected_parent);
	}

	public override void deselectPen()
	{
		stopString(new Maybe<DragPin>());
		base.tool_selected = false;
		tool_follow_runner.stop();
		if (tooltip.is_some)
		{
			tooltip.value.fadeAndDestroy();
			tooltip = new Maybe<TemporaryToolTip>();
		}
		onToolDeselect();
	}

	protected override void onToolDeselect()
	{
		colour_wheel.stopMousePosCheckAndClose();
		base_string.stopFollowingMouse();
		base.transform.SetParent(unselected_parent);
		base.transform.localPosition = unselected_position;
	}

	public void onColourSelectStart()
	{
		colour_wheel.startMousePosCheck();
		colour_wheel.setColoursAndOpen(colours, base.transform.position, changeColour, _limit_y: false);
	}

	public void changePenColourLeft(InputAction.CallbackContext _context)
	{
		if (_context.performed && base.tool_selected)
		{
			colour_index += colours.Count - 1;
			colour_index %= colours.Count;
			if (current_string.is_some)
			{
				current_string.value.setStringColour(colour_index, colours[colour_index]);
			}
			base_string.setStringColour(colour_index, colours[colour_index]);
		}
	}

	public void changePenColourRight(InputAction.CallbackContext _context)
	{
		if (_context.performed && base.tool_selected)
		{
			colour_index++;
			colour_index %= colours.Count;
			if (current_string.is_some)
			{
				current_string.value.setStringColour(colour_index, colours[colour_index]);
			}
			base_string.setStringColour(colour_index, colours[colour_index]);
		}
	}

	private IEnumerator checkColourChange()
	{
		return checkColourChange(delegate(int _index)
		{
			colour_index = (colour_index + _index) % colours.Count;
			if (current_string.is_some)
			{
				current_string.value.setStringColour(colour_index, colours[colour_index]);
			}
			base_string.setStringColour(colour_index, colours[colour_index]);
		}, colours.Count);
	}

	public void OnPointerUp(PointerEventData eventData)
	{
		if (!base.tool_selected)
		{
			selectPen();
		}
		else if (eventData.button == PointerEventData.InputButton.Left)
		{
			Maybe<DragPin> maybe = pins_controller.getClosestPinWithinDist(getToolPosition(), string_snap_distance);
			bool flag = false;
			if (!maybe.is_some)
			{
				maybe = pins_controller.addPinAtPosition(getToolPosition(), colours[colour_index]).maybe();
				flag = true;
			}
			stopString(flag ? maybe : new Maybe<DragPin>());
			startStringOnPin(maybe.value);
			base_string.stopFollowingMouse();
		}
		else if (eventData.button == PointerEventData.InputButton.Right)
		{
			deselectPen();
		}
		else if (eventData.button == PointerEventData.InputButton.Middle)
		{
			colour_wheel.stopMousePosCheckAndClose();
		}
	}

	public void OnPointerDown(PointerEventData eventData)
	{
		if (base.tool_selected && eventData.button == PointerEventData.InputButton.Middle)
		{
			onColourSelectStart();
		}
	}

	public void startStringFromPin(DragPin _pin, int _colour_index)
	{
		colour_index = _colour_index;
		selectPen();
		base_string.stopFollowingMouse();
		startStringOnPin(_pin);
	}

	private void startStringOnPin(DragPin _pin)
	{
		if (current_string.is_some)
		{
			Debug.LogError("Starting new string while old string is some???!");
			return;
		}
		current_string = UnityEngine.Object.Instantiate(use_verlet_string ? ((ConnectionStringBase)connection_string_verlet) : ((ConnectionStringBase)connection_string_standard), strings_parent).maybe();
		current_string.value.setStringColour(colour_index, colours[colour_index]);
		current_string.value.startConnectingMouse(_pin, pins_controller, base.getToolPosition, string_snap_distance, removeFromList);
	}

	public void stopString(Maybe<DragPin> _closest)
	{
		if (current_string.is_some)
		{
			if (current_string.value.stopConnecting(_closest))
			{
				placed_strings.Add(current_string.value);
			}
			current_string = new Maybe<ConnectionStringBase>();
		}
	}

	public void startControllerStringFromPin(DragPin _pin, int _colour_index, Func<Vector2> _controller_position)
	{
		colour_index = _colour_index;
		selectPen();
		base_string.stopFollowingMouse();
		startControllerStringOnPin(_pin, _controller_position);
	}

	private void startControllerStringOnPin(DragPin _pin, Func<Vector2> _controller_position)
	{
		if (current_string.is_some)
		{
			Debug.LogError("Starting new string while old string is some???!");
			return;
		}
		current_string = UnityEngine.Object.Instantiate(use_verlet_string ? ((ConnectionStringBase)connection_string_verlet) : ((ConnectionStringBase)connection_string_standard), strings_parent).maybe();
		current_string.value.setStringColour(colour_index, colours[colour_index]);
		current_string.value.startConnectingController(_pin, pins_controller, _controller_position, removeFromList);
	}

	public void stopControllerString(Maybe<DragPin> _closest)
	{
		if (current_string.is_some)
		{
			if (_closest.is_some && current_string.value.isStartingPin(_closest.value))
			{
				current_string.value.destroyStringWithoutDetachment();
			}
			else if (current_string.value.stopConnecting(_closest))
			{
				placed_strings.Add(current_string.value);
			}
			current_string = new Maybe<ConnectionStringBase>();
			deselectPen();
		}
	}

	public List<Color> getPossibleColours()
	{
		return colours;
	}

	public void changeColour(Color _colour)
	{
		colour_index = colours.FindIndex(0, (Color _clr) => _clr == _colour);
		if (current_string.is_some)
		{
			current_string.value.setStringColour(colour_index, colours[colour_index]);
		}
		base_string.setStringColour(colour_index, colours[colour_index]);
	}

	public Color getCurrentStringColour()
	{
		if (!current_string.is_some)
		{
			return colours[0];
		}
		return current_string.value.getStringColour();
	}

	public void setUpFromSave()
	{
		if (!GameHandler.State.case_notes.is_some)
		{
			return;
		}
		CaseNotes caseNotes = GameHandler.State.getCaseNotes();
		if (caseNotes.strings_data.is_empty)
		{
			return;
		}
		Dictionary<int, DragPin> dict = new Dictionary<int, DragPin>();
		List<DragPin> board_pins = pins_controller.getAllPins();
		Dictionary<int, int> indeces = pins_controller.getRemappedIndeces();
		List<StringSaveData> list = caseNotes.strings_data.strings_data.copy();
		caseNotes.strings_data = new StringSave();
		foreach (StringSaveData string_save in list)
		{
			try
			{
				DragPin orCreate = dict.getOrCreate(string_save.pin_connection.Item1, () => board_pins.Find((DragPin _p) => _p.pin_index == indeces[string_save.pin_connection.Item1]));
				DragPin orCreate2 = dict.getOrCreate(string_save.pin_connection.Item2, () => board_pins.Find((DragPin _p) => _p.pin_index == indeces[string_save.pin_connection.Item2]));
				ConnectionStringBase connectionStringBase = UnityEngine.Object.Instantiate(use_verlet_string ? ((ConnectionStringBase)connection_string_verlet) : ((ConnectionStringBase)connection_string_standard), strings_parent);
				connectionStringBase.setUpFromSave(orCreate, orCreate2, colours[string_save.colour], string_save.colour, removeFromList);
				placed_strings.add(connectionStringBase);
			}
			catch (Exception arg)
			{
				Debug.LogError($"Could not put string from save! Error:\n{arg}");
			}
		}
	}

	public void refreshList()
	{
		placed_strings = placed_strings.removeNull();
	}

	public void removeFromList(ConnectionStringBase _string)
	{
		placed_strings.Remove(_string);
	}

	public Maybe<ConnectionStringBase> getCutableString(Vector2 _position, float _cut_dist)
	{
		Maybe<ConnectionStringBase> result = new Maybe<ConnectionStringBase>();
		float num = _cut_dist;
		foreach (ConnectionStringBase placed_string in placed_strings)
		{
			float distanceFromPoint = placed_string.getDistanceFromPoint(_position);
			if (distanceFromPoint < num)
			{
				num = distanceFromPoint;
				result = placed_string.maybe();
			}
		}
		return result;
	}

	public void clearAll()
	{
		placed_strings.ForEach(delegate(ConnectionStringBase _s)
		{
			_s.destroyStringWithoutDetachment();
		});
		placed_strings = new List<ConnectionStringBase>();
		GameHandler.State.getCaseNotes().strings_data.strings_data = new List<StringSaveData>();
	}
}
