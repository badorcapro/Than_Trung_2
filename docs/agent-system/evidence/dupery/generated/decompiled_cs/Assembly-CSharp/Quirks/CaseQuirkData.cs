using System;
using System.Collections.Generic;
using System.Linq;
using CaseCreation;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using GRGLocalisation;
using Leads;
using Localisation;
using UnityEngine;

namespace Quirks;

public abstract class CaseQuirkData : IAmLocalised
{
	public abstract CaseQuirks quirk_type { get; }

	public virtual int execution_order => (int)quirk_type;

	public string name => localisation_asset.checkTranslation(loc_name_key, () => english_name);

	public string description => localisation_asset.checkTranslation(loc_desc_key, () => english_description);

	public virtual string description_white => description;

	public string extra_description
	{
		get
		{
			if (!(english_extra_description == ""))
			{
				return localisation_asset.checkTranslation(loc_extra_key, () => english_extra_description);
			}
			return "";
		}
	}

	protected abstract string english_name { get; }

	protected abstract string english_description { get; }

	protected virtual string english_extra_description => "";

	public virtual string english_clue_prefix => "";

	public virtual string english_clue_suffix => "";

	public virtual string credit => "";

	public bool quirk_completed { get; protected set; }

	public virtual bool is_marker_quirk => false;

	public virtual bool is_suspect_addition_quirk => false;

	public virtual bool is_suspect_removal_quirk => false;

	public virtual bool is_ratio_modification_quirk => false;

	public virtual bool is_suspects_ratio_quirk => false;

	public virtual bool is_board_placement_quirk => false;

	public virtual bool is_visual_ratio_quirk => false;

	public virtual bool is_visual_suspect_list_quirk => false;

	public virtual bool is_case_start_quirk => false;

	public virtual bool is_case_load_quirk => false;

	public virtual bool is_investigate_quirk => false;

	public virtual bool is_arrest_quirk => false;

	public virtual bool is_kill_quirk => false;

	public virtual bool is_snapshot_quirk => false;

	public virtual bool is_case_solve_quirk => false;

	public virtual bool is_time_quirk => false;

	public virtual bool is_card_reaction_quirk => false;

	public virtual bool is_chips_spent_quirk => false;

	public virtual bool is_dredged_quirk => false;

	private AssetKey localisation_asset => LocalisationHelper.quirk_asset;

	protected string loc_name_key => $"{quirk_type} [name]";

	protected string loc_desc_key => $"{quirk_type} [desc]";

	protected string loc_extra_key => $"{quirk_type} [extra]";

	public virtual bool isCompatible(CaseType _case_type)
	{
		return true;
	}

	public virtual bool canAdd(List<Roles> _available_roles, List<CaseQuirks> _in_play_quirks, CaseType _case_type)
	{
		return isCompatible(_case_type);
	}

	public virtual bool isValidForClue(List<CaseQuirks> _quirks, List<Roles> _unforced, Dictionary<ClueTypes, List<Roles>> _forced)
	{
		return true;
	}

	public virtual List<Roles> filterRoleForClues(List<Roles> _roles, ClueTypes _type, List<Roles> _unforced, Dictionary<ClueTypes, List<Roles>> _forced)
	{
		return _roles;
	}

	protected bool canRoleAppearInPlay(Roles _role, List<Roles> _unforced, Dictionary<ClueTypes, List<Roles>> _forced)
	{
		if (!_unforced.Contains(_role) && !_forced.getOrCreate(ClueTypes.ROLE_IN_PLAY, () => new List<Roles>()).Contains(_role))
		{
			return _forced.getOrCreate(ClueTypes.ROLE_SUSPECTED, () => new List<Roles>()).Contains(_role);
		}
		return true;
	}

	protected bool isRoleOfMarkerAlwaysSuspected(RoleGenerationMarkers _marker, Dictionary<ClueTypes, List<Roles>> _forced)
	{
		return isRoleAlwaysSuspected((Roles _r) => _r.createEmptyRole().generation_constraint.isOfMarker(_marker), _forced);
	}

	protected bool isRoleAlwaysSuspected(Func<Roles, bool> _validation, Dictionary<ClueTypes, List<Roles>> _forced)
	{
		if (!_forced.getOrCreate(ClueTypes.ROLE_IN_PLAY, () => new List<Roles>()).Any(_validation))
		{
			return _forced.getOrCreate(ClueTypes.ROLE_SUSPECTED, () => new List<Roles>()).Any(_validation);
		}
		return true;
	}

	public virtual Maybe<Roles> onSuspectAddition(Roles _adding, bool _force, List<Roles> _from)
	{
		if (!is_suspect_addition_quirk)
		{
			return new Maybe<Roles>();
		}
		Debug.LogError($"Quirk {quirk_type} is marked as a suspect addition quirk but onSuspectAddition is not overriden!");
		return new Maybe<Roles>();
	}

	public virtual Maybe<Roles> onSuspectRemoval(Roles _removal, bool _force, List<Roles> _from)
	{
		if (!is_suspect_removal_quirk)
		{
			return new Maybe<Roles>();
		}
		Debug.LogError($"Quirk {quirk_type} is marked as a suspect removal quirk but onSuspectRemoval is not overriden!");
		return new Maybe<Roles>();
	}

	public virtual Dictionary<RoleClassifications, int> onRatioModification(Dictionary<RoleClassifications, int> _modified, Dictionary<RoleClassifications, int> _ratio, List<Roles> _suspect_list, System.Random _rng)
	{
		if (!is_ratio_modification_quirk)
		{
			return _modified;
		}
		Debug.LogError($"Quirk {quirk_type} is marked as a ratio modification quirk but onRatioModification is not overriden!");
		return _modified;
	}

	public virtual Dictionary<RoleClassifications, int> onSuspectRatio(Dictionary<RoleClassifications, int> _needed_extras, Dictionary<RoleClassifications, int> _ratio, System.Random _rng)
	{
		if (!is_suspects_ratio_quirk)
		{
			return _needed_extras;
		}
		Debug.LogError($"Quirk {quirk_type} is marked as a suspects ratio modification quirk but onSuspectRatio is not overriden!");
		return _needed_extras;
	}

	public virtual Dictionary<Roles, List<IPositioningGenerationConstraint>> onBoardPlacement(Dictionary<Roles, List<IPositioningGenerationConstraint>> _constraints, List<Roles> _in_play_roles, System.Random _rng)
	{
		if (!is_board_placement_quirk)
		{
			return new Dictionary<Roles, List<IPositioningGenerationConstraint>>();
		}
		Debug.LogError($"Quirk {quirk_type} is marked as a board placement quirk but onBoardPlacement is not overriden!");
		return new Dictionary<Roles, List<IPositioningGenerationConstraint>>();
	}

	public virtual Dictionary<RoleClassifications, int> onVisualRatioCreation(Dictionary<RoleClassifications, int> _visual, Dictionary<RoleClassifications, int> _real, System.Random _rng)
	{
		if (!is_visual_ratio_quirk)
		{
			return _visual;
		}
		Debug.LogError($"Quirk {quirk_type} is marked as a visual ratio quirk but onVisualRatioCreation is not overriden!");
		return _visual;
	}

	public virtual HashSet<RoleData> onVisualSuspectListCreation(HashSet<RoleData> _visual, HashSet<RoleData> _real, System.Random _rng)
	{
		if (!is_visual_suspect_list_quirk)
		{
			return _visual;
		}
		Debug.LogError($"Quirk {quirk_type} is marked as a suspect list quirk but onVisualSuspectListCreation is not overriden!");
		return _visual;
	}

	public virtual Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onCaseStart(Case _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, System.Random _rng)
	{
		if (!is_case_start_quirk)
		{
			return _board;
		}
		Debug.LogError($"Quirk {quirk_type} is marked as a case start quirk but onCaseStart is not overriden!");
		return _board;
	}

	public virtual void onCaseLoaded(Case _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, System.Random _rng)
	{
		if (is_case_load_quirk)
		{
			Debug.LogError($"Quirk {quirk_type} is marked as a case load quirk but onCaseLoaded is not overriden!");
		}
	}

	public virtual void onInvestigate(Case _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, int _address, System.Random _rng)
	{
		if (is_investigate_quirk)
		{
			Debug.LogError($"Quirk {quirk_type} is marked as a investigate quirk but onInvestigate is not overriden!");
		}
	}

	public virtual void onArrest(Case _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, RoleData _arrested_role, System.Random _rng)
	{
		if (is_arrest_quirk)
		{
			Debug.LogError($"Quirk {quirk_type} is marked as a arrest quirk but onArrest is not overriden!");
		}
	}

	public virtual void onKill(Case _case, RoleData _killed_role, bool _was_alive, System.Random _rng)
	{
		if (is_kill_quirk)
		{
			Debug.LogError($"Quirk {quirk_type} is marked as a kill quirk but onKill is not overriden!");
		}
	}

	public virtual CaseSnapshot onSnapshot(Case _case, CaseSnapshot _snap, System.Random _rng)
	{
		if (!is_snapshot_quirk)
		{
			return _snap;
		}
		Debug.LogError($"Quirk {quirk_type} is marked as a snapshot quirk but onSnapshot is not overriden!");
		return _snap;
	}

	public virtual CaseReward onCaseSolved(CaseReward _reward, GameState _state, CaseSnapshot _snapshot, CaseActionPayload _payload, System.Random _rng)
	{
		if (!is_case_solve_quirk)
		{
			return _reward;
		}
		Debug.LogError($"Quirk {quirk_type} is marked as a case solved quirk but onCaseSolved is not overriden!");
		return _reward;
	}

	public virtual void onTime(ClockCase _case, int _current_time, System.Random _rng)
	{
		if (is_time_quirk)
		{
			Debug.LogError($"Quirk {quirk_type} is marked as a time quirk but onTime is not overriden!");
		}
	}

	public virtual void onCardChange(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CasinoCase _case, List<CasinoCard> _discarded, List<CasinoCard> _new_cards, System.Random _rng)
	{
		if (is_card_reaction_quirk)
		{
			Debug.LogError($"Quirk {quirk_type} is marked as a card reaction quirk but onCardChange is not overriden!");
		}
	}

	public virtual void onChipsSpent(CasinoCase _case, int _chips_diff, System.Random _rng)
	{
		if (is_chips_spent_quirk)
		{
			Debug.LogError($"Quirk {quirk_type} is marked as a chips spent quirk but onChipsSpent is not overriden!");
		}
	}

	public virtual void onDredgeRole(DocksCase _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, RoleData _dredged, Maybe<RoleData> _dredger, System.Random _rng)
	{
		if (is_dredged_quirk)
		{
			Debug.LogError($"Quirk {quirk_type} is marked as a dredged quirk but onDredgeRole is not overriden!");
		}
	}
}
