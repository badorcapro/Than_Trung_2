using System.Collections.Generic;
using System.Linq;
using CaseCreation;
using GRGLib.Extensions.Collections;
using GRGLib.Generic;
using GRGLib.Maybe;
using UnityEngine;

public class VisualClassificationRatioGC : ClassificationRatioGC
{
	public VisualClassificationRatioGC(RoleClassifications _class, int _min_needed, DisguiseConstraintType _disguise = DisguiseConstraintType.IGNORE_WHEN_LYING)
		: base(_class, _min_needed, _disguise)
	{
	}

	public VisualClassificationRatioGC(RoleClassifications _class, MinMaxInt _needed, DisguiseConstraintType _disguise = DisguiseConstraintType.IGNORE_WHEN_LYING)
		: base(_class, _needed, _disguise)
	{
	}

	public override bool canSuspectWithRatio(Dictionary<RoleClassifications, int> _ratio, List<Roles> _forced_suspects, List<Roles> _forced_in_play, SuspectListFactory _factory)
	{
		Dictionary<RoleClassifications, int> dictionary = _ratio.copy();
		dictionary[classification] -= countRequiredExtra(_forced_in_play);
		return base.canSuspectWithRatio(dictionary, _forced_suspects, _forced_in_play, _factory);
	}

	public override bool canBeInPlayWithRatio(Dictionary<RoleClassifications, int> _ratio, List<Roles> _forced_in_play, InPlayListFactory _factory)
	{
		Dictionary<RoleClassifications, int> dictionary = _ratio.copy();
		dictionary[classification] -= countRequiredExtra(_forced_in_play);
		return base.canBeInPlayWithRatio(dictionary, _forced_in_play, _factory);
	}

	public override CaseRatioBuilderData updateBuilder(CaseRatioBuilderData _ratio_builder, bool _guaranteed_suspected, bool _guaranteed_in_play, List<Roles> _forced_suspects, List<Roles> _forced_in_play)
	{
		if (!_guaranteed_in_play && !_guaranteed_suspected)
		{
			return _ratio_builder;
		}
		int num = countRequiredExtra(_forced_in_play);
		if (min_needed > 0)
		{
			_ratio_builder.setMin(classification, min_needed + num);
		}
		if (max_needed.is_some)
		{
			_ratio_builder.setMax(classification, max_needed.value - num);
		}
		return _ratio_builder;
	}

	protected int countRequiredExtra(List<Roles> _roles)
	{
		(int, int) tuple = _roles.Aggregate((0, 0), delegate((int, int) _a, Roles _r)
		{
			RoleClassifications classificationFromRoleType = _r.getClassificationFromRoleType();
			RoleClassifications visualClassification = _r.createEmptyRole().getVisualClassification();
			if (classificationFromRoleType != visualClassification)
			{
				if (classificationFromRoleType == classification)
				{
					return (_a.Item1 + 1, _a.Item2);
				}
				if (visualClassification == classification)
				{
					return (_a.Item1, _a.Item2 + 1);
				}
			}
			return _a;
		});
		return tuple.Item2 - tuple.Item1;
	}

	public override bool validateDisguise(RoleData _role, Vector2Int _board_size, bool _bad_info, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, List<RoleData> _suspects)
	{
		if (requireFurtherCheck(disguise_constraint, _bad_info))
		{
			return ratioFits(_board.getOnBoardRatio(_true_class: false));
		}
		return true;
	}
}
