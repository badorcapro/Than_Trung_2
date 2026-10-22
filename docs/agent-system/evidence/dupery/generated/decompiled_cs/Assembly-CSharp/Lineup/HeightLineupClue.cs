using System;
using GRGLib.Maybe;
using Localisation;
using UnityEngine;

namespace Lineup;

public class HeightLineupClue : LineupClue
{
	public int height;

	public int variant;

	public override ClueElementTypes type => ClueElementTypes.HEIGHT;

	public override string clue_text => base.localisation_asset.checkTranslationWithData(loc_height_key, englishHeight, SuspectClueHelper.getHeightString(variant));

	public override string loc_info_key => loc_height_key;

	private string loc_height_key => "Clue [height_base]";

	public HeightLineupClue(System.Random _rng)
		: this(_rng.Next(1, 14), _rng)
	{
	}

	public HeightLineupClue(int _height, System.Random _rng)
	{
		height = _height;
		variant = Mathf.Max(height - _rng.Next(1, 5), 0);
	}

	public HeightLineupClue(string _save)
	{
		try
		{
			string[] array = _save.Split(',');
			height = int.Parse(array[0]);
			variant = int.Parse(array[1]);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load AgeLineupClue from save! ({_save}) | Error: {arg}");
		}
	}

	public override bool conforms(LineupSuspectInfo _clues)
	{
		return _clues.height_index >= variant;
	}

	public override bool forceTruth(LineupSuspectInfo _clues, System.Random _rng)
	{
		if (variant >= 13)
		{
			return false;
		}
		_clues.height_index = _rng.Next(variant + 1, 14);
		return true;
	}

	public override bool forceError(LineupSuspectInfo _clue, System.Random _rng)
	{
		if (variant == 0)
		{
			return false;
		}
		_clue.height_index = _rng.Next(0, variant);
		return true;
	}

	public override Maybe<int> hasDataOn(ClueElementTypes _type)
	{
		if (_type != type)
		{
			return new Maybe<int>();
		}
		return height.maybe();
	}

	public override Maybe<int> hasNoneConformingDataOn(ClueElementTypes _type, System.Random _rng)
	{
		if (_type != type)
		{
			return new Maybe<int>();
		}
		if (variant == 0)
		{
			Debug.LogWarning("Height of real suspect is at the lowest. Can't have a none-conforming person...");
			return _rng.Next(1, 14).maybe();
		}
		return _rng.Next(0, variant).maybe();
	}

	protected override string getSaveData()
	{
		return $"{height},{variant}";
	}

	private static string englishHeight(string _data)
	{
		return "I heard the boss is at least " + _data + ".";
	}
}
