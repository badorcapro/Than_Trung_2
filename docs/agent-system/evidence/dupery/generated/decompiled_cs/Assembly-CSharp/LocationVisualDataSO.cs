using GRGLib.Extensions.Collections;
using GRGLib.Serializable;
using UnityEngine;
using Visual;

[CreateAssetMenu(menuName = "ScriptableObject/Location Visual Data SO")]
public class LocationVisualDataSO : ScriptableObject
{
	[Header("Settings")]
	[SerializeField]
	private SerializableDictionary<LocationTypes, LocationVisual> locations;

	[SerializeField]
	private LocationVisual backup_locations;

	public LocationVisual this[LocationTypes _location] => locations.getOrDefault(_location, backup_locations);

	private LocationVisual getLocation(LocationTypes _location)
	{
		if (locations.ContainsKey(_location))
		{
			return locations[_location];
		}
		Debug.LogError($"Could not find visual for location type {_location}!");
		return backup_locations;
	}
}
