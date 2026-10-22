using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using GRGLib.Serializable;
using Lineup;

namespace Save;

[Serializable]
public class SaveDatav0_5_19 : BaseSaveData
{
	public StatsSaveData run_stats;

	public List<LineupClueSave> clues;

	public List<Regions> completed_regions = new List<Regions>();

	public List<Roles> available_roles = new List<Roles>();

	public Maybe<STupple<CaseSave, CaseRewardSave>> current_case = new Maybe<STupple<CaseSave, CaseRewardSave>>();

	public Maybe<PinsSave> pins_data = new Maybe<PinsSave>();

	public Maybe<LinesSave> lines_data = new Maybe<LinesSave>();

	public Maybe<StringSave> strings_data = new Maybe<StringSave>();

	public List<CaseBuildDataSave> available_cases = new List<CaseBuildDataSave>();

	public SaveDatav0_5_19(string _scene, GameState _state)
		: base(_scene)
	{
	}

	public override GameState toGameState()
	{
		if (!pins_data.is_some && !lines_data.is_some && !strings_data.is_some)
		{
			new Maybe<CaseNotes>();
		}
		else
		{
			new CaseNotes(pins_data, lines_data, strings_data).maybe();
		}
		return null;
	}

	public override void onLoaded()
	{
	}
}
