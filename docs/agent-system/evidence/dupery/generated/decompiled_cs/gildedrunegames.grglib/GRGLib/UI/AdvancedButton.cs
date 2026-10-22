using System.Collections.Generic;
using GRGLib.PropertyDrawers;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.Events;
using UnityEngine.UI;

namespace GRGLib.UI;

[AddComponentMenu("GRGLib/UI/AdvancedButton")]
public class AdvancedButton : Button
{
	[Header("Custom Navigation")]
	[SerializeField]
	protected List<Selectable> up_selectable;

	[SerializeField]
	protected List<Selectable> down_selectable;

	[SerializeField]
	protected List<Selectable> left_selectable;

	[SerializeField]
	protected List<Selectable> right_selectable;

	[SerializeField]
	private bool pointer_enter_on_select;

	[SerializeField]
	private bool use_pointer_down_up_callbacks;

	[SerializeField]
	[ConditionalField("use_pointer_down_up_callbacks")]
	private UnityEvent<PointerEventData> on_pointer_down;

	[SerializeField]
	[ConditionalField("use_pointer_down_up_callbacks")]
	private UnityEvent<PointerEventData> on_pointer_up;

	[SerializeField]
	private UnityEvent<PointerEventData> on_pointer_enter;

	[SerializeField]
	private UnityEvent<PointerEventData> on_pointer_exit;

	[SerializeField]
	private UnityEvent<BaseEventData> on_select;

	[SerializeField]
	private UnityEvent<BaseEventData> on_deselect;

	public override void OnPointerDown(PointerEventData eventData)
	{
		if (use_pointer_down_up_callbacks)
		{
			base.OnPointerDown(eventData);
			on_pointer_down.Invoke(eventData);
		}
	}

	public override void OnPointerUp(PointerEventData eventData)
	{
		if (use_pointer_down_up_callbacks)
		{
			base.OnPointerUp(eventData);
			on_pointer_up.Invoke(eventData);
		}
	}

	public override void OnPointerEnter(PointerEventData eventData)
	{
		base.OnPointerEnter(eventData);
		on_pointer_enter.Invoke(eventData);
	}

	public override void OnPointerExit(PointerEventData eventData)
	{
		base.OnPointerExit(eventData);
		on_pointer_exit.Invoke(eventData);
	}

	public override void OnSelect(BaseEventData eventData)
	{
		if (pointer_enter_on_select)
		{
			on_pointer_enter.Invoke(null);
		}
		on_select.Invoke(eventData);
		base.OnSelect(eventData);
	}

	public override void OnDeselect(BaseEventData eventData)
	{
		if (pointer_enter_on_select)
		{
			on_pointer_exit.Invoke(null);
		}
		on_deselect.Invoke(eventData);
		base.OnDeselect(eventData);
	}

	public override Selectable FindSelectableOnUp()
	{
		for (int i = 0; i < up_selectable.Count; i++)
		{
			if (up_selectable[i] != null && up_selectable[i].interactable)
			{
				return up_selectable[i];
			}
		}
		if (base.navigation.mode == Navigation.Mode.Explicit)
		{
			return base.navigation.selectOnUp;
		}
		if ((base.navigation.mode & Navigation.Mode.Vertical) != 0)
		{
			return FindSelectable(base.transform.rotation * Vector3.up);
		}
		return null;
	}

	public override Selectable FindSelectableOnDown()
	{
		for (int i = 0; i < down_selectable.Count; i++)
		{
			if (down_selectable[i] != null && down_selectable[i].interactable)
			{
				return down_selectable[i];
			}
		}
		if (base.navigation.mode == Navigation.Mode.Explicit)
		{
			return base.navigation.selectOnDown;
		}
		if ((base.navigation.mode & Navigation.Mode.Vertical) != 0)
		{
			return FindSelectable(base.transform.rotation * Vector3.down);
		}
		return null;
	}

	public override Selectable FindSelectableOnLeft()
	{
		for (int i = 0; i < left_selectable.Count; i++)
		{
			if (left_selectable[i] != null && left_selectable[i].interactable)
			{
				return left_selectable[i];
			}
		}
		if (base.navigation.mode == Navigation.Mode.Explicit)
		{
			return base.navigation.selectOnLeft;
		}
		if ((base.navigation.mode & Navigation.Mode.Horizontal) != 0)
		{
			return FindSelectable(base.transform.rotation * Vector3.left);
		}
		return null;
	}

	public override Selectable FindSelectableOnRight()
	{
		for (int i = 0; i < right_selectable.Count; i++)
		{
			if (right_selectable[i] != null && right_selectable[i].interactable)
			{
				return right_selectable[i];
			}
		}
		if (base.navigation.mode == Navigation.Mode.Explicit)
		{
			return base.navigation.selectOnRight;
		}
		if ((base.navigation.mode & Navigation.Mode.Horizontal) != 0)
		{
			return FindSelectable(base.transform.rotation * Vector3.right);
		}
		return null;
	}

	public void addUpSelectable(Selectable _selectable)
	{
		up_selectable.Add(_selectable);
	}

	public void addDownSelectable(Selectable _selectable)
	{
		down_selectable.Add(_selectable);
	}

	public void addLeftSelectable(Selectable _selectable)
	{
		left_selectable.Add(_selectable);
	}

	public void addRightSelectable(Selectable _selectable)
	{
		right_selectable.Add(_selectable);
	}

	public void addUpSelectables(params Selectable[] _selectable)
	{
		up_selectable.AddRange(_selectable);
	}

	public void addDownSelectables(params Selectable[] _selectable)
	{
		down_selectable.AddRange(_selectable);
	}

	public void addLeftSelectables(params Selectable[] _selectable)
	{
		left_selectable.AddRange(_selectable);
	}

	public void addRightSelectables(params Selectable[] _selectable)
	{
		right_selectable.AddRange(_selectable);
	}

	public void clearUpSelectable()
	{
		up_selectable.Clear();
	}

	public void clearDownSelectable()
	{
		down_selectable.Clear();
	}

	public void clearLeftSelectable()
	{
		left_selectable.Clear();
	}

	public void clearRightSelectable()
	{
		right_selectable.Clear();
	}

	private static Vector3 GetPointOnRectEdge(RectTransform rect, Vector2 dir)
	{
		if (rect == null)
		{
			return Vector3.zero;
		}
		if (dir != Vector2.zero)
		{
			dir /= Mathf.Max(Mathf.Abs(dir.x), Mathf.Abs(dir.y));
		}
		dir = rect.rect.center + Vector2.Scale(rect.rect.size, dir * 0.5f);
		return dir;
	}
}
