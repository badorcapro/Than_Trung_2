using System;
using System.Collections.Generic;
using GRGLib.Generic;
using Save;
using UnityEngine;

namespace Leads;

public class OfficeLead : Lead
{
	public const int max_reputation = 6;

	public const int starting_reputation = 6;

	public override CaseType case_type => CaseType.CLOCK;

	public int reputation { get; private set; } = 6;

	public OfficeLead(List<Roles> _available, Vector2Int _grid_size, MinMaxFloat _diff, int _lead_length, RoleSetInfoStruct _prime_suspect_set)
		: base(_available, _grid_size, _diff, _lead_length, _prime_suspect_set)
	{
	}

	public OfficeLead(List<Roles> _available, Vector2Int _grid_size, MinMaxFloat _diff, int _lead_length, RoleSetInfoStruct _prime_suspect_set, List<Clue> _clues)
		: base(_available, _grid_size, _diff, _lead_length, 0, _prime_suspect_set, _clues)
	{
	}

	public OfficeLead(List<Roles> _available, List<Vector2Int> _grid_size, MinMaxFloat _diff, int _lead_length, RoleSetInfoStruct _prime_suspect_set)
		: base(_available, _grid_size, _diff, _lead_length, _prime_suspect_set)
	{
	}

	public OfficeLead(List<Roles> _available, List<Vector2Int> _grid_size, MinMaxFloat _diff, int _lead_length, RoleSetInfoStruct _prime_suspect_set, List<Clue> _clues)
		: base(_available, _grid_size, _diff, _lead_length, 0, _prime_suspect_set, _clues)
	{
	}

	public OfficeLead(LeadSaveData _save)
		: base(_save)
	{
		try
		{
			reputation = int.Parse(_save.unique_data);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load Office Lead!\nData: {_save.unique_data}\nError: {arg}");
			reputation = 5;
		}
	}

	public override Case createCase(GameState _state)
	{
		return new ClockCase(this, reputation, case_difficulty, createCaseRatioBuilder());
	}

	public override Case createRandomCase(System.Random _rng)
	{
		base.current_case = _rng.Next(0, base.max_case);
		if (base.current_board_size.x == 3 && _rng.Next(0, 7) > 1)
		{
			setBoardSize(new Vector2Int(4, 4), _force: true);
		}
		return new ClockCase(this, _rng.Next(2, 7), case_difficulty, createCaseRatioBuilder());
	}

	private CaseRatioBuilderData createCaseRatioBuilder()
	{
		CaseRatioBuilderData caseRatioBuilderData = new CaseRatioBuilderData(base.lead_roles, case_address_size);
		if (base.current_case >= base.max_case - base.forced_end_traitor_cases)
		{
			caseRatioBuilderData.setForced(RoleClassifications.TRAITOR, 1);
		}
		return caseRatioBuilderData;
	}

	public override CaseReward createCaseReward(GameState _state)
	{
		return new ClockCaseReward(0, 1, _syndicate_clue: false);
	}

	protected override void applyReward(Case _case, CaseReward _reward)
	{
		if (!(_case is ClockCase clockCase) || !(_reward is ClockCaseReward clockCaseReward))
		{
			Debug.LogError("Cannot apply reward to office lead without both a clock case and a clock reward!");
		}
		else
		{
			reputation = Mathf.Min(clockCase.reputation + clockCaseReward.reputation_gain, 6);
		}
	}

	public void increateReputation(int _rep)
	{
		reputation = Mathf.Min(6, reputation + _rep);
	}

	public override string uniqueSaveData()
	{
		return reputation.ToString();
	}
}
