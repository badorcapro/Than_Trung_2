using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLocalisation;
using Localisation;
using UnityEngine;

namespace Nodes.Logic;

[CreateAssetMenu(menuName = "NodeGraphs/RoleSets Graph")]
public class RoleSetsGraph : NodeGraphBase, IAmLocalised
{
	[Flags]
	public enum SetsType
	{
		NONE = 0,
		OFFICE = 1,
		DOCKS = 2,
		CASINO = 4,
		BACK_ALLEYS = 8
	}

	[Header("Settings")]
	[SerializeField]
	private string loc_key_base;

	[SerializeField]
	private string prime_suspect_name;

	[SerializeField]
	private string lead_title_suffix;

	[SerializeField]
	private SetsType set_type;

	private AssetKey localisation_asset => LocalisationHelper.ui_asset;

	private string loc_name_key => loc_key_base + " [name]";

	private string loc_suffix_key => loc_key_base + " [suffix]";

	public SetsType getSetType()
	{
		return set_type;
	}

	public string getSetName()
	{
		return localisation_asset.checkTranslation(loc_name_key, () => prime_suspect_name, _check_keywords: false);
	}

	public string getLeadTitleSuffix()
	{
		return localisation_asset.checkTranslation(loc_suffix_key, () => lead_title_suffix, _check_keywords: false);
	}

	public List<Roles> getSetRoles()
	{
		return (from _n in fetchNodes<SetsRoleNode>()
			select _n.getRole()).ToList().sort();
	}

	public bool hasSameRolesAs(List<Roles> _roles)
	{
		List<Roles> setRoles = getSetRoles();
		if (setRoles.Count != _roles.Count)
		{
			return false;
		}
		return setRoles.All((Roles _r) => _roles.Contains(_r));
	}

	public List<CaseType> getCaseTypes()
	{
		List<CaseType> list = new List<CaseType>();
		if ((set_type & SetsType.OFFICE) == SetsType.OFFICE)
		{
			list.Add(CaseType.CLOCK);
		}
		if ((set_type & SetsType.DOCKS) == SetsType.DOCKS)
		{
			list.Add(CaseType.DOCKS);
		}
		if ((set_type & SetsType.CASINO) == SetsType.CASINO)
		{
			list.Add(CaseType.CASINO);
		}
		if ((set_type & SetsType.BACK_ALLEYS) == SetsType.BACK_ALLEYS)
		{
			list.Add(CaseType.BACK_ALLEYS);
		}
		return list;
	}

	public SetsType toPackType(CaseType _type)
	{
		return _type switch
		{
			CaseType.CLOCK => SetsType.OFFICE, 
			CaseType.DOCKS => SetsType.DOCKS, 
			CaseType.CASINO => SetsType.CASINO, 
			CaseType.BACK_ALLEYS => SetsType.BACK_ALLEYS, 
			_ => throw new ArgumentException($"No SetType set up for CaseType {_type}!!"), 
		};
	}

	public bool isAllowed(GameState _state, List<Roles> _current_roles)
	{
		if (fetchNodes<RoleSetsConditionNodeBase>().Any((RoleSetsConditionNodeBase _c) => !_c.isConditionMet(_state, _current_roles)))
		{
			return false;
		}
		return true;
	}
}
