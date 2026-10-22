using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Localisation;
using Save;
using UnityEngine;

namespace Leads;

public class IncreaseBoardSizeEvent : LeadEvent
{
	private int cases_remaining;

	public override LeadEventType event_type => LeadEventType.INCREASE_BOARD_SIZE;

	public override string empty_name => name;

	public override string name => base.localisation_asset.checkTranslation(loc_name_key, englishName, _check_keywords: false);

	public override string description => base.localisation_asset.checkTranslation(loc_desc_key, englishDesc);

	public override List<CaseType> event_case_type => new List<CaseType>
	{
		CaseType.CLOCK,
		CaseType.DOCKS,
		CaseType.CASINO
	};

	protected override List<string> english_event_quote_text => new List<string> { "The Syndicate's reach has grown..." };

	private string loc_name_key => $"{event_type} [name]";

	private string loc_desc_key => $"{event_type} [desc]";

	public static Maybe<LeadEvent> tryCreateEvent(System.Random _rng, Lead _lead, bool _show_exact = false)
	{
		try
		{
			IncreaseBoardSizeEvent increaseBoardSizeEvent = new IncreaseBoardSizeEvent(_rng, _lead, _show_exact);
			if (increaseBoardSizeEvent.isValidForCurrentLead(_lead))
			{
				return ((LeadEvent)increaseBoardSizeEvent).maybe();
			}
			return new Maybe<LeadEvent>();
		}
		catch
		{
			return new Maybe<LeadEvent>();
		}
	}

	public IncreaseBoardSizeEvent()
		: base(null, null, _show_exact: false)
	{
	}

	public IncreaseBoardSizeEvent(System.Random _rng, Lead _lead, bool _show_exact)
		: base(_rng, _lead, _show_exact)
	{
		cases_remaining = _lead.max_case - _lead.current_case;
	}

	public IncreaseBoardSizeEvent(LeadEventSaveData _save, Lead _lead, System.Random _rng)
		: base(_save, _lead, _rng)
	{
		try
		{
			cases_remaining = int.Parse(_save.data);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load lead event {event_type}!\nData: {_save.data}\nError: {arg}");
			cases_remaining = 0;
		}
	}

	private string englishName()
	{
		return "EXPAND JURISDICTION";
	}

	private string englishDesc()
	{
		return "The remaining " + TextHelper.cases + " of this " + Keywords.LEAD.toString() + " will now be on a larger grid.";
	}

	public override List<StampReference> getStamps(Lead _lead)
	{
		return new List<StampReference>
		{
			new StampReference(StampType.INCREASE_BOARD_SIZE)
		};
	}

	public override Maybe<List<Vector2Int>> gridSizeOverrides(Lead _lead)
	{
		return _lead.grid_sizes.Select((Vector2Int _s) => _s + new Vector2Int(1, 1)).ToList().maybe();
	}

	public override bool isValidForCurrentLead(Lead _lead)
	{
		if (_lead.current_board_size.x < 5)
		{
			return _lead.current_board_size.y < 5;
		}
		return false;
	}

	public override void helpFacade(LeadEventFacade _facade)
	{
		_facade.setStamp(StampType.INCREASE_BOARD_SIZE);
	}

	protected override string getSaveData()
	{
		return cases_remaining.ToString();
	}
}
