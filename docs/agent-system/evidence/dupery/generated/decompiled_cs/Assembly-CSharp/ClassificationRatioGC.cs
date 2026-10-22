using System.Collections.Generic;
using CaseCreation;
using GRGLib.Generic;
using GRGLib.Maybe;
using UnityEngine;

public class ClassificationRatioGC : AdvancedGenerationConstraint, IClassificationGenerationConstraint
{
	protected RoleClassifications classification;

	protected int min_needed;

	protected Maybe<int> max_needed = new Maybe<int>();

	protected DisguiseConstraintType disguise_constraint;

	public ClassificationRatioGC(RoleClassifications _class, int _min_needed, DisguiseConstraintType _disguise = DisguiseConstraintType.IGNORE_WHEN_LYING)
	{
		classification = _class;
		min_needed = _min_needed;
		disguise_constraint = _disguise;
	}

	public ClassificationRatioGC(RoleClassifications _class, MinMaxInt _needed, DisguiseConstraintType _disguise = DisguiseConstraintType.IGNORE_WHEN_LYING)
	{
		int min = _needed.min;
		Maybe<int> maybe = _needed.max.maybe();
		classification = _class;
		min_needed = min;
		max_needed = maybe;
		disguise_constraint = _disguise;
	}

	public virtual bool canSuspectWithRatio(Dictionary<RoleClassifications, int> _ratio, List<Roles> _forced_suspects, List<Roles> _forced_in_play, SuspectListFactory _factory)
	{
		return ratioFits(_ratio);
	}

	public virtual bool canBeInPlayWithRatio(Dictionary<RoleClassifications, int> _ratio, List<Roles> _forced_in_play, InPlayListFactory _factory)
	{
		return ratioFits(_ratio);
	}

	protected virtual bool ratioFits(Dictionary<RoleClassifications, int> _ratio)
	{
		if (_ratio[classification] >= min_needed)
		{
			if (max_needed.is_some)
			{
				return _ratio[classification] <= max_needed.value;
			}
			return true;
		}
		return false;
	}

	public virtual CaseRatioBuilderData updateBuilder(CaseRatioBuilderData _ratio_builder, bool _guaranteed_suspected, bool _guaranteed_in_play, List<Roles> _forced_suspects, List<Roles> _forced_in_play)
	{
		if (_guaranteed_in_play || _guaranteed_suspected)
		{
			_ratio_builder.setMin(classification, min_needed);
			if (max_needed.is_some)
			{
				_ratio_builder.setMax(classification, max_needed.value);
			}
			return _ratio_builder;
		}
		return _ratio_builder;
	}

	public override bool validateDisguise(RoleData _role, Vector2Int _board_size, bool _bad_info, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, List<RoleData> _suspects)
	{
		if (requireFurtherCheck(disguise_constraint, _bad_info))
		{
			return ratioFits(_board.getOnBoardRatio(_true_class: true));
		}
		return true;
	}
}
