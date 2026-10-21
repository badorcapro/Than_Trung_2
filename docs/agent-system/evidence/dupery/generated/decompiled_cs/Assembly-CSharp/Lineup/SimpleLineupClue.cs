using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Localisation;
using UnityEngine;

namespace Lineup;

public class SimpleLineupClue : LineupClue
{
	private ClueElementTypes clue_type;

	private int variant;

	public override ClueElementTypes type => clue_type;

	public override string loc_info_key => constructLocKey(type, data, variant);

	public override string clue_text => base.localisation_asset.checkTranslation(loc_info_key, getEnglishText());

	public bool data { get; private set; }

	public SimpleLineupClue(List<LineupClue> _clues, ClueElementTypes _type, System.Random _rng)
	{
		clue_type = _type;
		variant = _rng.Next(0, 2);
		switch (_type)
		{
		case ClueElementTypes.GENDER:
		{
			LineupClue lineupClue3 = _clues.Find((LineupClue _c) => _c.type == ClueElementTypes.FACIAL_HAIR);
			if (lineupClue3 != null && lineupClue3 is SimpleLineupClue { data: not false })
			{
				data = true;
				return;
			}
			LineupClue lineupClue4 = _clues.Find((LineupClue _c) => _c.type == ClueElementTypes.NAME);
			if (lineupClue4 != null && lineupClue4 is NameLineupClue nameLineupClue2)
			{
				data = nameLineupClue2.gender;
				return;
			}
			break;
		}
		case ClueElementTypes.FACIAL_HAIR:
		{
			LineupClue lineupClue = _clues.Find((LineupClue _c) => _c.type == ClueElementTypes.GENDER);
			if (lineupClue != null && lineupClue is SimpleLineupClue { data: false })
			{
				data = false;
				return;
			}
			LineupClue lineupClue2 = _clues.Find((LineupClue _c) => _c.type == ClueElementTypes.NAME);
			if (lineupClue2 != null && lineupClue2 is NameLineupClue { gender: false })
			{
				data = false;
				return;
			}
			break;
		}
		}
		data = _rng.Next(0, 2) == 1;
	}

	public SimpleLineupClue(string _save)
	{
		try
		{
			string[] array = _save.Split(',');
			clue_type = (ClueElementTypes)int.Parse(array[0]);
			data = array[1] == "t";
			variant = int.Parse(array[2]);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load SimpleLineupClue! ({_save}) | Error: {arg}");
		}
	}

	public override bool conforms(LineupSuspectInfo _clues)
	{
		return clue_type switch
		{
			ClueElementTypes.GENDER => _clues.male == data, 
			ClueElementTypes.HAIR_OR_HAT => _clues.has_hair == data, 
			ClueElementTypes.FACIAL_HAIR => _clues.has_facial_hair == data, 
			ClueElementTypes.GLASSES => _clues.has_glasses == data, 
			ClueElementTypes.EARING => _clues.has_earing == data, 
			_ => throw new ArgumentException($"No confroms function set up for clue type {clue_type}!"), 
		};
	}

	public override bool forceTruth(LineupSuspectInfo _clues, System.Random _rng)
	{
		switch (type)
		{
		case ClueElementTypes.GENDER:
			_clues.male = data;
			return true;
		case ClueElementTypes.HAIR_OR_HAT:
			_clues.has_hair = data;
			_clues.has_hat = !data;
			return true;
		case ClueElementTypes.GLASSES:
			_clues.has_glasses = data;
			return true;
		case ClueElementTypes.FACIAL_HAIR:
			if (data)
			{
				_clues.male = true;
			}
			_clues.has_facial_hair = data;
			return true;
		case ClueElementTypes.EARING:
			_clues.has_earing = data;
			return true;
		default:
			Debug.LogError($"No ForceError function set up for type {type}!");
			return false;
		}
	}

	public override bool forceError(LineupSuspectInfo _clues, System.Random _rng)
	{
		switch (type)
		{
		case ClueElementTypes.GENDER:
			_clues.male = !data;
			if (_clues.has_facial_hair && !data)
			{
				_clues.has_facial_hair = false;
			}
			return true;
		case ClueElementTypes.HAIR_OR_HAT:
			_clues.has_hair = !data;
			_clues.has_hat = data;
			return true;
		case ClueElementTypes.GLASSES:
			_clues.has_glasses = !data;
			return true;
		case ClueElementTypes.FACIAL_HAIR:
			if (!_clues.male)
			{
				_clues.male = true;
			}
			_clues.has_facial_hair = !data;
			return true;
		case ClueElementTypes.EARING:
			_clues.has_earing = !data;
			return true;
		default:
			Debug.LogError($"No ForceError function set up for type {type}!");
			return false;
		}
	}

	public override Maybe<int> hasDataOn(ClueElementTypes _type)
	{
		if (_type == type)
		{
			return (data ? 1 : 0).maybe();
		}
		if (_type == ClueElementTypes.GENDER && type == ClueElementTypes.FACIAL_HAIR && data)
		{
			return 1.maybe();
		}
		if (_type == ClueElementTypes.FACIAL_HAIR && type == ClueElementTypes.GENDER && !data)
		{
			return 0.maybe();
		}
		return new Maybe<int>();
	}

	protected override string getSaveData()
	{
		return string.Format("{0},{1},{2}", (int)clue_type, data ? "t" : "f", variant);
	}

	private Func<string> getEnglishText()
	{
		return clue_type switch
		{
			ClueElementTypes.GENDER => (variant != 1) ? (data ? new Func<string>(englishGenderIsMale) : new Func<string>(englishGenderIsFemale)) : (data ? new Func<string>(englishGenderIsNotFemale) : new Func<string>(englishGenderIsNotMale)), 
			ClueElementTypes.HAIR_OR_HAT => (variant != 1) ? (data ? new Func<string>(englishHair) : new Func<string>(englishHat)) : (data ? new Func<string>(englishNoHat) : new Func<string>(englishNoHair)), 
			ClueElementTypes.FACIAL_HAIR => (variant != 1) ? (data ? new Func<string>(englishFacialHair) : new Func<string>(englishNoFacialHair)) : (data ? new Func<string>(englishFacialHairv1) : new Func<string>(englishNoFacialHairv1)), 
			ClueElementTypes.GLASSES => (variant != 1) ? (data ? new Func<string>(englishGlasses) : new Func<string>(englishNoGlasses)) : (data ? new Func<string>(englishGlassesv1) : new Func<string>(englishNoGlassesv1)), 
			ClueElementTypes.EARING => (variant != 1) ? (data ? new Func<string>(englishEaring) : new Func<string>(englishNoEaring)) : (data ? new Func<string>(englishEaringv1) : new Func<string>(englishNoEaringv1)), 
			_ => throw new ArgumentException($"No getEnglishText function set up for clue type {clue_type}!"), 
		};
	}

	private string constructLocKey(ClueElementTypes _type, bool _data, int _variant)
	{
		return $"Clue [{_type}_{_data}{_variant}]";
	}

	private string englishGenderIsMale()
	{
		return "I header the boss is a man.";
	}

	private string englishGenderIsNotMale()
	{
		return "I header the boss is a woman.";
	}

	private string englishGenderIsFemale()
	{
		return "I header the boss isn't a man.";
	}

	private string englishGenderIsNotFemale()
	{
		return "I header the boss isn't a woman.";
	}

	private string englishHair()
	{
		return "The boss hates to wear hats.";
	}

	private string englishHat()
	{
		return "The boss never leaves without their hat.";
	}

	private string englishNoHair()
	{
		return "The boss always tries to hide their hair with something.";
	}

	private string englishNoHat()
	{
		return "The boss loves showing off their hair.";
	}

	private string englishGlasses()
	{
		return "I'm pretty sure the boss wears glasses.";
	}

	private string englishNoGlasses()
	{
		return "I heard the boss has perfect vision.";
	}

	private string englishGlassesv1()
	{
		return "The boss has terrible vision I heard.";
	}

	private string englishNoGlassesv1()
	{
		return "I heard the boss wears contacts.";
	}

	private string englishFacialHair()
	{
		return "The boss has facial hair.";
	}

	private string englishNoFacialHair()
	{
		return "The boss is clean shaven.";
	}

	private string englishFacialHairv1()
	{
		return "The boss is never clean shaven.";
	}

	private string englishNoFacialHairv1()
	{
		return "The boss has no facial hair.";
	}

	private string englishEaring()
	{
		return "The boss always had their earings in.";
	}

	private string englishNoEaring()
	{
		return "The boss hates earings.";
	}

	private string englishEaringv1()
	{
		return "The boss loves earings.";
	}

	private string englishNoEaringv1()
	{
		return "The boss never wears earings.";
	}
}
