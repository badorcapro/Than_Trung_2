using System;

namespace GRGLocalisation;

[Serializable]
public struct AssetKey
{
	public int key;

	public AssetKey(int _key)
	{
		key = _key;
	}

	public static implicit operator int(AssetKey _a)
	{
		return _a.key;
	}

	public static implicit operator AssetKey(int _a)
	{
		return new AssetKey(_a);
	}

	public static bool operator ==(AssetKey lhs, AssetKey rhs)
	{
		return lhs.key == rhs.key;
	}

	public static bool operator !=(AssetKey lhs, AssetKey rhs)
	{
		return lhs.key != rhs.key;
	}

	public override bool Equals(object obj)
	{
		if (obj.GetType() == typeof(AssetKey))
		{
			return ((AssetKey)obj).key == key;
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
