using System;
using System.Collections.Generic;
using GRGLib.Extensions.Collections;
using GRGLib.Generic;
using GRGLib.Maybe;
using Leads;
using Save;
using UnityEngine;

public class CaseBuildData
{
	public CaseType case_type;

	public float difficulty_01;

	public Vector2Int board_size;

	public CaseRatioBuilderData ratio_builder_data;

	public Maybe<CaseQuirks> quirk_added;

	public List<CaseQuirks> case_quirks;

	private Maybe<Case> built_case;

	public Roles icon;

	public string case_description = "";

	public CaseReward case_reward;

	public CaseBuildData(CaseType _case_type, Maybe<Vector2Int> _board_size, List<CaseQuirks> _quirks, Maybe<CaseQuirks> _new_quirk, CaseRatioBuilderData _ratio_data, float _diff, System.Random _rng)
	{
		case_type = _case_type;
		setUpBasics(_quirks, _new_quirk, _ratio_data, _diff);
		if (_board_size.is_some)
		{
			board_size = _board_size.value;
			int num = board_size.x * board_size.y / 2;
			_ratio_data.address_size = new MinMaxInt(Mathf.Max(num, _ratio_data.address_size.min), Mathf.Max(_ratio_data.address_size.max, num));
		}
		else
		{
			setUpBoardSizeFromDifficultyAndRatio(_rng);
		}
	}

	public CaseBuildData setCaseReward(CaseReward _case_reward)
	{
		case_reward = _case_reward;
		return this;
	}

	private void setUpBasics(List<CaseQuirks> _quirks, Maybe<CaseQuirks> _new_quirk, CaseRatioBuilderData _ratio_data, float _diff)
	{
		difficulty_01 = _diff;
		ratio_builder_data = _ratio_data;
		case_quirks = _quirks.copy().addIfSome(_new_quirk);
		quirk_added = _new_quirk;
		built_case = new Maybe<Case>();
	}

	private void setUpBoardSizeFromDifficultyAndRatio(System.Random _rng)
	{
		if (difficulty_01 > 0.35f)
		{
			board_size = new Vector2Int(4, 4);
			return;
		}
		int num = Mathf.Max(ratio_builder_data.getMinRatioFromClassifications(), ratio_builder_data.address_size.min);
		if (num <= 7 && (float)_rng.Next(0, 50) > difficulty_01 * 100f)
		{
			board_size = new Vector2Int(3, 3);
			ratio_builder_data.address_size = new MinMaxInt(num, 7);
		}
		else
		{
			board_size = new Vector2Int(4, 4);
		}
	}

	public CaseBuildData(CaseBuildDataSave _data)
	{
		case_type = _data.case_type;
		board_size = _data.board_size;
		difficulty_01 = _data.difficulty_01;
		ratio_builder_data = _data.ratio_builder_data;
		quirk_added = _data.quirk_added;
		case_quirks = _data.case_quirks.copy();
		case_quirks = _data.case_quirks;
		built_case = (_data.built_case.is_some ? CaseSave.toCase(_data.built_case.value, GameHandler.State.current_lead).maybe() : new Maybe<Case>());
		case_reward = _data.getReward();
	}

	public Case buildCase()
	{
		return buildCase(GameHandler.State.current_lead.value.lead_roles);
	}

	public Case buildCase(List<Roles> _available_roles)
	{
		if (!built_case.is_some)
		{
			if (case_type == CaseType.CLOCK)
			{
				OfficeLead officeLead = GameHandler.State.current_lead.value as OfficeLead;
				built_case = new Maybe<Case>(new ClockCase(officeLead.reputation, this, _available_roles));
			}
			else
			{
				Debug.LogError($"No build case function set up for case type {case_type}!");
			}
		}
		return built_case.value;
	}

	public void updateBuiltCase(Func<Case, Case> _case_update)
	{
		built_case = _case_update(buildCase()).maybe();
	}

	protected virtual string getUniqueData()
	{
		return "";
	}

	public CaseBuildDataSave toSave()
	{
		return new CaseBuildDataSave(this, built_case, getUniqueData());
	}
}
