using System;
using System.Runtime.InteropServices;

namespace FMOD.Studio;

public struct VCA
{
	public IntPtr handle;

	public RESULT getID(out GUID id)
	{
		return FMOD_Studio_VCA_GetID(handle, out id);
	}

	public RESULT getPath(out string path)
	{
		path = null;
		using StringHelper.ThreadSafeEncoding threadSafeEncoding = StringHelper.GetFreeHelper();
		IntPtr intPtr = Marshal.AllocHGlobal(256);
		int retrieved = 0;
		RESULT rESULT = FMOD_Studio_VCA_GetPath(handle, intPtr, 256, out retrieved);
		if (rESULT == RESULT.ERR_TRUNCATED)
		{
			Marshal.FreeHGlobal(intPtr);
			intPtr = Marshal.AllocHGlobal(retrieved);
			rESULT = FMOD_Studio_VCA_GetPath(handle, intPtr, retrieved, out retrieved);
		}
		if (rESULT == RESULT.OK)
		{
			path = threadSafeEncoding.stringFromNative(intPtr);
		}
		Marshal.FreeHGlobal(intPtr);
		return rESULT;
	}

	public RESULT getVolume(out float volume)
	{
		float finalvolume;
		return getVolume(out volume, out finalvolume);
	}

	public RESULT getVolume(out float volume, out float finalvolume)
	{
		return FMOD_Studio_VCA_GetVolume(handle, out volume, out finalvolume);
	}

	public RESULT setVolume(float volume)
	{
		return FMOD_Studio_VCA_SetVolume(handle, volume);
	}

	[DllImport("fmodstudio")]
	private static extern bool FMOD_Studio_VCA_IsValid(IntPtr vca);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_VCA_GetID(IntPtr vca, out GUID id);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_VCA_GetPath(IntPtr vca, IntPtr path, int size, out int retrieved);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_VCA_GetVolume(IntPtr vca, out float volume, out float finalvolume);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_VCA_SetVolume(IntPtr vca, float volume);

	public VCA(IntPtr ptr)
	{
		handle = ptr;
	}

	public bool hasHandle()
	{
		return handle != IntPtr.Zero;
	}

	public void clearHandle()
	{
		handle = IntPtr.Zero;
	}

	public bool isValid()
	{
		if (hasHandle())
		{
			return FMOD_Studio_VCA_IsValid(handle);
		}
		return false;
	}
}
