using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLocalisation;
using Localisation;
using UnityEngine;

namespace Nodes.Logic;

[CreateAssetMenu(menuName = "NodeGraphs/Region Data Graph")]
public class RegionDataGraph : NodeGraphBase, IAmLocalised
{
	[Header("Base Information")]
	public Regions region;

	public CaseType case_type;

	[SerializeField]
	private string english_region_name;

	[SerializeField]
	private string english_fired_end_text;

	[Header("Default Sets")]
	[SerializeField]
	private List<RoleSetsGraph> standard_sets;

	[SerializeField]
	private List<RoleSetsGraph> challenge_sets;

	[SerializeField]
	private List<RoleSetsGraph> traitor_sets;

	[Header("Case Quirks")]
	[SerializeField]
	private bool allow_all_quirks;

	[SerializeField]
	private List<CaseQuirks> allowed_case_quirks;

	public string region_name => localisation_asset.checkTranslation(loc_name_key, () => english_region_name);

	public string fired_end_text => localisation_asset.checkTranslation(loc_end_fired_key, () => english_fired_end_text);

	private string loc_name_key => $"R{(int)region} [name]";

	private string loc_end_fired_key => $"R{(int)region} [fired]";

	private AssetKey localisation_asset => LocalisationHelper.ui_asset;

	public RegionStartNode fetchStartNode()
	{
		List<RegionStartNode> list = fetchNodes<RegionStartNode>();
		if (list.Count != 1)
		{
			Debug.LogError("There isnt 1 starting node!!! Must have at least 1 and can not have more than 1!!!");
		}
		return list[0];
	}

	public RoleSetsGraph getStartingSet(System.Random _rng)
	{
		return fetchStartNode().getStartingSet(_rng);
	}

	public bool canRoleAppear(Roles _role)
	{
		if (!_role.isRoleOfCaseType(case_type))
		{
			return false;
		}
		if (fetchStartNode().getAllStartingSets().Any((RoleSetsGraph _ss) => _ss.getSetRoles().Contains(_role)))
		{
			return true;
		}
		return fetchNodes<RegionSetsChoiceBaseNode>().Any((RegionSetsChoiceBaseNode _n) => _n.canRoleAppear(_role));
	}

	public bool canRoleAppearInDefaultSet(RoleSetsType _type, Roles _role)
	{
		return getDefaultSets(_type).Any((RoleSetsGraph _s) => _s.getSetRoles().Contains(_role));
	}

	public bool canRoleAppearInDefaultSet(RoleSetsType _type, Roles _role, Func<RoleSetsGraph, bool> _condition)
	{
		return getDefaultSets(_type).Where(_condition).Any((RoleSetsGraph _s) => _s.getSetRoles().Contains(_role));
	}

	public bool canQuirkAppear(CaseQuirks _quirk)
	{
		Debug.LogError("canQuirkAppear has not been set up!!!");
		return false;
	}

	public List<RoleSetsGraph> getDefaultSets(RoleSetsType _type)
	{
		return _type switch
		{
			RoleSetsType.STANDARD => standard_sets, 
			RoleSetsType.CHALLENGE => challenge_sets, 
			RoleSetsType.TRAITOR => traitor_sets, 
			_ => throw new ArgumentException($"No sets set up for type {_type}! (in RegionDataGraph.getDefaultSets)"), 
		};
	}

	public List<CaseQuirks> getAllowedCaseQuirks()
	{
		if (!allow_all_quirks)
		{
			return allowed_case_quirks;
		}
		return (from _q in new List<CaseQuirks>().addAll()
			where !_q.isScrapped()
			select _q).ToList();
	}

	public List<CaseQuirks> getAllowedCaseQuirks(Func<CaseQuirks, bool> _condition)
	{
		if (!allow_all_quirks)
		{
			return allowed_case_quirks.Where(_condition).ToList();
		}
		return (from _q in new List<CaseQuirks>().addAll()
			where !_q.isScrapped() && _condition(_q)
			select _q).ToList();
	}
}
