using ControllerSupport;
using GRGLib.Serializable;
using UnityEngine;

namespace CaseSelection;

public class CaseSelectionRegionsHandler : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private CaseSelectionInputHandler input_handler;

	[Header("Prefabs")]
	[SerializeField]
	private SerializableDictionary<Regions, CaseSelectionRegionSpecificManager> region_prefabs;

	private CaseSelectionRegionSpecificManager region_specific_part;

	private void Start()
	{
	}

	public void setUp(Regions _region, _dep_RegionState _state)
	{
		if (!region_prefabs.ContainsKey(_region))
		{
			Debug.LogError($"No Region specific part for region {_region} set!");
			return;
		}
		region_specific_part = Object.Instantiate(region_prefabs[_region], base.transform);
		region_specific_part.setUp(_state, input_handler);
	}
}
