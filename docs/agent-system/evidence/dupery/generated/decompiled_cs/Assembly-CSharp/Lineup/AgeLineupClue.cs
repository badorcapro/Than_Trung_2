using System;
using GRGLib.Extensions.Numbers;
using GRGLib.Generic;
using GRGLib.Maybe;
using Localisation;
using UnityEngine;

namespace Lineup;

public class AgeLineupClue : LineupClue
{
	public int age;

	public int variant;

	public MinMaxInt valid_ages;

	public override ClueElementTypes type => ClueElementTypes.AGE;

	public override string clue_text
	{
		get
		{
			if (!variant.between(2, 4, _inclusive: true))
			{
				return base.localisation_asset.checkTranslationWithData(loc_info_key, englishAgeOlderThan, valid_ages.min);
			}
			return base.localisation_asset.checkTranslation(loc_info_key, (variant == 2) ? new Func<string>(englishAge20) : ((variant == 3) ? new Func<string>(englishAge30) : new Func<string>(englishAge40)));
		}
	}

	public override string loc_info_key => constructLocKey(variant);

	public AgeLineupClue(System.Random _rng)
		: this(_rng.Next(21, 46), _rng)
	{
	}

	public AgeLineupClue(int _age, System.Random _rng)
	{
		age = _age;
		variant = ((_age <= 25) ? 1 : _rng.Next(0, 2));
		if (variant == 0)
		{
			valid_ages = new MinMaxInt(age - _rng.Next(1, 5), 99);
			return;
		}
		variant = age / 10;
		valid_ages = new MinMaxInt(age - age % 10, 10 + age - age % 10);
	}

	public AgeLineupClue(string _save)
	{
		try
		{
			string[] array = _save.Split(',');
			age = int.Parse(array[0]);
			variant = int.Parse(array[1]);
			int num = int.Parse(array[2]);
			if (variant == 0)
			{
				valid_ages = new MinMaxInt(num, 99);
			}
			else
			{
				valid_ages = new MinMaxInt(num, num + 10);
			}
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load AgeLineupClue from save! ({_save}) | Error: {arg}");
		}
	}

	public override bool conforms(LineupSuspectInfo _clues)
	{
		return _clues.age.between(valid_ages.min, valid_ages.max, _inclusive: true);
	}

	public override bool forceTruth(LineupSuspectInfo _clues, System.Random _rng)
	{
		_clues.age = _rng.Next(valid_ages.min, Mathf.Min(46, valid_ages.max));
		return true;
	}

	public override bool forceError(LineupSuspectInfo _clue, System.Random _rng)
	{
		_clue.age = getRandomWrongAge(_rng);
		return true;
	}

	public override Maybe<int> hasDataOn(ClueElementTypes _type)
	{
		if (_type != type)
		{
			return new Maybe<int>();
		}
		return age.maybe();
	}

	public override Maybe<int> hasNoneConformingDataOn(ClueElementTypes _type, System.Random _rng)
	{
		if (_type != type)
		{
			return new Maybe<int>();
		}
		return getRandomWrongAge(_rng).maybe();
	}

	private int getRandomWrongAge(System.Random _rng)
	{
		int num = _rng.Next(21, 46);
		if (num.between(valid_ages.min, valid_ages.max))
		{
			num = ((valid_ages.max >= 40) ? (valid_ages.min - _rng.Next(1, 5)) : (valid_ages.max + _rng.Next(1, 5)));
		}
		return num;
	}

	protected override string getSaveData()
	{
		return $"{age},{variant},{valid_ages.min}";
	}

	private string constructLocKey(int _variant)
	{
		return $"Clue [Age_{_variant}]";
	}

	private static string englishAge20()
	{
		return "I heard the boss is in their twenties";
	}

	private static string englishAge30()
	{
		return "I heard the boss is in their thirties";
	}

	private static string englishAge40()
	{
		return "I heard the boss is in their fourties";
	}

	private static string englishAgeOlderThan(string _data)
	{
		return "The boss is older than " + _data + ".";
	}
}
