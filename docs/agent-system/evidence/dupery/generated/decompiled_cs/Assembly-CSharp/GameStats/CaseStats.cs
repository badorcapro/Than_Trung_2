using System;
using System.Collections.Generic;
using GRGLib.Extensions.Collections;
using GRGLib.Serializable;
using Save;

namespace GameStats;

public abstract class CaseStats
{
	public Dictionary<Roles, int> investigated = new Dictionary<Roles, int>();

	public Dictionary<Roles, int> arrested = new Dictionary<Roles, int>();

	public Dictionary<Alignments, int> arrested_align = new Dictionary<Alignments, int>();

	public Dictionary<Roles, int> died = new Dictionary<Roles, int>();

	public Dictionary<Alignments, int> died_align = new Dictionary<Alignments, int>();

	public Dictionary<Roles, int> ability_used = new Dictionary<Roles, int>();

	public static CaseStats createEmpty(CaseType _case_type)
	{
		return _case_type switch
		{
			CaseType.CLOCK => new OfficeCaseStats(), 
			CaseType.DOCKS => new DocksCaseStats(), 
			CaseType.CASINO => new CasinoCaseStats(), 
			CaseType.BACK_ALLEYS => new BackAlleyCaseStats(), 
			_ => throw new ArgumentException($"No case stats factory set up for case type {_case_type}!"), 
		};
	}

	public static CaseStats load(CaseStatsSaveData _save, CaseType _case_type)
	{
		return _case_type switch
		{
			CaseType.CLOCK => new OfficeCaseStats(_save), 
			CaseType.DOCKS => new DocksCaseStats(_save), 
			CaseType.CASINO => new CasinoCaseStats(_save), 
			CaseType.BACK_ALLEYS => new BackAlleyCaseStats(_save), 
			_ => throw new ArgumentException($"No case stats factory set up for case type {_case_type}!"), 
		};
	}

	public CaseStats()
	{
	}

	public CaseStats(CaseStatsSaveData _save)
	{
		investigated = _save.investigated.unserialize();
		arrested = _save.arrested.unserialize();
		arrested_align = _save.arrested_align.unserialize();
		died = _save.died.unserialize();
		died_align = _save.died_align.unserialize();
		ability_used = _save.ability_used.unserialize();
	}

	public CaseStats addStats(CaseStats _stats)
	{
		investigated.increaseOrCreateRange(_stats.investigated);
		arrested.increaseOrCreateRange(_stats.arrested);
		arrested_align.increaseOrCreateRange(_stats.arrested_align);
		died.increaseOrCreateRange(_stats.died);
		died_align.increaseOrCreateRange(_stats.died_align);
		ability_used.increaseOrCreateRange(_stats.ability_used);
		addRegionStats(_stats);
		return this;
	}

	protected abstract void addRegionStats(CaseStats _stats);

	public abstract string getRegionSaveData();
}
