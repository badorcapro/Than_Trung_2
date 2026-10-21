using System;
using System.Collections.Generic;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using UnityEngine;

namespace Save;

[Serializable]
public class CaseBuildDataSave
{
	public CaseType case_type;

	public Vector2Int board_size;

	public float difficulty_01;

	public CaseRatioBuilderData ratio_builder_data;

	public Maybe<CaseQuirks> quirk_added;

	public List<CaseQuirks> case_quirks;

	public Maybe<CaseSave> built_case;

	public CaseRewardSave reward;

	public string unique_data;

	public CaseBuildDataSave(CaseBuildData _data, Maybe<Case> _built, string _unique_data)
	{
		case_type = _data.case_type;
		difficulty_01 = _data.difficulty_01;
		ratio_builder_data = _data.ratio_builder_data;
		quirk_added = _data.quirk_added;
		case_quirks = _data.case_quirks.copy();
		case_quirks = _data.case_quirks;
		board_size = _data.board_size;
		built_case = (_built.is_some ? _built.value.toSave().maybe() : new Maybe<CaseSave>());
		reward = _data.case_reward.toSave();
		unique_data = _unique_data;
	}

	public CaseBuildDataSave(CaseBuilDataSavev0_3_12 _old)
	{
		case_type = CaseType.CLOCK;
		difficulty_01 = _old.difficulty_01;
		ratio_builder_data = _old.ratio_builder_data;
		quirk_added = _old.quirk_added;
		case_quirks = _old.case_quirks.copy();
		case_quirks = _old.case_quirks;
		board_size = new Vector2Int(4, 4);
		built_case = (_old.case_save.is_some ? new CaseSave(_old.case_save.value).maybe() : new Maybe<CaseSave>());
		reward = new CaseRewardSave(_old.case_reward.syndicate_clue, $"{_old.case_reward.region_progress},{_old.case_reward.reputation_gain}");
		unique_data = "";
	}

	public CaseReward getReward()
	{
		return CaseRewardSave.load(reward, case_type);
	}

	public static CaseBuildData load(CaseBuildDataSave _save)
	{
		switch (_save.case_type)
		{
		case CaseType.CLOCK:
		case CaseType.CASINO:
		case CaseType.BACK_ALLEYS:
			return new CaseBuildData(_save);
		case CaseType.DOCKS:
			return new DocksCaseBuildData(_save);
		default:
			Debug.LogError($"Loading function for CaseBuildData of type {_save.case_type} is not set up!");
			return new CaseBuildData(_save);
		}
	}
}
