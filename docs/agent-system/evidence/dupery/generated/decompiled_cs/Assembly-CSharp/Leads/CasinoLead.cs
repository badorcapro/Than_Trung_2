using System;
using System.Collections.Generic;
using GRGLib.Generic;
using Save;
using UnityEngine;

namespace Leads;

public class CasinoLead : Lead
{
	public static int starting_chips = 200;

	public static int starting_syndicate_chips = 150;

	public override CaseType case_type => CaseType.CASINO;

	public int chips { get; private set; } = starting_chips;

	public float cost_multi { get; private set; } = 1f;

	public CasinoLead(List<Roles> _available, Vector2Int _grid_size, MinMaxFloat _diff, int _lead_length, RoleSetInfoStruct _prime_suspect_set, int _starting_chips)
		: base(_available, _grid_size, _diff, _lead_length, _prime_suspect_set)
	{
		chips = _starting_chips;
	}

	public CasinoLead(LeadSaveData _save)
		: base(_save)
	{
		try
		{
			(chips, cost_multi) = JsonUtility.FromJson<(int, float)>(_save.unique_data);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load Casino Lead!\nData: {_save.unique_data}\nError: {arg}");
			chips = 100;
			cost_multi = 1f;
		}
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

	public override Case createCase(GameState _state)
	{
		return new CasinoCase(this, chips, cost_multi, case_difficulty, createCaseRatioBuilder());
	}

	public override Case createRandomCase(System.Random _rng)
	{
		base.current_case = _rng.Next(0, base.max_case);
		if (base.current_board_size.x == 3 && _rng.Next(0, 7) > 1)
		{
			setBoardSize(new Vector2Int(4, 4), _force: true);
		}
		chips = (base.current_board_size.x + base.current_board_size.y) * 4 + _rng.Next(0, 60);
		return new CasinoCase(this, chips, 1f, case_difficulty, createCaseRatioBuilder());
	}

	protected override void applyReward(Case _case, CaseReward _reward)
	{
		if (!(_case is CasinoCase casinoCase) || !(_reward is CasinoCaseReward casinoCaseReward))
		{
			Debug.LogError("Cannot apply reward to casino lead without both a casino case and a casino reward!");
			return;
		}
		if (casinoCase.chips > chips)
		{
			SteamHelper.tryAchieve(Achiements.SUCCESSFUL_GAMBLER);
		}
		chips = casinoCase.chips + casinoCaseReward.chips_gained;
	}

	public void increaseChips(int _chips)
	{
		chips += _chips;
	}

	public override CaseReward createCaseReward(GameState _state)
	{
		return new CasinoCaseReward(0, _syndicate_clue: false);
	}

	public override string uniqueSaveData()
	{
		return JsonUtility.ToJson((chips, cost_multi));
	}
}
