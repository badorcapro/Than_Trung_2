using System;
using System.Runtime.InteropServices;

namespace FMOD.Studio;

public struct System
{
	public IntPtr handle;

	public static RESULT create(out System system)
	{
		return FMOD_Studio_System_Create(out system.handle, 131849u);
	}

	public RESULT setAdvancedSettings(ADVANCEDSETTINGS settings)
	{
		settings.cbsize = Marshal.SizeOf<ADVANCEDSETTINGS>();
		return FMOD_Studio_System_SetAdvancedSettings(handle, ref settings);
	}

	public RESULT setAdvancedSettings(ADVANCEDSETTINGS settings, string encryptionKey)
	{
		using StringHelper.ThreadSafeEncoding threadSafeEncoding = StringHelper.GetFreeHelper();
		IntPtr encryptionkey = settings.encryptionkey;
		settings.encryptionkey = threadSafeEncoding.intptrFromStringUTF8(encryptionKey);
		RESULT result = setAdvancedSettings(settings);
		settings.encryptionkey = encryptionkey;
		return result;
	}

	public RESULT getAdvancedSettings(out ADVANCEDSETTINGS settings)
	{
		settings.cbsize = Marshal.SizeOf<ADVANCEDSETTINGS>();
		return FMOD_Studio_System_GetAdvancedSettings(handle, out settings);
	}

	public RESULT initialize(int maxchannels, INITFLAGS studioflags, FMOD.INITFLAGS flags, IntPtr extradriverdata)
	{
		return FMOD_Studio_System_Initialize(handle, maxchannels, studioflags, flags, extradriverdata);
	}

	public RESULT release()
	{
		return FMOD_Studio_System_Release(handle);
	}

	public RESULT update()
	{
		return FMOD_Studio_System_Update(handle);
	}

	public RESULT getCoreSystem(out FMOD.System coresystem)
	{
		return FMOD_Studio_System_GetCoreSystem(handle, out coresystem.handle);
	}

	public RESULT getEvent(string path, out EventDescription _event)
	{
		using StringHelper.ThreadSafeEncoding threadSafeEncoding = StringHelper.GetFreeHelper();
		return FMOD_Studio_System_GetEvent(handle, threadSafeEncoding.byteFromStringUTF8(path), out _event.handle);
	}

	public RESULT getBus(string path, out Bus bus)
	{
		using StringHelper.ThreadSafeEncoding threadSafeEncoding = StringHelper.GetFreeHelper();
		return FMOD_Studio_System_GetBus(handle, threadSafeEncoding.byteFromStringUTF8(path), out bus.handle);
	}

	public RESULT getVCA(string path, out VCA vca)
	{
		using StringHelper.ThreadSafeEncoding threadSafeEncoding = StringHelper.GetFreeHelper();
		return FMOD_Studio_System_GetVCA(handle, threadSafeEncoding.byteFromStringUTF8(path), out vca.handle);
	}

	public RESULT getBank(string path, out Bank bank)
	{
		using StringHelper.ThreadSafeEncoding threadSafeEncoding = StringHelper.GetFreeHelper();
		return FMOD_Studio_System_GetBank(handle, threadSafeEncoding.byteFromStringUTF8(path), out bank.handle);
	}

	public RESULT getEventByID(GUID id, out EventDescription _event)
	{
		return FMOD_Studio_System_GetEventByID(handle, ref id, out _event.handle);
	}

	public RESULT getBusByID(GUID id, out Bus bus)
	{
		return FMOD_Studio_System_GetBusByID(handle, ref id, out bus.handle);
	}

	public RESULT getVCAByID(GUID id, out VCA vca)
	{
		return FMOD_Studio_System_GetVCAByID(handle, ref id, out vca.handle);
	}

	public RESULT getBankByID(GUID id, out Bank bank)
	{
		return FMOD_Studio_System_GetBankByID(handle, ref id, out bank.handle);
	}

	public RESULT getSoundInfo(string key, out SOUND_INFO info)
	{
		using StringHelper.ThreadSafeEncoding threadSafeEncoding = StringHelper.GetFreeHelper();
		return FMOD_Studio_System_GetSoundInfo(handle, threadSafeEncoding.byteFromStringUTF8(key), out info);
	}

	public RESULT getParameterDescriptionByName(string name, out PARAMETER_DESCRIPTION parameter)
	{
		using StringHelper.ThreadSafeEncoding threadSafeEncoding = StringHelper.GetFreeHelper();
		return FMOD_Studio_System_GetParameterDescriptionByName(handle, threadSafeEncoding.byteFromStringUTF8(name), out parameter);
	}

	public RESULT getParameterDescriptionByID(PARAMETER_ID id, out PARAMETER_DESCRIPTION parameter)
	{
		return FMOD_Studio_System_GetParameterDescriptionByID(handle, id, out parameter);
	}

	public RESULT getParameterLabelByName(string name, int labelindex, out string label)
	{
		label = null;
		using StringHelper.ThreadSafeEncoding threadSafeEncoding = StringHelper.GetFreeHelper();
		IntPtr intPtr = Marshal.AllocHGlobal(256);
		int retrieved = 0;
		byte[] name2 = threadSafeEncoding.byteFromStringUTF8(name);
		RESULT rESULT = FMOD_Studio_System_GetParameterLabelByName(handle, name2, labelindex, intPtr, 256, out retrieved);
		if (rESULT == RESULT.ERR_TRUNCATED)
		{
			Marshal.FreeHGlobal(intPtr);
			rESULT = FMOD_Studio_System_GetParameterLabelByName(handle, name2, labelindex, IntPtr.Zero, 0, out retrieved);
			intPtr = Marshal.AllocHGlobal(retrieved);
			rESULT = FMOD_Studio_System_GetParameterLabelByName(handle, name2, labelindex, intPtr, retrieved, out retrieved);
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
		RESULT rESULT = FMOD_Studio_System_GetParameterLabelByID(handle, id, labelindex, intPtr, 256, out retrieved);
		if (rESULT == RESULT.ERR_TRUNCATED)
		{
			Marshal.FreeHGlobal(intPtr);
			rESULT = FMOD_Studio_System_GetParameterLabelByID(handle, id, labelindex, IntPtr.Zero, 0, out retrieved);
			intPtr = Marshal.AllocHGlobal(retrieved);
			rESULT = FMOD_Studio_System_GetParameterLabelByID(handle, id, labelindex, intPtr, retrieved, out retrieved);
		}
		if (rESULT == RESULT.OK)
		{
			label = threadSafeEncoding.stringFromNative(intPtr);
		}
		Marshal.FreeHGlobal(intPtr);
		return rESULT;
	}

	public RESULT getParameterByID(PARAMETER_ID id, out float value)
	{
		float finalvalue;
		return getParameterByID(id, out value, out finalvalue);
	}

	public RESULT getParameterByID(PARAMETER_ID id, out float value, out float finalvalue)
	{
		return FMOD_Studio_System_GetParameterByID(handle, id, out value, out finalvalue);
	}

	public RESULT setParameterByID(PARAMETER_ID id, float value, bool ignoreseekspeed = false)
	{
		return FMOD_Studio_System_SetParameterByID(handle, id, value, ignoreseekspeed);
	}

	public RESULT setParameterByIDWithLabel(PARAMETER_ID id, string label, bool ignoreseekspeed = false)
	{
		using StringHelper.ThreadSafeEncoding threadSafeEncoding = StringHelper.GetFreeHelper();
		return FMOD_Studio_System_SetParameterByIDWithLabel(handle, id, threadSafeEncoding.byteFromStringUTF8(label), ignoreseekspeed);
	}

	public RESULT setParametersByIDs(PARAMETER_ID[] ids, float[] values, int count, bool ignoreseekspeed = false)
	{
		return FMOD_Studio_System_SetParametersByIDs(handle, ids, values, count, ignoreseekspeed);
	}

	public RESULT getParameterByName(string name, out float value)
	{
		float finalvalue;
		return getParameterByName(name, out value, out finalvalue);
	}

	public RESULT getParameterByName(string name, out float value, out float finalvalue)
	{
		using StringHelper.ThreadSafeEncoding threadSafeEncoding = StringHelper.GetFreeHelper();
		return FMOD_Studio_System_GetParameterByName(handle, threadSafeEncoding.byteFromStringUTF8(name), out value, out finalvalue);
	}

	public RESULT setParameterByName(string name, float value, bool ignoreseekspeed = false)
	{
		using StringHelper.ThreadSafeEncoding threadSafeEncoding = StringHelper.GetFreeHelper();
		return FMOD_Studio_System_SetParameterByName(handle, threadSafeEncoding.byteFromStringUTF8(name), value, ignoreseekspeed);
	}

	public RESULT setParameterByNameWithLabel(string name, string label, bool ignoreseekspeed = false)
	{
		using StringHelper.ThreadSafeEncoding threadSafeEncoding = StringHelper.GetFreeHelper();
		using StringHelper.ThreadSafeEncoding threadSafeEncoding2 = StringHelper.GetFreeHelper();
		return FMOD_Studio_System_SetParameterByNameWithLabel(handle, threadSafeEncoding.byteFromStringUTF8(name), threadSafeEncoding2.byteFromStringUTF8(label), ignoreseekspeed);
	}

	public RESULT lookupID(string path, out GUID id)
	{
		using StringHelper.ThreadSafeEncoding threadSafeEncoding = StringHelper.GetFreeHelper();
		return FMOD_Studio_System_LookupID(handle, threadSafeEncoding.byteFromStringUTF8(path), out id);
	}

	public RESULT lookupPath(GUID id, out string path)
	{
		path = null;
		using StringHelper.ThreadSafeEncoding threadSafeEncoding = StringHelper.GetFreeHelper();
		IntPtr intPtr = Marshal.AllocHGlobal(256);
		int retrieved = 0;
		RESULT rESULT = FMOD_Studio_System_LookupPath(handle, ref id, intPtr, 256, out retrieved);
		if (rESULT == RESULT.ERR_TRUNCATED)
		{
			Marshal.FreeHGlobal(intPtr);
			intPtr = Marshal.AllocHGlobal(retrieved);
			rESULT = FMOD_Studio_System_LookupPath(handle, ref id, intPtr, retrieved, out retrieved);
		}
		if (rESULT == RESULT.OK)
		{
			path = threadSafeEncoding.stringFromNative(intPtr);
		}
		Marshal.FreeHGlobal(intPtr);
		return rESULT;
	}

	public RESULT getNumListeners(out int numlisteners)
	{
		return FMOD_Studio_System_GetNumListeners(handle, out numlisteners);
	}

	public RESULT setNumListeners(int numlisteners)
	{
		return FMOD_Studio_System_SetNumListeners(handle, numlisteners);
	}

	public RESULT getListenerAttributes(int listener, out ATTRIBUTES_3D attributes)
	{
		return FMOD_Studio_System_GetListenerAttributes(handle, listener, out attributes, IntPtr.Zero);
	}

	public RESULT getListenerAttributes(int listener, out ATTRIBUTES_3D attributes, out VECTOR attenuationposition)
	{
		return FMOD_Studio_System_GetListenerAttributes(handle, listener, out attributes, out attenuationposition);
	}

	public RESULT setListenerAttributes(int listener, ATTRIBUTES_3D attributes)
	{
		return FMOD_Studio_System_SetListenerAttributes(handle, listener, ref attributes, IntPtr.Zero);
	}

	public RESULT setListenerAttributes(int listener, ATTRIBUTES_3D attributes, VECTOR attenuationposition)
	{
		return FMOD_Studio_System_SetListenerAttributes(handle, listener, ref attributes, ref attenuationposition);
	}

	public RESULT getListenerWeight(int listener, out float weight)
	{
		return FMOD_Studio_System_GetListenerWeight(handle, listener, out weight);
	}

	public RESULT setListenerWeight(int listener, float weight)
	{
		return FMOD_Studio_System_SetListenerWeight(handle, listener, weight);
	}

	public RESULT loadBankFile(string filename, LOAD_BANK_FLAGS flags, out Bank bank)
	{
		using StringHelper.ThreadSafeEncoding threadSafeEncoding = StringHelper.GetFreeHelper();
		return FMOD_Studio_System_LoadBankFile(handle, threadSafeEncoding.byteFromStringUTF8(filename), flags, out bank.handle);
	}

	public RESULT loadBankMemory(byte[] buffer, LOAD_BANK_FLAGS flags, out Bank bank)
	{
		GCHandle gCHandle = GCHandle.Alloc(buffer, GCHandleType.Pinned);
		IntPtr buffer2 = gCHandle.AddrOfPinnedObject();
		RESULT result = FMOD_Studio_System_LoadBankMemory(handle, buffer2, buffer.Length, LOAD_MEMORY_MODE.LOAD_MEMORY, flags, out bank.handle);
		gCHandle.Free();
		return result;
	}

	public RESULT loadBankCustom(BANK_INFO info, LOAD_BANK_FLAGS flags, out Bank bank)
	{
		info.size = Marshal.SizeOf<BANK_INFO>();
		return FMOD_Studio_System_LoadBankCustom(handle, ref info, flags, out bank.handle);
	}

	public RESULT unloadAll()
	{
		return FMOD_Studio_System_UnloadAll(handle);
	}

	public RESULT flushCommands()
	{
		return FMOD_Studio_System_FlushCommands(handle);
	}

	public RESULT flushSampleLoading()
	{
		return FMOD_Studio_System_FlushSampleLoading(handle);
	}

	public RESULT startCommandCapture(string filename, COMMANDCAPTURE_FLAGS flags)
	{
		using StringHelper.ThreadSafeEncoding threadSafeEncoding = StringHelper.GetFreeHelper();
		return FMOD_Studio_System_StartCommandCapture(handle, threadSafeEncoding.byteFromStringUTF8(filename), flags);
	}

	public RESULT stopCommandCapture()
	{
		return FMOD_Studio_System_StopCommandCapture(handle);
	}

	public RESULT loadCommandReplay(string filename, COMMANDREPLAY_FLAGS flags, out CommandReplay replay)
	{
		using StringHelper.ThreadSafeEncoding threadSafeEncoding = StringHelper.GetFreeHelper();
		return FMOD_Studio_System_LoadCommandReplay(handle, threadSafeEncoding.byteFromStringUTF8(filename), flags, out replay.handle);
	}

	public RESULT getBankCount(out int count)
	{
		return FMOD_Studio_System_GetBankCount(handle, out count);
	}

	public RESULT getBankList(out Bank[] array)
	{
		array = null;
		RESULT rESULT = FMOD_Studio_System_GetBankCount(handle, out var count);
		if (rESULT != 0)
		{
			return rESULT;
		}
		if (count == 0)
		{
			array = new Bank[0];
			return rESULT;
		}
		IntPtr[] array2 = new IntPtr[count];
		rESULT = FMOD_Studio_System_GetBankList(handle, array2, count, out var count2);
		if (rESULT != 0)
		{
			return rESULT;
		}
		if (count2 > count)
		{
			count2 = count;
		}
		array = new Bank[count2];
		for (int i = 0; i < count2; i++)
		{
			array[i].handle = array2[i];
		}
		return RESULT.OK;
	}

	public RESULT getParameterDescriptionCount(out int count)
	{
		return FMOD_Studio_System_GetParameterDescriptionCount(handle, out count);
	}

	public RESULT getParameterDescriptionList(out PARAMETER_DESCRIPTION[] array)
	{
		array = null;
		RESULT rESULT = FMOD_Studio_System_GetParameterDescriptionCount(handle, out var count);
		if (rESULT != 0)
		{
			return rESULT;
		}
		if (count == 0)
		{
			array = new PARAMETER_DESCRIPTION[0];
			return RESULT.OK;
		}
		PARAMETER_DESCRIPTION[] array2 = new PARAMETER_DESCRIPTION[count];
		rESULT = FMOD_Studio_System_GetParameterDescriptionList(handle, array2, count, out var count2);
		if (rESULT != 0)
		{
			return rESULT;
		}
		if (count2 != count)
		{
			Array.Resize(ref array2, count2);
		}
		array = array2;
		return RESULT.OK;
	}

	public RESULT getCPUUsage(out CPU_USAGE usage, out FMOD.CPU_USAGE usage_core)
	{
		return FMOD_Studio_System_GetCPUUsage(handle, out usage, out usage_core);
	}

	public RESULT getBufferUsage(out BUFFER_USAGE usage)
	{
		return FMOD_Studio_System_GetBufferUsage(handle, out usage);
	}

	public RESULT resetBufferUsage()
	{
		return FMOD_Studio_System_ResetBufferUsage(handle);
	}

	public RESULT setCallback(SYSTEM_CALLBACK callback, SYSTEM_CALLBACK_TYPE callbackmask = SYSTEM_CALLBACK_TYPE.ALL)
	{
		return FMOD_Studio_System_SetCallback(handle, callback, callbackmask);
	}

	public RESULT getUserData(out IntPtr userdata)
	{
		return FMOD_Studio_System_GetUserData(handle, out userdata);
	}

	public RESULT setUserData(IntPtr userdata)
	{
		return FMOD_Studio_System_SetUserData(handle, userdata);
	}

	public RESULT getMemoryUsage(out MEMORY_USAGE memoryusage)
	{
		return FMOD_Studio_System_GetMemoryUsage(handle, out memoryusage);
	}

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_Create(out IntPtr system, uint headerversion);

	[DllImport("fmodstudio")]
	private static extern bool FMOD_Studio_System_IsValid(IntPtr system);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_SetAdvancedSettings(IntPtr system, ref ADVANCEDSETTINGS settings);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_GetAdvancedSettings(IntPtr system, out ADVANCEDSETTINGS settings);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_Initialize(IntPtr system, int maxchannels, INITFLAGS studioflags, FMOD.INITFLAGS flags, IntPtr extradriverdata);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_Release(IntPtr system);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_Update(IntPtr system);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_GetCoreSystem(IntPtr system, out IntPtr coresystem);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_GetEvent(IntPtr system, byte[] path, out IntPtr _event);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_GetBus(IntPtr system, byte[] path, out IntPtr bus);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_GetVCA(IntPtr system, byte[] path, out IntPtr vca);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_GetBank(IntPtr system, byte[] path, out IntPtr bank);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_GetEventByID(IntPtr system, ref GUID id, out IntPtr _event);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_GetBusByID(IntPtr system, ref GUID id, out IntPtr bus);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_GetVCAByID(IntPtr system, ref GUID id, out IntPtr vca);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_GetBankByID(IntPtr system, ref GUID id, out IntPtr bank);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_GetSoundInfo(IntPtr system, byte[] key, out SOUND_INFO info);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_GetParameterDescriptionByName(IntPtr system, byte[] name, out PARAMETER_DESCRIPTION parameter);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_GetParameterDescriptionByID(IntPtr system, PARAMETER_ID id, out PARAMETER_DESCRIPTION parameter);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_GetParameterLabelByName(IntPtr system, byte[] name, int labelindex, IntPtr label, int size, out int retrieved);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_GetParameterLabelByID(IntPtr system, PARAMETER_ID id, int labelindex, IntPtr label, int size, out int retrieved);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_GetParameterByID(IntPtr system, PARAMETER_ID id, out float value, out float finalvalue);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_SetParameterByID(IntPtr system, PARAMETER_ID id, float value, bool ignoreseekspeed);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_SetParameterByIDWithLabel(IntPtr system, PARAMETER_ID id, byte[] label, bool ignoreseekspeed);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_SetParametersByIDs(IntPtr system, PARAMETER_ID[] ids, float[] values, int count, bool ignoreseekspeed);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_GetParameterByName(IntPtr system, byte[] name, out float value, out float finalvalue);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_SetParameterByName(IntPtr system, byte[] name, float value, bool ignoreseekspeed);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_SetParameterByNameWithLabel(IntPtr system, byte[] name, byte[] label, bool ignoreseekspeed);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_LookupID(IntPtr system, byte[] path, out GUID id);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_LookupPath(IntPtr system, ref GUID id, IntPtr path, int size, out int retrieved);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_GetNumListeners(IntPtr system, out int numlisteners);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_SetNumListeners(IntPtr system, int numlisteners);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_GetListenerAttributes(IntPtr system, int listener, out ATTRIBUTES_3D attributes, IntPtr zero);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_GetListenerAttributes(IntPtr system, int listener, out ATTRIBUTES_3D attributes, out VECTOR attenuationposition);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_SetListenerAttributes(IntPtr system, int listener, ref ATTRIBUTES_3D attributes, IntPtr zero);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_SetListenerAttributes(IntPtr system, int listener, ref ATTRIBUTES_3D attributes, ref VECTOR attenuationposition);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_GetListenerWeight(IntPtr system, int listener, out float weight);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_SetListenerWeight(IntPtr system, int listener, float weight);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_LoadBankFile(IntPtr system, byte[] filename, LOAD_BANK_FLAGS flags, out IntPtr bank);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_LoadBankMemory(IntPtr system, IntPtr buffer, int length, LOAD_MEMORY_MODE mode, LOAD_BANK_FLAGS flags, out IntPtr bank);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_LoadBankCustom(IntPtr system, ref BANK_INFO info, LOAD_BANK_FLAGS flags, out IntPtr bank);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_UnloadAll(IntPtr system);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_FlushCommands(IntPtr system);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_FlushSampleLoading(IntPtr system);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_StartCommandCapture(IntPtr system, byte[] filename, COMMANDCAPTURE_FLAGS flags);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_StopCommandCapture(IntPtr system);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_LoadCommandReplay(IntPtr system, byte[] filename, COMMANDREPLAY_FLAGS flags, out IntPtr replay);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_GetBankCount(IntPtr system, out int count);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_GetBankList(IntPtr system, IntPtr[] array, int capacity, out int count);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_GetParameterDescriptionCount(IntPtr system, out int count);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_GetParameterDescriptionList(IntPtr system, [Out] PARAMETER_DESCRIPTION[] array, int capacity, out int count);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_GetCPUUsage(IntPtr system, out CPU_USAGE usage, out FMOD.CPU_USAGE usage_core);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_GetBufferUsage(IntPtr system, out BUFFER_USAGE usage);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_ResetBufferUsage(IntPtr system);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_SetCallback(IntPtr system, SYSTEM_CALLBACK callback, SYSTEM_CALLBACK_TYPE callbackmask);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_GetUserData(IntPtr system, out IntPtr userdata);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_SetUserData(IntPtr system, IntPtr userdata);

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_System_GetMemoryUsage(IntPtr system, out MEMORY_USAGE memoryusage);

	public System(IntPtr ptr)
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
			return FMOD_Studio_System_IsValid(handle);
		}
		return false;
	}
}
