using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using GRGLib.Serializable;
using UnityEngine;

namespace Save;

[Serializable]
public class SaveDatav0_4_23 : BaseSaveData
{
	public StatsSaveDatav0_4_23 run_stats;

	public List<Regions> completed_regions = new List<Regions>();

	public List<Roles> available_roles = new List<Roles>();

	public Maybe<STupple<CaseSavev0_4_23, CaseRewardSave>> current_case = new Maybe<STupple<CaseSavev0_4_23, CaseRewardSave>>();

	public Maybe<PinsSave> pins_data = new Maybe<PinsSave>();

	public Maybe<LinesSave> lines_data = new Maybe<LinesSave>();

	public Maybe<StringSave> strings_data = new Maybe<StringSave>();

	public List<CaseBuildDataSave> available_cases = new List<CaseBuildDataSave>();

	public SaveDatav0_4_23(string _scene)
		: base(_scene)
	{
		Debug.LogError("SHOULD NOT BE TRYING TO SAVE USING v0.4.23 save files!");
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
		if (!current_case.is_some)
		{
			new Maybe<STupple<CaseSave, CaseRewardSave>>();
		}
		else
		{
			new STupple<CaseSave, CaseRewardSave>(new CaseSave(current_case.value.Item1), current_case.value.Item2).maybe();
		}
		return null;
	}

	public override void onLoaded()
	{
	}
}
