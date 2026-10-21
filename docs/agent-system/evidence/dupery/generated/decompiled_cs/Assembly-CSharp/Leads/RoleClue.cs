using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.String;
using GRGLib.Generic;
using GRGLocalisation;
using Localisation;
using Save;
using UnityEngine;

namespace Leads;

public class RoleClue : Clue, IAmLocalised
{
	private ClueTypes m_type;

	public Roles role_in_focus { get; private set; }

	public RoleData facade { get; private set; }

	public override ClueTypes clue_type => m_type;

	public override int progression => clue_type switch
	{
		ClueTypes.ROLE_IN_PLAY => getProgressionInPlay(role_in_focus.getClassificationFromRoleType()), 
		ClueTypes.ROLE_NOT_IN_PLAY => getProgressionNotInPlay(role_in_focus.getClassificationFromRoleType()), 
		ClueTypes.ROLE_SUSPECTED => getProgressionSuspected(role_in_focus.getClassificationFromRoleType()), 
		_ => 0, 
	};

	private AssetKey localisation_asset => LocalisationHelper.misc_asset;

	private string loc_in_play_name => "RoleClue [n_ip]";

	private string loc_in_play_desc => "RoleClue [d_ip]";

	private string loc_not_in_play_name => "RoleClue [n_nip]";

	private string loc_not_in_play_desc => "RoleClue [d_nip]";

	private string loc_suspected_name => "RoleClue [n_sus]";

	private string loc_suspected_desc => "RoleClue [d_sus]";

	public static MinMaxInt getProgressionRange(ClueTypes _type)
	{
		return _type switch
		{
			ClueTypes.ROLE_IN_PLAY => new MinMaxInt(-1, 8), 
			ClueTypes.ROLE_NOT_IN_PLAY => new MinMaxInt(0, 2), 
			ClueTypes.ROLE_SUSPECTED => new MinMaxInt(0, 4), 
			_ => errorAndReturn(new MinMaxInt(-1, 8), $"No Progression range set up for clue type {_type}!"), 
		};
	}

	private static MinMaxInt errorAndReturn(MinMaxInt _return, string _error)
	{
		Debug.LogError(_error);
		return _return;
	}

	public RoleClue(bool _immutable, Roles _role, ClueTypes _type)
		: base(_immutable)
	{
		role_in_focus = _role;
		facade = role_in_focus.createEmptyRole();
		m_type = _type;
	}

	public RoleClue(ClueSaveData _save)
		: base(_save)
	{
		try
		{
			if (_save.unique_data.Contains(','))
			{
				string[] array = _save.unique_data.Split(',');
				role_in_focus = (Roles)int.Parse(array[0]);
			}
			else
			{
				role_in_focus = (Roles)int.Parse(_save.unique_data);
			}
			m_type = _save.type;
			facade = role_in_focus.createEmptyRole();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load RoleClue!\nData: {_save.unique_data}\nError: {arg}");
			role_in_focus = Roles.PRIEST;
			facade = role_in_focus.createEmptyRole();
			m_type = ClueTypes.ROLE_NOT_IN_PLAY;
		}
	}

	private int getProgressionInPlay(RoleClassifications _class)
	{
		switch (_class)
		{
		case RoleClassifications.INNOCENT:
			return -1;
		case RoleClassifications.MEDDLER:
			return 3;
		case RoleClassifications.UNDERLING:
			return 5;
		case RoleClassifications.TRAITOR:
			return 8;
		default:
		{
			global::_003CPrivateImplementationDetails_003E.ThrowSwitchExpressionException(_class);
			int result = default(int);
			return result;
		}
		}
	}

	private int getProgressionNotInPlay(RoleClassifications _class)
	{
		switch (_class)
		{
		case RoleClassifications.INNOCENT:
			return 2;
		case RoleClassifications.MEDDLER:
			return 1;
		case RoleClassifications.UNDERLING:
			return 0;
		case RoleClassifications.TRAITOR:
			return 0;
		default:
		{
			global::_003CPrivateImplementationDetails_003E.ThrowSwitchExpressionException(_class);
			int result = default(int);
			return result;
		}
		}
	}

	private int getProgressionSuspected(RoleClassifications _class)
	{
		switch (_class)
		{
		case RoleClassifications.INNOCENT:
			return 0;
		case RoleClassifications.MEDDLER:
			return 1;
		case RoleClassifications.UNDERLING:
			return 2;
		case RoleClassifications.TRAITOR:
			return 4;
		default:
		{
			global::_003CPrivateImplementationDetails_003E.ThrowSwitchExpressionException(_class);
			int result = default(int);
			return result;
		}
		}
	}

	public int getProgressionDiffWhenInverted()
	{
		if (clue_type == ClueTypes.ROLE_IN_PLAY)
		{
			return getProgressionNotInPlay(role_in_focus.getClassificationFromRoleType()) - progression;
		}
		if (clue_type == ClueTypes.ROLE_NOT_IN_PLAY)
		{
			return getProgressionInPlay(role_in_focus.getClassificationFromRoleType()) - progression;
		}
		return 0;
	}

	public override List<ClueTags> getClueTags()
	{
		List<ClueTags> list = new List<ClueTags> { ClueTags.ROLE };
		if (role_in_focus.isInnocent())
		{
			list.Add(ClueTags.INNOCENT);
		}
		if (role_in_focus.isMeddler())
		{
			list.Add(ClueTags.MEDDLER);
		}
		if (role_in_focus.isUnderling())
		{
			list.Add(ClueTags.UNDERLING);
		}
		if (role_in_focus.isTraitor())
		{
			list.Add(ClueTags.TRAITOR);
		}
		if (facade.getHasRoleAbility())
		{
			list.Add(ClueTags.ABILITY);
		}
		return list;
	}

	public override bool isValidInRegion(CaseType _region)
	{
		return role_in_focus.isRoleOfCaseType(_region);
	}

	public override string getName()
	{
		return m_type switch
		{
			ClueTypes.ROLE_IN_PLAY => localisation_asset.checkTranslationWithData(loc_in_play_name, englishIPName, facade.name), 
			ClueTypes.ROLE_SUSPECTED => localisation_asset.checkTranslationWithData(loc_suspected_name, englishSusName, facade.name), 
			ClueTypes.ROLE_NOT_IN_PLAY => localisation_asset.checkTranslationWithData(loc_not_in_play_name, englishNIPName, facade.name), 
			_ => throw new ArgumentException($"No description of roleclue set for type {m_type}!"), 
		};
	}

	private string englishIPName(string _data)
	{
		return "Surveil " + _data;
	}

	private string englishNIPName(string _data)
	{
		return "Absolve " + _data;
	}

	private string englishSusName(string _data)
	{
		return "Suspect " + _data;
	}

	public override string getDescription()
	{
		return m_type switch
		{
			ClueTypes.ROLE_IN_PLAY => localisation_asset.checkTranslationWithData(loc_in_play_desc, englishIPDesc, facade.name_coloured.link(facade.role.getHoverLink())), 
			ClueTypes.ROLE_SUSPECTED => localisation_asset.checkTranslationWithData(loc_suspected_desc, englishSusDesc, facade.name_coloured.link(facade.role.getHoverLink())), 
			ClueTypes.ROLE_NOT_IN_PLAY => localisation_asset.checkTranslationWithData(loc_not_in_play_desc, englishNIPDesc, facade.name_coloured.link(facade.role.getHoverLink())), 
			_ => throw new ArgumentException($"No description of roleclue set for type {m_type}!"), 
		};
	}

	private string englishIPDesc(string _data)
	{
		return _data + " is always " + Keywords.IN_PLAY.toString() + ".";
	}

	private string englishNIPDesc(string _data)
	{
		return _data + " is never " + Keywords.IN_PLAY.toString() + ".";
	}

	private string englishSusDesc(string _data)
	{
		return _data + " is always " + Keywords.SUSPECTED.toString() + ".";
	}

	public override string getPrefix()
	{
		return facade.english_clue_prefix;
	}

	public override string getSuffix()
	{
		return facade.english_clue_suffix;
	}

	public override string uniqueSaveData()
	{
		return $"{(int)role_in_focus}";
	}

	public Color getIconColour(RoleVisualDataSO _visuals_so)
	{
		return clue_type switch
		{
			ClueTypes.ROLE_IN_PLAY => _visuals_so[role_in_focus.getClassificationFromRoleType()].class_colour, 
			ClueTypes.ROLE_NOT_IN_PLAY => _visuals_so.getIconNotInPlayColour(), 
			ClueTypes.ROLE_SUSPECTED => _visuals_so.getIconSuspectedColour(), 
			_ => throw new ArgumentException($"No icon colour set for clue type {clue_type}!"), 
		};
	}

	public override List<Roles> filterRoleForClues(List<Roles> _roles, ClueTypes _type, List<Roles> _unforced, Dictionary<ClueTypes, List<Roles>> _forced)
	{
		return role_in_focus.createEmptyRole().generation_constraint.filterRoleCluePossibilities(_roles, _type, this, _unforced, _forced);
	}

	public bool canBeInverted(List<Roles> _lead_roles, List<Roles> _prime_suspects, List<Clue> _clues)
	{
		if (clue_type == ClueTypes.ROLE_SUSPECTED)
		{
			return false;
		}
		List<Roles> unforced = _lead_roles.copy();
		unforced.removeRange(_prime_suspects);
		Dictionary<ClueTypes, List<Roles>> forced = new Dictionary<ClueTypes, List<Roles>> { 
		{
			ClueTypes.ROLE_SUSPECTED,
			_prime_suspects.copy()
		} };
		foreach (Clue _clue in _clues)
		{
			if (_clue is RoleClue roleClue && roleClue.role_in_focus != role_in_focus)
			{
				forced.addOrCreate(roleClue.clue_type, roleClue.role_in_focus);
			}
		}
		ClueTypes flipped_type = ((clue_type != ClueTypes.ROLE_IN_PLAY) ? ClueTypes.ROLE_IN_PLAY : ClueTypes.ROLE_NOT_IN_PLAY);
		if (!facade.generation_constraint.canBeAddedAsRoleClue(role_in_focus, flipped_type, unforced, forced))
		{
			return false;
		}
		List<Roles> list = _clues.Aggregate(new List<Roles> { role_in_focus }, (List<Roles> _a, Clue _c) => (!_c.isSameAs(this)) ? _c.filterRoleForClues(_a, flipped_type, unforced, forced) : _a);
		if (list.Count == 0)
		{
			return false;
		}
		list = _prime_suspects.Aggregate(list, (List<Roles> _a, Roles _r) => _r.createEmptyRole().generation_constraint.filterRoleCluePossibilities(_a, flipped_type, _r, ClueTypes.ROLE_SUSPECTED, unforced, forced));
		if (list.Count == 0)
		{
			return false;
		}
		return true;
	}

	public override bool isSameAs(Clue _clue)
	{
		if (_clue != this)
		{
			if (_clue is RoleClue roleClue && roleClue.role_in_focus == role_in_focus)
			{
				return roleClue.clue_type == clue_type;
			}
			return false;
		}
		return true;
	}
}
