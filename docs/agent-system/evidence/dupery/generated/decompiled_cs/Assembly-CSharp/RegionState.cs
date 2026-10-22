using System.Collections.Generic;
using GRGLib.Maybe;
using Leads;
using Save;
using UnityEngine;

public class RegionState
{
	public Regions region;

	protected List<CaseQuirks> vetoed_quirks = new List<CaseQuirks>();

	public List<CaseQuirks> case_quirks { get; protected set; } = new List<CaseQuirks>();

	public int region_progress { get; protected set; }

	public Maybe<Lead> current_lead { get; protected set; } = new Maybe<Lead>();

	public static Maybe<RegionState> load(RegionSaveData _save)
	{
		switch (_save.region)
		{
		case Regions.OFFICE:
			return new RegionState(_save).maybe();
		case Regions.NONE:
			return new Maybe<RegionState>();
		default:
			Debug.LogError($"No load function set up for region save data of type {_save.region}!");
			return new RegionState(_save).maybe();
		}
	}

	public RegionState(Regions _region)
	{
		region = _region;
	}

	public RegionState(RegionSaveData _save)
	{
		region = _save.region;
		setQuirks(_save.case_quirks);
		region_progress = _save.region_progress;
		current_lead = _save.current_lead.fmap((LeadSaveData _s) => Lead.load(_s));
	}

	public virtual void setQuirks(List<CaseQuirks> _quirks)
	{
		case_quirks.Clear();
		vetoed_quirks.Clear();
		_quirks.ForEach(addQuirk);
	}

	public virtual void addQuirk(CaseQuirks _quirk)
	{
		case_quirks.Add(_quirk);
		Maybe<List<CaseQuirks>> quirkVetos = _quirk.getQuirkVetos();
		if (quirkVetos.is_some)
		{
			vetoed_quirks.AddRange(quirkVetos.value);
		}
	}

	public virtual bool allowedQuirk(CaseQuirks _quirk)
	{
		if (case_quirks.Contains(_quirk))
		{
			return false;
		}
		return !vetoed_quirks.Contains(_quirk);
	}

	public void startLead(GameState _state, Lead _lead)
	{
		current_lead = _lead.maybe();
	}

	public void endCurrentLead(GameState _state)
	{
		if (!current_lead.is_some)
		{
			Debug.LogError("Trying to end lead that does not exist!");
			return;
		}
		Lead value = current_lead.value;
		region_progress = 100;
		onLeadEnd(_state, value);
		current_lead = new Maybe<Lead>();
	}

	protected virtual void onLeadEnd(GameState _state, Lead _lead)
	{
	}

	public float leadBaseDifficulty()
	{
		if (region == Regions.OFFICE)
		{
			return (float)region_progress * 0.01f * 0.4f;
		}
		Debug.LogError($"No difficulty function set up for region {region}!");
		return (float)region_progress * 0.01f * 0.4f;
	}

	public virtual void onTutorialSolve()
	{
		case_quirks.Clear();
		vetoed_quirks.Clear();
	}

	public virtual string getUniqueData()
	{
		return "";
	}
}
