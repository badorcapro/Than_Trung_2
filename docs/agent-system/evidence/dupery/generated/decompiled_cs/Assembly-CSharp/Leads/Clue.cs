using System;
using System.Collections.Generic;
using Save;

namespace Leads;

public abstract class Clue
{
	public bool immutable { get; private set; }

	public bool can_be_changed => !immutable;

	public abstract ClueTypes clue_type { get; }

	public abstract int progression { get; }

	public static Clue load(ClueSaveData _save)
	{
		switch (_save.type)
		{
		case ClueTypes.ROLE_SUSPECTED:
		case ClueTypes.ROLE_IN_PLAY:
		case ClueTypes.ROLE_NOT_IN_PLAY:
			return new RoleClue(_save);
		case ClueTypes.QUIRK_IN_PLAY:
			return new QuirkClue(_save);
		default:
			throw new ArgumentException($"No load function set up for clue type {_save.type}!");
		}
	}

	public abstract string getSuffix();

	public abstract string getPrefix();

	public abstract string getName();

	public abstract string getDescription();

	public abstract List<ClueTags> getClueTags();

	public abstract bool isValidInRegion(CaseType _region);

	public virtual List<CaseType> getClueValidRegions()
	{
		return new List<CaseType>().addAll(isValidInRegion);
	}

	public Clue(bool _immutable)
	{
		immutable = _immutable;
	}

	public Clue(ClueSaveData _save)
	{
		immutable = _save.immutable;
	}

	public abstract string uniqueSaveData();

	public abstract bool isSameAs(Clue _clue);

	public abstract List<Roles> filterRoleForClues(List<Roles> _roles, ClueTypes _type, List<Roles> _unforced, Dictionary<ClueTypes, List<Roles>> _forced);
}
