using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using UnityEngine;

public class DisguiseCharacteristics
{
	public Func<RoleData, bool> disguise_possible = (RoleData _r) => true;

	public bool disguises { get; private set; }

	public DisguiseTarget pretend_target { get; private set; } = DisguiseTarget.NOT_SET;

	public bool has_requirement { get; private set; }

	public bool check_disguise_constraints { get; private set; } = true;

	public List<RoleClassifications> can_disguise_as_classification { get; private set; }

	public List<Roles> disguise_blacklist { get; private set; }

	public Maybe<Roles> disguise_as { get; private set; } = new Maybe<Roles>();

	public DisguiseCharacteristics()
	{
		disguises = false;
		pretend_target = DisguiseTarget.NOT_SET;
		can_disguise_as_classification = new List<RoleClassifications>();
		disguise_blacklist = new List<Roles>();
		check_disguise_constraints = true;
	}

	public DisguiseCharacteristics(DisguiseTarget _target, List<RoleClassifications> _can_disguise_as_classification, List<Roles> _disguise_blacklist, bool _check_disguise_constraints = true)
	{
		disguises = true;
		has_requirement = false;
		pretend_target = _target;
		can_disguise_as_classification = _can_disguise_as_classification;
		disguise_blacklist = _disguise_blacklist;
		check_disguise_constraints = _check_disguise_constraints;
	}

	public DisguiseCharacteristics(DisguiseTarget _target, List<RoleClassifications> _can_disguise_as_classification, Func<RoleData, bool> _requirement, List<Roles> _disguise_blacklist, bool _check_disguise_constraints = true)
	{
		disguises = true;
		pretend_target = _target;
		has_requirement = true;
		can_disguise_as_classification = _can_disguise_as_classification;
		disguise_blacklist = _disguise_blacklist;
		disguise_possible = _requirement;
		check_disguise_constraints = _check_disguise_constraints;
	}

	public DisguiseCharacteristics(Roles _disguise)
	{
		disguises = true;
		pretend_target = DisguiseTarget.SPECIFIC_ROLE;
		disguise_as = _disguise.maybe();
		has_requirement = false;
		can_disguise_as_classification = new List<RoleClassifications>();
		disguise_blacklist = new List<Roles>();
	}

	public DisguiseCharacteristics addBlacklist(Roles _role)
	{
		disguise_blacklist.Add(_role);
		return this;
	}

	public bool validateDisguise(Roles _self, RoleData _disguise, CaseSnapshot _snap)
	{
		if (!disguises)
		{
			return false;
		}
		if (disguise_as.is_some)
		{
			return _disguise.role == disguise_as.value;
		}
		if (!disguise_possible(_disguise))
		{
			return false;
		}
		if (!can_disguise_as_classification.Contains(_disguise.role.getClassificationFromRoleType()))
		{
			return false;
		}
		switch (pretend_target)
		{
		case DisguiseTarget.SUSPECTED:
		case DisguiseTarget.CUSTOM_SUSPECTED:
			return true;
		case DisguiseTarget.IN_PLAY:
		case DisguiseTarget.CUSTOM_IN_PLAY:
			return _snap.address_occupents.Values.Any((RoleData _r) => _r.role == _disguise.role);
		case DisguiseTarget.NOT_IN_PLAY:
		case DisguiseTarget.CUSTOM_NOT_IN_PLAY:
			return !_snap.address_occupents.Values.Any((RoleData _r) => _r.role == _disguise.role);
		default:
			Debug.LogError($"Dont know how to validate disguise with target {pretend_target}");
			return false;
		}
	}
}
