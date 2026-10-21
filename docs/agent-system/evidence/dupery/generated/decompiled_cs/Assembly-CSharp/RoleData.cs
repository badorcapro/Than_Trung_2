using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using GRGLocalisation;
using Localisation;
using Save;
using UnityEngine;

public abstract class RoleData : IAmLocalised
{
	private const string taint_temp_state_marker = "TNT";

	private const string obscure_temp_state_marker = "OBS";

	private const string obscure_immunity_temp_state_marker = "I_OBS";

	protected System.Random random;

	private Case m_case_ref;

	private Maybe<RoleDataInfo> m_role_info = new Maybe<RoleDataInfo>();

	protected bool forced_starting_disguise;

	protected Maybe<RoleData> disguise = new Maybe<RoleData>();

	protected Maybe<RoleData> true_self = new Maybe<RoleData>();

	protected Maybe<Roles> override_reveal_role = new Maybe<Roles>();

	private Maybe<RoleGenerationConstraints> m_constraint = new Maybe<RoleGenerationConstraints>();

	private Maybe<DisguiseCharacteristics> m_disguise_characteristics = new Maybe<DisguiseCharacteristics>();

	protected Maybe<RoleClassifications> override_visual_classification = new Maybe<RoleClassifications>();

	protected Maybe<Alignments> override_visual_alignments = new Maybe<Alignments>();

	protected bool ability_exhausted;

	protected static string loc_marker_1 = "{1}";

	protected static string loc_marker_2 = "{2}";

	protected static string loc_marker_3 = "{3}";

	protected static string loc_marker_4 = "{4}";

	protected static string loc_marker_5 = "{5}";

	protected Case case_ref
	{
		get
		{
			if (is_true_self)
			{
				return m_case_ref;
			}
			return true_self.value.case_ref;
		}
		set
		{
			if (is_true_self)
			{
				m_case_ref = value;
			}
		}
	}

	protected RoleDataInfo role_info
	{
		get
		{
			if (!is_true_self)
			{
				return true_self.value.role_info;
			}
			if (!m_role_info.is_some)
			{
				m_role_info = new RoleDataInfo(getStartingClassification(), getStartingAlignment()).maybe();
			}
			return m_role_info.value;
		}
	}

	protected RoleClassifications classification
	{
		get
		{
			return role_info.classification;
		}
		set
		{
			role_info.classification = value;
		}
	}

	protected Alignments alignment
	{
		get
		{
			return role_info.alignment;
		}
		set
		{
			role_info.alignment = value;
		}
	}

	protected int address
	{
		get
		{
			return role_info.address;
		}
		set
		{
			role_info.address = value;
		}
	}

	protected Vector2Int board_position
	{
		get
		{
			return role_info.board_position;
		}
		set
		{
			role_info.board_position = value;
		}
	}

	protected bool investigated
	{
		get
		{
			return role_info.investigated;
		}
		set
		{
			role_info.investigated = value;
		}
	}

	protected bool tainted
	{
		get
		{
			if (!is_true_self)
			{
				if (!role_info.tainted && !role_info.disguise_tainted)
				{
					return role_info.temp_states.Contains("#TNT");
				}
				return true;
			}
			if (!role_info.tainted)
			{
				return role_info.temp_states.Contains("#TNT");
			}
			return true;
		}
		set
		{
			if (is_true_self)
			{
				role_info.tainted = value;
			}
			else
			{
				role_info.disguise_tainted = value;
			}
		}
	}

	protected bool lying
	{
		get
		{
			return role_info.lying;
		}
		set
		{
			role_info.lying = value;
		}
	}

	protected bool arrested
	{
		get
		{
			return role_info.arrested;
		}
		set
		{
			role_info.arrested = value;
		}
	}

	protected bool dead
	{
		get
		{
			return role_info.dead;
		}
		set
		{
			role_info.dead = value;
		}
	}

	protected bool obscured
	{
		get
		{
			if (!getIsObscuredImmune())
			{
				if (!role_info.obscured)
				{
					return role_info.temp_states.Contains("#OBS");
				}
				return true;
			}
			return false;
		}
		set
		{
			role_info.obscured = value;
		}
	}

	protected bool hidden
	{
		get
		{
			return role_info.hidden;
		}
		set
		{
			role_info.hidden = value;
		}
	}

	protected string blocking_investigation
	{
		get
		{
			return role_info.blocking_investigation;
		}
		set
		{
			role_info.blocking_investigation = value;
		}
	}

	protected bool can_be_investigated => blocking_investigation == "";

	protected bool is_true_self => !true_self.is_some;

	public abstract Roles role { get; }

	public virtual int execution_order => (int)role;

	public virtual Roles reveal_as
	{
		get
		{
			if (!override_reveal_role.is_some)
			{
				return role;
			}
			return override_reveal_role.value;
		}
	}

	public string name => this.getRoleName();

	public string name_coloured => GameHandler.Text.getRoleNameColoured(this);

	public virtual string english_clue_prefix => clue_prefix_fallback;

	public virtual string english_clue_suffix => clue_suffix_fallback;

	protected string clue_prefix_fallback => "Mysterious";

	protected string clue_suffix_fallback => "of the Unknown";

	public abstract string english_name { get; }

	public string description => defaultFillDescription(this.getRoleDescription());

	public abstract string english_description { get; }

	public List<(DescriptionType, string)> extra_descriptions => this.getRoleExtraDescriptions(fillExtraDescription);

	public virtual List<(DescriptionType, string)> english_extra_descriptions => new List<(DescriptionType, string)>();

	public virtual string credits => "";

	public RoleGenerationConstraints generation_constraint
	{
		get
		{
			if (!m_constraint.is_some)
			{
				m_constraint = getGenerationConstraints().maybe();
			}
			return m_constraint.value;
		}
	}

	public virtual bool can_be_disguise => true;

	public abstract bool hasInfo { get; }

	protected Maybe<string> info_string
	{
		get
		{
			return role_info.info_string;
		}
		set
		{
			role_info.info_string = value;
		}
	}

	public virtual bool has_hover_focus => false;

	public virtual bool has_end_info_hover_focus => has_hover_focus;

	public virtual bool has_truth_hover_focus => false;

	public bool has_bad_info
	{
		get
		{
			if (!tainted)
			{
				return lying;
			}
			return true;
		}
	}

	public AssetKey localisation_asset => this.getAssetForRole();

	private static string loc_base_truth_key => "Default Truth";

	protected string loc_default_info_key => $"{role} [info]";

	protected string loc_default_truth_key => $"{role} [truth]";

	protected string loc_default_ability_prompt_key => $"{role} [abil]";

	public RoleData(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
	{
		random = _random;
		if (_true_self.is_some)
		{
			true_self = _true_self;
		}
		else
		{
			m_role_info = new RoleDataInfo(getStartingClassification(), getStartingAlignment(), _address, _board_position).maybe();
		}
	}

	public RoleData(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
	{
		random = _random;
		ability_exhausted = _save.ability_exhausted;
		if (_info.is_some)
		{
			m_role_info = new RoleDataInfo(_info.value).maybe();
		}
		if (_disguise.is_some)
		{
			disguise = _from_save(_disguise.value).maybe();
			disguise.value.setTrueSelfReference(this);
		}
		else
		{
			disguise = new Maybe<RoleData>();
		}
	}

	public RoleData(System.Random _random)
	{
		random = _random;
		m_role_info = new RoleDataInfo(getStartingClassification(), getStartingAlignment()).maybe();
	}

	public RoleData(System.Random _random, RoleData _true_self)
	{
		random = _random;
		true_self = _true_self.maybe();
	}

	public void setCaseRef(Case _case_ref)
	{
		case_ref = _case_ref;
	}

	protected virtual RoleClassifications getStartingClassification()
	{
		return role.getClassificationFromRoleType();
	}

	protected virtual Alignments getStartingAlignment()
	{
		return role.getAlignmentFromRoleType();
	}

	protected virtual bool isLiar()
	{
		return getStartingClassification().equalToAny(RoleClassifications.UNDERLING, RoleClassifications.TRAITOR);
	}

	public void setOverrideRevealRole(Roles _role)
	{
		override_reveal_role = _role.maybe();
	}

	public string getCaseDescription(CaseSnapshot _snapshot)
	{
		return fillDescription(this.getRoleDescription(), _snapshot);
	}

	protected virtual string fillDescription(string _description, CaseSnapshot _snapshot)
	{
		return defaultFillDescription(_description);
	}

	protected virtual string defaultFillDescription(string _description)
	{
		return _description;
	}

	protected virtual string fillExtraDescription(string _description, DescriptionType _type)
	{
		return _description;
	}

	public virtual RoleGenerationConstraints getGenerationConstraints()
	{
		if (!getHasAnyAbility())
		{
			return new RoleGenerationConstraints();
		}
		return new RoleGenerationConstraints(RoleGenerationMarkers.HAS_ABILITY);
	}

	public DisguiseCharacteristics getDisguiseCharacteristics(Case _case_ref)
	{
		if (!m_disguise_characteristics.is_some)
		{
			m_disguise_characteristics = generateDisguiseCharacteristics(_case_ref).maybe();
		}
		return m_disguise_characteristics.value;
	}

	protected virtual DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return new DisguiseCharacteristics();
	}

	public void setDisguiseCharacteristics(DisguiseCharacteristics _disguise)
	{
		if (m_disguise_characteristics.is_some)
		{
			Debug.LogError("Overriding disguise characteristics! Is this wanted? This most likely does nothing!");
		}
		m_disguise_characteristics = _disguise.maybe();
	}

	public abstract string generateInfoString(CaseSnapshot _snap);

	public virtual string getTruthString()
	{
		if (!disguise.is_some)
		{
			return "";
		}
		return checkTranslationDefaultAsset(loc_base_truth_key, () => getDefaultTruthEnglish(disguise.value.name), () => disguise.value.name).checkOption(disguise.value.getNamePrefixOption()) + "\n" + disguise.value.getTruthString();
	}

	private static string getDefaultTruthEnglish(string _data)
	{
		return "I pretended to be a{#/n} " + _data + ".";
	}

	public virtual bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		return false;
	}

	public virtual bool checkEndInfoHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		return checkHoverFocus(_snap, _position, _occupent);
	}

	public virtual bool checkEndHoverTruthFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		return false;
	}

	public virtual List<RevealLineSettings> getRevealLines(CaseSnapshot _snap)
	{
		return new List<RevealLineSettings>();
	}

	protected List<RevealLineSettings> getRevealLineToTarget(int _target, RevealLineColour _colour, CaseSnapshot _snap)
	{
		return new RevealLineSettings(board_position, _target, _colour, _snap).makeListFromItem();
	}

	protected List<RevealLineSettings> getRevealLineToTargets(RevealLineColour _colour, CaseSnapshot _snap, params int[] _targets)
	{
		return _targets.Select((int _t) => new RevealLineSettings(board_position, _t, _colour, _snap)).ToList();
	}

	protected List<RevealLineSettings> getRevealLineToTargets(RevealLineColour _colour, CaseSnapshot _snap, List<int> _targets)
	{
		return _targets.Select((int _t) => new RevealLineSettings(board_position, _t, _colour, _snap)).ToList();
	}

	public RoleClassifications getTrueClassification()
	{
		return classification;
	}

	public virtual RoleClassifications getVisualClassification()
	{
		if (!override_visual_classification.is_some)
		{
			return classification;
		}
		return override_visual_classification.value;
	}

	public Alignments getTrueAlignment()
	{
		return alignment;
	}

	public virtual Alignments getVisualAlignment()
	{
		if (!override_visual_alignments.is_some)
		{
			return alignment;
		}
		return override_visual_alignments.value;
	}

	public int getAddress()
	{
		return address;
	}

	public Vector2Int getBoardPosition()
	{
		return board_position;
	}

	public bool getIsInvestigated()
	{
		return investigated;
	}

	public bool getIsTainted()
	{
		return tainted;
	}

	public bool getIsLying()
	{
		return lying;
	}

	public bool getIsLyingOrTainted()
	{
		if (!lying)
		{
			return tainted;
		}
		return true;
	}

	public bool getIsObscured()
	{
		return obscured;
	}

	public bool getIsObscuredImmune()
	{
		return role_info.temp_states.Contains("#I_OBS");
	}

	public bool getIsHidden()
	{
		return hidden;
	}

	public bool getIsArrested()
	{
		return arrested;
	}

	public bool getIsDead()
	{
		return dead;
	}

	public bool getIsDisguised()
	{
		return disguise.is_some;
	}

	public Roles getVisualAppearance()
	{
		if (!arrested)
		{
			return getVisualRole().role;
		}
		return reveal_as;
	}

	public RoleData getVisualRole()
	{
		if (!disguise.is_some)
		{
			return this;
		}
		return disguise.value;
	}

	public Maybe<RoleData> getDisguise()
	{
		return disguise;
	}

	public void setAddress(int _new_address)
	{
		address = _new_address;
	}

	public void setBoardPosition(Vector2Int _new_position)
	{
		board_position = _new_position;
	}

	public void setAlignment(Alignments _new)
	{
		alignment = _new;
	}

	public void setTainted(bool _new)
	{
		tainted = _new;
	}

	public void setLying(bool _new)
	{
		lying = _new;
	}

	public void forceTruth()
	{
		tainted = false;
		lying = false;
		role_info.resetTempState("TNT");
	}

	public void resurrect()
	{
		dead = false;
	}

	public void setObscured(bool _new)
	{
		obscured = _new;
	}

	public void setHidden(bool _new)
	{
		hidden = _new;
	}

	public void setCanBeInvestigated(string _key, bool _true, bool _uninvestigate = false)
	{
		if (_true)
		{
			blocking_investigation = blocking_investigation.Replace(_key, "");
		}
		else
		{
			blocking_investigation += _key;
		}
		if (_uninvestigate)
		{
			investigated = false;
		}
	}

	public void setInvestigatedOuter(bool _force = false)
	{
		if (can_be_investigated || _force)
		{
			investigated = true;
			if (!obscured)
			{
				case_ref.checkAddSuspect(getVisualAppearance());
			}
		}
	}

	public void uninvestigateOuter()
	{
		investigated = false;
	}

	public void setVisualAlignment(Alignments _alignment)
	{
		override_visual_alignments = _alignment.maybe();
	}

	public void setVisualClassification(RoleClassifications _class)
	{
		override_visual_classification = _class.maybe();
	}

	public void setTempObscuredImmunity(RoleData _sender, bool _true)
	{
		setTempObscuredImmunity($"R{(int)_sender.role}", _true);
	}

	public void setTempObscuredImmunity(string _key, bool _true)
	{
		if (_true)
		{
			RoleDataInfo roleDataInfo = role_info;
			roleDataInfo.temp_states = roleDataInfo.temp_states + "#I_OBS_" + _key;
		}
		else
		{
			role_info.temp_states = role_info.temp_states.Replace("#I_OBS_" + _key, "");
		}
	}

	public bool isTempObscureBy(RoleData _role)
	{
		return isTempObscureBy($"R{(int)_role.role}");
	}

	public bool isTempObscureBy(string _key)
	{
		return role_info.temp_states.Contains(_key);
	}

	public void setTempObscured(RoleData _sender, bool _true)
	{
		setTempObscured($"R{(int)_sender.role}", _true);
	}

	public void setTempObscured(string _key, bool _true)
	{
		if (_true)
		{
			RoleDataInfo roleDataInfo = role_info;
			roleDataInfo.temp_states = roleDataInfo.temp_states + "#OBS_" + _key;
		}
		else
		{
			role_info.temp_states = role_info.temp_states.Replace("#OBS_" + _key, "");
		}
	}

	public void clearTempObscured()
	{
		clearTempState("OBS");
	}

	public bool isTempTaintedBy(RoleData _role)
	{
		return isTempTaintedBy($"R{(int)_role.role}");
	}

	public bool isTempTaintedBy(string _key)
	{
		return role_info.temp_states.Contains(_key);
	}

	public void setTempTaint(RoleData _sender, bool _true)
	{
		setTempTaint($"R{(int)_sender.role}", _true);
	}

	public void setTempTaint(string _key, bool _true)
	{
		if (_true)
		{
			RoleDataInfo roleDataInfo = role_info;
			roleDataInfo.temp_states = roleDataInfo.temp_states + "#TNT_" + _key;
		}
		else
		{
			role_info.temp_states = role_info.temp_states.Replace("#TNT_" + _key, "");
		}
	}

	public void clearTempTaint()
	{
		clearTempState("TNT");
	}

	private void clearTempState(string _marker)
	{
		string[] array = role_info.temp_states.Split('#');
		string text = "";
		string[] array2 = array;
		foreach (string text2 in array2)
		{
			if (!text2.StartsWith(_marker))
			{
				text = text + "#" + text2;
			}
		}
		role_info.temp_states = text;
	}

	public void setDisguise(Maybe<RoleData> _new, bool _set_true_self = false)
	{
		disguise = _new;
		if (_new.is_some && _set_true_self)
		{
			_new.value.setTrueSelfReference(this);
		}
	}

	public void overrideWithNewDisguise(Roles _new_role, bool _set_data = true, bool _set_true_self = false)
	{
		RoleData roleData = (is_true_self ? this : true_self.value);
		RoleData roleData2 = _new_role.createRole(address, board_position, random, roleData.maybe());
		roleData.setDisguise(roleData2.maybe(), _set_true_self);
		if (_set_data)
		{
			roleData2.setDisguiseData(case_ref);
		}
	}

	public void setTrueSelfReference(RoleData _true_self)
	{
		true_self = _true_self.maybe();
	}

	protected virtual void setDisguiseData(Case _case_ref)
	{
	}

	public void setForcedDisguised(bool _forced = true)
	{
		forced_starting_disguise = _forced;
	}

	public virtual bool getHasAnyAbility()
	{
		if (!getHasRoleAbility())
		{
			return getHasSpecialAbility();
		}
		return true;
	}

	public virtual bool getHasRoleAbility()
	{
		return this is IHaveRoleAbility;
	}

	public virtual bool getHasSpecialAbility()
	{
		return this is IHaveSpecialAbility;
	}

	public virtual bool getIsAbilityExhausted()
	{
		if (!getHasRoleAbility())
		{
			if (!getHasSpecialAbility())
			{
				return true;
			}
			return (this as IHaveSpecialAbility).abilityExhausted;
		}
		return (this as IHaveRoleAbility).abilityExhausted;
	}

	public virtual void restoreAbility()
	{
		if (getHasAnyAbility() && getIsAbilityExhausted())
		{
			ability_exhausted = false;
		}
	}

	public virtual bool canBeArrested(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board)
	{
		return true;
	}

	public virtual bool canBeKilled(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board)
	{
		return true;
	}

	public virtual bool canBeInvestigated(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board)
	{
		return can_be_investigated;
	}

	public void onRoundCreated(Case _ref)
	{
		case_ref = _ref;
		lying = isLiar();
	}

	public Maybe<RoleData> createDisguise(DisguiseCharacteristics _disguise_characteistics, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, List<RoleData> _suspects, bool _force = false)
	{
		return checkForDisguises(_disguise_characteistics, _board, _suspects, new List<Roles>(), _force);
	}

	private Maybe<RoleData> checkForDisguises(DisguiseCharacteristics _disguise_characteistics, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, List<RoleData> _suspects, List<Roles> _vetoed, bool _force = false)
	{
		if (forced_starting_disguise)
		{
			return disguise;
		}
		if (!_disguise_characteistics.disguises || !is_true_self)
		{
			return new Maybe<RoleData>();
		}
		Maybe<RoleData> maybe = new Maybe<RoleData>();
		List<RoleData> list = new List<RoleData>();
		switch (_disguise_characteistics.pretend_target)
		{
		case DisguiseTarget.SPECIFIC_ROLE:
		{
			RoleData roleData = _suspects.Find((RoleData _r) => _r.role == _disguise_characteistics.disguise_as.value);
			if (roleData == null)
			{
				Debug.LogError($"The specific role ({_disguise_characteistics.disguise_as.value}) that this role ({role}) wants as a disguise is not on the suspect list!");
				return new Maybe<RoleData>();
			}
			if (_vetoed.Contains(roleData.role))
			{
				Debug.LogError($"The specific role ({_disguise_characteistics.disguise_as.value}) that this role ({role}) wants as a disguise is vetoed! They do not satisfy their generation constraints!");
				return new Maybe<RoleData>();
			}
			list.Add(roleData);
			break;
		}
		case DisguiseTarget.CUSTOM_SUSPECTED:
			list = _suspects.Where((RoleData _s) => !_vetoed.Contains(_s.role) && _s.can_be_disguise && _disguise_characteistics.can_disguise_as_classification.Contains(_s.role.getClassificationFromRoleType()) && !_disguise_characteistics.disguise_blacklist.Contains(_s.role) && _disguise_characteistics.disguise_possible(_s) && !_s.getDisguiseCharacteristics(case_ref).disguises).ToList();
			break;
		case DisguiseTarget.CUSTOM_IN_PLAY:
			list = _board.getRolesInPlay().Values.Where((RoleData _s) => !_vetoed.Contains(_s.role) && _s.can_be_disguise && _disguise_characteistics.can_disguise_as_classification.Contains(_s.role.getClassificationFromRoleType()) && !_disguise_characteistics.disguise_blacklist.Contains(_s.role) && _disguise_characteistics.disguise_possible(_s) && !_s.getDisguiseCharacteristics(case_ref).disguises).ToList();
			break;
		case DisguiseTarget.CUSTOM_NOT_IN_PLAY:
			list = (from _s in _board.getRolesNotInPlay(_suspects)
				where !_vetoed.Contains(_s.role) && _s.can_be_disguise && _disguise_characteistics.can_disguise_as_classification.Contains(_s.role.getClassificationFromRoleType()) && !_disguise_characteistics.disguise_blacklist.Contains(_s.role) && _disguise_characteistics.disguise_possible(_s) && !_s.getDisguiseCharacteristics(case_ref).disguises
				select _s).ToList();
			break;
		case DisguiseTarget.SUSPECTED:
			list = _suspects.Where((RoleData _e) => !_vetoed.Contains(_e.role) && _e.can_be_disguise && !_e.getDisguiseCharacteristics(case_ref).disguises && _disguise_characteistics.can_disguise_as_classification.Contains(_e.role.getClassificationFromRoleType()) && !_disguise_characteistics.disguise_blacklist.Contains(_e.role)).ToList();
			break;
		case DisguiseTarget.IN_PLAY:
			list = (((is_true_self ? role : true_self.value.role) != Roles.WANNABE) ? _board.getRolesInPlay().Values.Where((RoleData _e) => !_vetoed.Contains(_e.role) && _e.can_be_disguise && !_e.getDisguiseCharacteristics(case_ref).disguises && _disguise_characteistics.can_disguise_as_classification.Contains(_e.role.getClassificationFromRoleType()) && !_disguise_characteistics.disguise_blacklist.Contains(_e.role)).ToList() : _board.getRolesInPlay().Values.Where((RoleData _e) => !_vetoed.Contains(_e.role) && _e.can_be_disguise && _disguise_characteistics.can_disguise_as_classification.Contains(_e.role.getClassificationFromRoleType()) && !_disguise_characteistics.disguise_blacklist.Contains(_e.role)).ToList());
			break;
		case DisguiseTarget.NOT_IN_PLAY:
			list = (from _e in _board.getRolesNotInPlay(_suspects)
				where !_vetoed.Contains(_e.role) && _e.can_be_disguise && !_e.getDisguiseCharacteristics(case_ref).disguises && _disguise_characteistics.can_disguise_as_classification.Contains(_e.role.getClassificationFromRoleType()) && !_disguise_characteistics.disguise_blacklist.Contains(_e.role)
				select _e).ToList();
			break;
		case DisguiseTarget.NOT_SET:
			Debug.LogError($"Disguise target not set! {role}");
			return new Maybe<RoleData>();
		}
		if (list.Count == 0)
		{
			Debug.LogError(string.Format("Disguising Role FAILED {0}! {1} Case: {2}", role, _force ? "Fallback failed!" : "Fallback, disguising ignoring constraints!", case_ref.pregameSnap().debugPrint(new List<CaseQuirks>())));
			if (!_force)
			{
				return checkForDisguises(_disguise_characteistics, _board, _suspects, new List<Roles>(), _force: true);
			}
			return new Maybe<RoleData>();
		}
		maybe = list.getRandomElementFromList(random).copy(this).maybe();
		if (!_force && maybe.is_some && _disguise_characteistics.check_disguise_constraints && !maybe.value.generation_constraint.validateDisguise(this, case_ref.board_size, has_bad_info, _board, _suspects))
		{
			_vetoed.Add(maybe.value.role);
			return checkForDisguises(_disguise_characteistics, _board, _suspects, _vetoed);
		}
		return maybe;
	}

	private bool checkForDisguises(DisguiseCharacteristics _disguise_characteistics, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, List<RoleData> _suspects, List<Roles> _vetoed, out Maybe<RoleData> _disguise, bool _force = false)
	{
		if (forced_starting_disguise)
		{
			_disguise = disguise;
			return true;
		}
		if (!_disguise_characteistics.disguises || !is_true_self)
		{
			_disguise = new Maybe<RoleData>();
			return true;
		}
		Maybe<RoleData> maybe = new Maybe<RoleData>();
		List<RoleData> list = new List<RoleData>();
		switch (_disguise_characteistics.pretend_target)
		{
		case DisguiseTarget.SPECIFIC_ROLE:
		{
			RoleData roleData = _suspects.Find((RoleData _r) => _r.role == _disguise_characteistics.disguise_as.value);
			if (roleData == null)
			{
				_disguise = new Maybe<RoleData>();
				return false;
			}
			if (_vetoed.Contains(roleData.role))
			{
				_disguise = new Maybe<RoleData>();
				return false;
			}
			list.Add(roleData);
			break;
		}
		case DisguiseTarget.CUSTOM_SUSPECTED:
			list = _suspects.Where((RoleData _s) => !_vetoed.Contains(_s.role) && _s.can_be_disguise && _disguise_characteistics.can_disguise_as_classification.Contains(_s.role.getClassificationFromRoleType()) && !_disguise_characteistics.disguise_blacklist.Contains(_s.role) && _disguise_characteistics.disguise_possible(_s) && !_s.getDisguiseCharacteristics(case_ref).disguises).ToList();
			break;
		case DisguiseTarget.CUSTOM_IN_PLAY:
			list = _board.getRolesInPlay().Values.Where((RoleData _s) => !_vetoed.Contains(_s.role) && _s.can_be_disguise && _disguise_characteistics.can_disguise_as_classification.Contains(_s.role.getClassificationFromRoleType()) && !_disguise_characteistics.disguise_blacklist.Contains(_s.role) && _disguise_characteistics.disguise_possible(_s) && !_s.getDisguiseCharacteristics(case_ref).disguises).ToList();
			break;
		case DisguiseTarget.CUSTOM_NOT_IN_PLAY:
			list = (from _s in _board.getRolesNotInPlay(_suspects)
				where !_vetoed.Contains(_s.role) && _s.can_be_disguise && _disguise_characteistics.can_disguise_as_classification.Contains(_s.role.getClassificationFromRoleType()) && !_disguise_characteistics.disguise_blacklist.Contains(_s.role) && _disguise_characteistics.disguise_possible(_s) && !_s.getDisguiseCharacteristics(case_ref).disguises
				select _s).ToList();
			break;
		case DisguiseTarget.SUSPECTED:
			list = _suspects.Where((RoleData _e) => !_vetoed.Contains(_e.role) && _e.can_be_disguise && !_e.getDisguiseCharacteristics(case_ref).disguises && _disguise_characteistics.can_disguise_as_classification.Contains(_e.role.getClassificationFromRoleType()) && !_disguise_characteistics.disguise_blacklist.Contains(_e.role)).ToList();
			break;
		case DisguiseTarget.IN_PLAY:
			list = (((is_true_self ? role : true_self.value.role) != Roles.WANNABE) ? _board.getRolesInPlay().Values.Where((RoleData _e) => !_vetoed.Contains(_e.role) && _e.can_be_disguise && !_e.getDisguiseCharacteristics(case_ref).disguises && _disguise_characteistics.can_disguise_as_classification.Contains(_e.role.getClassificationFromRoleType()) && !_disguise_characteistics.disguise_blacklist.Contains(_e.role)).ToList() : _board.getRolesInPlay().Values.Where((RoleData _e) => !_vetoed.Contains(_e.role) && _e.can_be_disguise && _disguise_characteistics.can_disguise_as_classification.Contains(_e.role.getClassificationFromRoleType()) && !_disguise_characteistics.disguise_blacklist.Contains(_e.role)).ToList());
			break;
		case DisguiseTarget.NOT_IN_PLAY:
			list = (from _e in _board.getRolesNotInPlay(_suspects)
				where !_vetoed.Contains(_e.role) && _e.can_be_disguise && !_e.getDisguiseCharacteristics(case_ref).disguises && _disguise_characteistics.can_disguise_as_classification.Contains(_e.role.getClassificationFromRoleType()) && !_disguise_characteistics.disguise_blacklist.Contains(_e.role)
				select _e).ToList();
			break;
		case DisguiseTarget.NOT_SET:
			Debug.LogError($"Disguise target not set! {role}");
			_disguise = new Maybe<RoleData>();
			return false;
		}
		if (list.Count == 0)
		{
			_disguise = new Maybe<RoleData>();
			return false;
		}
		maybe = list.getRandomElementFromList(random).copy(this).maybe();
		if (!_force && maybe.is_some && _disguise_characteistics.check_disguise_constraints && !maybe.value.generation_constraint.validateDisguise(this, case_ref.board_size, has_bad_info, _board, _suspects))
		{
			_vetoed.Add(maybe.value.role);
			return checkForDisguises(_disguise_characteistics, _board, _suspects, _vetoed, out _disguise);
		}
		_disguise = maybe;
		return true;
	}

	public Maybe<Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>>> onSetDisguise(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		if (!checkForDisguises(getDisguiseCharacteristics(case_ref), _board, _suspects, new List<Roles>(), out disguise))
		{
			return new Maybe<Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>>>();
		}
		_board = onDisguiseSet(_board, _payload, _suspects);
		if (disguise.is_some)
		{
			_board = disguise.value.onDisguiseSet(_board, _payload, _suspects);
		}
		return _board.maybe();
	}

	public Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStarted(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		_board = onRoundStartAction(_board, _payload, _suspects);
		if (disguise.is_some)
		{
			_board = disguise.value.onRoundStarted(_board, _payload, _suspects);
		}
		_board = onRoundStartAfterDisguiseAction(_board, _payload, _suspects);
		if (!is_true_self)
		{
			return _board;
		}
		return _board.registerRoleChange(board_position, this);
	}

	public string getInfoString(CaseSnapshot _snap)
	{
		if (info_string.is_some)
		{
			return info_string.value;
		}
		try
		{
			info_string = generateInfoString(_snap).maybe();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to generate info string! ({role}) || \nError: {arg}");
			info_string = new Maybe<string>();
			return "";
		}
		return info_string.value;
	}

	public bool overrideInfo(string _info, bool _force = true)
	{
		if (!_force && info_string.is_some)
		{
			return false;
		}
		info_string = _info.maybe();
		return true;
	}

	public void resetInfo()
	{
		info_string = new Maybe<string>();
		onInfoReset();
	}

	protected virtual void onInfoReset()
	{
	}

	public Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onInvestigation(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _investigated_address)
	{
		if (!canBeInvestigated(_board) || !getVisualRole().canBeInvestigated(_board))
		{
			return _board;
		}
		if (_investigated_address == address)
		{
			investigated = true;
		}
		_board = onInvestigationAction(_board, _payload, _investigated_address);
		if (disguise.is_some)
		{
			_board = disguise.value.onInvestigation(_board, _payload, _investigated_address);
		}
		if (!is_true_self)
		{
			return _board;
		}
		return _board.registerRoleChange(board_position, this);
	}

	public Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onArrest(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _arrested_address)
	{
		if (!canBeArrested(_board))
		{
			return _board;
		}
		if (_arrested_address == address)
		{
			arrested = true;
		}
		_board = onArrestAction(_board, _payload, _arrested_address);
		if (disguise.is_some)
		{
			_board = disguise.value.onArrest(_board, _payload, _arrested_address);
		}
		if (!is_true_self)
		{
			return _board;
		}
		return _board.registerRoleChange(board_position, this);
	}

	public Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onKill(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _murdered_address, Maybe<RoleData> _killer)
	{
		if (!canBeKilled(_board))
		{
			return _board;
		}
		if (_murdered_address == address)
		{
			dead = true;
		}
		_board = onKillAction(_board, _payload, _murdered_address, _killer);
		if (disguise.is_some)
		{
			_board = disguise.value.onKill(_board, _payload, _murdered_address, _killer);
		}
		if (!is_true_self)
		{
			return _board;
		}
		return _board.registerRoleChange(board_position, this);
	}

	public Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onSpecialAbilityUsed(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _ability_user_address, List<AbilityData> _data)
	{
		if (_ability_user_address == address)
		{
			ability_exhausted = true;
		}
		if (this is IHaveSpecialAbility haveSpecialAbility)
		{
			haveSpecialAbility.onSpecialAbility(_board, _payload, _ability_user_address, _data);
		}
		if (disguise.is_some && disguise.value is IHaveSpecialAbility haveSpecialAbility2)
		{
			haveSpecialAbility2.onSpecialAbility(_board, _payload, _ability_user_address, _data);
		}
		return onAbilityUsed(_board, _payload, _ability_user_address, _data.whereSelect((AbilityData _d) => _d is AddressAbilityData, (AbilityData _a) => (_a as AddressAbilityData).address));
	}

	public Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onAbilityUsed(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _ability_user_address, List<int> _target_addresses)
	{
		if (_ability_user_address == address)
		{
			ability_exhausted = true;
			resetInfo();
		}
		if (disguise.is_some)
		{
			_board = disguise.value.onAbilityUsed(_board, _payload, _ability_user_address, _target_addresses);
		}
		_board = onAbilityUsedAction(_board, _payload, _ability_user_address, _target_addresses);
		if (!is_true_self)
		{
			return _board;
		}
		return _board.registerRoleChange(board_position, this);
	}

	public Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onCaseOver(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, bool _won)
	{
		_board = onCaseOverAction(_board, _payload, _won);
		if (disguise.is_some)
		{
			_board = disguise.value.onCaseOver(_board, _payload, _won);
		}
		if (!is_true_self)
		{
			return _board;
		}
		return _board.registerRoleChange(board_position, this);
	}

	public Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onLocationTriggered(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects, LocationData _location)
	{
		if (disguise.is_some)
		{
			_board = disguise.value.onLocationTriggered(_board, _payload, _suspects, _location);
		}
		return onLocationTriggeredAction(_board, _payload, _suspects, _location);
	}

	protected virtual Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onInvestigationAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _investigated_address)
	{
		return _board;
	}

	protected virtual Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onArrestAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _arrested_address)
	{
		return _board;
	}

	protected virtual Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onKillAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _murdered_address, Maybe<RoleData> _killer)
	{
		return _board;
	}

	protected virtual Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onAbilityUsedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _ability_user_address, List<int> _target_addresses)
	{
		return _board;
	}

	protected virtual Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onDisguiseSet(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		return _board;
	}

	protected virtual Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		return _board;
	}

	protected virtual Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAfterDisguiseAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		return _board;
	}

	protected virtual Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onCaseOverAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, bool _won)
	{
		return _board;
	}

	protected virtual Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onLocationTriggeredAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects, LocationData _location)
	{
		return _board;
	}

	public RoleData copy(RoleData _true_self)
	{
		return role.createRole(_true_self.getAddress(), _true_self.getBoardPosition(), random, _true_self.maybe());
	}

	public RoleSave toSave()
	{
		return new RoleSave(role, role_info, ability_exhausted, getUniqueSaveData(), disguise, override_reveal_role, override_visual_classification, override_visual_alignments);
	}

	public RoleDataSave toDataSave()
	{
		return new RoleDataSave(role, ability_exhausted, getUniqueSaveData(), override_reveal_role, override_visual_classification, override_visual_alignments);
	}

	public abstract string getUniqueSaveData();

	public bool getNamePrefixOption()
	{
		switch (GRGLocalisationHandler.instance.current_language)
		{
		case Languages.ENGLISH:
			return getEnglishNamePrefixOption();
		case Languages.CHINESE_SIMPLIFIED:
		case Languages.CHINESE_TRADITIONAL:
		case Languages.JAPANESE:
		case Languages.KOREAN:
		case Languages.THAI:
			return true;
		default:
			Debug.LogError($"No prefix option set up for language {GRGLocalisationHandler.instance.current_language}!");
			return true;
		}
	}

	protected virtual bool getEnglishNamePrefixOption()
	{
		return true;
	}

	protected string checkPlural(string _text, bool _singular)
	{
		return _text.checkPlural(_singular);
	}

	protected string checkTranslation(Func<string> _english)
	{
		return checkTranslation(loc_default_info_key, _english);
	}

	protected string checkTranslation(string _key, Func<string> _english)
	{
		return this.checkRoleTranslation(_key, _english);
	}

	protected string checkTranslationWithPlural(Func<string, string> _english, int _replace)
	{
		return checkTranslationWithPlural(loc_default_info_key, _english, _replace);
	}

	protected string checkTranslationWithPlural(string _key, Func<string, string> _english, int _replace)
	{
		return checkTranslationWithData(_key, _english, _replace).checkPlural(_replace == 1);
	}

	protected string checkTranslationWithData(Func<string, string> _english, int _replace)
	{
		return checkTranslationWithData(loc_default_info_key, _english, _replace);
	}

	protected string checkTranslationWithData(string _key, Func<string, string> _english, int _replace)
	{
		return this.checkRoleTranslationWithData(_key, _english, _replace);
	}

	protected string checkTranslationWithData(Func<string, string> _english, string _replace)
	{
		return checkTranslationWithData(loc_default_info_key, _english, _replace);
	}

	protected string checkTranslationWithData(string _key, Func<string, string> _english, string _replace)
	{
		return this.checkRoleTranslationWithData(_key, _english, _replace);
	}

	protected string checkTranslationWithReplace(Func<string> _english, params int[] _replace)
	{
		return checkTranslationWithReplace(loc_default_info_key, _english, _replace);
	}

	protected string checkTranslationWithReplace(string _key, Func<string> _english, params int[] _replace)
	{
		return this.checkRoleTranslationWithReplace(_key, _english, _check_keywords: true, _replace);
	}

	protected string checkTranslationWithReplace(Func<string> _english, params Func<string>[] _replace)
	{
		return checkTranslationWithReplace(loc_default_info_key, _english, _replace);
	}

	protected string checkTranslationWithReplace(string _key, Func<string> _english, params Func<string>[] _replace)
	{
		return this.checkRoleTranslationWithReplace(_key, _english, _check_keywords: true, _replace);
	}

	private string checkTranslationDefaultAsset(string _key, Func<string> _english, params Func<string>[] _replace)
	{
		if (GRGLocalisationHandler.needs_translation)
		{
			string _result = "";
			if (GRGLocalisationHandler.instance.translateAndReplace(LocalisationHelper.defaultRoleAsset(), _key, out _result, _replace.Select((Func<string> _r) => _r()).ToArray()))
			{
				return _result;
			}
		}
		return _english();
	}
}
