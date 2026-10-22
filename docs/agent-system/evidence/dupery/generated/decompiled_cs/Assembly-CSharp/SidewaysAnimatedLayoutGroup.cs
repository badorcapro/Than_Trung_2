using System.Collections.Generic;
using System.Linq;
using GRGLib.Coroutines;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Vector;
using GRGLib.Maybe;
using GRGLib.UI;
using UnityEngine;

public class SidewaysAnimatedLayoutGroup : AnimatedLayoutGroup
{
	[Header("Sideways Animation Settings")]
	[SerializeField]
	private Vector2 sideways_offset = new Vector2(100f, 0f);

	private Dictionary<Transform, Vector3> previous_wanted_positions = new Dictionary<Transform, Vector3>();

	protected override void setLayout(bool _animate = true, bool _change_z_position = true)
	{
		if (use_child_size)
		{
			calculated_dist = getChildSize() + extra_distance;
		}
		sequential_layout_coroutine.stopCoroutineIfSome(this);
		sequential_layout_coroutine = new Maybe<Coroutine>();
		List<(Transform, Vector3)> list = getWantedChildrenPosition();
		if (!_change_z_position)
		{
			list = list.Select(((Transform, Vector3) _c) => (_c.Item1, _c.Item2.setZ(_c.Item1.localPosition.z))).toListSafe();
		}
		if (_animate)
		{
			list.ForEach(delegate((Transform, Vector3) _child)
			{
				if (!previous_wanted_positions.ContainsKey(_child.Item1) || previous_wanted_positions[_child.Item1] != _child.Item2)
				{
					if (moving_coroutines.ContainsKey(_child.Item1))
					{
						moving_coroutines[_child.Item1].stop(this);
						moving_coroutines.Remove(_child.Item1);
					}
					_child.Item1.localPosition = _child.Item2.addVector2(sideways_offset);
					moving_coroutines[_child.Item1] = childMovement(_child.Item1, _child.Item2).addCallback(delegate
					{
						moving_coroutines.Remove(_child.Item1);
					}).start(this);
				}
			});
		}
		else
		{
			list.ForEach(delegate((Transform, Vector3) _child)
			{
				_child.Item1.localPosition = _child.Item2;
			});
		}
		previous_wanted_positions = list.toDictionary();
	}
}
