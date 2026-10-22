using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLib.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

namespace Leads;

public abstract class Lead
{
	public const int max_clues = 10;

	public abstract CaseType case_type { get; }

	public List<Roles> lead_roles { get; protected set; } = new List<Roles>();

	public List<Vector2Int> grid_sizes { get; protected set; } = new List<Vector2Int>();

	public Vector2Int current_board_size
	{
		get
		{
			if (grid_sizes.Count != 1)
			{
				return grid_sizes[current_case];
			}
			return grid_sizes[0];
		}
	}

	protected virtual MinMaxInt case_address_size => new MinMaxInt(Mathf.Max(6, current_board_size.x * current_board_size.y / 2), current_board_size.x * current_board_size.y - 1);

	public MinMaxFloat lead_difficulty { get; private set; } = new MinMaxFloat(0.25f, 0.75f);

	public virtual float case_difficulty => lead_difficulty.estimate((float)current_case / (float)Mathf.Max(max_case - 1, 1));

	public int max_case { get; private set; } = -1;

	public virtual bool is_lead_completed => current_case >= max_case;

	public int current_case { get; protected set; } = -1;

	public RoleSetInfoStruct prime_suspect_set { get; private set; }

	public List<Clue> clues { get; private set; } = new List<Clue>();

	public List<CaseQuirks> clues_as_quirks => clues.whereSelect((Clue _c) => _c is QuirkClue, (Clue _c) => (_c as QuirkClue).quirk_in_focus);

	public List<StampInfo> stamps { get; private set; } = new List<StampInfo>();

	public int forced_end_traitor_cases { get; protected set; } = 1;

	public bool can_modify => current_case == 0;

	public static Lead load(LeadSaveData _save)
	{
		return _save.case_type switch
		{
			CaseType.CLOCK => new OfficeLead(_save), 
			CaseType.CASINO => new CasinoLead(_save), 
			CaseType.DOCKS => new DocksLead(_save), 
			(CaseType)(-1) => new CaseToCaseLead(_save), 
			_ => throw new ArgumentException($"No load function set up for Lead of case type {_save.case_type}!"), 
		};
	}

	public Lead(List<Roles> _available, List<Vector2Int> _grid_sizes, MinMaxFloat _difficulty, int _max_case, int _current_case, RoleSetInfoStruct _prime_suspect_set, List<Clue> _clues)
	{
		lead_roles = _available;
		grid_sizes = _grid_sizes;
		lead_difficulty = _difficulty;
		max_case = _max_case;
		current_case = _current_case;
		prime_suspect_set = _prime_suspect_set;
		clues = _clues;
		if (_clues.Count > 10)
		{
			throw new ArgumentException("Clues must contain eight or less elements!");
		}
	}

	public Lead(List<Roles> _available, Vector2Int _grid_size, MinMaxFloat _difficulty, int _max_case, int _current_case, RoleSetInfoStruct _prime_suspect_set, List<Clue> _clues)
	{
		lead_roles = _available;
		grid_sizes = new List<Vector2Int> { _grid_size };
		lead_difficulty = _difficulty;
		max_case = _max_case;
		current_case = _current_case;
		prime_suspect_set = _prime_suspect_set;
		clues = _clues;
		if (_clues.Count > 10)
		{
			throw new ArgumentException("Clues must contain eight or less elements!");
		}
	}

	public Lead(List<Roles> _available, List<Vector2Int> _grid_sizes, MinMaxFloat _difficulty, int _max_case, RoleSetInfoStruct _prime_suspect_set)
		: this(_available, _grid_sizes, _difficulty, _max_case, 0, _prime_suspect_set, new List<Clue>())
	{
	}

	public Lead(List<Roles> _available, Vector2Int _grid_size, MinMaxFloat _difficulty, int _max_case, RoleSetInfoStruct _prime_suspect_set)
		: this(_available, _grid_size, _difficulty, _max_case, 0, _prime_suspect_set, new List<Clue>())
	{
	}

	public Lead(LeadSaveData _save)
	{
		lead_roles = _save.available_roles;
		grid_sizes = _save.grid_sizes.copy();
		lead_difficulty = _save.lead_difficulty;
		max_case = _save.max_case;
		current_case = _save.current_case;
		prime_suspect_set = _save.prime_suspect_set;
		clues = _save.clues.Select((ClueSaveData _s) => Clue.load(_s)).ToList();
		stamps = _save.stamp_info.copy();
	}

	public void updateClueList(List<Clue> _clues)
	{
		clues = _clues;
	}

	public void updateMaxCase(int _new_max)
	{
		max_case = _new_max;
	}

	public void updateGridSizes(List<Vector2Int> _grid_size)
	{
		grid_sizes = _grid_size;
	}

	public Lead applyEvent(LeadEvent _event)
	{
		return _event.apply(this);
	}

	public void applyStamp(StampInfo _stamp)
	{
		stamps.Add(_stamp);
	}

	public void fadeStamp(StampReference _ref)
	{
		Maybe<StampInfo> maybe = stamps.firstIfSome((StampInfo _s) => _s.stamp_reference.isSameAs(_ref) && !_s.faded);
		if (maybe.is_some)
		{
			maybe.value.faded = true;
		}
	}

	public List<Vector2Int> getGridSizes()
	{
		return grid_sizes;
	}

	public Maybe<Clue>[] getClueArray()
	{
		Maybe<Clue>[] array = new Maybe<Clue>[8]
		{
			new Maybe<Clue>(),
			new Maybe<Clue>(),
			new Maybe<Clue>(),
			new Maybe<Clue>(),
			new Maybe<Clue>(),
			new Maybe<Clue>(),
			new Maybe<Clue>(),
			new Maybe<Clue>()
		};
		for (int i = 0; i < clues.Count; i++)
		{
			array[i] = clues[i].maybe();
		}
		return array;
	}

	public void onCaseFinish(Case _case, CaseReward _reward)
	{
		applyReward(_case, _reward);
		current_case++;
	}

	public abstract Case createCase(GameState _state);

	public abstract Case createRandomCase(System.Random _rng);

	public abstract CaseReward createCaseReward(GameState _state);

	protected abstract void applyReward(Case _case, CaseReward _reward);

	public abstract string uniqueSaveData();

	public void setLeadLength(int _length)
	{
		if (can_modify)
		{
			max_case = _length;
		}
	}

	public void setBoardSize(Vector2Int _size, bool _force = false)
	{
		if (can_modify || _force)
		{
			grid_sizes = new List<Vector2Int> { _size };
		}
	}

	public void setDifficulty(MinMaxFloat _diff)
	{
		if (can_modify)
		{
			lead_difficulty = _diff;
		}
	}

	public void setPrimeSuspect(RoleSetInfoStruct _set)
	{
		if (can_modify)
		{
			prime_suspect_set = _set;
		}
	}

	public void setAvailableRoles(List<Roles> _roles)
	{
		if (can_modify)
		{
			lead_roles = _roles;
		}
	}

	public void setForcedEndTraitorCases(int _nb)
	{
		if (can_modify)
		{
			forced_end_traitor_cases = _nb;
		}
	}

	public void setStartingClues(List<CaseQuirks> _quirks)
	{
		clues = ((IEnumerable<CaseQuirks>)_quirks).Select((Func<CaseQuirks, Clue>)((CaseQuirks _q) => new QuirkClue(_immutable: true, _q))).ToList();
	}
}
