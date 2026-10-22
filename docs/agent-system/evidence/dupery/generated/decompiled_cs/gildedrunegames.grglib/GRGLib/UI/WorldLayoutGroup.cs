using UnityEngine;

namespace GRGLib.UI;

[AddComponentMenu("GRGLib/UI/WorldLayoutGroup")]
public class WorldLayoutGroup : CustomLayoutGroup
{
	[SerializeField]
	private Vector2 box_min;

	[SerializeField]
	private Vector2 box_max;

	[SerializeField]
	private Vector2 element_distance;

	[Header("Advanced Settings")]
	[SerializeField]
	private bool change_z_position = true;

	protected override Vector2 Min => box_min;

	protected override Vector2 Max => box_max;

	protected override Vector2 Distance => element_distance;

	protected override bool set_z_pos => change_z_position;
}
