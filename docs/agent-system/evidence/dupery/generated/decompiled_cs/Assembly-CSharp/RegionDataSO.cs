using System;
using System.Collections.Generic;
using System.Linq;
using CaseCreation;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Random;
using GRGLib.Serializable;
using GRGLocalisation;
using Localisation;
using Nodes.Logic;
using UnityEngine;

[CreateAssetMenu(menuName = "ScriptableObject/Regions/Region Data!")]
public class RegionDataSO : ScriptableObject, IAmLocalised
{
	[Header("Settings")]
	public Regions region;

	[SerializeField]
	private string english_region_name;

	[SerializeField]
	private string english_fired_end_text;

	[Header("Role Sets")]
	[SerializeField]
	private int roles_in_lead = 40;

	[SerializeField]
	private int roles_from_sets = 25;

	[SerializeField]
	private List<RoleSetsGraph> initial_sets;

	[SerializeField]
	private List<RoleSetsGraph> none_prime_sets;

	[SerializeField]
	private List<ListStruct<RoleSetsGraph>> tier_up_sets;

	[Header("Quirks")]
	[SerializeField]
	private List<CaseQuirks> initial_quirks;

	[SerializeField]
	private List<ListStruct<CaseQuirks>> tier_up_quirks;

	public static Dictionary<RoleClassifications, int> min_required => new Dictionary<RoleClassifications, int>
	{
		{
			RoleClassifications.INNOCENT,
			16
		},
		{
			RoleClassifications.MEDDLER,
			7
		},
		{
			RoleClassifications.UNDERLING,
			7
		},
		{
			RoleClassifications.TRAITOR,
			4
		}
	};

	public string region_name => localisation_asset.checkTranslation(loc_name_key, () => english_region_name);

	public string fired_end_text => localisation_asset.checkTranslation(loc_end_fired_key, () => english_fired_end_text);

	private string loc_name_key => $"R{(int)region} [name]";

	private string loc_end_fired_key => $"R{(int)region} [fired]";

	private AssetKey localisation_asset => LocalisationHelper.ui_asset;

	public List<Roles> getAvailableRoles(int _tier)
	{
		return getTierSets(_tier, _include_initial_sets: true, _include_non_prime_sets: true).Aggregate(new HashSet<Roles>(), (HashSet<Roles> _a, RoleSetsGraph _s) => _a.addRange(_s.getSetRoles())).ToList();
	}

	public List<CaseQuirks> getAvailableQuirks(int _tier)
	{
		List<CaseQuirks> list = initial_quirks.copy();
		for (int i = 0; i + 2 <= _tier && i < tier_up_quirks.Count; i++)
		{
			list.AddRange(tier_up_quirks[i].list);
		}
		return list;
	}

	public List<Roles> createAvailableRoles(int _tier, System.Random _rng, List<Roles> _prime_suspects)
	{
		List<RoleSetsGraph> tierSets = getTierSets(_tier, _include_initial_sets: true, _include_non_prime_sets: true);
		HashSet<Roles> hashSet = _prime_suspects.ToHashSet();
		while (hashSet.Count < roles_from_sets && tierSets.Count > 0)
		{
			RoleSetsGraph randomElementFromList = tierSets.getRandomElementFromList(_rng);
			hashSet.addRange(randomElementFromList.getSetRoles());
			tierSets.Remove(randomElementFromList);
		}
		List<Roles> remaining_roles = tierSets.Aggregate(new HashSet<Roles>(), (HashSet<Roles> _a, RoleSetsGraph _s) => _a.addRange(_s.getSetRoles())).ToList();
		Dictionary<RoleClassifications, int> dict = hashSet.Aggregate(new Dictionary<RoleClassifications, int>(), (Dictionary<RoleClassifications, int> _a, Roles _r) => _a.increaseOrCreate(_r.getClassificationFromRoleType(), 1));
		foreach (KeyValuePair<RoleClassifications, int> wanted in min_required)
		{
			if (dict.getOrDefault(wanted.Key, 0) < wanted.Value)
			{
				int num = wanted.Value - dict.getOrDefault(wanted.Key, 0);
				List<Roles> list = remaining_roles.Where((Roles _r) => _r.getClassificationFromRoleType() == wanted.Key).ToList();
				List<Roles> randomElementsFromList = list.getRandomElementsFromList(_rng, Mathf.Min(list.Count, num));
				hashSet.addRange(randomElementsFromList);
				remaining_roles.removeRange(randomElementsFromList);
				if (randomElementsFromList.Count != num)
				{
					Debug.LogError($"{wanted.Key} does not have enough roles!");
				}
			}
		}
		hashSet.addRange(remaining_roles.getRandomElementsFromList(_rng, Mathf.Min(_tier + roles_in_lead - hashSet.Count, remaining_roles.Count)));
		if (_prime_suspects.Count > 0)
		{
			hashSet = _prime_suspects.Aggregate(hashSet, delegate(HashSet<Roles> _a, Roles _ps)
			{
				List<IFilterRoleCluesGenerationConstraint> constraintOfInterface = _ps.createEmptyRole().generation_constraint.getConstraintOfInterface<IFilterRoleCluesGenerationConstraint>();
				if (constraintOfInterface.Count == 0)
				{
					return _a;
				}
				constraintOfInterface.ForEach(delegate(IFilterRoleCluesGenerationConstraint _c)
				{
					_a = _c.addToLeadRoles(_ps, _a, remaining_roles, _rng);
				});
				return _a;
			});
		}
		return hashSet.ToList();
	}

	public List<RoleSetsGraph> getTierSets(int _tier, bool _include_initial_sets = true, bool _include_non_prime_sets = false)
	{
		List<RoleSetsGraph> list = (_include_initial_sets ? initial_sets.copy() : new List<RoleSetsGraph>());
		if (_include_non_prime_sets)
		{
			list.AddRange(none_prime_sets);
		}
		if (_tier < 2)
		{
			return list;
		}
		for (int i = 0; i + 2 <= _tier && i < tier_up_sets.Count; i++)
		{
			list.addRange(tier_up_sets[i].list);
		}
		return list;
	}

	public List<RoleSetsGraph> getSetOfTier(int _tier)
	{
		if (_tier > 1)
		{
			if (tier_up_sets.Count <= _tier - 2)
			{
				return new List<RoleSetsGraph>();
			}
			return tier_up_sets[_tier - 2].list;
		}
		return initial_sets;
	}
}
