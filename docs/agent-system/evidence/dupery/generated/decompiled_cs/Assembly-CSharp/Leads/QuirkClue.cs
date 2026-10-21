using System;
using System.Collections.Generic;
using GRGLib.Generic;
using Quirks;
using Save;
using UnityEngine;

namespace Leads;

public class QuirkClue : Clue
{
	private CaseQuirkData facade;

	public static MinMaxInt progression_range => new MinMaxInt(-1, 4);

	public CaseQuirks quirk_in_focus { get; private set; }

	public override ClueTypes clue_type => ClueTypes.QUIRK_IN_PLAY;

	public override int progression
	{
		get
		{
			if (!quirk_in_focus.isBadQuirk())
			{
				return -1;
			}
			return 4;
		}
	}

	public QuirkClue(bool _immutable, CaseQuirks _quirk)
		: base(_immutable)
	{
		quirk_in_focus = _quirk;
		facade = _quirk.createQuirk();
	}

	public QuirkClue(ClueSaveData _save)
		: base(_save)
	{
		try
		{
			quirk_in_focus = (CaseQuirks)int.Parse(_save.unique_data);
			facade = quirk_in_focus.createQuirk();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load QuirkClue!\nData: {_save.unique_data}\nError: {arg}");
			quirk_in_focus = CaseQuirks.EVIL_GAZE;
			facade = quirk_in_focus.createQuirk();
		}
	}

	public override List<ClueTags> getClueTags()
	{
		_ = quirk_in_focus;
		return new List<ClueTags> { ClueTags.QUIRK };
	}

	public override bool isValidInRegion(CaseType _region)
	{
		return facade.isCompatible(_region);
	}

	public override string getName()
	{
		return facade.name;
	}

	public override string getDescription()
	{
		return facade.description;
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
		return $"{(int)quirk_in_focus}";
	}

	public override List<Roles> filterRoleForClues(List<Roles> _roles, ClueTypes _type, List<Roles> _unforced, Dictionary<ClueTypes, List<Roles>> _forced)
	{
		return facade.filterRoleForClues(_roles, _type, _unforced, _forced);
	}

	public bool isValidForClue(List<CaseQuirks> _quirks, List<Roles> _unforced, Dictionary<ClueTypes, List<Roles>> _forced)
	{
		if (facade == null)
		{
			return false;
		}
		return facade.isValidForClue(_quirks, _unforced, _forced);
	}

	public override bool isSameAs(Clue _clue)
	{
		if (_clue != this)
		{
			if (_clue is QuirkClue quirkClue && quirkClue.quirk_in_focus == quirk_in_focus)
			{
				return quirkClue.clue_type == clue_type;
			}
			return false;
		}
		return true;
	}
}
