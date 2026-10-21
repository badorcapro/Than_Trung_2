using System.Collections;
using Audio;
using GRGLib.Coroutines;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.Events;
using UnityEngine.InputSystem;
using Visual;

public class LeverHandle : MonoBehaviour, IPointerEnterHandler, IEventSystemHandler, IPointerExitHandler, IPointerDownHandler, IPointerUpHandler
{
	private enum InteractableSettings
	{
		DRAG,
		CLICK
	}

	[Header("References")]
	[SerializeField]
	private RectTransform shaft_rt;

	[Header("Callbacks")]
	[SerializeField]
	private UnityEvent<bool> onHandleStateChanged = new UnityEvent<bool>();

	[SerializeField]
	private UnityEvent<bool> onHandleActivation = new UnityEvent<bool>();

	private AbilityVisualManager ability_manager;

	private bool disabled;

	private bool in_zone;

	private bool handle_active;

	private bool handle_engaged;

	private bool handle_state_changed;

	private RectTransform rect_transform;

	private float starting_y;

	private bool using_space_bar;

	private bool handle_selected;

	private float controller_a_value;

	private CoroutineRunner holding_a_runner;

	private CoroutineRunner holding_shoulder_runner;

	private CoroutineRunner auto_lerp_runner;

	public void setUp(AbilityVisualManager _ab_manager)
	{
		ability_manager = _ab_manager;
	}

	public void OnPointerEnter(PointerEventData eventData)
	{
		in_zone = true;
	}

	public void OnPointerExit(PointerEventData eventData)
	{
		in_zone = false;
	}

	public void OnPointerDown(PointerEventData eventData)
	{
		if (!disabled && SettingsHandler.docks_boat_lever != 1 && in_zone && !handle_state_changed)
		{
			handle_active = true;
			onHandleActivation.Invoke(handle_active);
		}
	}

	public void OnPointerUp(PointerEventData eventData)
	{
		if (!checkForClickSetting() && handle_active && !handle_state_changed)
		{
			handle_active = false;
			onHandleActivation.Invoke(handle_active);
			resetHandle();
		}
	}

	public void onSelect()
	{
		handle_selected = true;
	}

	public void onDeselect()
	{
		handle_selected = false;
	}

	public void onSouthButton(InputAction.CallbackContext _context)
	{
		if (!handle_selected || holding_shoulder_runner.is_running)
		{
			return;
		}
		if (_context.canceled)
		{
			if (!checkForClickSetting() && handle_active)
			{
				handle_active = false;
				holding_a_runner.stop();
				controller_a_value = (handle_engaged ? 1 : 0);
				auto_lerp_runner.run(lerpHandle(handle_engaged));
			}
		}
		else if (_context.performed && SettingsHandler.docks_boat_lever != 1)
		{
			handle_active = true;
			auto_lerp_runner.stop();
			holding_a_runner.run(holdA((!handle_engaged) ? 1 : 0, handle_engaged ? 0.3f : 0.5f));
		}
	}

	public void onSpaceButton(InputAction.CallbackContext _context)
	{
		if (_context.canceled)
		{
			if (!checkForClickSetting())
			{
				using_space_bar = false;
				if (handle_active)
				{
					handle_active = false;
					holding_a_runner.stop();
					controller_a_value = (handle_engaged ? 1 : 0);
					auto_lerp_runner.run(lerpHandle(handle_engaged));
				}
			}
		}
		else if (_context.performed && SettingsHandler.docks_boat_lever != 1)
		{
			handle_active = true;
			using_space_bar = true;
			auto_lerp_runner.stop();
			holding_a_runner.run(holdA((!handle_engaged) ? 1 : 0, handle_engaged ? 0.3f : 0.5f));
		}
	}

	public void onShoulder(InputAction.CallbackContext _context)
	{
		if (holding_a_runner.is_running)
		{
			return;
		}
		if (_context.canceled)
		{
			if (!checkForClickSetting() && handle_active)
			{
				handle_active = false;
				holding_shoulder_runner.stop();
				controller_a_value = (handle_engaged ? 1 : 0);
				auto_lerp_runner.run(lerpHandle(handle_engaged));
			}
		}
		else if (_context.performed && SettingsHandler.docks_boat_lever != 1)
		{
			handle_active = true;
			auto_lerp_runner.stop();
			holding_shoulder_runner.run(holdA((!handle_engaged) ? 1 : 0));
		}
	}

	private IEnumerator holdA(float _target, float _duration = 0.5f)
	{
		float e = 0f;
		float starting_value = controller_a_value;
		float diff = _target - starting_value;
		while (e < _duration)
		{
			e += Time.deltaTime;
			controller_a_value = starting_value + diff * CoroutineExtensions.easeInFunc(e / _duration);
			yield return null;
		}
		controller_a_value = _target;
	}

	private void resetHandle()
	{
		rect_transform.anchoredPosition = new Vector2(rect_transform.anchoredPosition.x, handle_engaged ? (0f - starting_y) : starting_y);
		shaft_rt.rotation = Quaternion.Euler(handle_engaged ? 150 : 0, 0f, 0f);
	}

	public Vector2 getPointerPos()
	{
		return Pointer.current.position.ReadValue();
	}

	private void Awake()
	{
		holding_a_runner = new CoroutineRunner(this);
		holding_shoulder_runner = new CoroutineRunner(this);
		auto_lerp_runner = new CoroutineRunner(this);
		rect_transform = GetComponent<RectTransform>();
		refreshYAnchors();
	}

	private void refreshYAnchors()
	{
		starting_y = rect_transform.anchoredPosition.y;
	}

	public float updateYPos()
	{
		Vector2 pointerPos = getPointerPos();
		RectTransformUtility.ScreenPointToLocalPointInRectangle(base.transform.parent.GetComponent<RectTransform>(), pointerPos, Camera.main, out var localPoint);
		float num = Mathf.Clamp(localPoint.y, 0f - starting_y, starting_y);
		rect_transform.anchoredPosition = new Vector2(rect_transform.anchoredPosition.x, num);
		return Mathf.InverseLerp(starting_y, 0f - starting_y, num);
	}

	public void setDisabled(bool _new_state)
	{
		disabled = _new_state;
	}

	private void Update()
	{
		handle_state_changed = false;
		if (handle_active)
		{
			float num;
			if (GameHandler.instance.using_gamepad || using_space_bar)
			{
				num = controller_a_value;
				rect_transform.anchoredPosition = new Vector2(rect_transform.anchoredPosition.x, starting_y + -2f * starting_y * num);
			}
			else
			{
				num = updateYPos();
			}
			shaft_rt.rotation = Quaternion.Euler(Mathf.Lerp(0f, 150f, num), 0f, 0f);
			if (num == 1f && !handle_engaged)
			{
				controller_a_value = num;
				handle_active = false;
				handle_engaged = true;
				handle_state_changed = true;
				base.transform.parent.GetComponent<MonoBehaviour>().jiggle();
				onHandleStateChanged.Invoke(arg0: true);
				ability_manager.cancelIfSelectionExists();
				AudioHandler.Sfx.playSfx(Sfx.BOAT_ACTIVATE, 0.65f);
			}
			else if (num == 0f && handle_engaged)
			{
				controller_a_value = num;
				handle_active = false;
				handle_engaged = false;
				handle_state_changed = true;
				base.transform.parent.GetComponent<MonoBehaviour>().jiggle();
				onHandleStateChanged.Invoke(arg0: false);
				ability_manager.cancelIfSelectionExists();
				AudioHandler.Sfx.playSfx(Sfx.BOAT_DEACTIVATE, 0.65f);
			}
		}
	}

	public void putHandleOff()
	{
		handle_active = false;
		handle_engaged = false;
		auto_lerp_runner.run(lerpHandle(_on: false));
		onHandleStateChanged.Invoke(arg0: false);
	}

	private IEnumerator lerpHandle(bool _on)
	{
		shaft_rt.rotateTransform(_on ? Quaternion.Euler(150f, 0f, 0f) : Quaternion.Euler(0f, 0f, 0f), 0.25f, CoroutineExtensions.noEaseFunc).start(this);
		controller_a_value = (_on ? 1 : 0);
		yield return rect_transform.anchoredMove(_on ? new Vector3(rect_transform.anchoredPosition.x, 0f - starting_y, 0f) : new Vector3(rect_transform.anchoredPosition.x, starting_y, 0f), 0.25f, CoroutineExtensions.noEaseFunc);
		yield return base.transform.parent.jiggle();
		handle_engaged = _on;
	}

	private bool checkForClickSetting()
	{
		if (SettingsHandler.docks_boat_lever != 1)
		{
			return false;
		}
		handle_engaged = !handle_engaged;
		auto_lerp_runner.run(lerpHandle(handle_engaged));
		handle_active = false;
		onHandleStateChanged.Invoke(handle_engaged);
		return true;
	}
}
