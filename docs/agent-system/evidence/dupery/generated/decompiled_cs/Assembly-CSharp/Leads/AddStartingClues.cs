using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using Localisation;
using Save;

namespace Leads;

public class AddStartingClues : LeadEvent
{
	private bool failed_initialisation;

	private List<Clue> clues_to_stamp = new List<Clue>();

	public override LeadEventType event_type => LeadEventType.ADD_STARTING_CLUES;

	public override List<CaseType> event_case_type => new List<CaseType>().addAll();

	public override string empty_name => base.localisation_asset.checkTranslation(loc_name_key, englishName, _check_keywords: false);

	public override string name
	{
		get
		{
			if (clues_to_stamp.Count != 1)
			{
				return base.localisation_asset.checkTranslation(loc_name_key, englishName, _check_keywords: false);
			}
			return clues_to_stamp[0].getName().ToUpper();
		}
	}

	public override string description
	{
		get
		{
			if (clues_to_stamp.Count != 1)
			{
				return base.localisation_asset.checkTranslation(loc_desc_key, englishDesc);
			}
			return clues_to_stamp[0].getDescription();
		}
	}

	protected override List<string> english_event_quote_text => new List<string> { "Something strange is afoot here. This town feels different to what I'm used to...", "How many stamps will I get this time?", "Each lead has it's quirks. Let's see what this one has in store for us..." };

	private string loc_name_key => $"{event_type} [name]";

	private string loc_desc_key => $"{event_type} [desc]";

	public AddStartingClues()
		: base(null, null, _show_exact: false)
	{
	}

	public AddStartingClues(Lead _lead, Random _rng)
		: base(_rng, _lead, _show_exact: true)
	{
		clues_to_stamp = _lead.clues;
	}

	public AddStartingClues(LeadEventSaveData _save, Lead _lead, Random _rng)
		: base(_save, _lead, _rng)
	{
		clues_to_stamp = _lead.clues;
	}

	private string englishName()
	{
		return "SURPRISING BEGINNINGS";
	}

	private string englishDesc()
	{
		return "The collection of " + TextHelper.stamps + " this lead begins with.";
	}

	public override void helpFacade(LeadEventFacade _facade)
	{
		if (clues_to_stamp.Count == 1)
		{
			if (clues_to_stamp[0] is QuirkClue quirkClue)
			{
				_facade.setIconAsQuirk(quirkClue.quirk_in_focus);
			}
			else if (clues_to_stamp[0] is RoleClue roleClue)
			{
				_facade.setIconAsRole(roleClue.role_in_focus);
			}
		}
	}

	public override List<StampReference> getStamps(Lead _lead)
	{
		return clues_to_stamp.Aggregate(new List<StampReference>(), (List<StampReference> _a, Clue _c) => _a.addIfSome(getStampFromClue(_c)));
	}

	private Maybe<StampReference> getStampFromClue(Clue _clue)
	{
		if (_clue is RoleClue roleClue)
		{
			return new StampReference(roleClue.clue_type.toStampType(), roleClue.role_in_focus).maybe();
		}
		if (_clue is QuirkClue quirkClue)
		{
			return new StampReference(StampType.QUIRK, quirkClue.quirk_in_focus).maybe();
		}
		return new Maybe<StampReference>();
	}

	public override bool isValidForCurrentLead(Lead _lead)
	{
		return false;
	}

	protected override string getSaveData()
	{
		return "";
	}
}
