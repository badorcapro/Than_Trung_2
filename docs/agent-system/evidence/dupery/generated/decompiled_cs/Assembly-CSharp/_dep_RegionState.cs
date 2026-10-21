using System.Collections.Generic;
using GRGLib.Maybe;
using Nodes.Logic;
using Save;

public abstract class _dep_RegionState
{
	public Regions region;

	protected List<CaseQuirks> vetoed_quirks = new List<CaseQuirks>();

	protected RegionDataGraph region_graph;

	public RegionDataGraphNavigator region_navigator;

	public RegionEventsType wanted_event;

	public List<CaseQuirks> case_quirks { get; protected set; } = new List<CaseQuirks>();

	public abstract CaseType case_type { get; }

	public _dep_RegionState(RegionDataGraph _graph)
	{
		Regions regions = _graph.region;
		RegionDataGraphNavigator regionDataGraphNavigator = new RegionDataGraphNavigator(_graph.fetchStartNode());
		region = regions;
		region_graph = _graph;
		region_navigator = regionDataGraphNavigator;
	}

	public _dep_RegionState(_dep_RegionSaveData _save_data)
	{
		region = _save_data.region;
		setQuirks(_save_data.quirks);
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

	public abstract void onCaseSolve(GameState _state, CaseActionPayload _payload);

	public virtual void onTutorialSolve()
	{
		case_quirks.Clear();
		vetoed_quirks.Clear();
	}

	public abstract string getUniqueData();
}
