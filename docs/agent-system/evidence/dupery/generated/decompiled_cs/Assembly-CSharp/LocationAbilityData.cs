using UnityEngine;

public class LocationAbilityData : AbilityData
{
	public Vector2Int position;

	public LocationTypes location;

	public override string as_debug => $"{location} at ({position.x}, {position.y})";

	public LocationAbilityData(Vector2Int _pos, LocationTypes _loc)
	{
		position = _pos;
		location = _loc;
	}
}
