using System;

namespace GRGLocalisation;

[Serializable]
public struct SpriteAssetKey
{
	public int key;

	public SpriteAssetKey(int _key)
	{
		key = _key;
	}

	public static implicit operator int(SpriteAssetKey _a)
	{
		return _a.key;
	}

	public static implicit operator SpriteAssetKey(int _a)
	{
		return new SpriteAssetKey(_a);
	}

	public static bool operator ==(SpriteAssetKey lhs, SpriteAssetKey rhs)
	{
		return lhs.key == rhs.key;
	}

	public static bool operator !=(SpriteAssetKey lhs, SpriteAssetKey rhs)
	{
		return lhs.key != rhs.key;
	}

	public override bool Equals(object obj)
	{
		if (obj.GetType() == typeof(SpriteAssetKey))
		{
			return ((SpriteAssetKey)obj).key == key;
		}
		return false;
	}

	public override int GetHashCode()
	{
		return key;
	}

	public override string ToString()
	{
		return getAssetName();
	}

	private string getAssetName()
	{
		return key.ToString();
	}
}
