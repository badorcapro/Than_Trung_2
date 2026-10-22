using System;
using System.Collections;
using GRGLib.Coroutines;
using GRGLib.Extensions.Unity;
using GRGLib.Extensions.Vector;
using GRGLib.Maybe;
using Leads;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;

public class LeadStampManager : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private Canvas canvas;

	[SerializeField]
	private CanvasGroup group;

	[Header("Settings")]
	[SerializeField]
	private float controller_movement_speed = 10f;

	[SerializeField]
	private Vector2 starting_controller_position;

	[SerializeField]
	private Button stamp_button;

	private StampFacade stamp_ref;

	private CoroutineRunner stamp_follow;

	private Action<StampInfo> on_stamp;

	private StampReference stamp;

	private bool stamping;

	private Maybe<Vector2> controller_input = new Maybe<Vector2>();

	private bool high_speed;

	public RectTransform rect_trans => base.transform as RectTransform;

	private void Awake()
	{
		stamp_follow = new CoroutineRunner(this);
	}

	public void startStamping(StampReference _ref, StampVisualDataSO _stamp_data, Action<StampInfo> _callback)
	{
		stamp = _ref;
		on_stamp = _callback;
		group.putOn();
		base.transform.SetAsLastSibling();
		if (stamp_ref != null)
		{
			UnityEngine.Object.Destroy(stamp_ref.gameObject);
		}
		stamp_ref = _stamp_data[_ref, base.transform];
		stamp_ref.setFaded();
		if (GameHandler.instance.using_gamepad)
		{
			stamp_ref.transform.localPosition = starting_controller_position;
			stamp_follow.run(followController());
			stamp_button.Select();
		}
		else
		{
			stamp_follow.run(followMouse());
		}
		stamping = true;
	}

	private IEnumerator followMouse()
	{
		while (true)
		{
			stamp_ref.transform.position = canvas.worldCamera.ScreenToWorldPoint(Pointer.current.position.ReadValue());
			stamp_ref.transform.localPosition = new Vector3(stamp_ref.transform.localPosition.x, stamp_ref.transform.localPosition.y, 0f);
			yield return null;
		}
	}

	private IEnumerator followController()
	{
		while (true)
		{
			if (!controller_input.is_some)
			{
				yield return null;
				continue;
			}
			stamp_ref.transform.localPosition += controller_input.value.normalized.toVector3() * controller_movement_speed * Time.deltaTime * (high_speed ? 2.5f : 1f);
			yield return null;
		}
	}

	public void tryStamp()
	{
		if (stamping && !(stamp_ref.transform.localPosition.x < -50f - rect_trans.sizeDelta.x / 2f) && !(stamp_ref.transform.localPosition.x > 50f + rect_trans.sizeDelta.x / 2f) && !(stamp_ref.transform.localPosition.y < -50f - rect_trans.sizeDelta.y / 2f) && !(stamp_ref.transform.localPosition.y > 50f + rect_trans.sizeDelta.y / 2f))
		{
			group.putOn(_on: false);
			stamp_follow.stop();
			stamping = false;
			on_stamp(new StampInfo(stamp, stamp_ref.transform.localPosition, stamp_ref.transform.localEulerAngles.z));
			SteamHelper.addToStats(AchiementStats.STAMPS_PLACED, 1);
		}
	}

	public void onInputChange(PlayerInput _input)
	{
		if (stamping)
		{
			if (_input.isUsingGamepad())
			{
				stamp_follow.run(followController());
			}
			else
			{
				stamp_follow.run(followMouse());
			}
		}
	}

	public void onScroll(InputAction.CallbackContext _context)
	{
		if (stamping && _context.performed)
		{
			float num = Mathf.Clamp(_context.ReadValue<Vector2>().y, -4f, 4f);
			stamp_ref.transform.localEulerAngles = new Vector3(0f, 0f, stamp_ref.transform.localEulerAngles.z + num);
		}
	}

	public void onTrigger(InputAction.CallbackContext _context)
	{
		if (_context.canceled)
		{
			high_speed = false;
		}
		if (_context.performed)
		{
			high_speed = true;
		}
	}

	public void onLeftJoystick(InputAction.CallbackContext _context)
	{
		if (!stamping)
		{
			return;
		}
		if (_context.canceled)
		{
			controller_input = new Maybe<Vector2>();
		}
		else if (_context.performed)
		{
			Vector2 obj = _context.ReadValue<Vector2>();
			if (obj.magnitude < 0.7f)
			{
				controller_input = new Maybe<Vector2>();
			}
			else
			{
				controller_input = obj.maybe();
			}
		}
	}

	public void onRightJoystick(InputAction.CallbackContext _context)
	{
		if (stamping && _context.performed)
		{
			Vector2 to = _context.ReadValue<Vector2>();
			if (!(to.magnitude < 0.9f))
			{
				float z = Vector2.SignedAngle(Vector2.right, to);
				stamp_ref.transform.localEulerAngles = new Vector3(0f, 0f, z);
			}
		}
	}
}
