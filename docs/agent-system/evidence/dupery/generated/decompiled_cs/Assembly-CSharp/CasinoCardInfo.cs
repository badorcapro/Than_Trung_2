using System;
using GRGLib.Extensions.String;
using UnityEngine;

[Serializable]
public struct CasinoCardInfo
{
	public enum Suit
	{
		HEARTS,
		DIAMONDS,
		CLUBS,
		SPADES
	}

	public int value;

	public Suit suit;

	public static string jack_sprite_link_name => "c_jack";

	public static string queen_sprite_link_name => "c_queen";

	public static string king_sprite_link_name => "c_king";

	public bool is_face_card => value > 10;

	public static string getTextSpriteForSuit(Suit _suit)
	{
		return _suit switch
		{
			Suit.HEARTS => "<sprite name=\"s_heart\">", 
			Suit.DIAMONDS => "<sprite name=\"s_diamond\">", 
			Suit.CLUBS => "<sprite name=\"s_club\">", 
			Suit.SPADES => "<sprite name=\"s_spade\">", 
			_ => throw new ArgumentException("Suit was not hearts, diamonds, clubs or spades!!??? (CasinoCardInfo.getTextSpriteForSuit)"), 
		};
	}

	public static string getTextSpriteForSuitColoured(Suit _suit)
	{
		return getTextSpriteForSuit(_suit, getHexColourOfSuit(_suit));
	}

	public static string getHexColourOfSuit(Suit _suit)
	{
		return _suit switch
		{
			Suit.HEARTS => "C51F1F", 
			Suit.CLUBS => "248DC3", 
			Suit.DIAMONDS => "C58414", 
			Suit.SPADES => "A112FF", 
			_ => throw new ArgumentException("Suit was not hearts, diamonds, clubs or spades!!??? (CasinoCardInfo.getHexColourOfSuit)"), 
		};
	}

	public static string getTextSpriteForSuit(Suit _suit, Color _colour)
	{
		return getTextSpriteForSuit(_suit, ColorUtility.ToHtmlStringRGBA(_colour));
	}

	public static string getTextSpriteForSuit(Suit _suit, string _colour)
	{
		return _suit switch
		{
			Suit.HEARTS => "<sprite name=\"s_heart\" color=#" + _colour + ">", 
			Suit.DIAMONDS => "<sprite name=\"s_diamond\" color=#" + _colour + ">", 
			Suit.CLUBS => "<sprite name=\"s_club\" color=#" + _colour + ">", 
			Suit.SPADES => "<sprite name=\"s_spade\" color=#" + _colour + ">", 
			_ => throw new ArgumentException("Suit was not hearts, diamonds, clubs or spades!!??? (CasinoCardInfo.getTextSpriteForSuit)"), 
		};
	}

	public CasinoCardInfo(int _val, Suit _suit)
	{
		value = _val;
		suit = _suit;
	}

	public CasinoCardInfo(System.Random _rng)
	{
		int num = _rng.Next(1, 14);
		Suit suit = (Suit)_rng.Next(0, 4);
		value = num;
		this.suit = suit;
	}

	public static bool operator ==(CasinoCardInfo _a, CasinoCardInfo _b)
	{
		if (_a.value == _b.value)
		{
			return _a.suit == _b.suit;
		}
		return false;
	}

	public static bool operator !=(CasinoCardInfo _a, CasinoCardInfo _b)
	{
		if (_a.value == _b.value)
		{
			return _a.suit != _b.suit;
		}
		return true;
	}

	public static bool sameValue(CasinoCardInfo _a, CasinoCardInfo _b)
	{
		return _a.value == _b.value;
	}

	public static bool sameSuit(CasinoCardInfo _a, CasinoCardInfo _b)
	{
		return _a.suit == _b.suit;
	}

	public static int sumValues(CasinoCardInfo _a, CasinoCardInfo _b)
	{
		return _a.value + _b.value;
	}

	public static CasinoCardInfo parse(string _data)
	{
		string[] array = _data.Split('#');
		return new CasinoCardInfo(int.Parse(array[0]), (Suit)int.Parse(array[1]));
	}

	public static string toData(CasinoCardInfo _card)
	{
		return $"{_card.value}#{(int)_card.suit}";
	}

	public string toSymbolString()
	{
		return suitTextSprite() + valueString();
	}

	public string suitTextSprite()
	{
		return getTextSpriteForSuitColoured(suit);
	}

	public string valueString(bool _coloured = true)
	{
		if (value <= 10)
		{
			if (!_coloured)
			{
				return value.ToString();
			}
			return value.ToString().sandwichString("<color=#" + getHexColourOfSuit(suit) + ">", "</color>");
		}
		if (value == 11)
		{
			if (!_coloured)
			{
				return "<sprite name=\"" + jack_sprite_link_name + "\" color=#000000>";
			}
			return "<sprite name=\"" + jack_sprite_link_name + "\" color=#" + getHexColourOfSuit(suit) + ">";
		}
		if (value == 12)
		{
			if (!_coloured)
			{
				return "<sprite name=\"" + queen_sprite_link_name + "\" color=#000000>";
			}
			return "<sprite name=\"" + queen_sprite_link_name + "\" color=#" + getHexColourOfSuit(suit) + ">";
		}
		if (value == 13)
		{
			if (!_coloured)
			{
				return "<sprite name=\"" + king_sprite_link_name + "\" color=#000000>";
			}
			return "<sprite name=\"" + king_sprite_link_name + "\" color=#" + getHexColourOfSuit(suit) + ">";
		}
		Debug.LogError("Value was not between 1-13!!!");
		if (!_coloured)
		{
			return value.ToString();
		}
		return value.ToString().sandwichString("<color=#" + getHexColourOfSuit(suit) + ">", "</color>");
	}

	public override string ToString()
	{
		return $"{value} of {suit}";
	}

	public override bool Equals(object obj)
	{
		if (obj is CasinoCardInfo casinoCardInfo && casinoCardInfo.value == value)
		{
			return casinoCardInfo.suit == suit;
		}
		return false;
	}

	public override int GetHashCode()
	{
		return (int)suit * 10000 + value;
	}
}
