using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Localisation;
using Save;
using UnityEngine;

namespace Leads;

public class RemoveOneQuirkEvent : LeadEvent, IClueRemovalFilterEvent
{
	private Clue selected_clue;

	public override LeadEventType event_type => LeadEventType.REMOVE_QUIRK_CLUE;

	public bool initialisation_failed { get; private set; }

	public override List<CaseType> event_case_type => new List<CaseType>
	{
		CaseType.CLOCK,
		CaseType.DOCKS,
		CaseType.CASINO
	};

	public override string empty_name => base.localisation_asset.checkTranslation(loc_name_key, englishName);

	public override string name
	{
		get
		{
			if (!base.show_exact)
			{
				return base.localisation_asset.checkTranslation(loc_name_key, englishName);
			}
			return base.localisation_asset.checkTranslationWithData(loc_name_exact_key, englishNameExact, selected_clue.getName().ToUpper());
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
			return base.localisation_asset.checkTranslationWithData(loc_desc_exact_key, englishDescExact, selected_clue.getName());
		}
	}

	protected override List<string> english_event_quote_text => new List<string> { "Perhaps we got this wrong, detective?", "We must have been duped at some point along the line." };

	private string loc_name_key => $"{event_type} [name]";

	private string loc_name_exact_key => $"{event_type} [name_e]";

	private string loc_desc_key => $"{event_type} [desc]";

	private string loc_desc_exact_key => $"{event_type} [desc_e]";

	public static Maybe<LeadEvent> tryCreateEvent(System.Random _rng, Lead _lead, List<LeadEvent> _events, bool _show_exact = false)
	{
		try
		{
			RemoveOneQuirkEvent removeOneQuirkEvent = new RemoveOneQuirkEvent(_rng, _lead, _events, _show_exact);
			if (removeOneQuirkEvent.isValidForCurrentLead(_lead))
			{
				return ((LeadEvent)removeOneQuirkEvent).maybe();
			}
			return new Maybe<LeadEvent>();
		}
		catch
		{
			return new Maybe<LeadEvent>();
		}
	}

	public RemoveOneQuirkEvent()
		: base(null, null, _show_exact: false)
	{
	}

	public RemoveOneQuirkEvent(System.Random _rng, Lead _lead, List<LeadEvent> _events, bool _show_exact)
		: base(_rng, _lead, _show_exact)
	{
		if (!isValidForCurrentLead(_lead))
		{
			return;
		}
		List<Clue> list = lead_preview.clues.Where((Clue _c) => _c.can_be_changed && _c.clue_type == ClueTypes.QUIRK_IN_PLAY && !_events.Any((LeadEvent _e) => _e is IClueRemovalFilterEvent clueRemovalFilterEvent && !clueRemovalFilterEvent.canClueBeRemoved(_c))).ToList();
		if (list.Count == 0)
		{
			initialisation_failed = true;
		}
		else
		{
			selected_clue = list.getRandomElementFromList(_rng);
		}
	}

	public RemoveOneQuirkEvent(LeadEventSaveData _save, Lead _lead, System.Random _rng)
		: base(_save, _lead, _rng)
	{
		try
		{
			Clue save_clue = Clue.load(JsonUtility.FromJson<ClueSaveData>(_save.data));
			selected_clue = _lead.clues.Find((Clue _c) => save_clue.isSameAs(_c));
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load lead event {event_type}!\nData: {_save.data}\nError: {arg}");
		}
	}

	private string englishName()
	{
		return "ELIMINATE ODDITY";
	}

	private string englishNameExact(string _data)
	{
		return "REMOVE " + _data;
	}

	private string englishDesc()
	{
		return "Removes one random " + Keywords.QUIRK.toString() + " " + Keywords.STAMP.toString() + ".";
	}

	private string englishDescExact(string _data)
	{
		return "Removes " + _data + ".";
	}

	public override List<StampReference> getStamps(Lead _lead)
	{
		return new List<StampReference>();
	}

	public override List<StampReference> getStampsToFade(Lead _lead)
	{
		return new List<StampReference>
		{
			new StampReference(selected_clue.clue_type.toStampType(), (selected_clue as QuirkClue).quirk_in_focus)
		};
	}

	public override List<Clue> clues(Lead _lead)
	{
		return _lead.clues.removeFirst((Clue _c) => _c.isSameAs(selected_clue));
	}

	public override bool isValidForCurrentLead(Lead _lead)
	{
		if (!initialisation_failed)
		{
			return _lead.clues.Where((Clue _w) => !_w.immutable && _w.clue_type == ClueTypes.QUIRK_IN_PLAY).Count() > 0;
		}
		return false;
	}

	protected override string getSaveData()
	{
		return JsonUtility.ToJson(new ClueSaveData(selected_clue));
	}

	public bool canClueBeRemoved(Clue _clue)
	{
		if (!initialisation_failed)
		{
			return _clue.isSameAs(selected_clue);
		}
		return true;
	}
}
