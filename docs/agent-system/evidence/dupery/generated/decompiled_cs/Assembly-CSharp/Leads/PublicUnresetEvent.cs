using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using Localisation;
using Save;

namespace Leads;

public class PublicUnresetEvent : LeadEvent
{
	public override LeadEventType event_type => LeadEventType.PUBLIC_UNREST;

	public override List<CaseType> event_case_type => new List<CaseType>
	{
		CaseType.DOCKS,
		CaseType.CLOCK
	};

	public override string empty_name => name;

	public override string name => base.localisation_asset.checkTranslation(loc_name_key, englishName, _check_keywords: false);

	public override string description => base.localisation_asset.checkTranslation(loc_desc_key, englishDescription);

	protected override List<string> english_event_quote_text => new List<string> { "If we don't stop the Syndicate soon, the papers will eat us alive!", "Riots have started in the streets! They want the Syndicate gone." };

	private string loc_name_key => $"{event_type} [name]";

	private string loc_desc_key => $"{event_type} [desc]";

	public PublicUnresetEvent()
		: base(null, null, _show_exact: false)
	{
	}

	public PublicUnresetEvent(Random _rng, Lead _lead)
		: base(_rng, _lead, _show_exact: true)
	{
	}

	public PublicUnresetEvent(LeadEventSaveData _save, Lead _lead, Random _rng)
		: base(_save, _lead, _rng)
	{
	}

	private string englishName()
	{
		return "Public Unrest";
	}

	private string englishDescription()
	{
		return "You no longer regain " + Keywords.REPUTATION.toString() + " when solving a " + Keywords.CASE.toString() + ".";
	}

	public override List<Clue> clues(Lead _lead)
	{
		return _lead.clues.add(new QuirkClue(_immutable: false, CaseQuirks.PUBLIC_UNREST));
	}

	public override List<StampReference> getStamps(Lead _lead)
	{
		return new List<StampReference>
		{
			new StampReference(StampType.PUBLIC_UNREST)
		};
	}

	public override void helpFacade(LeadEventFacade _facade)
	{
		_facade.setStamp(StampType.PUBLIC_UNREST);
	}

	public override bool isValidForCurrentLead(Lead _lead)
	{
		return !_lead.clues.Any((Clue _c) => _c is QuirkClue quirkClue && quirkClue.quirk_in_focus == CaseQuirks.PUBLIC_UNREST);
	}

	protected override string getSaveData()
	{
		return "";
	}
}
