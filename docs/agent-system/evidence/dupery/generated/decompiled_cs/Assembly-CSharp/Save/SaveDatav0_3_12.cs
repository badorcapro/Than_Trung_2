using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using GRGLib.Serializable;
using UnityEngine;

namespace Save;

[Serializable]
public class SaveDatav0_3_12 : BaseSaveData
{
	public StatsSaveData run_stats;

	public List<Regions> completed_regions = new List<Regions>();

	public int reputation;

	public Regions current_region;

	public List<Roles> available_roles = new List<Roles>();

	public List<CaseQuirks> region_case_quirks = new List<CaseQuirks>();

	public int region_progress;

	public Maybe<STupple<CaseSavev0_3_12, CaseRewardSave>> current_case = new Maybe<STupple<CaseSavev0_3_12, CaseRewardSave>>();

	public Maybe<PinsSave> pins_data = new Maybe<PinsSave>();

	public Maybe<LinesSave> lines_data = new Maybe<LinesSave>();

	public Maybe<StringSave> strings_data = new Maybe<StringSave>();

	public List<CaseBuilDataSavev0_3_12> available_cases = new List<CaseBuilDataSavev0_3_12>();

	public SaveDatav0_3_12(string _scene, GameState _state)
		: base(_scene)
	{
		Debug.LogError("SHOULD NOT BE TRYING TO SAVE USING v0.3.12 save files!");
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
