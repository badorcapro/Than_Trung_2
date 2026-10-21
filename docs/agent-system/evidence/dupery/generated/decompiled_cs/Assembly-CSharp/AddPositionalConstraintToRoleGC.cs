using System;
using System.Collections.Generic;
using System.Linq;
using CaseCreation;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Random;

public class AddPositionalConstraintToRoleGC : InPlayRequireRoleGC, IAddPositionalGenerationConstraint
{
	private IPositioningGenerationConstraint to_add;

	public AddPositionalConstraintToRoleGC(Roles _role, IPositioningGenerationConstraint _constraint, DisguiseConstraintType _disguise = DisguiseConstraintType.ALWAYS_IGNORE, bool _lock_self = false)
		: base(_role, _disguise, _lock_self)
	{
		to_add = _constraint;
	}

	public AddPositionalConstraintToRoleGC(RoleClassifications _class, IPositioningGenerationConstraint _constraint, bool _true_class = false, DisguiseConstraintType _disguise = DisguiseConstraintType.ALWAYS_IGNORE, bool _lock_self = false)
		: base(_class, 1, _true_class, _disguise, _lock_self)
	{
		to_add = _constraint;
	}

	public AddPositionalConstraintToRoleGC(RoleGenerationMarkers _marker, IPositioningGenerationConstraint _constraint, DisguiseConstraintType _disguise = DisguiseConstraintType.ALWAYS_IGNORE, bool _lock_self = false)
		: base(_marker, 1, _disguise, _lock_self)
	{
		to_add = _constraint;
	}

	public AddPositionalConstraintToRoleGC(RoleClassifications _class, RoleGenerationMarkers _marker, IPositioningGenerationConstraint _constraint, bool _true_class = false, DisguiseConstraintType _disguise = DisguiseConstraintType.ALWAYS_IGNORE, bool _lock_self = false)
		: base(_class, _marker, 1, _true_class, _disguise, _lock_self)
	{
		to_add = _constraint;
	}

	public AddPositionalConstraintToRoleGC(List<RoleClassifications> _class, IPositioningGenerationConstraint _constraint, bool _true_class = false, DisguiseConstraintType _disguise = DisguiseConstraintType.ALWAYS_IGNORE, bool _lock_self = false)
		: base(_class, 1, _true_class, _disguise, _lock_self)
	{
		to_add = _constraint;
	}

	public AddPositionalConstraintToRoleGC(Func<Roles, bool> _condition, EditorErrorBuilder _error_builder, IPositioningGenerationConstraint _constraint, DisguiseConstraintType _disguise = DisguiseConstraintType.ALWAYS_IGNORE, bool _lock_self = false)
		: base(_condition, _error_builder, 1, _disguise, _lock_self)
	{
		to_add = _constraint;
	}

	public Dictionary<Roles, List<IPositioningGenerationConstraint>> addConstraints(Dictionary<Roles, List<IPositioningGenerationConstraint>> _constraints, List<Roles> _in_play_roles, Random _rng)
	{
		Roles randomElementFromList = _in_play_roles.Where(is_target).ToList().getRandomElementFromList(_rng);
		_constraints.addOrCreate(randomElementFromList, to_add);
		return _constraints;
	}
}
