using System;

namespace FMOD;

[Serializable]
public struct GUID : IEquatable<GUID>
{
	public int Data1;

	public int Data2;

	public int Data3;

	public int Data4;

	public bool IsNull
	{
		get
		{
			if (Data1 == 0 && Data2 == 0 && Data3 == 0)
			{
				return Data4 == 0;
			}
			return false;
		}
	}

	public GUID(Guid guid)
	{
		byte[] value = guid.ToByteArray();
		Data1 = BitConverter.ToInt32(value, 0);
		Data2 = BitConverter.ToInt32(value, 4);
		Data3 = BitConverter.ToInt32(value, 8);
		Data4 = BitConverter.ToInt32(value, 12);
	}

	public static GUID Parse(string s)
	{
		return new GUID(new Guid(s));
	}

	public override bool Equals(object other)
	{
		if (other is GUID)
		{
			return Equals((GUID)other);
		}
		return false;
	}

	public bool Equals(GUID other)
	{
		if (Data1 == other.Data1 && Data2 == other.Data2 && Data3 == other.Data3)
		{
			return Data4 == other.Data4;
		}
		return false;
	}

	public static bool operator ==(GUID a, GUID b)
	{
		return a.Equals(b);
	}

	public static bool operator !=(GUID a, GUID b)
	{
		return !a.Equals(b);
	}

	public override int GetHashCode()
	{
		return Data1 ^ Data2 ^ Data3 ^ Data4;
	}

	public static implicit operator Guid(GUID guid)
	{
		return new Guid(guid.Data1, (short)(guid.Data2 & 0xFFFF), (short)((guid.Data2 >> 16) & 0xFFFF), (byte)(guid.Data3 & 0xFF), (byte)((guid.Data3 >> 8) & 0xFF), (byte)((guid.Data3 >> 16) & 0xFF), (byte)((guid.Data3 >> 24) & 0xFF), (byte)(guid.Data4 & 0xFF), (byte)((guid.Data4 >> 8) & 0xFF), (byte)((guid.Data4 >> 16) & 0xFF), (byte)((guid.Data4 >> 24) & 0xFF));
	}

	public override string ToString()
	{
		return ((Guid)this).ToString("B");
	}
}
