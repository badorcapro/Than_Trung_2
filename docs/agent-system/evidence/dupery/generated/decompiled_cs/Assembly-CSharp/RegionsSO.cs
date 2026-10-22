using System.Collections.Generic;
using Leads;
using Nodes.Logic;
using UnityEngine;

[CreateAssetMenu(menuName = "ScriptableObject/Regions/Regions!")]
public class RegionsSO : ScriptableObject
{
	[Header("Settings")]
	[SerializeField]
	private List<RegionDataSO> region_data;

	[SerializeField]
	private RoleSetsGraph mystery_graph;

	public RegionDataSO this[Regions _region] => region_data.Find((RegionDataSO _r) => _r.region == _region);

	public RegionDataSO this[CaseType _type] => region_data.Find((RegionDataSO _r) => _r.region == _type.fromType());

	public RoleSetInfoStruct getEmptyPrimeSuspectSet()
	{
		return new RoleSetInfoStruct(mystery_graph);
	}
}
