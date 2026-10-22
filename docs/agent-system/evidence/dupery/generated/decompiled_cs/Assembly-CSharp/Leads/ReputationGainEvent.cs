using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Localisation;
using Save;
using UnityEngine;

namespace Leads;

public class ReputationGainEvent : LeadEvent
{
	private int rep_gain = 1;

	public override LeadEventType event_type => LeadEventType.REPUTATION_GAIN;

	public override string empty_name => name;

	public override string name => base.localisation_asset.checkTranslation(loc_name_key, englishName, _check_keywords: false);

	public override string description => base.localisation_asset.checkTranslationWithData(loc_desc_key, englishDesc, rep_gain);

	public override List<CaseType> event_case_type => new List<CaseType>
	{
		CaseType.CLOCK,
		CaseType.DOCKS
	};

	protected override List<string> english_event_quote_text => new List<string> { "Finally I'm given a break.", "The Syndicate cannot stop me.", "Recognition at last!" };

	private string loc_name_key => $"{event_type} [name]";

	private string loc_desc_key => $"{event_type} [desc]";

	public static Maybe<LeadEvent> tryCreateEvent(System.Random _rng, Lead _lead, int _rep_gain = 1, bool _show_exact = false)
	{
		try
		{
			ReputationGainEvent reputationGainEvent = new ReputationGainEvent(_rng, _lead, _show_exact, _rep_gain);
			if (reputationGainEvent.isValidForCurrentLead(_lead))
			{
				return ((LeadEvent)reputationGainEvent).maybe();
			}
			return new Maybe<LeadEvent>();
		}
		catch
		{
			return new Maybe<LeadEvent>();
		}
	}

	public ReputationGainEvent()
		: base(null, null, _show_exact: false)
	{
	}

	public ReputationGainEvent(System.Random _rng, Lead _lead, bool _show_exact, int _rep_gain = 1)
		: base(_rng, _lead, _show_exact)
	{
		rep_gain = _rep_gain;
	}

	public ReputationGainEvent(LeadEventSaveData _save, Lead _lead, System.Random _rng)
		: base(_save, _lead, _rng)
	{
		try
		{
			rep_gain = int.Parse(_save.data);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Could not load event type {event_type}!\nData: {_save.data}\nError: {arg}");
			rep_gain = 1;
		}
	}

	private string englishName()
	{
		return "PUBLIC APPROVAL";
	}

	private string englishDesc(string _data)
	{
		return "Regain " + _data + " " + Keywords.REPUTATION.toString() + ".";
	}

	public override bool isValidForCurrentLead(Lead _lead)
	{
		if (_lead is OfficeLead officeLead)
		{
			return officeLead.reputation <= 6 - rep_gain;
		}
		return false;
	}

	public override List<StampReference> getStamps(Lead _lead)
	{
		return new List<StampReference>
		{
			new StampReference(StampType.REP_GAIN)
		};
	}

	public override Lead apply(Lead _lead)
	{
		if (_lead is OfficeLead officeLead)
		{
			officeLead.increateReputation(rep_gain);
			return base.apply(_lead);
		}
		if (_lead is DocksLead docksLead)
		{
			docksLead.increaseReputation(rep_gain);
			return base.apply(_lead);
		}
		Debug.LogError($"No function set up to regain reputation! (Case type: {_lead.case_type})");
		return base.apply(_lead);
	}

	public override void helpFacade(LeadEventFacade _facade)
	{
		_facade.setStamp(StampType.REP_GAIN);
	}

	protected override string getSaveData()
	{
		return rep_gain.ToString();
	}
}
