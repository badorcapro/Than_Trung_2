using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using Localisation;
using Save;
using UnityEngine;

namespace Leads;

public class FillOutWithRandomRolesEvent : LeadEvent, IRoleFilterEvent
{
	private List<Clue> clues_to_add = new List<Clue>();

	public override LeadEventType event_type => LeadEventType.FILL_OUT_WITH_ROLE_CLUES;

	public bool initialisation_failed { get; private set; }

	public override string empty_name => name;

	public override string name => base.localisation_asset.checkTranslation(loc_name_key, englishName, _check_keywords: false);

	public override string description => base.localisation_asset.checkTranslationWithData(loc_desc_key, englishDesc, 10);

	public override List<CaseType> event_case_type => new List<CaseType>
	{
		CaseType.CLOCK,
		CaseType.DOCKS,
		CaseType.CASINO
	};

	protected override List<string> english_event_quote_text => new List<string> { "Of course! This has to be it!", "Eureka! I've got it!" };

	private string loc_name_key => $"{event_type} [name]";

	private string loc_desc_key => $"{event_type} [desc]";

	public static Maybe<LeadEvent> tryCreateEvent(System.Random _rng, Lead _lead, List<LeadEvent> _events, bool _show_exact = false)
	{
		try
		{
			FillOutWithRandomRolesEvent fillOutWithRandomRolesEvent = new FillOutWithRandomRolesEvent(_rng, _lead, _events, _show_exact);
			if (fillOutWithRandomRolesEvent.isValidForCurrentLead(_lead))
			{
				return ((LeadEvent)fillOutWithRandomRolesEvent).maybe();
			}
			return new Maybe<LeadEvent>();
		}
		catch
		{
			return new Maybe<LeadEvent>();
		}
	}

	public FillOutWithRandomRolesEvent()
		: base(null, null, _show_exact: false)
	{
	}

	public FillOutWithRandomRolesEvent(System.Random _rng, Lead _lead, List<LeadEvent> _events, bool _show_exact = false)
		: base(_rng, _lead, _show_exact)
	{
		int num = 10 - _lead.clues.Count;
		List<Clue> list = _lead.clues.copy();
		for (int i = 0; i < num; i++)
		{
			Maybe<RoleClue> maybe = LeadHelper.createNonTraitorRoleClue(_lead.prime_suspect_set.set_roles, _lead.lead_roles, list, _lead.current_board_size, _events, _rng);
			if (!maybe.is_some)
			{
				initialisation_failed = true;
				break;
			}
			clues_to_add.Add(maybe.value);
			list.Add(maybe.value);
		}
	}

	public FillOutWithRandomRolesEvent(LeadEventSaveData _save, Lead _lead, System.Random _rng)
		: base(_save, _lead, _rng)
	{
		try
		{
			clues_to_add = (from _c in JsonUtility.FromJson<List<ClueSaveData>>(_save.data)
				select Clue.load(_c)).ToList();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load lead event {event_type}!\nData: {_save.data}\nError: {arg}");
		}
	}

	private string englishName()
	{
		return "SUDDEN BREAKTHROUGH";
	}

	private string englishDesc(string _data)
	{
		return $"Add {Keywords.ROLE.toString()} {TextHelper.stamps} until you have {10} {TextHelper.stamps} total.";
	}

	public override List<StampReference> getStamps(Lead _lead)
	{
		return clues_to_add.Select((Clue _c) => new StampReference(_c.clue_type.toStampType(), (_c as RoleClue).role_in_focus)).ToList();
	}

	public override List<Clue> clues(Lead _lead)
	{
		return _lead.clues.addRange(clues_to_add);
	}

	public override bool isValidForCurrentLead(Lead _lead)
	{
		if (!initialisation_failed)
		{
			return _lead.clues.Count < 10;
		}
		return false;
	}

	protected override string getSaveData()
	{
		return JsonUtility.ToJson(clues_to_add.Select((Clue _c) => new ClueSaveData(_c)).ToList());
	}

	public bool canRoleAppear(Roles _role)
	{
		return !clues_to_add.Any((Clue _c) => _c is RoleClue roleClue && roleClue.role_in_focus == _role);
	}
}
