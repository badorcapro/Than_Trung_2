using System;
using System.Collections.Generic;
using GRGLib.Generic;
using GRGLib.Maybe;
using Localisation;
using Save;
using UnityEngine;

namespace Leads;

public class CasinoChipsGainEvent : LeadEvent
{
	private int chips;

	private MinMaxInt chips_range;

	public override LeadEventType event_type => LeadEventType.CHIPS_GAIN;

	public override List<CaseType> event_case_type => new List<CaseType> { CaseType.CASINO };

	public override string empty_name => name;

	public override string name => base.localisation_asset.checkTranslation(loc_name_key, englishName, _check_keywords: false);

	public override string description
	{
		get
		{
			if (!base.show_exact)
			{
				return base.localisation_asset.checkTranslationWithReplace(loc_desc_unknown_key, () => englishDescUnknown(chips_range.min, chips_range.max), true, chips_range.min, chips_range.max);
			}
			return base.localisation_asset.checkTranslationWithData(loc_desc_key, englishDesc, chips);
		}
	}

	protected override List<string> english_event_quote_text => new List<string> { "I'll take all the help I can get!" };

	private string loc_name_key => $"{event_type} [name]";

	private string loc_desc_key => $"{event_type} [desc]";

	private string loc_desc_unknown_key => $"{event_type} [desc_un]";

	public static Maybe<LeadEvent> tryCreateEvent(System.Random _rng, Lead _lead, MinMaxInt _range, bool _show_exact = false)
	{
		try
		{
			CasinoChipsGainEvent casinoChipsGainEvent = new CasinoChipsGainEvent(_lead, _range, _rng, _show_exact);
			if (casinoChipsGainEvent.isValidForCurrentLead(_lead))
			{
				return ((LeadEvent)casinoChipsGainEvent).maybe();
			}
			return new Maybe<LeadEvent>();
		}
		catch
		{
			return new Maybe<LeadEvent>();
		}
	}

	public CasinoChipsGainEvent()
		: base(null, null, _show_exact: false)
	{
	}

	public CasinoChipsGainEvent(Lead _lead, MinMaxInt _chips, System.Random _rng, bool _show_exact)
		: base(_rng, _lead, _show_exact)
	{
		chips_range = _chips;
		chips = chips_range.get(_rng);
	}

	public CasinoChipsGainEvent(LeadEventSaveData _save, Lead _lead, System.Random _rng)
		: base(_save, _lead, _rng)
	{
		try
		{
			string[] array = _save.data.Split(',');
			chips = int.Parse(array[0]);
			chips_range = new MinMaxInt(int.Parse(array[1]), int.Parse(array[2]));
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load casino chips gain event!\nData: {_save.data}\nError: {arg}");
			chips = 10;
		}
	}

	private string englishName()
	{
		return "Extra Funding";
	}

	private string englishDesc(string _data)
	{
		return "Regain " + _data + " " + TextHelper.chips_with_link_white + "!";
	}

	private string englishDescUnknown(int _data_1, int _data_2)
	{
		return englishDescUnknown(_data_1.ToString(), _data_2.ToString());
	}

	private string englishDescUnknown(string _data_1, string _data_2)
	{
		return "Regain " + _data_1 + "-" + _data_2 + " " + TextHelper.chips_with_link_white + "!";
	}

	public override Lead apply(Lead _lead)
	{
		if (_lead is CasinoLead casinoLead)
		{
			casinoLead.increaseChips(chips);
			return base.apply(_lead);
		}
		Debug.LogError($"Could not apply event of type {GetType()} because it requires a CasinoLead and was given a {_lead.GetType()}!");
		return base.apply(_lead);
	}

	public override List<StampReference> getStamps(Lead _lead)
	{
		return new List<StampReference>
		{
			new StampReference(StampType.CHIPS_GAIN)
		};
	}

	public override void helpFacade(LeadEventFacade _facade)
	{
		_facade.setStamp(StampType.CHIPS_GAIN);
	}

	public override bool isValidForCurrentLead(Lead _lead)
	{
		return _lead.case_type == CaseType.CASINO;
	}

	protected override string getSaveData()
	{
		return $"{chips},{chips_range.min},{chips_range.max}";
	}
}
