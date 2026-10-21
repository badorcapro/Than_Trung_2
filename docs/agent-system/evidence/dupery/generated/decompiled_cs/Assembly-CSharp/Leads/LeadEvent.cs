using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using GRGLocalisation;
using Localisation;
using Save;
using UnityEngine;

namespace Leads;

public abstract class LeadEvent : IAmLocalised
{
	protected System.Random random;

	protected readonly Lead lead_preview;

	public abstract LeadEventType event_type { get; }

	public abstract List<CaseType> event_case_type { get; }

	public virtual int case_length_offset => 0;

	public abstract string empty_name { get; }

	public abstract string name { get; }

	public abstract string description { get; }

	protected abstract List<string> english_event_quote_text { get; }

	public bool show_exact { get; private set; }

	protected AssetKey localisation_asset => LocalisationHelper.misc_asset;

	public static LeadEvent createEmpty(LeadEventType _type)
	{
		return _type switch
		{
			LeadEventType.ADD_ROLE_CLUE => new AddSingleRandomRoleEvent(), 
			LeadEventType.ADD_QUIRK_CLUE => new AddSingleRandomQuirkEvent(), 
			LeadEventType.REMOVE_RANDOM_CLUE => new RemoveRandomClueEvent(), 
			LeadEventType.INVERT_RANDOM_ROLE_CLUE => new InvertRandomRoleStatusEvent(), 
			LeadEventType.ADD_ABILITY_ROLE_CLUE => new AddSingleRandomRoleWithAbilityEvent(), 
			LeadEventType.REPLACE_MULTI_ROLE_CLUES => new ReplaceMultipleRandomRolesEvent(), 
			LeadEventType.REMOVE_QUIRK_CLUE => new RemoveOneQuirkEvent(), 
			LeadEventType.REPLACE_QUIRK_CLUE => new ReplaceOneQuirkEvent(), 
			LeadEventType.FILL_OUT_WITH_ROLE_CLUES => new FillOutWithRandomRolesEvent(), 
			LeadEventType.PLUS_ONE_CASE => new PlusOneCaseEvent(), 
			LeadEventType.INCREASE_BOARD_SIZE => new IncreaseBoardSizeEvent(), 
			LeadEventType.REPUTATION_GAIN => new ReputationGainEvent(), 
			LeadEventType.PUBLIC_UNREST => new PublicUnresetEvent(), 
			LeadEventType.ADD_STARTING_CLUES => new AddStartingClues(), 
			LeadEventType.CHIPS_GAIN => new CasinoChipsGainEvent(), 
			_ => throw new ArgumentException($"No create empty function set up for event type {_type}"), 
		};
	}

	public static LeadEvent load(LeadEventSaveData _save_data, Lead _lead, System.Random _rng)
	{
		return _save_data.type switch
		{
			LeadEventType.ADD_ROLE_CLUE => new AddSingleRandomRoleEvent(_save_data, _lead, _rng), 
			LeadEventType.ADD_QUIRK_CLUE => new AddSingleRandomQuirkEvent(_save_data, _lead, _rng), 
			LeadEventType.REMOVE_RANDOM_CLUE => new RemoveRandomClueEvent(_save_data, _lead, _rng), 
			LeadEventType.INVERT_RANDOM_ROLE_CLUE => new InvertRandomRoleStatusEvent(_save_data, _lead, _rng), 
			LeadEventType.ADD_ABILITY_ROLE_CLUE => new AddSingleRandomRoleWithAbilityEvent(_save_data, _lead, _rng), 
			LeadEventType.REPLACE_MULTI_ROLE_CLUES => new ReplaceMultipleRandomRolesEvent(_save_data, _lead, _rng), 
			LeadEventType.REMOVE_QUIRK_CLUE => new RemoveOneQuirkEvent(_save_data, _lead, _rng), 
			LeadEventType.REPLACE_QUIRK_CLUE => new ReplaceOneQuirkEvent(_save_data, _lead, _rng), 
			LeadEventType.FILL_OUT_WITH_ROLE_CLUES => new FillOutWithRandomRolesEvent(_save_data, _lead, _rng), 
			LeadEventType.PLUS_ONE_CASE => new PlusOneCaseEvent(_save_data, _lead, _rng), 
			LeadEventType.INCREASE_BOARD_SIZE => new IncreaseBoardSizeEvent(_save_data, _lead, _rng), 
			LeadEventType.REPUTATION_GAIN => new ReputationGainEvent(_save_data, _lead, _rng), 
			LeadEventType.PUBLIC_UNREST => new PublicUnresetEvent(_save_data, _lead, _rng), 
			LeadEventType.ADD_STARTING_CLUES => new AddStartingClues(_save_data, _lead, _rng), 
			LeadEventType.CHIPS_GAIN => new CasinoChipsGainEvent(_save_data, _lead, _rng), 
			_ => throw new ArgumentException($"No loading function set up for event type {_save_data.type}"), 
		};
	}

	public abstract bool isValidForCurrentLead(Lead _lead);

	public virtual Maybe<List<Vector2Int>> gridSizeOverrides(Lead _lead)
	{
		return new Maybe<List<Vector2Int>>();
	}

	public virtual List<Clue> clues(Lead _lead)
	{
		return _lead.clues;
	}

	public virtual string getRandomEventQuoteText(System.Random _rng)
	{
		int quote_nb = _rng.Next(0, english_event_quote_text.Count);
		return localisation_asset.checkTranslation(getEventQuoteLocKey(quote_nb), () => english_event_quote_text[quote_nb], _check_keywords: false);
	}

	public virtual void helpFacade(LeadEventFacade _facade)
	{
	}

	public LeadEvent(System.Random _rng, Lead _lead, bool _show_exact)
	{
		random = _rng;
		show_exact = _show_exact;
		lead_preview = _lead;
	}

	public LeadEvent(LeadEventSaveData _save, Lead _lead, System.Random _rng)
	{
		show_exact = _save.show_exact;
		lead_preview = _lead;
		random = _rng;
	}

	public abstract List<StampReference> getStamps(Lead _lead);

	public virtual List<StampReference> getStampsToFade(Lead _lead)
	{
		return new List<StampReference>();
	}

	public virtual Lead apply(Lead _lead)
	{
		_lead.updateMaxCase(_lead.max_case + case_length_offset);
		if (gridSizeOverrides(_lead).is_some)
		{
			_lead.updateGridSizes(gridSizeOverrides(_lead).value);
		}
		_lead.updateClueList(clues(_lead));
		return _lead;
	}

	public void setShowExact(bool _true)
	{
		show_exact = _true;
	}

	protected abstract string getSaveData();

	public LeadEventSaveData toSave()
	{
		return new LeadEventSaveData(event_type, show_exact, getSaveData());
	}

	protected virtual string getEventQuoteLocKey(int _quote_nb)
	{
		return $"{event_type} [event_{_quote_nb}]";
	}
}
