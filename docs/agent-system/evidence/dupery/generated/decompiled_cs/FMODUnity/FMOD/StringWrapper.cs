using System;
using System.Runtime.InteropServices;

namespace FMOD;

public struct StringWrapper
{
	private IntPtr nativeUtf8Ptr;

	public StringWrapper(IntPtr ptr)
	{
		nativeUtf8Ptr = ptr;
	}

	public static implicit operator string(StringWrapper fstring)
	{
		using StringHelper.ThreadSafeEncoding threadSafeEncoding = StringHelper.GetFreeHelper();
		return threadSafeEncoding.stringFromNative(fstring.nativeUtf8Ptr);
	}

	public bool StartsWith(byte[] prefix)
	{
		if (nativeUtf8Ptr == IntPtr.Zero)
		{
			return false;
		}
		for (int i = 0; i < prefix.Length; i++)
		{
			if (Marshal.ReadByte(nativeUtf8Ptr, i) != prefix[i])
			{
				return false;
			}
		}
		return true;
	}

	public bool Equals(byte[] comparison)
	{
		if (nativeUtf8Ptr == IntPtr.Zero)
		{
			return false;
		}
		for (int i = 0; i < comparison.Length; i++)
		{
			if (Marshal.ReadByte(nativeUtf8Ptr, i) != comparison[i])
			{
				return false;
			}
		}
		if (Marshal.ReadByte(nativeUtf8Ptr, comparison.Length) != 0)
		{
			return false;
		}
		return true;
	}
}
