using System;
using System.Collections;
using GRGLib.Coroutines;
using GRGLib.Extensions.Unity;
using GRGLib.Maybe;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;

namespace Visual;

public abstract class NotesToolManager : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	protected RectTransform tool_trans;

	[SerializeField]
	protected Image tool_shadow;

	[Header("Prefabs")]
	[SerializeField]
	protected TemporaryToolTip tooltip_prefab;

	[Header("Settings")]
	[SerializeField]
	protected Vector2 tool_inactive_offset;

	[SerializeField]
	protected Vector2 tool_active_offset;

	[SerializeField]
	protected float tool_inactive_rotation;

	[SerializeField]
	protected float tool_active_rotation = -145f;

	[SerializeField]
	protected float tool_jiggle_offset;

	[SerializeField]
	protected bool rotation_direction = true;

	[SerializeField]
	protected bool back_rotation_opposite = true;

	protected Canvas canvas;

	protected PlayerInput player_input;

	protected CoroutineRunner movement_runner;

	protected CoroutineRunner tool_follow_runner;

	protected CoroutineRunner tool_position_runner;

	protected CoroutineRunner tool_rotation_runner;

	protected CoroutineRunner jiggle_runner;

	protected CoroutineRunner shadow_runner;

	protected Vector3 starting_position;

	protected Maybe<TemporaryToolTip> tooltip = new Maybe<TemporaryToolTip>();

	public bool tool_selected { get; protected set; }

	protected abstract Vector3 starting_tool_position { get; }

	protected abstract Vector2 tool_offset { get; }

	protected TemporaryToolTip active_tooltip
	{
		get
		{
			if (tooltip.is_some)
			{
				return tooltip.value;
			}
			tooltip = UnityEngine.Object.Instantiate(tooltip_prefab, base.transform.parent).maybe();
			return tooltip.value;
		}
	}

	protected virtual void Awake()
	{
		starting_position = base.transform.localPosition;
		movement_runner = new CoroutineRunner(this);
		tool_follow_runner = new CoroutineRunner(this);
		tool_position_runner = new CoroutineRunner(this);
		tool_rotation_runner = new CoroutineRunner(this);
		jiggle_runner = new CoroutineRunner(this);
		shadow_runner = new CoroutineRunner(this);
	}

	public virtual void setUpReferences(Canvas _canvas, PlayerInput _player_input)
	{
		canvas = _canvas;
		player_input = _player_input;
	}

	protected abstract bool canSelect();

	public virtual void selectPen()
	{
		if (canSelect())
		{
			tool_selected = true;
			movement_runner.stop();
			jiggle_runner.stop();
			tool_follow_runner.run(followMouse());
			tool_rotation_runner.run(tool_trans.rotateTransformDirection(tool_active_rotation, 0.5f, rotation_direction, CoroutineExtensions.easeInOutFunc));
			tool_position_runner.run(tool_trans.moveTransform(tool_inactive_offset, 0.5f, CoroutineExtensions.easeInOutFunc));
			shadow_runner.run(tool_shadow.fade(0f, 0.15f, CoroutineExtensions.easeInOutFunc));
			onToolSelect();
			if (SettingsHandler.display_tooltips)
			{
				active_tooltip.setUpAndStart(player_input);
			}
		}
	}

	protected abstract void onToolSelect();

	public virtual void deselectPen()
	{
		tool_selected = false;
		tool_follow_runner.stop();
		movement_runner.run(base.transform.moveTransform(starting_position, 0.5f, CoroutineExtensions.easeInOutFunc));
		tool_rotation_runner.run(tool_trans.rotateTransformDirection(tool_inactive_rotation, 0.5f, back_rotation_opposite ? (!rotation_direction) : rotation_direction, CoroutineExtensions.easeInOutFunc));
		tool_position_runner.run(tool_trans.moveTransform(starting_tool_position, 0.5f, CoroutineExtensions.easeInOutFunc));
		shadow_runner.run(shadowFadeIn());
		if (tooltip.is_some)
		{
			tooltip.value.fadeAndDestroy();
			tooltip = new Maybe<TemporaryToolTip>();
		}
		onToolDeselect();
	}

	protected abstract void onToolDeselect();

	protected IEnumerator shadowFadeIn()
	{
		yield return 0.35f.wait();
		yield return tool_shadow.fade(1f, 0.15f, CoroutineExtensions.easeInOutFunc);
	}

	public void jiggle()
	{
		if (!tool_selected && !movement_runner.is_running)
		{
			jiggle_runner.run(base.transform.jiggle((2f, 4f), tool_jiggle_offset));
		}
	}

	protected IEnumerator followMouse()
	{
		yield return base.transform.moveTransformToMovingTarget(() => getToolPosition(), 0.35f, CoroutineExtensions.easeInOutFunc);
		while (true)
		{
			base.transform.localPosition = getToolPosition() + tool_offset;
			yield return null;
		}
	}

	protected Vector2 getToolPosition()
	{
		return canvas.getPositionToUI(Pointer.current.position.ReadValue());
	}

	protected IEnumerator checkColourChange(Action<int> _change_colour, int _total_colours)
	{
		while (tool_selected)
		{
			Vector2 vector = Mouse.current.scroll.ReadValue();
			if (vector.y != 0f)
			{
				_change_colour((vector.y > 0f) ? 1 : (_total_colours - 1));
			}
			yield return null;
		}
	}
}
