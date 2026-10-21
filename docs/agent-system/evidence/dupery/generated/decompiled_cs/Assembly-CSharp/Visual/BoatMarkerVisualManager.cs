using System;
using System.Collections;
using System.Linq;
using GRGLib.Coroutines;
using GRGLib.Extensions.Bezier;
using GRGLib.Extensions.Random;
using GRGLib.Mono;
using UnityEngine;
using UnityEngine.UI;

namespace Visual;

public class BoatMarkerVisualManager : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private Image boat_image;

	[SerializeField]
	private SplineHandler spline_handler;

	private CoroutineRunner rotation_runner;

	private CoroutineRunner movement_runner;

	private CoroutineRunner scale_runner;

	private MultiCoroutineRunner target_calc_runner;

	private System.Random random = RandomExtensions.freshRandom();

	private Vector2 offset;

	private Func<Vector2Int, Vector2> get_true_pos;

	private Vector2 base_position;

	private Vector2Int board_pos;

	private bool moving_boat;

	private bool wants_idle = true;

	private Vector2 target_position;

	private float target_rotation;

	public RectTransform rect_trans => base.transform as RectTransform;

	public void setUp(Func<Vector2Int, Vector2> _converter, Vector2Int _start_position, Vector2 _offset)
	{
		rotation_runner = new CoroutineRunner(this);
		movement_runner = new CoroutineRunner(this);
		scale_runner = new CoroutineRunner(this);
		target_calc_runner = new MultiCoroutineRunner(this);
		offset = _offset;
		get_true_pos = _converter;
		board_pos = _start_position;
		base_position = get_true_pos(_start_position) + offset;
		boat_image.fade(1f, 0.5f, CoroutineExtensions.easeInOutFunc).start(this);
		rect_trans.localPosition = base_position;
		startIdleAnimation();
	}

	public void moveBoat(Vector2Int _position)
	{
		if (board_pos == _position)
		{
			return;
		}
		board_pos = _position;
		Vector3[] curveMovementToPosition = getCurveMovementToPosition(_position);
		base_position = get_true_pos(_position) + offset;
		moving_boat = true;
		movement_runner.run(rect_trans.moveTransformAlongLine(curveMovementToPosition.ToList(), 2.2f, CoroutineExtensions.easeInOutFunc).addCallback(delegate
		{
			moving_boat = false;
			if (wants_idle)
			{
				startIdleAnimation();
			}
			else
			{
				startActiveAnimation();
			}
		}));
		bool flag = rect_trans.localPosition.x < base_position.x;
		target_calc_runner.run(calculateWantedRotation(flag));
		rotation_runner.run(rect_trans.rotateTransformToSmartMovingTarget(() => target_rotation, 2.2f, CoroutineExtensions.easeInOutFunc));
		scale_runner.run(rect_trans.scaleTransform(flag ? new Vector2(-1f, 1f) : new Vector2(1f, 1f), 0.6f, CoroutineExtensions.easeInOutFunc).addCallback(delegate
		{
			scale_runner.run(1f.wait(delegate
			{
				scale_runner.run(rect_trans.scaleTransform(1f, 0.6f, CoroutineExtensions.easeInOutFunc));
			}));
		}));
	}

	private IEnumerator calculateWantedRotation(bool _inversed_scale)
	{
		Vector3 prev_pos = rect_trans.localPosition;
		target_rotation = rect_trans.localEulerAngles.z;
		while (true)
		{
			yield return null;
			Vector3 vector = rect_trans.localPosition - prev_pos;
			target_rotation = Mathf.Clamp(Vector2.SignedAngle(_inversed_scale ? Vector2.right : Vector2.left, vector), -65f, 65f);
			prev_pos = rect_trans.localPosition;
		}
	}

	private Vector3[] getCurveMovementToPosition(Vector2Int _position)
	{
		Vector2 vector = get_true_pos(_position) + offset;
		Vector2 vector2;
		Vector2 vector3;
		if (Mathf.Abs(board_pos.x - _position.x) >= Mathf.Abs(board_pos.y - _position.y))
		{
			vector2 = new Vector2((base_position.x + vector.x) / 2f, base_position.y);
			vector3 = new Vector2((base_position.x + vector.x) / 2f, vector.y);
		}
		else
		{
			vector2 = new Vector2(base_position.x, (base_position.y + vector.y) / 2f);
			vector3 = new Vector2(vector.x, (base_position.y + vector.y) / 2f);
		}
		return BezierCurve.CubicBezierCurve(rect_trans.localPosition, vector2, vector3, vector, 100);
	}

	public void startIdleAnimation()
	{
		if (moving_boat)
		{
			wants_idle = true;
			return;
		}
		movement_runner.run(idleMovement());
		rotation_runner.run(idleRotation());
		scale_runner.run(rect_trans.scaleTransform(1f, 0.35f, CoroutineExtensions.easeInOutFunc));
		target_calc_runner.stop();
	}

	private IEnumerator idleMovement()
	{
		while (true)
		{
			yield return rect_trans.moveTransform(base_position + new Vector2(0f, 4f), random.nextFloat(2f, 2.15f), CoroutineExtensions.easeInOutFunc);
			yield return rect_trans.moveTransform(base_position - new Vector2(0f, 4f), random.nextFloat(2f, 2.15f), CoroutineExtensions.easeInOutFunc);
		}
	}

	private IEnumerator idleRotation()
	{
		while (true)
		{
			yield return rect_trans.rotateTransformSmart(-1.5f, random.nextFloat(1.8f, 1.95f), CoroutineExtensions.easeInOutFunc);
			yield return rect_trans.rotateTransformSmart(1.5f, random.nextFloat(1.8f, 1.95f), CoroutineExtensions.easeInOutFunc);
		}
	}

	public void startActiveAnimation()
	{
		if (moving_boat)
		{
			wants_idle = false;
			return;
		}
		target_calc_runner.run(changeTargetPosAxis(delegate(float _x)
		{
			target_position.x = _x;
		}, 6.4f, offset.x * 2f, 0f, _x: true), changeTargetPosAxis(delegate(float _y)
		{
			target_position.y = _y;
		}, 2f, -12f, 12f, _x: false));
		movement_runner.run(activeAnimation());
		scale_runner.run(scaleActiveAnimation());
	}

	private IEnumerator activeAnimation()
	{
		target_position = rect_trans.localPosition;
		while (true)
		{
			yield return null;
			rect_trans.localPosition = target_position;
		}
	}

	private IEnumerator scaleActiveAnimation()
	{
		float min_flip = base_position.x - (offset.x * 2f - 15f);
		float max_flip = base_position.x - 15f;
		bool scaled_left = true;
		while (true)
		{
			if (scaled_left && target_position.x < min_flip)
			{
				scaled_left = false;
				yield return rect_trans.scaleTransform(new Vector2(-1f, 1f), 0.95f, CoroutineExtensions.easeInOutFunc);
			}
			else if (!scaled_left && target_position.x > max_flip)
			{
				scaled_left = true;
				yield return rect_trans.scaleTransform(1f, 0.95f, CoroutineExtensions.easeInOutFunc);
			}
			else
			{
				yield return null;
			}
		}
	}

	private IEnumerator changeTargetPosAxis(Action<float> _set_pos, float _duration, float _left_diff, float _right_diff, bool _x)
	{
		float x = (_x ? rect_trans.localPosition.x : rect_trans.localPosition.y);
		bool left = true;
		while (true)
		{
			float target = (_x ? base_position.x : base_position.y) - (left ? _left_diff : _right_diff);
			float diff = target - x;
			float e = 0f;
			while (e < _duration)
			{
				e += Time.deltaTime;
				_set_pos(x + CoroutineExtensions.easeInOutFunc(e / _duration) * diff);
				yield return null;
			}
			x = target;
			left = !left;
		}
	}
}
