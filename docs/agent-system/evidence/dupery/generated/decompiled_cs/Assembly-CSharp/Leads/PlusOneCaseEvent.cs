using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Localisation;
using Save;

namespace Leads;

public class PlusOneCaseEvent : LeadEvent
{
	public override LeadEventType event_type => LeadEventType.PLUS_ONE_CASE;

	public override string empty_name => name;

	public override string name => base.localisation_asset.checkTranslation(loc_name_key, englishName, _check_keywords: false);

	public override string description => base.localisation_asset.checkTranslation(loc_desc_key, englishDesc);

	public override List<CaseType> event_case_type => new List<CaseType>
	{
		CaseType.CLOCK,
		CaseType.DOCKS,
		CaseType.CASINO
	};

	public override int case_length_offset => 1;

	protected override List<string> english_event_quote_text => new List<string> { "This is bigger than we thought...", "I need more time!" };

	private string loc_name_key => $"{event_type} [name]";

	private string loc_desc_key => $"{event_type} [desc]";

	public static Maybe<LeadEvent> tryCreateEvent(Random _rng, Lead _lead, bool _show_exact = false)
	{
		try
		{
			PlusOneCaseEvent plusOneCaseEvent = new PlusOneCaseEvent(_rng, _lead, _show_exact);
			if (plusOneCaseEvent.isValidForCurrentLead(_lead))
			{
				return ((LeadEvent)plusOneCaseEvent).maybe();
			}
			return new Maybe<LeadEvent>();
		}
		catch
		{
			return new Maybe<LeadEvent>();
		}
	}

	public PlusOneCaseEvent()
		: base(null, null, _show_exact: false)
	{
	}

	public PlusOneCaseEvent(Random _rng, Lead _lead, bool _show_exact)
		: base(_rng, _lead, _show_exact)
	{
	}

	public PlusOneCaseEvent(LeadEventSaveData _save, Lead _lead, Random _rng)
		: base(_save, _lead, _rng)
	{
	}

	private string englishName()
	{
		return "DEADLINE EXTENSION";
	}

	private string englishDesc()
	{
		return "The current " + Keywords.LEAD.toString() + " requires an extra " + Keywords.CASE.toString() + " to be completed.";
	}

	public override bool isValidForCurrentLead(Lead _lead)
	{
		return _lead.max_case <= 10;
	}

	public override List<StampReference> getStamps(Lead _lead)
	{
		return new List<StampReference>
		{
			new StampReference(StampType.PLUS_ONE_CASE)
		};
	}

	public override void helpFacade(LeadEventFacade _facade)
	{
		_facade.setStamp(StampType.PLUS_ONE_CASE);
	}

	protected override string getSaveData()
	{
		return "";
	}
}
