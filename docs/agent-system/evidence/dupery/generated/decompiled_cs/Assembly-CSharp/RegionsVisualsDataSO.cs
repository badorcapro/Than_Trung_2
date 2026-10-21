using GRGLib.Serializable;
using UnityEngine;
using Visual;

[CreateAssetMenu(menuName = "ScriptableObject/Region Visuals Data SO")]
public class RegionsVisualsDataSO : ScriptableObject
{
	[Header("Settings")]
	[SerializeField]
	private SerializableDictionary<CaseType, WorldVisualManager> region_world_managers;

	public WorldVisualManager getWorldManagerPrefab(CaseType _type)
	{
		return region_world_managers[_type];
	}
}
