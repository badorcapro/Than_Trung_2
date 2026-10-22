using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using GRGLib.Serializable;
using UnityEngine;

namespace Save;

[Serializable]
public class SaveDatav0_2_51 : BaseSaveData
{
	public StatsSaveData run_stats;

	public List<Regions> completed_regions = new List<Regions>();

	public int reputation;

	public Regions current_region;

	public List<Roles> available_roles = new List<Roles>();

	public List<CaseQuirks> region_case_quirks = new List<CaseQuirks>();

	public int region_progress;

	public Maybe<STupple<CaseSavev0_3_12, CaseRewardSave>> current_case = new Maybe<STupple<CaseSavev0_3_12, CaseRewardSave>>();

	public List<CaseBuilDataSavev0_3_12> available_cases = new List<CaseBuilDataSavev0_3_12>();

	public SaveDatav0_2_51(string _scene, GameState _state)
		: base(_scene)
	{
		Debug.LogError("SHOULD NOT BE TRYING TO SAVE USING v0.2.51 save files!");
	}

	public override GameState toGameState()
	{
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
		if (current_case.is_some && current_case.value.Item1.board_roles.Exists((RoleDataSaveV0_3_12 _r) => isIncompatible(_r.role)))
		{
			current_case = new Maybe<STupple<CaseSavev0_3_12, CaseRewardSave>>();
			Debug.Log("Reset case");
		}
	}

	private static bool isIncompatible(Roles _role)
	{
		return _role switch
		{
			Roles.BOUNTY_HUNTER => true, 
			Roles.ROMANTIC => true, 
			Roles.DOPPELGANGER => true, 
			Roles.STALKER => true, 
			Roles.CASANOVA => true, 
			Roles.PREACHER => true, 
			Roles.JUDGE => true, 
			_ => false, 
		};
	}
}
