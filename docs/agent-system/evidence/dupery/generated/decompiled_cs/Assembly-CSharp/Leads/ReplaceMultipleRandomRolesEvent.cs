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

public class ReplaceMultipleRandomRolesEvent : LeadEvent, IRoleFilterEvent
{
	private int to_replace = 3;

	private List<Clue> selected_clues = new List<Clue>();

	private List<Clue> replacing_clues = new List<Clue>();

	public override LeadEventType event_type => LeadEventType.REPLACE_MULTI_ROLE_CLUES;

	public bool initialisation_failed { get; private set; }

	public override string empty_name => name;

	public override string name => base.localisation_asset.checkTranslationWithData(loc_name_key, englishName, to_replace, _check_keywords: false);

	public override string description => base.localisation_asset.checkTranslationWithData(loc_desc_key, englishDesc, to_replace);

	public override List<CaseType> event_case_type => new List<CaseType>
	{
		CaseType.CLOCK,
		CaseType.DOCKS,
		CaseType.CASINO
	};

	protected override List<string> english_event_quote_text => new List<string> { "Perhaps it's best we look at this from a new angle detective?" };

	private string loc_name_key => $"{event_type} [name]";

	private string loc_desc_key => $"{event_type} [desc]";

	public static Maybe<LeadEvent> tryCreateEvent(System.Random _rng, Lead _lead, List<LeadEvent> _events, int _to_replace, bool _show_exact = false)
	{
		try
		{
			ReplaceMultipleRandomRolesEvent replaceMultipleRandomRolesEvent = new ReplaceMultipleRandomRolesEvent(_rng, _lead, _events, _to_replace, _show_exact);
			if (replaceMultipleRandomRolesEvent.isValidForCurrentLead(_lead))
			{
				return ((LeadEvent)replaceMultipleRandomRolesEvent).maybe();
			}
			return new Maybe<LeadEvent>();
		}
		catch
		{
			return new Maybe<LeadEvent>();
		}
	}

	public ReplaceMultipleRandomRolesEvent()
		: base(null, null, _show_exact: false)
	{
	}

	public ReplaceMultipleRandomRolesEvent(System.Random _rng, Lead _lead, List<LeadEvent> _events, int _to_replace, bool _show_exact)
		: base(_rng, _lead, _show_exact)
	{
		to_replace = _to_replace;
		List<Clue> list = lead_preview.clues.Where((Clue _c) => _c.can_be_changed && _c is RoleClue).ToList();
		selected_clues = list.getRandomElementsFromList(_rng, _to_replace);
		List<Clue> list2 = _lead.clues.copy();
		for (int i = 0; i < to_replace; i++)
		{
			Maybe<RoleClue> maybe = LeadHelper.createNonTraitorRoleClue(_lead.prime_suspect_set.set_roles, _lead.lead_roles, list2, _lead.current_board_size, _events, _rng);
			if (!maybe.is_some)
			{
				initialisation_failed = true;
				break;
			}
			replacing_clues.Add(maybe.value);
			list.Add(maybe.value);
			list2.Add(maybe.value);
		}
	}

	public ReplaceMultipleRandomRolesEvent(LeadEventSaveData _save, Lead _lead, System.Random _rng)
		: base(_save, _lead, _rng)
	{
		try
		{
			STupple<List<ClueSaveData>, List<ClueSaveData>> sTupple = JsonUtility.FromJson<STupple<List<ClueSaveData>, List<ClueSaveData>>>(_save.data);
			replacing_clues = sTupple.Item2.Select((ClueSaveData _s) => Clue.load(_s)).ToList();
			to_replace = replacing_clues.Count;
			selected_clues = (from _s in sTupple.Item1
				select Clue.load(_s) into _c
				select _lead.clues.Find((Clue _lc) => _c.isSameAs(_lc))).ToList();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load lead event {event_type}!\nData: {_save.data}\nError: {arg}");
		}
	}

	private string englishName(string _data)
	{
		return "RETHINK " + _data + " SUSPECTS";
	}

	private string englishDesc(string _data)
	{
		return "Replaces " + _data + " random " + Keywords.ROLE.toString() + " " + TextHelper.stamps + " with " + _data + " new " + Keywords.ROLE.toString() + " " + TextHelper.stamps + ".";
	}

	public override List<StampReference> getStamps(Lead _lead)
	{
		return replacing_clues.Select((Clue _c) => new StampReference(_c.clue_type.toStampType(), (_c as RoleClue).role_in_focus)).ToList();
	}

	public override List<StampReference> getStampsToFade(Lead _lead)
	{
		return selected_clues.Select((Clue _c) => new StampReference(_c.clue_type.toStampType(), (_c as RoleClue).role_in_focus)).ToList();
	}

	public override List<Clue> clues(Lead _lead)
	{
		return _lead.clues.removeAll((Clue _c) => selected_clues.Any((Clue _sc) => _c.isSameAs(_sc))).addRange(replacing_clues);
	}

	public override bool isValidForCurrentLead(Lead _lead)
	{
		if (!initialisation_failed)
		{
			return _lead.clues.Where((Clue _e) => _e.can_be_changed && _e is RoleClue).ToList().Count >= 3;
		}
		return false;
	}

	protected override string getSaveData()
	{
		return JsonUtility.ToJson(new STupple<List<ClueSaveData>, List<ClueSaveData>>(selected_clues.Select((Clue _c) => new ClueSaveData(_c)).ToList(), replacing_clues.Select((Clue _c) => new ClueSaveData(_c)).ToList()));
	}

	public bool canRoleAppear(Roles _role)
	{
		return !replacing_clues.Any((Clue _c) => _c is RoleClue roleClue && roleClue.role_in_focus == _role);
	}
}
