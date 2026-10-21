using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Coroutines;
using GRGLib.Extensions;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Vector;
using GRGLib.Maybe;
using GRGLib.PropertyDrawers;
using UnityEngine;

namespace GRGLib.UI;

public abstract class CustomLayoutGroup : MonoBehaviour
{
	protected enum LayoutMove
	{
		NONE,
		MOVE,
		RESET
	}

	[Header("Animation")]
	[SerializeField]
	protected bool animate = true;

	[Header("Settings")]
	[SerializeField]
	protected bool check_on_update = true;

	[SerializeField]
	[ConditionalField("check_on_update")]
	protected bool check_order;

	[SerializeField]
	protected bool layout_only_active = true;

	[SerializeField]
	protected LayoutAlignment alignment;

	[SerializeField]
	protected bool start_horizontal = true;

	[SerializeField]
	[ConditionalField("start_horizontal")]
	protected int force_per_row = -1;

	[SerializeField]
	[ConditionalField("start_horizontal", false, new object[] { false })]
	protected int force_per_column = -1;

	private List<Transform> m_child_order;

	protected Dictionary<Transform, Coroutine> moving_coroutines = new Dictionary<Transform, Coroutine>();

	protected Maybe<Coroutine> sequential_layout_coroutine = new Maybe<Coroutine>();

	protected abstract Vector2 Min { get; }

	protected abstract Vector2 Max { get; }

	protected abstract Vector2 Distance { get; }

	protected virtual bool set_z_pos => false;

	protected List<Transform> child_order
	{
		get
		{
			if (m_child_order == null)
			{
				m_child_order = new List<Transform>();
			}
			return m_child_order;
		}
	}

	public int current_child_number { get; private set; }

	public void checkUpdateWithOrder()
	{
		if (!checkChildOrder())
		{
			forceUpdate(updateChildOrder());
		}
	}

	public void checkUpdate()
	{
		int childNumber = getChildNumber();
		if (current_child_number != childNumber)
		{
			forceUpdate(childNumber);
		}
	}

	public void Update()
	{
		if (check_on_update)
		{
			if (check_order)
			{
				checkUpdateWithOrder();
			}
			else
			{
				checkUpdate();
			}
		}
	}

	public void forceUpdate(int _child_count, bool _force_no_animation = false)
	{
		current_child_number = _child_count;
		setLayout(!_force_no_animation && animate);
	}

	public void forceUpdateSequential(int _child_count, float _time_between_movement = 0.1f)
	{
		current_child_number = _child_count;
		setLayoutSequential(_time_between_movement);
	}

	private int getChildNumber()
	{
		if (!layout_only_active)
		{
			return base.transform.childCount;
		}
		return countActiveChildren();
	}

	public int countActiveChildren()
	{
		int num = 0;
		for (int i = 0; i < base.transform.childCount; i++)
		{
			num += (base.transform.GetChild(i).gameObject.activeSelf ? 1 : 0);
		}
		return num;
	}

	protected bool checkChildOrder()
	{
		if (!check_order)
		{
			return true;
		}
		int num = 0;
		for (int i = 0; i < base.transform.childCount; i++)
		{
			Transform child = base.transform.GetChild(i);
			if (!layout_only_active || child.gameObject.activeSelf)
			{
				if (child_order.Count <= num || child_order[num] != child)
				{
					return false;
				}
				num++;
			}
		}
		return true;
	}

	protected int updateChildOrder()
	{
		child_order.Clear();
		for (int i = 0; i < base.transform.childCount; i++)
		{
			Transform child = base.transform.GetChild(i);
			if (!layout_only_active || child.gameObject.activeSelf)
			{
				child_order.Add(child);
			}
		}
		return child_order.Count;
	}

	public void setLayout(bool _animate = true)
	{
		setLayout(_animate, set_z_pos);
	}

	protected virtual void setLayout(bool _animate = true, bool _change_z_position = true)
	{
		sequential_layout_coroutine.stopCoroutineIfSome(this);
		sequential_layout_coroutine = new Maybe<Coroutine>();
		List<(Transform, Vector3)> list = getWantedChildrenPosition();
		if (!_change_z_position)
		{
			list = list.Select(((Transform, Vector3) _c) => (_c.Item1, _c.Item2.setZ(_c.Item1.localPosition.z))).toListSafe();
		}
		if (_animate)
		{
			foreach (KeyValuePair<Transform, Coroutine> moving_coroutine in moving_coroutines)
			{
				moving_coroutine.Value.stop(this);
			}
			moving_coroutines.Clear();
			list.ForEach(delegate((Transform, Vector3) _child)
			{
				moving_coroutines[_child.Item1] = childMovement(_child.Item1, _child.Item2).addCallback(delegate
				{
					moving_coroutines.Remove(_child.Item1);
				}).start(this);
			});
		}
		else
		{
			list.ForEach(delegate((Transform, Vector3) _child)
			{
				_child.Item1.localPosition = _child.Item2;
			});
		}
	}

	protected virtual IEnumerator childMovement(Transform _child, Vector3 _wanted_pos)
	{
		yield return _child.moveTransform(_wanted_pos, 0.4f, CoroutineExtensions.easeInOutFunc);
	}

	public void setLayoutSequential(float _time_between_movement = 0.1f)
	{
		setLayoutSequential(set_z_pos, _time_between_movement);
	}

	protected virtual void setLayoutSequential(bool _change_z_position, float _time_between_movement = 0.1f)
	{
		List<(Transform, Vector3)> list = getWantedChildrenPosition();
		if (!_change_z_position)
		{
			list = list.Select(((Transform, Vector3) _c) => (_c.Item1, _c.Item2.setZ(_c.Item1.localPosition.z))).toListSafe();
		}
		sequential_layout_coroutine = setLayoutSequential(list, _time_between_movement).addCallback(delegate
		{
			sequential_layout_coroutine = new Maybe<Coroutine>();
		}).start(this).maybe();
	}

	protected virtual IEnumerator setLayoutSequential(List<(Transform, Vector3)> _target_positions, float _time_between_movement = 0.1f)
	{
		foreach (KeyValuePair<Transform, Coroutine> moving_coroutine in moving_coroutines)
		{
			moving_coroutine.Value.stop(this);
		}
		moving_coroutines.Clear();
		foreach (var child in _target_positions)
		{
			moving_coroutines[child.Item1] = childMovement(child.Item1, child.Item2).addCallback(delegate
			{
				moving_coroutines.Remove(child.Item1);
			}).start(this);
			yield return _time_between_movement.wait();
		}
	}

	protected virtual List<(Transform, Vector3)> getWantedChildrenPosition()
	{
		int childNumber = getChildNumber();
		int num = ((!start_horizontal) ? ((force_per_column >= 0) ? force_per_column : Mathf.FloorToInt((Max.y - Min.y) / Distance.y)) : ((force_per_row >= 0) ? force_per_row : Mathf.FloorToInt((Max.x - Min.x) / Distance.x)));
		int num2 = Mathf.CeilToInt((float)childNumber / (float)num);
		num = Mathf.Min(num, childNumber);
		List<(Transform, Vector3)> list = new List<(Transform, Vector3)>();
		Vector2 vector = (Min + Max) / 2f;
		Vector2 vector2 = new Vector2(0f, 0f);
		Vector2 vector3 = new Vector2(0f, 0f);
		if (isCenter(alignment))
		{
			vector2.x = vector.x - (start_horizontal ? ((float)(num - 1) * Distance.x * 0.5f) : ((float)(num2 - 1) * Distance.x * 0.5f));
			vector3.x = Distance.x;
		}
		else if (isLeft(alignment))
		{
			vector2.x = Min.x + Distance.x * 0.5f;
			vector3.x = Distance.x;
		}
		else
		{
			vector2.x = Max.x - Distance.x * 0.5f;
			vector3.x = 0f - Distance.x;
		}
		if (isMid(alignment))
		{
			vector2.y = vector.y + ((!start_horizontal) ? ((float)(num - 1) * Distance.y * 0.5f) : ((float)(num2 - 1) * Distance.y * 0.5f));
			vector3.y = 0f - Distance.y;
		}
		else if (isBottom(alignment))
		{
			vector2.y = Min.y + Distance.y * 0.5f;
			vector3.y = Distance.y;
		}
		else
		{
			vector2.y = Max.y - Distance.y * 0.5f;
			vector3.y = 0f - Distance.y;
		}
		Func<int, int, LayoutMove> moveHori = getMoveHori(start_horizontal);
		Func<int, int, LayoutMove> moveVerti = getMoveVerti(!start_horizontal);
		Vector2 vector4 = vector2 - vector3;
		int i = 0;
		for (int j = 0; j < childNumber; j++)
		{
			if (i >= base.transform.childCount)
			{
				break;
			}
			Vector2 vector5 = vector4;
			switch (moveHori(j, num))
			{
			case LayoutMove.MOVE:
				vector5.x += vector3.x;
				break;
			case LayoutMove.RESET:
				if (isCenter(alignment) && j + num > childNumber)
				{
					int num3 = childNumber - j;
					vector5.x = vector.x - (float)(num3 - 1) * Distance.x * 0.5f;
				}
				else
				{
					vector5.x = vector2.x;
				}
				break;
			}
			switch (moveVerti(j, num))
			{
			case LayoutMove.MOVE:
				vector5.y += vector3.y;
				break;
			case LayoutMove.RESET:
				if (isMid(alignment) && j + num > childNumber)
				{
					int num4 = childNumber - j;
					vector5.y = vector.y - (float)(num4 - 1) * Distance.y * 0.5f;
				}
				else
				{
					vector5.y = vector2.y;
				}
				break;
			}
			if (layout_only_active)
			{
				for (; i < base.transform.childCount - 1 && !base.transform.GetChild(i).gameObject.activeSelf; i++)
				{
				}
			}
			list.Add((base.transform.GetChild(i), vector5));
			vector4 = vector5;
			i++;
		}
		return list;
	}

	public bool isLeft(LayoutAlignment _aligment)
	{
		return _aligment.equalToAny(LayoutAlignment.TOP_LEFT, LayoutAlignment.MID_LEFT, LayoutAlignment.BOTTOM_LEFT);
	}

	public bool isCenter(LayoutAlignment _aligment)
	{
		return _aligment.equalToAny(LayoutAlignment.TOP_CENTER, LayoutAlignment.MID_CENTER, LayoutAlignment.BOTTOM_CENTER);
	}

	public bool isRight(LayoutAlignment _aligment)
	{
		return _aligment.equalToAny(LayoutAlignment.TOP_RIGHT, LayoutAlignment.MID_RIGHT, LayoutAlignment.BOTTOM_RIGHT);
	}

	public bool isTop(LayoutAlignment _aligment)
	{
		return _aligment.equalToAny(LayoutAlignment.TOP_LEFT, LayoutAlignment.TOP_CENTER, LayoutAlignment.TOP_RIGHT);
	}

	public bool isMid(LayoutAlignment _aligment)
	{
		return _aligment.equalToAny(LayoutAlignment.MID_LEFT, LayoutAlignment.MID_CENTER, LayoutAlignment.MID_RIGHT);
	}

	public bool isBottom(LayoutAlignment _aligment)
	{
		return _aligment.equalToAny(LayoutAlignment.BOTTOM_LEFT, LayoutAlignment.BOTTOM_CENTER, LayoutAlignment.BOTTOM_RIGHT);
	}

	private Func<int, int, LayoutMove> getMoveHori(bool _hori)
	{
		if (_hori)
		{
			return (int _i, int _per_row) => (_i % _per_row != 0) ? LayoutMove.MOVE : LayoutMove.RESET;
		}
		return (int _i, int _per_column) => (_i % _per_column == 0) ? LayoutMove.MOVE : LayoutMove.NONE;
	}

	private Func<int, int, LayoutMove> getMoveVerti(bool _verti)
	{
		if (_verti)
		{
			return (int _i, int _per_column) => (_i % _per_column != 0) ? LayoutMove.MOVE : LayoutMove.RESET;
		}
		return (int _i, int _per_row) => (_i % _per_row == 0) ? LayoutMove.MOVE : LayoutMove.NONE;
	}
}
