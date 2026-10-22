using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.Events;

namespace GRGLib.Input;

[AddComponentMenu("GRGLib/Input/DragInteraction")]
public class DragInteraction : DragInput
{
	[Header("Callbacks")]
	[SerializeField]
	private UnityEvent<PointerEventData.InputButton> start_drag;

	[SerializeField]
	private UnityEvent<PointerEventData> end_drag;

	[SerializeField]
	private UnityEvent<PointerEventData> left_click;

	[SerializeField]
	private UnityEvent<PointerEventData> right_click;

	[SerializeField]
	private UnityEvent<PointerEventData> start_hover;

	[SerializeField]
	private UnityEvent<PointerEventData> end_hover;

	protected override void onDragStart(PointerEventData.InputButton _input)
	{
		start_drag.Invoke(_input);
	}

	protected override void onDragEnd(PointerEventData eventData)
	{
		end_drag.Invoke(eventData);
	}

	protected override void onLeftClick(PointerEventData eventData)
	{
		left_click.Invoke(eventData);
	}

	protected override void onRightClick(PointerEventData eventData)
	{
		right_click.Invoke(eventData);
	}

	protected override void onStartHover(PointerEventData eventData)
	{
		start_hover.Invoke(eventData);
	}

	protected override void onEndHover(PointerEventData eventData)
	{
		end_hover.Invoke(eventData);
	}
}
