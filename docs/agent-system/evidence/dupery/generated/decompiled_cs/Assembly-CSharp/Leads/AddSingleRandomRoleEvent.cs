using System;
using System.Collections.Generic;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using Localisation;
using Save;
using UnityEngine;

namespace Leads;

public class AddSingleRandomRoleEvent : LeadEvent, IRoleFilterEvent
{
	private RoleClue selected_role_clue;

	public override LeadEventType event_type => LeadEventType.ADD_ROLE_CLUE;

	private Roles selected_role => selected_role_clue.role_in_focus;

	private ClueTypes type => selected_role_clue.clue_type;

	public bool initialisation_failed { get; private set; }

	public override string empty_name => base.localisation_asset.checkTranslation(loc_empty_name_key, englishEmptyName, _check_keywords: false);

	public override string name
	{
		get
		{
			if (base.show_exact)
			{
				return selected_role_clue.getName().ToUpper();
			}
			return type switch
			{
				ClueTypes.ROLE_IN_PLAY => base.localisation_asset.checkTranslation(loc_name_ip_key, englishNameIP, _check_keywords: false), 
				ClueTypes.ROLE_NOT_IN_PLAY => base.localisation_asset.checkTranslation(loc_name_nip_key, englishNameNIP, _check_keywords: false), 
				ClueTypes.ROLE_SUSPECTED => base.localisation_asset.checkTranslation(loc_name_sus_key, englishNameSus, _check_keywords: false), 
				_ => throw new ArgumentException($"No name set up for clue type {type}!"), 
			};
		}
	}

	public override string description
	{
		get
		{
			if (base.show_exact)
			{
				return selected_role_clue.getDescription();
			}
			return type switch
			{
				ClueTypes.ROLE_IN_PLAY => base.localisation_asset.checkTranslation(loc_desc_ip_key, englishDescIP), 
				ClueTypes.ROLE_NOT_IN_PLAY => base.localisation_asset.checkTranslation(loc_desc_nip_key, englishDescNIP), 
				ClueTypes.ROLE_SUSPECTED => base.localisation_asset.checkTranslation(loc_desc_sus_key, englishDescSus), 
				_ => throw new ArgumentException($"No name set up for clue type {type}!"), 
			};
		}
	}

	public override List<CaseType> event_case_type => new List<CaseType>
	{
		CaseType.CLOCK,
		CaseType.DOCKS,
		CaseType.CASINO
	};

	protected override List<string> english_event_quote_text => type switch
	{
		ClueTypes.ROLE_IN_PLAY => english_ip_quotes, 
		ClueTypes.ROLE_SUSPECTED => english_sus_quotes, 
		ClueTypes.ROLE_NOT_IN_PLAY => english_nip_quotes, 
		_ => throw new NotImplementedException("Unknown type!"), 
	};

	private List<string> english_ip_quotes => new List<string> { "I'm not sure how legal this is detective, but we might need someone on our side." };

	private List<string> english_sus_quotes => new List<string> { "I've seen them around this area before, why are they not a suspect?" };

	private List<string> english_nip_quotes => new List<string> { "Detective, this one's got an alibi, we have to rule them out." };

	private string loc_empty_name_key => $"{event_type} [empty_name]";

	private string loc_name_ip_key => $"{event_type} [name_ip]";

	private string loc_name_nip_key => $"{event_type} [name_nip]";

	private string loc_name_sus_key => $"{event_type} [name_sus]";

	private string loc_desc_ip_key => $"{event_type} [desc_ip]";

	private string loc_desc_nip_key => $"{event_type} [desc_nip]";

	private string loc_desc_sus_key => $"{event_type} [desc_sus]";

	public AddSingleRandomRoleEvent()
		: base(null, null, _show_exact: false)
	{
	}

	public AddSingleRandomRoleEvent(Lead _lead, List<LeadEvent> _events, System.Random _rng, bool _show_exact, bool _allow_traitors)
		: this(_lead, _events, _rng, _show_exact, new List<ClueTypes>(), _allow_traitors ? new RoleClassifications[0] : new RoleClassifications[3]
		{
			RoleClassifications.INNOCENT,
			RoleClassifications.MEDDLER,
			RoleClassifications.UNDERLING
		})
	{
	}

	public AddSingleRandomRoleEvent(Lead _lead, List<LeadEvent> _events, System.Random _rng, bool _show_exact, List<ClueTypes> _types, params RoleClassifications[] _allowed)
		: base(_rng, _lead, _show_exact)
	{
		Maybe<RoleClue> maybe = LeadHelper.createRoleClue(_lead, _events, _rng, _types, _allowed);
		if (!maybe.is_some)
		{
			initialisation_failed = true;
		}
		else
		{
			selected_role_clue = maybe.value;
		}
	}

	public AddSingleRandomRoleEvent(LeadEventSaveData _save, Lead _lead, System.Random _rng)
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

	private string englishEmptyName()
	{
		return "ADD ROLE CLUE";
	}

	private string englishNameIP()
	{
		return "APPROVE ROLE SURVEILLANCE";
	}

	private string englishNameNIP()
	{
		return "CONFIRM ROLE ALIBI";
	}

	private string englishNameSus()
	{
		return "DISCOVER NEW SUSPECT";
	}

	private string englishDescIP()
	{
		return "A random " + Keywords.ROLE.toString() + " will always be " + Keywords.IN_PLAY.toString();
	}

	private string englishDescNIP()
	{
		return "A random " + Keywords.ROLE.toString() + " will never be " + Keywords.SUSPECTED.toString();
	}

	private string englishDescSus()
	{
		return "A random " + Keywords.ROLE.toString() + " will always be " + Keywords.SUSPECTED.toString();
	}

	public override void helpFacade(LeadEventFacade _facade)
	{
		if (base.show_exact)
		{
			_facade.setIconAsRole(selected_role);
		}
		else
		{
			_facade.setStamp(type.toStampType());
		}
	}

	public override List<StampReference> getStamps(Lead _lead)
	{
		return new List<StampReference>
		{
			new StampReference(type.toStampType(), selected_role)
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

	private string getQuoteKey(ClueTypes _type, int _quote_nb)
	{
		return _type switch
		{
			ClueTypes.ROLE_IN_PLAY => getIPQuoteKey(_quote_nb), 
			ClueTypes.ROLE_NOT_IN_PLAY => getNIPQuoteKey(_quote_nb), 
			ClueTypes.ROLE_SUSPECTED => getSusQuoteKey(_quote_nb), 
			_ => throw new NotImplementedException("Unknown type!"), 
		};
	}

	private string getIPQuoteKey(int _quote_nb)
	{
		return $"{event_type} [ip_quote_{_quote_nb}]";
	}

	private string getNIPQuoteKey(int _quote_nb)
	{
		return $"{event_type} [nip_quote_{_quote_nb}]";
	}

	private string getSusQuoteKey(int _quote_nb)
	{
		return $"{event_type} [sus_quote_{_quote_nb}]";
	}

	protected override string getEventQuoteLocKey(int _quote_nb)
	{
		return getQuoteKey(type, _quote_nb);
	}
}
