using System;
using System.Collections.Generic;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using Localisation;
using Save;
using UnityEngine;

namespace Leads;

public class AddSingleRandomRoleWithAbilityEvent : LeadEvent, IRoleFilterEvent
{
	private RoleClue selected_role_clue;

	public override LeadEventType event_type => LeadEventType.ADD_ABILITY_ROLE_CLUE;

	private Roles selected_role => selected_role_clue.role_in_focus;

	public bool initialisation_failed { get; private set; }

	public override string empty_name => base.localisation_asset.checkTranslation(loc_name_key, englishName);

	public override string name
	{
		get
		{
			if (!base.show_exact)
			{
				return base.localisation_asset.checkTranslation(loc_name_key, englishName);
			}
			return selected_role_clue.getName();
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
			return selected_role_clue.getDescription();
		}
	}

	public override List<CaseType> event_case_type => new List<CaseType>
	{
		CaseType.CLOCK,
		CaseType.DOCKS,
		CaseType.CASINO
	};

	protected override List<string> english_event_quote_text => new List<string> { "This one's got talent, we could use them." };

	private string loc_name_key => $"{event_type} [name]";

	private string loc_desc_key => $"{event_type} [desc]";

	public static Maybe<LeadEvent> tryCreateEvent(System.Random _rng, Lead _lead, List<LeadEvent> _events, bool _show_exact = false)
	{
		try
		{
			AddSingleRandomRoleWithAbilityEvent addSingleRandomRoleWithAbilityEvent = new AddSingleRandomRoleWithAbilityEvent(_rng, _lead, _events, _show_exact);
			if (addSingleRandomRoleWithAbilityEvent.isValidForCurrentLead(_lead))
			{
				return ((LeadEvent)addSingleRandomRoleWithAbilityEvent).maybe();
			}
			return new Maybe<LeadEvent>();
		}
		catch
		{
			return new Maybe<LeadEvent>();
		}
	}

	public AddSingleRandomRoleWithAbilityEvent()
		: base(null, null, _show_exact: false)
	{
	}

	public AddSingleRandomRoleWithAbilityEvent(System.Random _rng, Lead _lead, List<LeadEvent> _events, bool _show_exact)
		: base(_rng, _lead, _show_exact)
	{
		Maybe<RoleClue> maybe = LeadHelper.createRoleClue(_lead, _events, _rng, (Roles _r) => _r.createEmptyRole().getGenerationConstraints().isOfMarker(RoleGenerationMarkers.HAS_ABILITY), false, ClueTypes.ROLE_IN_PLAY);
		if (!maybe.is_some)
		{
			initialisation_failed = true;
		}
		else
		{
			selected_role_clue = maybe.value;
		}
	}

	public AddSingleRandomRoleWithAbilityEvent(LeadEventSaveData _save, Lead _lead, System.Random _rng)
		: base(_save, _lead, _rng)
	{
		try
		{
			selected_role_clue = Clue.load(JsonUtility.FromJson<ClueSaveData>(_save.data)) as RoleClue;
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load lead event {event_type}!\nData: {_save.data}\nError: {arg}");
		}
	}

	private string englishName()
	{
		return "APPROVE SKILLED ROLE SURVEILLANCE";
	}

	private string englishDesc()
	{
		return "A random " + Keywords.ROLE.toString() + " with an " + TextHelper.ability_on_sprite_link + " " + Keywords.ABILITY.toString() + " will always be " + Keywords.IN_PLAY.toString() + ".";
	}

	public override void helpFacade(LeadEventFacade _facade)
	{
		if (base.show_exact)
		{
			_facade.setIconAsRole(selected_role);
		}
		else
		{
			_facade.setStamp(StampType.ROLE_IN_PLAY);
		}
	}

	public override List<StampReference> getStamps(Lead _lead)
	{
		return new List<StampReference>
		{
			new StampReference(StampType.ROLE_IN_PLAY, selected_role)
		};
	}

	public override List<Clue> clues(Lead _lead)
	{
		return _lead.clues.add(selected_role_clue);
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
		return JsonUtility.ToJson(new ClueSaveData(selected_role_clue));
	}

	public bool canRoleAppear(Roles _role)
	{
		return _role != selected_role;
	}
}
