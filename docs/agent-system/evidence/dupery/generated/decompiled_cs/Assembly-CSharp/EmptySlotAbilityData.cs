using UnityEngine;

public class EmptySlotAbilityData : AbilityData
{
	public Vector2Int position;

	public override string as_debug => $"({position.x}, {position.y})";

	public EmptySlotAbilityData(Vector2Int _position)
	{
		position = _position;
	}
}
