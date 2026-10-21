using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLib.Generic;
using GRGLocalisation;
using Leads;
using Localisation;
using Save;
using UnityEngine;

namespace AlternateModes;

public abstract class AlternateModeData : IAmLocalised
{
	public abstract AlternateModeTypes mode_type { get; }

	public string name => localisation_asset.checkTranslation(loc_name_key, () => english_name, _check_keywords: false);

	protected abstract string english_name { get; }

	public string description => localisation_asset.checkTranslation(loc_desc_key, () => english_description);

	protected abstract string english_description { get; }

	protected string completed_localised => localisation_asset.checkTranslation(loc_completed_key, englishCompleted);

	private AssetKey localisation_asset => LocalisationHelper.misc_asset;

	protected string loc_name_key => $"Mode_{(int)mode_type} [name]";

	protected string loc_desc_key => $"Mode_{(int)mode_type} [desc]";

	protected string loc_highscore_key => "Mode_G [highscore]";

	protected string loc_cases_solved_key => "Mode_G [cas_sol]";

	protected string loc_arrested_key => "Mode_G [arr]";

	protected string loc_completed_key => "Mode_G [completed]";

	public static List<AlternateModeData> createAllModes()
	{
		return new List<AlternateModeTypes>().addAll().Select(createData).ToList();
	}

	public static List<AlternateModeData> createAllUnlockedModes()
	{
		return (from _m in new List<AlternateModeTypes>().addAll().Select(createData)
			where _m.modeUnlocked()
			select _m).ToList();
	}

	public static AlternateModeData createData(AlternateModeTypes _mode)
	{
		return _mode switch
		{
			AlternateModeTypes.ONLY_QUIRKS => new OnlyQuirksALMD(), 
			AlternateModeTypes.RANDOM_QUIRKS => new RandomQuirksALMD(), 
			AlternateModeTypes.SPECTRES_DREAM => new SpectresDreamALMD(), 
			AlternateModeTypes.TRAITOR_ONLY => new TraitorsOnlyALMD(), 
			AlternateModeTypes.SURVIVAL => new SurvivalAMD(), 
			AlternateModeTypes.COUNTDOWN => new CountdownAMD(), 
			AlternateModeTypes.BANKRUPT_HERO => new BankruptHeroALMD(), 
			AlternateModeTypes.HIDE_AND_SEEK => new HideAndSeekALMD(), 
			_ => throw new ArgumentException($"No AlternateModeData set up for mode {_mode}!"), 
		};
	}

	public static AlternateModeData loadData(AlternateModeTypes _mode, string _save)
	{
		return _mode switch
		{
			AlternateModeTypes.COUNTDOWN => new CountdownAMD(_save), 
			AlternateModeTypes.SURVIVAL => new SurvivalAMD(_save), 
			_ => createData(_mode), 
		};
	}

	public virtual string getExtraDescription(Regions _region, AlternateModeStatsData _stats)
	{
		if (!_stats.completed.Contains(_region))
		{
			return "";
		}
		return completed_localised;
	}

	public virtual bool modeUnlocked()
	{
		return getAvailableRegions().Any((Regions _r) => GameHandler.MetaData.getTierOfRegion(_r) >= 2);
	}

	public virtual List<Regions> getAvailableRegions()
	{
		return new List<Regions>
		{
			Regions.OFFICE,
			Regions.CASINO,
			Regions.DOCKS
		};
	}

	public abstract void startMode(Regions _region, RegionsSO _regions_data, RegionProgressionSaveData _progression, System.Random _rng);

	public abstract void onModeCompleted(GameState _state, bool _success);

	protected Lead createBasicLead(Regions _region, RegionsSO _regions_data, int _tier, Vector2Int _board, MinMaxFloat _difficulty, int _length, System.Random _rng)
	{
		RegionDataSO regionDataSO = _regions_data[_region];
		RoleSetInfoStruct emptyPrimeSuspectSet = _regions_data.getEmptyPrimeSuspectSet();
		return createBasicLead(_region, regionDataSO.createAvailableRoles(_tier, _rng, new List<Roles>()), _board, _difficulty, _length, emptyPrimeSuspectSet);
	}

	protected Lead createBasicLead(Regions _region, List<Roles> _available, Vector2Int _board, MinMaxFloat _difficulty, int _length, RoleSetInfoStruct _prime)
	{
		return _region switch
		{
			Regions.OFFICE => new OfficeLead(_available, _board, _difficulty, _length, _prime), 
			Regions.CASINO => new CasinoLead(_available, _board, _difficulty, _length, _prime, 250), 
			Regions.DOCKS => new DocksLead(_available, _board, _difficulty, _length, _prime), 
			_ => throw new ArgumentException($"Not sure how to create custom lead of region {_region}!"), 
		};
	}

	protected string casesSolvedLocalised(string _d1)
	{
		return localisation_asset.checkTranslationWithData(loc_cases_solved_key, englishCasesSolved, _d1);
	}

	private string englishCasesSolved(string _d1)
	{
		return _d1 + " cases solved!";
	}

	protected string arrestedLocalised(string _d1)
	{
		return localisation_asset.checkTranslationWithData(loc_cases_solved_key, englishArrested, _d1);
	}

	private string englishArrested(string _d1)
	{
		return _d1 + " arrested!";
	}

	protected string highscoreLocalised(string _d1)
	{
		return localisation_asset.checkTranslationWithData(loc_highscore_key, englishHighscore, _d1);
	}

	private string englishHighscore(string _d1)
	{
		return "Highscore: " + _d1;
	}

	private string englishCompleted()
	{
		return "Completed!";
	}
}
