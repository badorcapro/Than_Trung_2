using System.Collections;
using GRGLib.Coroutines;
using UnityEngine;
using UnityEngine.EventSystems;

namespace GRGLib.Input;

public abstract class DragInput : MonoBehaviour, IPointerExitHandler, IEventSystemHandler, IPointerEnterHandler, IPointerDownHandler, IPointerUpHandler
{
	protected CoroutineRunner left_drag_convert;

	protected CoroutineRunner right_drag_convert;

	private void Awake()
	{
		left_drag_convert = new CoroutineRunner(this);
		right_drag_convert = new CoroutineRunner(this);
	}

	public virtual void OnPointerEnter(PointerEventData eventData)
	{
		onStartHover(eventData);
	}

	public virtual void OnPointerExit(PointerEventData eventData)
	{
		onEndHover(eventData);
	}

	public virtual void OnPointerDown(PointerEventData eventData)
	{
		if (eventData.button == PointerEventData.InputButton.Left)
		{
			left_drag_convert.run(convertToDrag(eventData.button));
		}
		else if (eventData.button == PointerEventData.InputButton.Right)
		{
			right_drag_convert.run(convertToDrag(eventData.button));
		}
	}

	public virtual void OnPointerUp(PointerEventData eventData)
	{
		if (eventData.button == PointerEventData.InputButton.Left)
		{
			if (left_drag_convert.is_running)
			{
				left_drag_convert.stop();
				onLeftClick(eventData);
			}
			else
			{
				onDragEnd(eventData);
			}
		}
		else if (eventData.button == PointerEventData.InputButton.Right)
		{
			if (right_drag_convert.is_running)
			{
				right_drag_convert.stop();
				onRightClick(eventData);
			}
			else
			{
				onDragEnd(eventData);
			}
		}
	}

	protected virtual IEnumerator convertToDrag(PointerEventData.InputButton _input)
	{
		yield return 0.15f.wait();
		onDragStart(_input);
	}

	protected abstract void onDragStart(PointerEventData.InputButton _input);

	protected abstract void onDragEnd(PointerEventData eventData);

	protected virtual void onLeftClick(PointerEventData eventData)
	{
	}

	protected virtual void onRightClick(PointerEventData eventData)
	{
	}

	protected virtual void onStartHover(PointerEventData eventData)
	{
	}

	protected virtual void onEndHover(PointerEventData eventData)
	{
	}
}
