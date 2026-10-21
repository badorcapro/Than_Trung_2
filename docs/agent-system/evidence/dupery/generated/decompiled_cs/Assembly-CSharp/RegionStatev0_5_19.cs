using System;
using System.Collections.Generic;
using GRGLib.Generic;
using GRGLib.Maybe;
using Save;

public abstract class RegionStatev0_5_19
{
	public Regions region;

	protected List<CaseQuirks> vetoed_quirks = new List<CaseQuirks>();

	public List<CaseQuirks> case_quirks { get; protected set; } = new List<CaseQuirks>();

	public abstract CaseType case_type { get; }

	public abstract float region_progress_01 { get; }

	protected abstract MinMaxFloat start_difficulty { get; }

	protected abstract MinMaxFloat end_difficulty { get; }

	protected virtual float case_difficulty_variency => 0.2f;

	protected MinMaxFloat difficulty_increase => end_difficulty - start_difficulty;

	protected MinMaxFloat current_difficulty => start_difficulty + difficulty_increase * region_progress_01;

	public RegionStatev0_5_19(Regions _region)
	{
		region = _region;
	}

	public RegionStatev0_5_19(RegionSaveDatav0_5_19 _save)
	{
		region = _save.region;
		case_quirks = new List<CaseQuirks>();
		vetoed_quirks = new List<CaseQuirks>();
		foreach (CaseQuirks quirk in _save.quirks)
		{
			addQuirk(quirk);
		}
	}

	public virtual float fetchCaseDifficulty(int _case, Random _rng, bool _final_case = false)
	{
		if (!_final_case)
		{
			return current_difficulty.get(_rng) + (float)_case * case_difficulty_variency;
		}
		return end_difficulty.max + case_difficulty_variency * 2f;
	}

	public virtual void setQuirks(List<CaseQuirks> _quirks)
	{
		case_quirks.Clear();
		vetoed_quirks.Clear();
		_quirks.ForEach(addQuirk);
	}

	protected virtual void addQuirk(CaseQuirks _quirk)
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

	public abstract CaseReward createRewardForCase(float _diff, Random _random, bool _is_final_case, CaseBuildData _case_build, int _case_option);

	public abstract bool isFinalCase();

	public abstract bool onCaseSolve(GameState _state, CaseActionPayload _payload);

	public virtual void onTutorialSolve()
	{
		case_quirks.Clear();
		vetoed_quirks.Clear();
	}

	public abstract string getUniqueData();
}
