using System;
using System.Runtime.InteropServices;

namespace FMOD.Studio;

public struct EventDescription
{
	public IntPtr handle;

	public RESULT getID(out GUID id)
	{
		return FMOD_Studio_EventDescription_GetID(handle, out id);
	}

	public RESULT getPath(out string path)
	{
		path = null;
		using StringHelper.ThreadSafeEncoding threadSafeEncoding = StringHelper.GetFreeHelper();
		IntPtr intPtr = Marshal.AllocHGlobal(256);
		int retrieved = 0;
		RESULT rESULT = FMOD_Studio_EventDescription_GetPath(handle, intPtr, 256, out retrieved);
		if (rESULT == RESULT.ERR_TRUNCATED)
		{
			Marshal.FreeHGlobal(intPtr);
			intPtr = Marshal.AllocHGlobal(retrieved);
			rESULT = FMOD_Studio_EventDescription_GetPath(handle, intPtr, retrieved, out retrieved);
		}
		if (rESULT == RESULT.OK)
		{
			path = threadSafeEncoding.stringFromNative(intPtr);
		}
		Marshal.FreeHGlobal(intPtr);
		return rESULT;
	}

	public RESULT getParameterDescriptionCount(out int count)
	{
		return FMOD_Studio_EventDescription_GetParameterDescriptionCount(handle, out count);
	}

	public RESULT getParameterDescriptionByIndex(int index, out PARAMETER_DESCRIPTION parameter)
	{
		return FMOD_Studio_EventDescription_GetParameterDescriptionByIndex(handle, index, out parameter);
	}

	public RESULT getParameterDescriptionByName(string name, out PARAMETER_DESCRIPTION parameter)
	{
		using StringHelper.ThreadSafeEncoding threadSafeEncoding = StringHelper.GetFreeHelper();
		return FMOD_Studio_EventDescription_GetParameterDescriptionByName(handle, threadSafeEncoding.byteFromStringUTF8(name), out parameter);
	}

	public RESULT getParameterDescriptionByID(PARAMETER_ID id, out PARAMETER_DESCRIPTION parameter)
	{
		return FMOD_Studio_EventDescription_GetParameterDescriptionByID(handle, id, out parameter);
	}

	public RESULT getParameterLabelByIndex(int index, int labelindex, out string label)
	{
		label = null;
		using StringHelper.ThreadSafeEncoding threadSafeEncoding = StringHelper.GetFreeHelper();
		IntPtr intPtr = Marshal.AllocHGlobal(256);
		int retrieved = 0;
		RESULT rESULT = FMOD_Studio_EventDescription_GetParameterLabelByIndex(handle, index, labelindex, intPtr, 256, out retrieved);
		if (rESULT == RESULT.ERR_TRUNCATED)
		{
			Marshal.FreeHGlobal(intPtr);
			rESULT = FMOD_Studio_EventDescription_GetParameterLabelByIndex(handle, index, labelindex, IntPtr.Zero, 0, out retrieved);
			intPtr = Marshal.AllocHGlobal(retrieved);
			rESULT = FMOD_Studio_EventDescription_GetParameterLabelByIndex(handle, index, labelindex, intPtr, retrieved, out retrieved);
		}
		if (rESULT == RESULT.OK)
		{
			label = threadSafeEncoding.stringFromNative(intPtr);
		}
		Marshal.FreeHGlobal(intPtr);
		return rESULT;
	}

	public RESULT getParameterLabelByName(string name, int labelindex, out string label)
	{
		label = null;
		using StringHelper.ThreadSafeEncoding threadSafeEncoding = StringHelper.GetFreeHelper();
		IntPtr intPtr = Marshal.AllocHGlobal(256);
		int retrieved = 0;
		byte[] name2 = threadSafeEncoding.byteFromStringUTF8(name);
		RESULT rESULT = FMOD_Studio_EventDescription_GetParameterLabelByName(handle, name2, labelindex, intPtr, 256, out retrieved);
		if (rESULT == RESULT.ERR_TRUNCATED)
		{
			Marshal.FreeHGlobal(intPtr);
			rESULT = FMOD_Studio_EventDescription_GetParameterLabelByName(handle, name2, labelindex, IntPtr.Zero, 0, out retrieved);
			intPtr = Marshal.AllocHGlobal(retrieved);
			rESULT = FMOD_Studio_EventDescription_GetParameterLabelByName(handle, name2, labelindex, intPtr, retrieved, out retrieved);
		}
		if (rESULT == RESULT.OK)
		{
			label = threadSafeEncoding.stringFromNative(intPtr);
		}
		Marshal.FreeHGlobal(intPtr);
		return rESULT;
	}

	public RESULT getParameterLabelByID(PARAMETER_ID id, int labelindex, out string label)
	{
		label = null;
		using StringHelper.ThreadSafeEncoding threadSafeEncoding = StringHelper.GetFreeHelper();
		IntPtr intPtr = Marshal.AllocHGlobal(256);
		int retrieved = 0;
		RESULT rESULT = FMOD_Studio_EventDescription_GetParameterLabelByID(handle, id, labelindex, intPtr, 256, out retrieved);
		if (rESULT == RESULT.ERR_TRUNCATED)
		{
			Marshal.FreeHGlobal(intPtr);
			rESULT = FMOD_Studio_EventDescription_GetParameterLabelByID(handle, id, labelindex, IntPtr.Zero, 0, out retrieved);
			intPtr = Marshal.AllocHGlobal(retrieved);
			rESULT = FMOD_Studio_EventDescription_GetParameterLabelByID(handle, id, labelindex, intPtr, retrieved, out retrieved);
		}
		if (rESULT == RESULT.OK)
		{
			label = threadSafeEncoding.stringFromNative(intPtr);
		}
		Marshal.FreeHGlobal(intPtr);
		return rESULT;
	}

	public RESULT getUserPropertyCount(out int count)
	{
		return FMOD_Studio_EventDescription_GetUserPropertyCount(handle, out count);
	}

	public RESULT getUserPropertyByIndex(int index, out USER_PROPERTY property)
	{
		return FMOD_Studio_EventDescription_GetUserPropertyByIndex(handle, index, out property);
	}

	public RESULT getUserProperty(string name, out USER_PROPERTY property)
	{
		using StringHelper.ThreadSafeEncoding threadSafeEncoding = StringHelper.GetFreeHelper();
		return FMOD_Studio_EventDescription_GetUserProperty(handle, threadSafeEncoding.byteFromStringUTF8(name), out property);
	}

	public RESULT getLength(out int length)
	{
		return FMOD_Studio_EventDescription_GetLength(handle, out length);
	}

	public RESULT getMinMaxDistance(out float min, out float max)
	{
		return FMOD_Studio_EventDescription_GetMinMaxDistance(handle, out min, out max);
	}

	public RESULT getSoundSize(out float size)
	{
		return FMOD_Studio_EventDescription_GetSoundSize(handle, out size);
	}

	public RESULT isSnapshot(out bool snapshot)
	{
		return FMOD_Studio_EventDescription_IsSnapshot(handle, out snapshot);
	}

	public RESULT isOneshot(out bool oneshot)
	{
		return FMOD_Studio_EventDescription_IsOneshot(handle, out oneshot);
	}

	public RESULT isStream(out bool isStream)
	{
		return FMOD_Studio_EventDescription_IsStream(handle, out isStream);
	}

	public RESULT is3D(out bool is3D)
	{
		return FMOD_Studio_EventDescription_Is3D(handle, out is3D);
	}

	public RESULT isDopplerEnabled(out bool doppler)
	{
		return FMOD_Studio_EventDescription_IsDopplerEnabled(handle, out doppler);
	}

	public RESULT hasSustainPoint(out bool sustainPoint)
	{
		return FMOD_Studio_EventDescription_HasSustainPoint(handle, out sustainPoint);
	}

	public RESULT createInstance(out EventInstance instance)
	{
		return FMOD_Studio_EventDescription_CreateInstance(handle, out instance.handle);
	}

	public RESULT getInstanceCount(out int count)
	{
		return FMOD_Studio_EventDescription_GetInstanceCount(handle, out count);
	}

	public RESULT getInstanceList(out EventInstance[] array)
	{
		array = null;
		RESULT rESULT = FMOD_Studio_EventDescription_GetInstanceCount(handle, out var count);
		if (rESULT != 0)
		{
			return rESULT;
		}
		if (count == 0)
		{
			array = new EventInstance[0];
			return rESULT;
		}
		IntPtr[] array2 = new IntPtr[count];
		rESULT = FMOD_Studio_EventDescription_GetInstanceList(handle, array2, count, out var count2);
		if (rESULT != 0)
		{
			return rESULT;
		}
		if (count2 > count)
		{
			count2 = count;
		}
		array = new EventInstance[count2];
		for (int i = 0; i < count2; i++)
		{
			array[i].handle = array2[i];
		}
		return RESULT.OK;
	}

	public RESULT loadSampleData()
	{
		return FMOD_Studio_EventDescription_LoadSampleData(handle);
	}

	public RESULT unloadSampleData()
	{
		return FMOD_Studio_EventDescription_UnloadSampleData(handle);
	}

	public RESULT getSampleLoadingState(out LOADING_STATE state)
	{
		return FMOD_Studio_EventDescription_GetSampleLoadingState(handle, out state);
	}

	public RESULT releaseAllInstances()
	{
		return FMOD_Studio_EventDescription_ReleaseAllInstances(handle);
	}

	public RESULT setCallback(EVENT_CALLBACK callback, EVENT_CALLBACK_TYPE callbackmask = EVENT_CALLBACK_TYPE.ALL)
	{
		return FMOD_Studio_EventDescription_SetCallback(handle, callback, callbackmask);
	}

	public RESULT getUserData(out IntPtr userdata)
	{
		return FMOD_Studio_EventDescription_GetUserData(handle, out userdata);
	}

	public RESULT setUserData(IntPtr userdata)
	{
		return FMOD_Studio_EventDescription_SetUserData(handle, userdata);
	}

	[DllImport("fmodstudio")]
	private static extern bool FMOD_Studio_EventDescription_IsValid(IntPtr eventdescription);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventDescription_GetID(IntPtr eventdescription, out GUID id);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventDescription_GetPath(IntPtr eventdescription, IntPtr path, int size, out int retrieved);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventDescription_GetParameterDescriptionCount(IntPtr eventdescription, out int count);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventDescription_GetParameterDescriptionByIndex(IntPtr eventdescription, int index, out PARAMETER_DESCRIPTION parameter);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventDescription_GetParameterDescriptionByName(IntPtr eventdescription, byte[] name, out PARAMETER_DESCRIPTION parameter);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventDescription_GetParameterDescriptionByID(IntPtr eventdescription, PARAMETER_ID id, out PARAMETER_DESCRIPTION parameter);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventDescription_GetParameterLabelByIndex(IntPtr eventdescription, int index, int labelindex, IntPtr label, int size, out int retrieved);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventDescription_GetParameterLabelByName(IntPtr eventdescription, byte[] name, int labelindex, IntPtr label, int size, out int retrieved);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventDescription_GetParameterLabelByID(IntPtr eventdescription, PARAMETER_ID id, int labelindex, IntPtr label, int size, out int retrieved);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventDescription_GetUserPropertyCount(IntPtr eventdescription, out int count);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventDescription_GetUserPropertyByIndex(IntPtr eventdescription, int index, out USER_PROPERTY property);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventDescription_GetUserProperty(IntPtr eventdescription, byte[] name, out USER_PROPERTY property);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventDescription_GetLength(IntPtr eventdescription, out int length);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventDescription_GetMinMaxDistance(IntPtr eventdescription, out float min, out float max);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventDescription_GetSoundSize(IntPtr eventdescription, out float size);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventDescription_IsSnapshot(IntPtr eventdescription, out bool snapshot);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventDescription_IsOneshot(IntPtr eventdescription, out bool oneshot);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventDescription_IsStream(IntPtr eventdescription, out bool isStream);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventDescription_Is3D(IntPtr eventdescription, out bool is3D);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventDescription_IsDopplerEnabled(IntPtr eventdescription, out bool doppler);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventDescription_HasSustainPoint(IntPtr eventdescription, out bool sustainPoint);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventDescription_CreateInstance(IntPtr eventdescription, out IntPtr instance);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventDescription_GetInstanceCount(IntPtr eventdescription, out int count);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventDescription_GetInstanceList(IntPtr eventdescription, IntPtr[] array, int capacity, out int count);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventDescription_LoadSampleData(IntPtr eventdescription);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventDescription_UnloadSampleData(IntPtr eventdescription);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventDescription_GetSampleLoadingState(IntPtr eventdescription, out LOADING_STATE state);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventDescription_ReleaseAllInstances(IntPtr eventdescription);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventDescription_SetCallback(IntPtr eventdescription, EVENT_CALLBACK callback, EVENT_CALLBACK_TYPE callbackmask);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventDescription_GetUserData(IntPtr eventdescription, out IntPtr userdata);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventDescription_SetUserData(IntPtr eventdescription, IntPtr userdata);

	public EventDescription(IntPtr ptr)
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
			return FMOD_Studio_EventDescription_IsValid(handle);
		}
		return false;
	}
}
