using System;
using System.Collections.Generic;
using GRGLib.Generic;
using Save;
using UnityEngine;

namespace Leads;

public class DocksLead : Lead
{
	public const int max_reputation = 6;

	public const int starting_reputation = 5;

	public override CaseType case_type => CaseType.DOCKS;

	public int reputation { get; private set; } = 5;

	public int needed_arrested { get; private set; } = 20;

	public int evil_arrested { get; private set; }

	public override bool is_lead_completed => evil_arrested >= needed_arrested;

	public override float case_difficulty => base.lead_difficulty.estimate(Mathf.Min((float)evil_arrested / (float)needed_arrested, 1f));

	public DocksLead(List<Roles> _available, Vector2Int _grid_size, MinMaxFloat _diff, int _arrests_needed, RoleSetInfoStruct _prime_suspect_set)
		: base(_available, _grid_size, _diff, _arrests_needed, _prime_suspect_set)
	{
		needed_arrested = _arrests_needed;
	}

	public DocksLead(List<Roles> _available, Vector2Int _grid_size, MinMaxFloat _diff, int _arrests_needed, RoleSetInfoStruct _prime_suspect_set, List<Clue> _clues)
		: base(_available, _grid_size, _diff, _arrests_needed, 0, _prime_suspect_set, _clues)
	{
		needed_arrested = _arrests_needed;
	}

	public DocksLead(LeadSaveData _save)
		: base(_save)
	{
		try
		{
			string[] array = _save.unique_data.Split(',');
			reputation = int.Parse(array[0]);
			evil_arrested = int.Parse(array[1]);
			needed_arrested = int.Parse(array[2]);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load Office Lead!\nData: {_save.unique_data}\nError: {arg}");
			reputation = 5;
			evil_arrested = 0;
			needed_arrested = 20;
		}
	}

	public override Case createCase(GameState _state)
	{
		return new DocksCase(this, reputation, calculateStartingFuel(), case_difficulty, createCaseRatioBuilder());
	}

	public override Case createRandomCase(System.Random _rng)
	{
		base.current_case = _rng.Next(0, base.max_case);
		if (base.current_board_size.x == 3 && _rng.Next(0, 7) > 1)
		{
			setBoardSize(new Vector2Int(4, 4), _force: true);
		}
		return new DocksCase(this, reputation, calculateStartingFuel(), case_difficulty, createCaseRatioBuilder());
	}

	private int calculateStartingFuel()
	{
		int num = 1 + Mathf.RoundToInt((float)(base.current_board_size.x - 1) * 3.5f + (float)(base.current_board_size.y - 1) * 3.5f);
		if (GameHandler.MetaData.difficulty == GameMetaData.Difficulty.EASY)
		{
			num += 4;
		}
		else if (GameHandler.MetaData.difficulty == GameMetaData.Difficulty.CHALLENGE)
		{
			num -= base.current_board_size.x + base.current_board_size.y - 4;
		}
		return num + Mathf.RoundToInt((1f - case_difficulty) * 2.2f);
	}

	private CaseRatioBuilderData createCaseRatioBuilder()
	{
		CaseRatioBuilderData caseRatioBuilderData = new CaseRatioBuilderData(base.lead_roles, case_address_size);
		if ((base.current_board_size.x > 3 && base.current_case % 5 == 4) || evil_arrested >= needed_arrested - 3)
		{
			caseRatioBuilderData.setForced(RoleClassifications.TRAITOR, 1);
		}
		return caseRatioBuilderData;
	}

	public override CaseReward createCaseReward(GameState _state)
	{
		return new DocksCaseReward(0, 1, _syndicate_clue: false);
	}

	protected override void applyReward(Case _case, CaseReward _reward)
	{
		if (!(_case is DocksCase docksCase) || !(_reward is DocksCaseReward docksCaseReward))
		{
			Debug.LogError("Cannot apply reward to Dock lead without both a Dock case and a Dock reward!");
			return;
		}
		evil_arrested += docksCase.arrested_evils;
		if (docksCase.anyEscapedEvils)
		{
			docksCaseReward.reputation_gain = Mathf.Max(docksCaseReward.reputation_gain - 1, 0);
		}
		reputation = Mathf.Min(docksCase.reputation + docksCaseReward.reputation_gain, 6);
	}

	public void increaseReputation(int _rep)
	{
		reputation = Mathf.Min(6, reputation + _rep);
	}

	public override string uniqueSaveData()
	{
		return $"{reputation},{evil_arrested},{needed_arrested}";
	}

	public void setNeededEvilArrested(int _value)
	{
		needed_arrested = _value;
	}
}
