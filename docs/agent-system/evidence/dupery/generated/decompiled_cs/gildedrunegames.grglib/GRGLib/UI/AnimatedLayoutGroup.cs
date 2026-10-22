using GRGLib.PropertyDrawers;
using UnityEngine;

namespace GRGLib.UI;

[RequireComponent(typeof(RectTransform))]
[AddComponentMenu("GRGLib/UI/AnimatedLayoutGroup")]
public class AnimatedLayoutGroup : CustomLayoutGroup
{
	[SerializeField]
	protected bool use_child_size = true;

	[SerializeField]
	[ConditionalField("use_child_size", false, new object[] { false })]
	protected Vector2 element_distance;

	[SerializeField]
	[ConditionalField("use_child_size")]
	protected Vector2 extra_distance;

	protected Vector2 calculated_dist = Vector2.zero;

	protected RectTransform rect_trans => base.transform as RectTransform;

	protected override Vector2 Min => -size * rect_trans.pivot;

	protected override Vector2 Max => size * (new Vector2(1f, 1f) - rect_trans.pivot);

	protected override Vector2 Distance
	{
		get
		{
			if (!use_child_size)
			{
				return element_distance;
			}
			return calculated_dist;
		}
	}

	protected Vector2 size => new Vector2(rect_trans.rect.width, rect_trans.rect.height);

	protected override void setLayout(bool _animate = true, bool _change_z_position = true)
	{
		if (use_child_size)
		{
			calculated_dist = getChildSize() + extra_distance;
		}
		base.setLayout(_animate, _change_z_position);
	}

	protected override void setLayoutSequential(bool _change_z_position, float _time_between_movement = 0.1f)
	{
		if (use_child_size)
		{
			calculated_dist = getChildSize() + extra_distance;
		}
		base.setLayoutSequential(_change_z_position, _time_between_movement);
	}

	protected Vector2 getChildSize()
	{
		Vector2 result = new Vector2(0f, 0f);
		for (int i = 0; i < base.transform.childCount; i++)
		{
			Vector2 sizeDelta = (base.transform.GetChild(i) as RectTransform).sizeDelta;
			if (sizeDelta.x > result.x)
			{
				result.x = sizeDelta.x;
			}
			if (sizeDelta.y > result.y)
			{
				result.y = sizeDelta.y;
			}
		}
		return result;
	}
}
