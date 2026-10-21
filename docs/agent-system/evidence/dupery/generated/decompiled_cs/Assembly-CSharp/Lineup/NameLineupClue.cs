using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Localisation;
using UnityEngine;

namespace Lineup;

public class NameLineupClue : LineupClue
{
	public int first_name_index;

	public int second_name_index;

	public bool gender;

	public string name_characters;

	public int variant;

	public override ClueElementTypes type => ClueElementTypes.NAME;

	public override string clue_text
	{
		get
		{
			if (variant != 1)
			{
				return base.localisation_asset.checkTranslationWithReplace(loc_info_key, () => englishHasLettersClue(name_characters[0].ToString(), name_characters[1].ToString(), name_characters[2].ToString()), true, name_characters[0].ToString(), name_characters[1].ToString(), name_characters[2].ToString());
			}
			return base.localisation_asset.checkTranslationWithData(loc_info_key, englishFirstLetterClue, name_characters[0].ToString());
		}
	}

	public override string loc_info_key => constructLocKey(variant);

	private string constructLocKey(int _variant)
	{
		return $"Clue [Name{_variant}]";
	}

	public NameLineupClue(List<LineupClue> _given_clues, System.Random _rng)
	{
		LineupClue lineupClue = _given_clues.Find((LineupClue _c) => _c.type == ClueElementTypes.GENDER);
		if (lineupClue != null && lineupClue is SimpleLineupClue simpleLineupClue)
		{
			gender = simpleLineupClue.data;
		}
		else
		{
			LineupClue lineupClue2 = _given_clues.Find((LineupClue _c) => _c.type == ClueElementTypes.FACIAL_HAIR);
			if (lineupClue2 != null && lineupClue2 is SimpleLineupClue { data: not false })
			{
				gender = true;
			}
			else
			{
				gender = _rng.Next(0, 2) == 1;
			}
		}
		first_name_index = _rng.Next(0, gender ? SuspectClueHelper.male_first_name_list_length : SuspectClueHelper.female_first_name_list_length);
		second_name_index = _rng.Next(0, SuspectClueHelper.last_name_list_length);
		variant = _rng.Next(0, 2);
		setUpNameCharacters(_rng);
	}

	public NameLineupClue(int _first_name_index, int _second_name_index, bool _gender, int _variant, System.Random _rng)
	{
		first_name_index = _first_name_index;
		second_name_index = _second_name_index;
		gender = _gender;
		variant = _variant;
		setUpNameCharacters(_rng);
	}

	public NameLineupClue(string _save)
	{
		try
		{
			string[] array = _save.Split(',');
			first_name_index = int.Parse(array[0]);
			second_name_index = int.Parse(array[1]);
			gender = array[2] == "t";
			variant = int.Parse(array[3]);
			name_characters = array[4];
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load NameLineupClue! ({_save}) | Error: {arg}");
		}
	}

	private void setUpNameCharacters(System.Random _rng)
	{
		if (variant == 1)
		{
			name_characters = SuspectClueHelper.getFirstCharOfFirstOrSecondName(_rng, gender, first_name_index, second_name_index).ToString();
			return;
		}
		string source = SuspectClueHelper.createName(gender, first_name_index, second_name_index);
		name_characters = source.Where((char _e) => !char.IsWhiteSpace(_e)).Distinct().ToList()
			.getRandomElementsFromList(_rng, 3)
			.Aggregate("", (string _a, char _c) => _a += _c);
	}

	private string englishFirstLetterClue(string _data)
	{
		return "The boss' first or second name begins with the letter '" + _data + "'.";
	}

	private string englishHasLettersClue(string _data_1, string _data_2, string _data_3)
	{
		return "The boss' name has the following letters in it: '" + _data_1 + "', '" + _data_2 + "' and '" + _data_3 + "'.";
	}

	protected override string getSaveData()
	{
		return string.Format("{0},{1},{2},{3},{4}", first_name_index, second_name_index, gender ? "t" : "f", variant, name_characters);
	}

	public override bool conforms(LineupSuspectInfo _clues)
	{
		string text = SuspectClueHelper.createName(_clues.male, _clues.first_name_index, _clues.second_name_index);
		if (variant == 1)
		{
			string[] array = text.Split(' ');
			if (array[0][0] != name_characters[0])
			{
				return array[1][0] == name_characters[0];
			}
			return true;
		}
		if (text.Contains(name_characters[0]) && text.Contains(name_characters[1]))
		{
			return text.Contains(name_characters[2]);
		}
		return false;
	}

	public override bool forceTruth(LineupSuspectInfo _clues, System.Random _rng)
	{
		return false;
	}

	public override bool forceError(LineupSuspectInfo _clue, System.Random _rng)
	{
		if (_clue.first_name_index == first_name_index)
		{
			_clue.first_name_index += ((_clue.first_name_index == 0) ? 1 : (-1));
		}
		return false;
	}

	public override Maybe<int> hasDataOn(ClueElementTypes _type)
	{
		return new Maybe<int>();
	}

	public override Maybe<(int, int)> hasDataOnName()
	{
		return (first_name_index, second_name_index).maybe();
	}
}
