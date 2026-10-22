using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using GRGLib.Serializable;
using Localisation;
using Save;
using UnityEngine;

namespace Leads;

public class ReplaceOneQuirkEvent : LeadEvent, IQuirkFilterEvent, IClueRemovalFilterEvent
{
	private Clue selected_clue;

	private Clue replacing_clue;

	public override LeadEventType event_type => LeadEventType.REPLACE_QUIRK_CLUE;

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

	protected override List<string> english_event_quote_text => new List<string> { "I've seen this trick before detective, the Syndicate is trying to fool us!" };

	private string loc_name_key => $"{event_type} [name]";

	private string loc_name_exact_key => $"{event_type} [name_e]";

	private string loc_desc_key => $"{event_type} [desc]";

	private string loc_desc_exact_key => $"{event_type} [desc_e]";

	public ReplaceOneQuirkEvent()
		: base(null, null, _show_exact: false)
	{
	}

	public ReplaceOneQuirkEvent(System.Random _rng, Lead _lead, List<LeadEvent> _events, List<CaseQuirks> _region_quirks, Func<CaseQuirks, bool> _allowed, bool _show_exact)
		: base(_rng, _lead, _show_exact)
	{
		if (!isValidForCurrentLead(_lead))
		{
			return;
		}
		List<QuirkClue> list = (from _c in lead_preview.clues
			where _c.can_be_changed && _c is QuirkClue && !_events.Any((LeadEvent _e) => _e is IClueRemovalFilterEvent clueRemovalFilterEvent && !clueRemovalFilterEvent.canClueBeRemoved(_c))
			select _c as QuirkClue).ToList();
		Maybe<QuirkClue> maybe = LeadHelper.createQuirkClue(_region_quirks, _lead, _events, _allowed, _rng);
		if (list.Count == 0 || !maybe.is_some)
		{
			initialisation_failed = true;
			return;
		}
		selected_clue = list.getRandomElementFromList(random);
		replacing_clue = maybe.value;
	}

	public ReplaceOneQuirkEvent(LeadEventSaveData _save, Lead _lead, System.Random _rng)
		: base(_save, _lead, _rng)
	{
		try
		{
			STupple<ClueSaveData, ClueSaveData> sTupple = JsonUtility.FromJson<STupple<ClueSaveData, ClueSaveData>>(_save.data);
			Clue selected = Clue.load(sTupple.Item1);
			selected_clue = _lead.clues.Find((Clue _c) => selected.isSameAs(_c));
			replacing_clue = Clue.load(sTupple.Item2);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load lead event {event_type}!\nData: {_save.data}\nError: {arg}");
		}
	}

	private string englishName()
	{
		return "RETHINK ODDITY";
	}

	private string englishNameExact(string _data)
	{
		return "REPLACE " + _data + " WITH A NEW ODDITY";
	}

	private string englishDesc()
	{
		return "Replaces one random " + Keywords.QUIRK.toString() + " " + Keywords.STAMP.toString() + " with another random " + Keywords.QUIRK.toString() + " " + Keywords.STAMP.toString();
	}

	private string englishDescExact(string _data)
	{
		return "Replaces " + _data + " with another random " + Keywords.QUIRK.toString() + " " + Keywords.STAMP.toString() + ".";
	}

	public override List<StampReference> getStamps(Lead _lead)
	{
		return new List<StampReference>
		{
			new StampReference(replacing_clue.clue_type.toStampType(), (replacing_clue as QuirkClue).quirk_in_focus)
		};
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
		return _lead.clues.removeFirst((Clue _c) => _c.isSameAs(selected_clue)).add(replacing_clue);
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
		return JsonUtility.ToJson(new STupple<ClueSaveData, ClueSaveData>(new ClueSaveData(selected_clue), new ClueSaveData(replacing_clue)));
	}

	public bool canQuirkAppear(CaseQuirks _quirk)
	{
		if (replacing_clue != null && replacing_clue is QuirkClue quirkClue)
		{
			return quirkClue.quirk_in_focus != _quirk;
		}
		return true;
	}

	public bool canClueBeRemoved(Clue _clue)
	{
		if (selected_clue != null)
		{
			return !selected_clue.isSameAs(_clue);
		}
		return true;
	}
}
