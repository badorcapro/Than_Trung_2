using System;
using System.Collections.Generic;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using Localisation;
using Save;
using UnityEngine;

namespace Leads;

public class AddSingleRandomQuirkEvent : LeadEvent, IQuirkFilterEvent
{
	private QuirkClue clue;

	private bool failed_initialisation;

	public override LeadEventType event_type => LeadEventType.ADD_QUIRK_CLUE;

	private CaseQuirks selected_quirk => clue.quirk_in_focus;

	public override List<CaseType> event_case_type => new List<CaseType>().addAll();

	public override string empty_name => base.localisation_asset.checkTranslation(loc_name_key, englishName, _check_keywords: false);

	public override string name
	{
		get
		{
			if (!base.show_exact)
			{
				return base.localisation_asset.checkTranslation(loc_name_key, englishName, _check_keywords: false);
			}
			return selected_quirk.toString();
		}
	}

	public override string description
	{
		get
		{
			if (!base.show_exact)
			{
				return base.localisation_asset.checkTranslation(loc_desc_key, englishDesc);
			}
			return selected_quirk.createQuirk().description_white;
		}
	}

	protected override List<string> english_event_quote_text => new List<string> { "The Syndicate play by different rules, it's time we do the same.", "It seems things are unfolding differently now that the game is afoot.", "The city is changing under the Syndicate's pressure." };

	private string loc_name_key => $"{event_type} [name]";

	private string loc_desc_key => $"{event_type} [desc]";

	public AddSingleRandomQuirkEvent()
		: base(null, null, _show_exact: false)
	{
	}

	public AddSingleRandomQuirkEvent(System.Random _rng, Lead _lead, List<LeadEvent> _events, List<CaseQuirks> _region_quirks, Func<CaseQuirks, bool> _allowed, bool _show_real)
		: base(_rng, _lead, _show_real)
	{
		Maybe<QuirkClue> maybe = LeadHelper.createQuirkClue(_region_quirks, _lead, _events, _allowed, _rng);
		if (!maybe.is_some)
		{
			failed_initialisation = true;
		}
		else
		{
			clue = maybe.value;
		}
	}

	public AddSingleRandomQuirkEvent(LeadEventSaveData _save, Lead _lead, System.Random _rng)
		: base(_save, _lead, _rng)
	{
		try
		{
			clue = Clue.load(JsonUtility.FromJson<ClueSaveData>(_save.data)) as QuirkClue;
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load lead event {event_type}!\nData: {_save.data}\nError: {arg}");
		}
	}

	private string englishName()
	{
		return "INVESTIGATE ODDITY";
	}

	private string englishDesc()
	{
		return "Gain a random " + Keywords.QUIRK.toString() + " " + Keywords.STAMP.toString() + ".";
	}

	public override void helpFacade(LeadEventFacade _facade)
	{
		if (base.show_exact)
		{
			_facade.setIconAsQuirk(selected_quirk);
		}
		else
		{
			_facade.setStamp(StampType.QUIRK);
		}
	}

	public override List<StampReference> getStamps(Lead _lead)
	{
		return new List<StampReference>
		{
			new StampReference(StampType.QUIRK, selected_quirk)
		};
	}

	public override List<Clue> clues(Lead _lead)
	{
		return _lead.clues.add(clue);
	}

	public override bool isValidForCurrentLead(Lead _lead)
	{
		if (!failed_initialisation)
		{
			return _lead.clues.Count < 10;
		}
		return false;
	}

	protected override string getSaveData()
	{
		return JsonUtility.ToJson(new ClueSaveData(clue));
	}

	public bool canQuirkAppear(CaseQuirks _quirk)
	{
		if (clue != null)
		{
			return _quirk != selected_quirk;
		}
		return true;
	}
}
