using System;
using GRGLib.Maybe;
using Leads;
using Save;

namespace AlternateModes;

public abstract class AlternateLeadModeData : AlternateModeData
{
	public override void startMode(Regions _region, RegionsSO _regions_data, RegionProgressionSaveData _progression, Random _rng)
	{
		LeadProgressionManager leadProgressionManager = createLeadProgressionManager(_region, _regions_data, _progression, _rng);
		Lead lead = createLead(leadProgressionManager, _regions_data, _progression, _rng);
		GameHandler.instance.startMode(this, lead, leadProgressionManager.maybe());
	}

	public override void onModeCompleted(GameState _state, bool _success)
	{
		if (_success)
		{
			GameHandler.StatsData.onAltModeFinished(mode_type, _state.current_lead.is_some ? _state.current_lead.value.case_type.fromType() : Regions.CUSTOM);
		}
	}

	public abstract LeadProgressionManager createLeadProgressionManager(Regions _region, RegionsSO _regions_data, RegionProgressionSaveData _progression, Random _rng);

	public abstract Lead createLead(LeadProgressionManager _manager, RegionsSO _regions_data, RegionProgressionSaveData _progression, Random _rng);

	protected LeadProgressionManager createBasicProgressionManager(Regions _region, RegionsSO _regions_data, RegionProgressionSaveData _progression)
	{
		return _region switch
		{
			Regions.OFFICE => new OfficeLeadProgressionManager(_regions_data, _progression.using_tier), 
			Regions.CASINO => new CasinoLeadProgressionManager(_regions_data, _progression.using_tier), 
			Regions.DOCKS => new DocksLeadProgressionManager(_regions_data, _progression.using_tier), 
			_ => throw new ArgumentException($"Not sure how to create custom lead of region {_region}!"), 
		};
	}
}
