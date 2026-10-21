using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using GRGLocalisation;
using Localisation;

namespace Lineup;

public abstract class LineupClue
{
	public abstract ClueElementTypes type { get; }

	public abstract string clue_text { get; }

	public abstract string loc_info_key { get; }

	public AssetKey localisation_asset => LocalisationHelper.lineup_asset;

	public static LineupClue createClue(List<LineupClue> _given, Random _rng)
	{
		return createClue(new List<ClueElementTypes>().addAll().removeAll((ClueElementTypes _t) => _given.Any((LineupClue _c) => _c.type == _t)).getRandomElementFromList(_rng), _given, _rng);
	}

	public static LineupClue createClue(ClueElementTypes _type, List<LineupClue> _given, Random _rng)
	{
		return _type switch
		{
			ClueElementTypes.AGE => new AgeLineupClue(_rng), 
			ClueElementTypes.HEIGHT => new HeightLineupClue(_rng), 
			ClueElementTypes.NAME => new NameLineupClue(_given, _rng), 
			_ => new SimpleLineupClue(_given, _type, _rng), 
		};
	}

	public abstract bool conforms(LineupSuspectInfo _clues);

	public abstract bool forceError(LineupSuspectInfo _clue, Random _rng);

	public abstract bool forceTruth(LineupSuspectInfo _clues, Random _rng);

	public abstract Maybe<int> hasDataOn(ClueElementTypes _type);

	public virtual Maybe<int> hasNoneConformingDataOn(ClueElementTypes _type, Random _rng)
	{
		Maybe<int> maybe = hasDataOn(_type);
		if (!maybe.is_some)
		{
			return maybe;
		}
		if (maybe.value == 0)
		{
			return 1.maybe();
		}
		return 0.maybe();
	}

	public virtual Maybe<(int, int)> hasDataOnName()
	{
		return new Maybe<(int, int)>();
	}

	public LineupClueSave getSave()
	{
		return new LineupClueSave(type, getSaveData());
	}

	protected abstract string getSaveData();
}
