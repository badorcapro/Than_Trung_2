using System.Collections;
using Audio;
using GRGLib.Coroutines;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.InputSystem;
using UnityEngine.UI;
using Visual;
using Visual.Drawing;

public class RubberManager : NotesToolManager
{
	[Header("Rubber References")]
	[SerializeField]
	private LRBrush pen_lr_brush;

	[SerializeField]
	private PenManager pen_manager;

	[SerializeField]
	private Image rubber_circle;

	[SerializeField]
	private GameObject rubber_brush;

	[Header("Settings")]
	[SerializeField]
	private float initial_rubber_radius = 32f;

	[SerializeField]
	private float min_rubber_radius = 16f;

	[SerializeField]
	private float max_rubber_radius = 160f;

	[SerializeField]
	private float scroll_speed = 5f;

	private CoroutineRunner rubber_erase_runner;

	private CoroutineRunner rubber_circle_runner;

	private bool pointer_down;

	private bool with_touch;

	private float rubber_radius = 32f;

	protected override Vector3 starting_tool_position => Vector3.zero;

	protected override Vector2 tool_offset
	{
		get
		{
			if (!base.tool_selected)
			{
				return new Vector2(5f, 10f);
			}
			return new Vector2(0f, 0f);
		}
	}

	protected override void Awake()
	{
		base.Awake();
		rubber_radius = initial_rubber_radius;
		rubber_circle.rectTransform.sizeDelta = new Vector2(rubber_radius * 2f, rubber_radius * 2f);
		rubber_erase_runner = new CoroutineRunner(this);
		rubber_circle_runner = new CoroutineRunner(this);
	}

	protected override bool canSelect()
	{
		if (!base.tool_selected)
		{
			return !pen_manager.tool_selected;
		}
		return false;
	}

	protected override void onToolSelect()
	{
		rubber_circle_runner.run(rubber_circle.fade(1f, 0.5f, CoroutineExtensions.easeInOutFunc));
		rubber_brush.SetActive(value: true);
	}

	public bool tryErase()
	{
		return pen_lr_brush.eraseAtMousePos(rubber_radius, with_touch);
	}

	protected override void onToolDeselect()
	{
		rubber_circle_runner.run(rubber_circle.fade(0f, 0.5f, CoroutineExtensions.easeInOutFunc));
		AudioHandler.Atmo.stopAtmoIfPlaying(Atmo.RUBBER_ERASING);
		rubber_erase_runner.stop();
		rubber_brush.SetActive(value: false);
	}

	public void onMouseScroll(InputAction.CallbackContext _context)
	{
		if (base.tool_selected)
		{
			float y = _context.ReadValue<Vector2>().y;
			if (y != 0f)
			{
				rubber_radius = Mathf.Clamp(rubber_radius + y * scroll_speed, min_rubber_radius, max_rubber_radius);
				rubber_circle.rectTransform.sizeDelta = new Vector2(rubber_radius * 2f, rubber_radius * 2f);
			}
		}
	}

	public void OnPointerUp(PointerEventData eventData)
	{
		if (!base.tool_selected)
		{
			return;
		}
		if (pointer_down && eventData.button == PointerEventData.InputButton.Left)
		{
			if (with_touch)
			{
				if (Touchscreen.current != null && Touchscreen.current.primaryTouch.ReadValue().isInProgress)
				{
					return;
				}
				with_touch = false;
			}
			rubber_erase_runner.stop();
			pointer_down = false;
			tool_position_runner.run(tool_trans.moveTransform(tool_inactive_offset, 0.35f, CoroutineExtensions.easeInOutFunc));
			tool_rotation_runner.run(tool_trans.rotateTransformSmart(-25f, 0.35f, CoroutineExtensions.easeInOutFunc));
			pen_lr_brush.resetLineSaves();
		}
		if (eventData.button == PointerEventData.InputButton.Right)
		{
			deselectPen();
		}
	}

	public void OnPointerDown(PointerEventData eventData)
	{
		if (base.tool_selected && !rubber_erase_runner.is_running && eventData.button == PointerEventData.InputButton.Left)
		{
			with_touch = Pointer.current == Touchscreen.current;
			rubber_erase_runner.run(tryEraseAtMoustPos());
			tool_position_runner.run(tool_trans.moveTransform(tool_active_offset, 0.35f, CoroutineExtensions.easeInOutFunc));
			tool_rotation_runner.run(tool_trans.rotateTransformDirection(330f, 0.35f, _clockwise: true, CoroutineExtensions.easeInOutFunc));
			pointer_down = true;
		}
	}

	private IEnumerator tryEraseAtMoustPos()
	{
		while (true)
		{
			if (tryErase())
			{
				if (!AudioHandler.Atmo.isAtmoPlaying(Atmo.RUBBER_ERASING))
				{
					AudioHandler.Atmo.playAtmoAsSfx(Atmo.RUBBER_ERASING);
				}
			}
			else
			{
				AudioHandler.Atmo.stopAtmoIfPlaying(Atmo.RUBBER_ERASING);
			}
			yield return null;
		}
	}
}
