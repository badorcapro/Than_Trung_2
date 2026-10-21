using System;

[Serializable]
public class CasinoCard
{
	public CasinoCardInfo info;

	public bool face_up;

	public bool smudged;

	public int value => info.value;

	public CasinoCardInfo.Suit suit => info.suit;

	public bool is_face_card => info.is_face_card;

	public CasinoCard(CasinoCardInfo _info, bool _face_up = true, bool _smudged = false)
	{
		info = _info;
		smudged = _smudged;
		face_up = _face_up;
	}

	public static bool operator ==(CasinoCard _a, CasinoCard _b)
	{
		if (object.Equals(_a, null))
		{
			return object.Equals(_b, null);
		}
		if (object.Equals(_b, null))
		{
			return false;
		}
		if (_a.value == _b.value && _a.suit == _b.suit && _a.smudged == _b.smudged)
		{
			return _a.face_up == _b.face_up;
		}
		return false;
	}

	public static bool operator !=(CasinoCard _a, CasinoCard _b)
	{
		if (object.Equals(_a, null))
		{
			return !object.Equals(_b, null);
		}
		if (object.Equals(_b, null))
		{
			return true;
		}
		if (_a.value == _b.value && _a.suit == _b.suit && _a.smudged == _b.smudged)
		{
			return _a.face_up != _b.face_up;
		}
		return true;
	}

	public static bool sameValue(CasinoCard _a, CasinoCard _b)
	{
		return _a.value == _b.value;
	}

	public static bool sameSuit(CasinoCard _a, CasinoCard _b)
	{
		return _a.suit == _b.suit;
	}

	public static int sumValues(CasinoCard _a, CasinoCard _b)
	{
		return _a.value + _b.value;
	}

	public static CasinoCard parse(string _data)
	{
		string[] array = _data.Split('#');
		return new CasinoCard(CasinoCardInfo.parse(_data), array[2] == "t", array[3] == "t");
	}

	public static string toData(CasinoCard _card)
	{
		return string.Format("{0}#{1}#{2}#{3}", _card.value, (int)_card.suit, _card.face_up ? "t" : "f", _card.smudged ? "t" : "f");
	}

	public override bool Equals(object obj)
	{
		if (!object.Equals(obj, null) && obj is CasinoCard casinoCard && casinoCard.value == value && casinoCard.suit == suit && casinoCard.smudged == smudged)
		{
			return casinoCard.face_up == face_up;
		}
		return false;
	}

	public override int GetHashCode()
	{
		return info.GetHashCode() + (smudged ? 1000 : 0) + (face_up ? 100 : 0);
	}
}
