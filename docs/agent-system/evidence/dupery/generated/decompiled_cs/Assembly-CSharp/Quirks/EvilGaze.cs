using System;
using System.Collections.Generic;
using System.Linq;
using CaseCreation;
using GRGLib.Extensions;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Random;
using UnityEngine;

namespace Quirks;

public class EvilGaze : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.EVIL_GAZE;

	protected override string english_name => "Evil Gaze";

	protected override string english_description => "At least 1 " + TextHelper.evilRole + " will always be " + Keywords.SURROUNDING.toString() + " the " + LocationTypes.CRIME_SCENE.toString() + ".";

	public override string description_white => base.description.colourSpriteLink("surrounding", Color.white);

	public override bool is_board_placement_quirk => true;

	public override bool isCompatible(CaseType _case_type)
	{
		return _case_type switch
		{
			CaseType.CLOCK => true, 
			CaseType.CASINO => true, 
			CaseType.BACK_ALLEYS => true, 
			_ => false, 
		};
	}

	public override Dictionary<Roles, List<IPositioningGenerationConstraint>> onBoardPlacement(Dictionary<Roles, List<IPositioningGenerationConstraint>> _constraints, List<Roles> _in_play_roles, System.Random _rng)
	{
		List<Roles> list = _in_play_roles.Where((Roles _r) => _r.getClassificationFromRoleType().equalToAny(RoleClassifications.UNDERLING, RoleClassifications.TRAITOR)).ToList();
		if (list.Count == 0)
		{
			Debug.LogError("NO EVIL IN THE IN PLAY LIST!!!!");
			return _constraints;
		}
		_constraints.addOrCreate(list.getRandomElementFromList(_rng), new PositionLocationGC(LocationTypes.CRIME_SCENE, GCPosition.SURROUNDING, DisguiseConstraintType.ALWAYS_IGNORE));
		return _constraints;
	}
}
