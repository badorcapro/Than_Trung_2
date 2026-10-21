using System;
using System.Runtime.InteropServices;

namespace FMOD.Studio;

public struct EventInstance
{
	public IntPtr handle;

	public RESULT getDescription(out EventDescription description)
	{
		return FMOD_Studio_EventInstance_GetDescription(handle, out description.handle);
	}

	public RESULT getSystem(out System system)
	{
		return FMOD_Studio_EventInstance_GetSystem(handle, out system.handle);
	}

	public RESULT getVolume(out float volume)
	{
		return FMOD_Studio_EventInstance_GetVolume(handle, out volume, IntPtr.Zero);
	}

	public RESULT getVolume(out float volume, out float finalvolume)
	{
		return FMOD_Studio_EventInstance_GetVolume(handle, out volume, out finalvolume);
	}

	public RESULT setVolume(float volume)
	{
		return FMOD_Studio_EventInstance_SetVolume(handle, volume);
	}

	public RESULT getPitch(out float pitch)
	{
		return FMOD_Studio_EventInstance_GetPitch(handle, out pitch, IntPtr.Zero);
	}

	public RESULT getPitch(out float pitch, out float finalpitch)
	{
		return FMOD_Studio_EventInstance_GetPitch(handle, out pitch, out finalpitch);
	}

	public RESULT setPitch(float pitch)
	{
		return FMOD_Studio_EventInstance_SetPitch(handle, pitch);
	}

	public RESULT get3DAttributes(out ATTRIBUTES_3D attributes)
	{
		return FMOD_Studio_EventInstance_Get3DAttributes(handle, out attributes);
	}

	public RESULT set3DAttributes(ATTRIBUTES_3D attributes)
	{
		return FMOD_Studio_EventInstance_Set3DAttributes(handle, ref attributes);
	}

	public RESULT getListenerMask(out uint mask)
	{
		return FMOD_Studio_EventInstance_GetListenerMask(handle, out mask);
	}

	public RESULT setListenerMask(uint mask)
	{
		return FMOD_Studio_EventInstance_SetListenerMask(handle, mask);
	}

	public RESULT getProperty(EVENT_PROPERTY index, out float value)
	{
		return FMOD_Studio_EventInstance_GetProperty(handle, index, out value);
	}

	public RESULT setProperty(EVENT_PROPERTY index, float value)
	{
		return FMOD_Studio_EventInstance_SetProperty(handle, index, value);
	}

	public RESULT getReverbLevel(int index, out float level)
	{
		return FMOD_Studio_EventInstance_GetReverbLevel(handle, index, out level);
	}

	public RESULT setReverbLevel(int index, float level)
	{
		return FMOD_Studio_EventInstance_SetReverbLevel(handle, index, level);
	}

	public RESULT getPaused(out bool paused)
	{
		return FMOD_Studio_EventInstance_GetPaused(handle, out paused);
	}

	public RESULT setPaused(bool paused)
	{
		return FMOD_Studio_EventInstance_SetPaused(handle, paused);
	}

	public RESULT start()
	{
		return FMOD_Studio_EventInstance_Start(handle);
	}

	public RESULT stop(STOP_MODE mode)
	{
		return FMOD_Studio_EventInstance_Stop(handle, mode);
	}

	public RESULT getTimelinePosition(out int position)
	{
		return FMOD_Studio_EventInstance_GetTimelinePosition(handle, out position);
	}

	public RESULT setTimelinePosition(int position)
	{
		return FMOD_Studio_EventInstance_SetTimelinePosition(handle, position);
	}

	public RESULT getPlaybackState(out PLAYBACK_STATE state)
	{
		return FMOD_Studio_EventInstance_GetPlaybackState(handle, out state);
	}

	public RESULT getChannelGroup(out ChannelGroup group)
	{
		return FMOD_Studio_EventInstance_GetChannelGroup(handle, out group.handle);
	}

	public RESULT getMinMaxDistance(out float min, out float max)
	{
		return FMOD_Studio_EventInstance_GetMinMaxDistance(handle, out min, out max);
	}

	public RESULT release()
	{
		return FMOD_Studio_EventInstance_Release(handle);
	}

	public RESULT isVirtual(out bool virtualstate)
	{
		return FMOD_Studio_EventInstance_IsVirtual(handle, out virtualstate);
	}

	public RESULT getParameterByID(PARAMETER_ID id, out float value)
	{
		float finalvalue;
		return getParameterByID(id, out value, out finalvalue);
	}

	public RESULT getParameterByID(PARAMETER_ID id, out float value, out float finalvalue)
	{
		return FMOD_Studio_EventInstance_GetParameterByID(handle, id, out value, out finalvalue);
	}

	public RESULT setParameterByID(PARAMETER_ID id, float value, bool ignoreseekspeed = false)
	{
		return FMOD_Studio_EventInstance_SetParameterByID(handle, id, value, ignoreseekspeed);
	}

	public RESULT setParameterByIDWithLabel(PARAMETER_ID id, string label, bool ignoreseekspeed = false)
	{
		using StringHelper.ThreadSafeEncoding threadSafeEncoding = StringHelper.GetFreeHelper();
		return FMOD_Studio_EventInstance_SetParameterByIDWithLabel(handle, id, threadSafeEncoding.byteFromStringUTF8(label), ignoreseekspeed);
	}

	public RESULT setParametersByIDs(PARAMETER_ID[] ids, float[] values, int count, bool ignoreseekspeed = false)
	{
		return FMOD_Studio_EventInstance_SetParametersByIDs(handle, ids, values, count, ignoreseekspeed);
	}

	public RESULT getParameterByName(string name, out float value)
	{
		float finalvalue;
		return getParameterByName(name, out value, out finalvalue);
	}

	public RESULT getParameterByName(string name, out float value, out float finalvalue)
	{
		using StringHelper.ThreadSafeEncoding threadSafeEncoding = StringHelper.GetFreeHelper();
		return FMOD_Studio_EventInstance_GetParameterByName(handle, threadSafeEncoding.byteFromStringUTF8(name), out value, out finalvalue);
	}

	public RESULT setParameterByName(string name, float value, bool ignoreseekspeed = false)
	{
		using StringHelper.ThreadSafeEncoding threadSafeEncoding = StringHelper.GetFreeHelper();
		return FMOD_Studio_EventInstance_SetParameterByName(handle, threadSafeEncoding.byteFromStringUTF8(name), value, ignoreseekspeed);
	}

	public RESULT setParameterByNameWithLabel(string name, string label, bool ignoreseekspeed = false)
	{
		using StringHelper.ThreadSafeEncoding threadSafeEncoding = StringHelper.GetFreeHelper();
		using StringHelper.ThreadSafeEncoding threadSafeEncoding2 = StringHelper.GetFreeHelper();
		return FMOD_Studio_EventInstance_SetParameterByNameWithLabel(handle, threadSafeEncoding.byteFromStringUTF8(name), threadSafeEncoding2.byteFromStringUTF8(label), ignoreseekspeed);
	}

	public RESULT keyOff()
	{
		return FMOD_Studio_EventInstance_KeyOff(handle);
	}

	public RESULT setCallback(EVENT_CALLBACK callback, EVENT_CALLBACK_TYPE callbackmask = EVENT_CALLBACK_TYPE.ALL)
	{
		return FMOD_Studio_EventInstance_SetCallback(handle, callback, callbackmask);
	}

	public RESULT getUserData(out IntPtr userdata)
	{
		return FMOD_Studio_EventInstance_GetUserData(handle, out userdata);
	}

	public RESULT setUserData(IntPtr userdata)
	{
		return FMOD_Studio_EventInstance_SetUserData(handle, userdata);
	}

	public RESULT getCPUUsage(out uint exclusive, out uint inclusive)
	{
		return FMOD_Studio_EventInstance_GetCPUUsage(handle, out exclusive, out inclusive);
	}

	public RESULT getMemoryUsage(out MEMORY_USAGE memoryusage)
	{
		return FMOD_Studio_EventInstance_GetMemoryUsage(handle, out memoryusage);
	}

	[DllImport("fmodstudio")]
	private static extern bool FMOD_Studio_EventInstance_IsValid(IntPtr _event);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventInstance_GetDescription(IntPtr _event, out IntPtr description);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventInstance_GetSystem(IntPtr _event, out IntPtr system);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventInstance_GetVolume(IntPtr _event, out float volume, IntPtr zero);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventInstance_GetVolume(IntPtr _event, out float volume, out float finalvolume);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventInstance_SetVolume(IntPtr _event, float volume);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventInstance_GetPitch(IntPtr _event, out float pitch, IntPtr zero);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventInstance_GetPitch(IntPtr _event, out float pitch, out float finalpitch);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventInstance_SetPitch(IntPtr _event, float pitch);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventInstance_Get3DAttributes(IntPtr _event, out ATTRIBUTES_3D attributes);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventInstance_Set3DAttributes(IntPtr _event, ref ATTRIBUTES_3D attributes);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventInstance_GetListenerMask(IntPtr _event, out uint mask);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventInstance_SetListenerMask(IntPtr _event, uint mask);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventInstance_GetProperty(IntPtr _event, EVENT_PROPERTY index, out float value);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventInstance_SetProperty(IntPtr _event, EVENT_PROPERTY index, float value);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventInstance_GetReverbLevel(IntPtr _event, int index, out float level);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventInstance_SetReverbLevel(IntPtr _event, int index, float level);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventInstance_GetPaused(IntPtr _event, out bool paused);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventInstance_SetPaused(IntPtr _event, bool paused);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventInstance_Start(IntPtr _event);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventInstance_Stop(IntPtr _event, STOP_MODE mode);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventInstance_GetTimelinePosition(IntPtr _event, out int position);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventInstance_SetTimelinePosition(IntPtr _event, int position);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventInstance_GetPlaybackState(IntPtr _event, out PLAYBACK_STATE state);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventInstance_GetChannelGroup(IntPtr _event, out IntPtr group);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventInstance_GetMinMaxDistance(IntPtr _event, out float min, out float max);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventInstance_Release(IntPtr _event);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventInstance_IsVirtual(IntPtr _event, out bool virtualstate);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventInstance_GetParameterByName(IntPtr _event, byte[] name, out float value, out float finalvalue);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventInstance_SetParameterByName(IntPtr _event, byte[] name, float value, bool ignoreseekspeed);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventInstance_SetParameterByNameWithLabel(IntPtr _event, byte[] name, byte[] label, bool ignoreseekspeed);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventInstance_GetParameterByID(IntPtr _event, PARAMETER_ID id, out float value, out float finalvalue);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventInstance_SetParameterByID(IntPtr _event, PARAMETER_ID id, float value, bool ignoreseekspeed);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventInstance_SetParameterByIDWithLabel(IntPtr _event, PARAMETER_ID id, byte[] label, bool ignoreseekspeed);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventInstance_SetParametersByIDs(IntPtr _event, PARAMETER_ID[] ids, float[] values, int count, bool ignoreseekspeed);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventInstance_KeyOff(IntPtr _event);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventInstance_SetCallback(IntPtr _event, EVENT_CALLBACK callback, EVENT_CALLBACK_TYPE callbackmask);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventInstance_GetUserData(IntPtr _event, out IntPtr userdata);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventInstance_SetUserData(IntPtr _event, IntPtr userdata);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventInstance_GetCPUUsage(IntPtr _event, out uint exclusive, out uint inclusive);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_EventInstance_GetMemoryUsage(IntPtr _event, out MEMORY_USAGE memoryusage);

	public EventInstance(IntPtr ptr)
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
			return FMOD_Studio_EventInstance_IsValid(handle);
		}
		return false;
	}
}
