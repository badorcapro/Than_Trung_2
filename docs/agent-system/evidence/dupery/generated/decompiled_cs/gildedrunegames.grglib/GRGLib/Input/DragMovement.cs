using System.Collections;
using GRGLib.Coroutines;
using GRGLib.Extensions.Vector;
using GRGLib.Maybe;
using GRGLib.PropertyDrawers;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.InputSystem;

namespace GRGLib.Input;

[AddComponentMenu("GRGLib/Input/DragMovement")]
public class DragMovement : DragInput
{
	[Header("DragMovement - Settings")]
	[SerializeField]
	protected bool drag_with_right_button;

	[SerializeField]
	protected bool scale_on_drag = true;

	[SerializeField]
	[ConditionalField("scale_on_drag")]
	protected Vector3 drag_scale = new Vector3(1.1f, 1.1f, 1.1f);

	[SerializeField]
	[ConditionalField("scale_on_drag")]
	protected float drag_scale_duration = 0.2f;

	[SerializeField]
	[ConditionalField("scale_on_drag")]
	protected Vector3 normal_scale = Vector3.one;

	protected Maybe<Coroutine> dragging_coroutine = new Maybe<Coroutine>();

	protected Maybe<Coroutine> scale_coroutine = new Maybe<Coroutine>();

	public bool can_drag { get; protected set; } = true;

	public bool is_dragging { get; protected set; }

	protected override void onDragStart(PointerEventData.InputButton _input)
	{
		if (!is_dragging && can_drag && (drag_with_right_button || _input != PointerEventData.InputButton.Right))
		{
			is_dragging = true;
			dragging_coroutine.stopCoroutineIfSome(this);
			dragging_coroutine = dragging_coroutine.start(dragging(), this);
		}
	}

	protected virtual IEnumerator dragging()
	{
		if (!is_dragging || !can_drag)
		{
			yield break;
		}
		if (scale_on_drag)
		{
			scale_coroutine.stopCoroutineIfSome(this);
			scale_coroutine = new Maybe<Coroutine>();
			scale_coroutine = base.transform.scaleTransform(drag_scale, drag_scale_duration, CoroutineExtensions.easeInOutFunc).addCallback(delegate
			{
				scale_coroutine = new Maybe<Coroutine>();
			}).start(this)
				.maybe();
		}
		yield return base.transform.moveTransformToMovingTargetGlobal(getDragPosition, 0.35f, CoroutineExtensions.easeInOutFunc);
		while (true)
		{
			base.transform.position = getDragPosition();
			yield return null;
		}
	}

	protected virtual Vector3 getDragPosition()
	{
		Vector3 result = Camera.main.ScreenToWorldPoint(Mouse.current.position.ReadValue()).xy();
		result.z = base.transform.position.z;
		return result;
	}

	protected override void onDragEnd(PointerEventData _event_data)
	{
		if (!can_drag || !is_dragging || (!drag_with_right_button && _event_data.button == PointerEventData.InputButton.Right))
		{
			return;
		}
		is_dragging = false;
		dragging_coroutine.stopCoroutineIfSome(this);
		dragging_coroutine = new Maybe<Coroutine>();
		scale_coroutine.stopCoroutineIfSome(this);
		scale_coroutine = new Maybe<Coroutine>();
		if (scale_on_drag)
		{
			scale_coroutine = base.transform.scaleTransform(normal_scale, drag_scale_duration, CoroutineExtensions.easeInOutFunc).addCallback(delegate
			{
				scale_coroutine = new Maybe<Coroutine>();
			}).start(this)
				.maybe();
		}
	}
}
