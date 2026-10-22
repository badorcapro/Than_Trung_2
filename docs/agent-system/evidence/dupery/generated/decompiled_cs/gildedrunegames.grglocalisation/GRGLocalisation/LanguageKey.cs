using System;

namespace GRGLocalisation;

[Serializable]
public struct LanguageKey
{
	public int key;

	public LanguageKey(int _key)
	{
		key = _key;
	}

	public LanguageKey(Languages _language)
	{
		key = (int)_language;
	}

	public static implicit operator Languages(LanguageKey _a)
	{
		return (Languages)_a.key;
	}

	public static implicit operator LanguageKey(Languages _a)
	{
		return new LanguageKey(_a);
	}

	public static bool operator ==(LanguageKey lhs, LanguageKey rhs)
	{
		return lhs.key == rhs.key;
	}

	public static bool operator !=(LanguageKey lhs, LanguageKey rhs)
	{
		return lhs.key != rhs.key;
	}

	public override bool Equals(object obj)
	{
		if (obj.GetType() == typeof(LanguageKey))
		{
			return ((LanguageKey)obj).key == key;
		}
		return false;
	}

	public override int GetHashCode()
	{
		return key;
	}

	public override string ToString()
	{
		return getAssetName() ?? "";
	}

	private string getAssetName()
	{
		return key.ToString();
	}
}
