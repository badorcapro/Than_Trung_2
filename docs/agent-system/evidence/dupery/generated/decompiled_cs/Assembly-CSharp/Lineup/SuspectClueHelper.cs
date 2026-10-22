using System;
using System.Collections.Generic;
using GRGLib.Extensions;
using GRGLib.Generic;
using GRGLib.Maybe;
using GRGLocalisation;
using Localisation;

namespace Lineup;

public static class SuspectClueHelper
{
	private static List<string> male_first_names = new List<string>
	{
		"MARCUS", "ALEXANDER", "CHRISTOPHER", "SAMUEL", "RYAN", "MASON", "JAMES", "BRANDON", "DAVID", "JOHN",
		"MATTHEW", "LUKE"
	};

	private static List<string> female_first_names = new List<string>
	{
		"REBECCA", "JESSICA", "VICTORIA", "OLIVIA", "GRACE", "LYDIA", "AMBER", "ANNA", "CHARLOTTE", "RUTH",
		"HELEN", "MADISON"
	};

	private static List<string> last_names = new List<string>
	{
		"MALLET", "FLETCHER", "FIGG", "CARRAWAY", "ACRES", "KERSWELL", "SMITH", "HYDE", "WALSH", "HILL",
		"MOSS", "REID"
	};

	private static List<string> heights = new List<string>
	{
		"5ft 3\"", "5ft 4\"", "5ft 5\"", "5ft 6\"", "5ft 7\"", "5ft 8\"", "5ft 9\"", "5ft 10\"", "5ft 11\"", "6ft",
		"6ft 1\"", "6ft 2\"", "6ft 3\"", "6ft 4\""
	};

	public static int male_first_name_list_length => male_first_names.Count;

	public static int female_first_name_list_length => female_first_names.Count;

	public static int last_name_list_length => last_names.Count;

	private static AssetKey localisation_asset => LocalisationHelper.lineup_asset;

	public static string createName(LineupSuspectInfo _clues)
	{
		return createName(_clues.male, _clues.first_name_index, _clues.second_name_index);
	}

	public static string createName(bool is_male, int _first_index, int _second_index)
	{
		return localisation_asset.checkTranslation(getLocFirstNameKey(is_male, _first_index), () => (!is_male) ? female_first_names[_first_index] : male_first_names[_first_index]) + " " + localisation_asset.checkTranslation(getLocLastNameKey(_second_index), () => last_names[_second_index]);
	}

	public static string getHeightString(int _height_index)
	{
		return localisation_asset.checkTranslation(getLocHeightKey(_height_index), () => heights[_height_index]);
	}

	public static char getFirstCharOfFirstOrSecondName(Random _r, bool is_male, int _first_index, int _second_index)
	{
		if (_r.Next(0, 2) == 1)
		{
			return localisation_asset.checkTranslation(getLocFirstNameKey(is_male, _first_index), () => (!is_male) ? female_first_names[_first_index] : male_first_names[_first_index])[0];
		}
		return localisation_asset.checkTranslation(getLocLastNameKey(_second_index), () => last_names[_second_index])[0];
	}

	public static bool getDataFromClueOrRandom(this List<LineupClue> _clues, ClueElementTypes _type, Random _rng, LineupSuspectInfo.ClueConformType _conformity)
	{
		return _clues.getDataFromClueOrRandom(_rng, (LineupClue _c) => _c.hasDataOn(_type), (int _i) => _i == 1, (Random _r) => _r.Next(0, 2) == 1, _conformity);
	}

	public static int getDataFromClueOrRandom(this List<LineupClue> _clues, ClueElementTypes _type, Random _rng, MinMaxInt _min_max_value, LineupSuspectInfo.ClueConformType _conformity)
	{
		return _clues.getDataFromClueOrRandom(_rng, (LineupClue _c) => _c.hasDataOn(_type), (int _i) => _i, (Random _r) => _min_max_value.get(_r), _conformity);
	}

	public static (int, int) getNameDataFromClueOrRandom(this List<LineupClue> _clues, Random _rng, bool _gender, LineupSuspectInfo.ClueConformType _conformity)
	{
		return _clues.getDataFromClueOrRandom(_rng, (LineupClue _c) => _c.hasDataOnName(), ((int, int) _i) => _i, (Random _r) => (_rng.Next(0, _gender ? male_first_name_list_length : female_first_name_list_length), _rng.Next(0, last_name_list_length)), _conformity);
	}

	private static T getDataFromClueOrRandom<T, T2>(this List<LineupClue> _clues, Random _rng, Func<LineupClue, Maybe<T2>> _fetch_data, Func<T2, T> _convert_data, Func<Random, T> _create, LineupSuspectInfo.ClueConformType _conformity)
	{
		if (_conformity.equalToAny(LineupSuspectInfo.ClueConformType.RANDOM_NOT_ALL, LineupSuspectInfo.ClueConformType.CONFORM_SOME))
		{
			return _create(_rng);
		}
		Maybe<T2> maybe = new Maybe<T2>();
		for (int i = 0; i < _clues.Count; i++)
		{
			if (maybe.is_some)
			{
				break;
			}
			maybe = _fetch_data(_clues[i]);
		}
		if (maybe.is_some)
		{
			return _convert_data(maybe.value);
		}
		return _create(_rng);
	}

	public static int getNoneConformingData(this List<LineupClue> _clues, ClueElementTypes _type, Random _rng, MinMaxInt _min_max_value)
	{
		Maybe<int> maybe = new Maybe<int>();
		for (int i = 0; i < _clues.Count; i++)
		{
			if (maybe.is_some)
			{
				break;
			}
			maybe = _clues[i].hasNoneConformingDataOn(_type, _rng);
		}
		if (maybe.is_some)
		{
			return maybe.value;
		}
		return _min_max_value.get(_rng);
	}

	private static int getRandomDifferent(MinMaxInt _min_max, int _value, Random _rng)
	{
		int num = _min_max.get(_rng);
		if (num == _value)
		{
			num++;
			if (num > _min_max.max)
			{
				num = _min_max.min;
			}
		}
		return num;
	}

	private static string getLocFirstNameKey(bool _male, int _index)
	{
		return string.Format("Suspect [Name_{0}{1}]", _male ? "m" : "f", _index);
	}

	private static string getLocLastNameKey(int _index)
	{
		return $"Suspect [Name_l{_index}]";
	}

	private static string getLocHeightKey(int _index)
	{
		return $"Suspect [Height_{_index}]";
	}
}
