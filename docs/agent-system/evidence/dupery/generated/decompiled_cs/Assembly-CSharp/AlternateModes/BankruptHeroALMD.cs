using System;
using System.Collections.Generic;
using GRGLib.Generic;
using Leads;
using Save;
using UnityEngine;

namespace AlternateModes;

public class BankruptHeroALMD : AlternateLeadModeData
{
	private const int starting_chips = 30;

	public override AlternateModeTypes mode_type => AlternateModeTypes.BANKRUPT_HERO;

	protected override string english_name => "Bankrupt Dreamer";

	protected override string english_description => $"A {Keywords.LEAD.toString()} where every {Keywords.CASE.toString()} has a {Roles.HOT_SHOT.toString()} but you start with only {30} {TextHelper.chips_with_link}" + " and you cannot regain them from " + TextHelper.stamps + ".";

	public override string getExtraDescription(Regions _region, AlternateModeStatsData _stats)
	{
		if (_stats.data == "")
		{
			return "";
		}
		int num = int.Parse(_stats.data);
		return highscoreLocalised($"{num}{TextHelper.chips_sprite_link}");
	}

	public override List<Regions> getAvailableRegions()
	{
		return new List<Regions> { Regions.CASINO };
	}

	public override LeadProgressionManager createLeadProgressionManager(Regions _region, RegionsSO _regions_data, RegionProgressionSaveData _progression, System.Random _rng)
	{
		LeadProgressionManager leadProgressionManager = createBasicProgressionManager(Regions.CASINO, _regions_data, _progression);
		leadProgressionManager.addEventVetoe(LeadEventType.CHIPS_GAIN);
		return leadProgressionManager;
	}

	public override Lead createLead(LeadProgressionManager _manager, RegionsSO _regions_data, RegionProgressionSaveData _progression, System.Random _rng)
	{
		RegionDataSO regionDataSO = _regions_data[_manager.region];
		CasinoLead obj = new CasinoLead(_prime_suspect_set: _regions_data.getEmptyPrimeSuspectSet(), _available: regionDataSO.createAvailableRoles(_progression.using_tier, _rng, new List<Roles>()), _grid_size: new Vector2Int(3, 3), _diff: new MinMaxFloat(0.3f, 0.88f), _lead_length: 9, _starting_chips: 30);
		obj.updateClueList(new List<Clue>
		{
			new RoleClue(_immutable: false, Roles.HOT_SHOT, ClueTypes.ROLE_IN_PLAY)
		});
		return obj;
	}

	public override void onModeCompleted(GameState _state, bool _success)
	{
		if (!_success)
		{
			return;
		}
		GameHandler.StatsData.onAltModeFinished(mode_type, Regions.CASINO, delegate(string _c)
		{
			if (!_state.current_lead.is_some || !(_state.current_lead.value is CasinoLead casinoLead))
			{
				return _c;
			}
			if (!int.TryParse(_c, out var result))
			{
				return casinoLead.chips.ToString();
			}
			return (casinoLead.chips > result) ? casinoLead.chips.ToString() : _c;
		});
	}
}
