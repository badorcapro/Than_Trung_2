using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Localisation;
using Save;
using UnityEngine;

namespace Leads;

public class InvertRandomRoleStatusEvent : LeadEvent
{
	private RoleClue selected_clue;

	private bool valid_event;

	public override LeadEventType event_type => LeadEventType.INVERT_RANDOM_ROLE_CLUE;

	public override string empty_name => base.localisation_asset.checkTranslation(loc_name_key, englishName);

	public override string name
	{
		get
		{
			if (!base.show_exact)
			{
				return base.localisation_asset.checkTranslation(loc_name_key, englishName);
			}
			return base.localisation_asset.checkTranslationWithData(loc_name_exact_key, englishNameExact, selected_clue.facade.name.ToUpper());
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
			return base.localisation_asset.checkTranslationWithReplace(loc_desc_exact_key, englishDescExactWithDataFilled, true, selected_clue.facade.name, (selected_clue.clue_type == ClueTypes.ROLE_IN_PLAY) ? Keywords.NOT_IN_PLAY.toString() : Keywords.IN_PLAY.toString());
		}
	}

	public override List<CaseType> event_case_type => new List<CaseType>
	{
		CaseType.CLOCK,
		CaseType.DOCKS,
		CaseType.CASINO
	};

	protected override List<string> english_event_quote_text => new List<string> { "The Syndicate's been messing with our reports!", "I can't have made a mistake, the Syndicate must be responsible!" };

	private string loc_name_key => $"{event_type} [name]";

	private string loc_name_exact_key => $"{event_type} [name_e]";

	private string loc_desc_key => $"{event_type} [desc]";

	private string loc_desc_exact_key => $"{event_type} [desc_e]";

	public static Maybe<LeadEvent> tryCreateEvent(System.Random _rng, Lead _lead, List<LeadEvent> _events, bool _show_exact = false)
	{
		try
		{
			InvertRandomRoleStatusEvent invertRandomRoleStatusEvent = new InvertRandomRoleStatusEvent(_rng, _lead, _events, _show_exact);
			if (invertRandomRoleStatusEvent.isValidForCurrentLead(_lead))
			{
				return ((LeadEvent)invertRandomRoleStatusEvent).maybe();
			}
			return new Maybe<LeadEvent>();
		}
		catch
		{
			return new Maybe<LeadEvent>();
		}
	}

	public InvertRandomRoleStatusEvent()
		: base(null, null, _show_exact: false)
	{
	}

	public InvertRandomRoleStatusEvent(System.Random _rng, Lead _lead, List<LeadEvent> _events, bool _show_exact)
		: base(_rng, _lead, _show_exact)
	{
		if (isValidForCurrentLead(_lead))
		{
			List<RoleClue> invertableClues = getInvertableClues(_lead);
			if (invertableClues.Count == 0)
			{
				valid_event = false;
			}
			selected_clue = invertableClues.getRandomElementFromList(_rng);
			valid_event = true;
		}
	}

	public InvertRandomRoleStatusEvent(LeadEventSaveData _save, Lead _lead, System.Random _rng)
		: base(_save, _lead, _rng)
	{
		try
		{
			RoleClue save_clue = Clue.load(JsonUtility.FromJson<ClueSaveData>(_save.data)) as RoleClue;
			selected_clue = _lead.clues.Find((Clue _c) => save_clue.isSameAs(_c)) as RoleClue;
			valid_event = true;
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load lead event {event_type}!\nData: {_save.data}\nError: {arg}");
		}
	}

	private string englishName()
	{
		return "CLERICAL MISTAKE";
	}

	private string englishNameExact(string _data)
	{
		return "INVERT " + _data + "'S STATUS";
	}

	private string englishDesc()
	{
		return "A random " + Keywords.ROLE.toString() + " " + Keywords.STAMP.toString() + " is inverted, making a " + TextHelper.notInPlayRole + " " + Keywords.IN_PLAY.toString() + ", or an " + TextHelper.inPlayRole + " " + Keywords.NOT_IN_PLAY.toString() + ".";
	}

	private string englishDescExactWithDataFilled()
	{
		return englishDescExact(selected_clue.facade.name, (selected_clue.clue_type == ClueTypes.ROLE_IN_PLAY) ? Keywords.NOT_IN_PLAY.toString() : Keywords.IN_PLAY.toString());
	}

	private string englishDescExact(string _data, string _data_2)
	{
		return "The " + _data + " will now always be " + _data_2 + ".";
	}

	public override bool isValidForCurrentLead(Lead _lead)
	{
		if (valid_event)
		{
			return _lead.clues.Where((Clue _c) => !_c.immutable && (_c.clue_type == ClueTypes.ROLE_IN_PLAY || _c.clue_type == ClueTypes.ROLE_NOT_IN_PLAY)).ToList().Count > 0;
		}
		return false;
	}

	private List<RoleClue> getInvertableClues(Lead _lead)
	{
		return (from _c in _lead.clues
			where _c.can_be_changed && _c is RoleClue roleClue && roleClue.canBeInverted(_lead.lead_roles, _lead.prime_suspect_set.set_roles, _lead.clues)
			select _c as RoleClue).ToList();
	}

	public override List<StampReference> getStamps(Lead _lead)
	{
		return new List<StampReference>
		{
			new StampReference((selected_clue.clue_type != ClueTypes.ROLE_IN_PLAY) ? StampType.ROLE_IN_PLAY : StampType.ROLE_NOT_IN_PLAY, selected_clue.role_in_focus)
		};
	}

	public override List<StampReference> getStampsToFade(Lead _lead)
	{
		return new List<StampReference>
		{
			new StampReference(selected_clue.clue_type.toStampType(), selected_clue.role_in_focus)
		};
	}

	public override List<Clue> clues(Lead _lead)
	{
		RoleClue e = new RoleClue(_immutable: false, selected_clue.role_in_focus, (selected_clue.clue_type != ClueTypes.ROLE_IN_PLAY) ? ClueTypes.ROLE_IN_PLAY : ClueTypes.ROLE_NOT_IN_PLAY);
		return _lead.clues.removeFirst((Clue _c) => _c.isSameAs(selected_clue)).add(e);
	}

	protected override string getSaveData()
	{
		return JsonUtility.ToJson(new ClueSaveData(selected_clue));
	}
}
