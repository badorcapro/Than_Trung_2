using System;
using FMOD;
using FMOD.Studio;
using UnityEngine;

namespace FMODUnity;

public static class RuntimeUtils
{
	public static string GetCommonPlatformPath(string path)
	{
		if (string.IsNullOrEmpty(path))
		{
			return path;
		}
		return path.Replace('\\', '/');
	}

	public static VECTOR ToFMODVector(this Vector3 vec)
	{
		VECTOR result = default(VECTOR);
		result.x = vec.x;
		result.y = vec.y;
		result.z = vec.z;
		return result;
	}

	public static ATTRIBUTES_3D To3DAttributes(this Vector3 pos)
	{
		ATTRIBUTES_3D result = default(ATTRIBUTES_3D);
		result.forward = Vector3.forward.ToFMODVector();
		result.up = Vector3.up.ToFMODVector();
		result.position = pos.ToFMODVector();
		return result;
	}

	public static ATTRIBUTES_3D To3DAttributes(this Transform transform)
	{
		ATTRIBUTES_3D result = default(ATTRIBUTES_3D);
		result.forward = transform.forward.ToFMODVector();
		result.up = transform.up.ToFMODVector();
		result.position = transform.position.ToFMODVector();
		return result;
	}

	public static ATTRIBUTES_3D To3DAttributes(this Transform transform, Vector3 velocity)
	{
		ATTRIBUTES_3D result = default(ATTRIBUTES_3D);
		result.forward = transform.forward.ToFMODVector();
		result.up = transform.up.ToFMODVector();
		result.position = transform.position.ToFMODVector();
		result.velocity = velocity.ToFMODVector();
		return result;
	}

	public static ATTRIBUTES_3D To3DAttributes(this GameObject go)
	{
		return go.transform.To3DAttributes();
	}

	public static ATTRIBUTES_3D To3DAttributes(Transform transform, Rigidbody rigidbody = null)
	{
		ATTRIBUTES_3D result = transform.To3DAttributes();
		if ((bool)rigidbody)
		{
			result.velocity = rigidbody.velocity.ToFMODVector();
		}
		return result;
	}

	public static ATTRIBUTES_3D To3DAttributes(GameObject go, Rigidbody rigidbody)
	{
		ATTRIBUTES_3D result = go.transform.To3DAttributes();
		if ((bool)rigidbody)
		{
			result.velocity = rigidbody.velocity.ToFMODVector();
		}
		return result;
	}

	public static ATTRIBUTES_3D To3DAttributes(Transform transform, Rigidbody2D rigidbody)
	{
		ATTRIBUTES_3D result = transform.To3DAttributes();
		if ((bool)rigidbody)
		{
			VECTOR velocity = default(VECTOR);
			velocity.x = rigidbody.velocity.x;
			velocity.y = rigidbody.velocity.y;
			velocity.z = 0f;
			result.velocity = velocity;
		}
		return result;
	}

	public static ATTRIBUTES_3D To3DAttributes(GameObject go, Rigidbody2D rigidbody)
	{
		ATTRIBUTES_3D result = go.transform.To3DAttributes();
		if ((bool)rigidbody)
		{
			VECTOR velocity = default(VECTOR);
			velocity.x = rigidbody.velocity.x;
			velocity.y = rigidbody.velocity.y;
			velocity.z = 0f;
			result.velocity = velocity;
		}
		return result;
	}

	public static THREAD_TYPE ToFMODThreadType(ThreadType threadType)
	{
		return threadType switch
		{
			ThreadType.Mixer => THREAD_TYPE.MIXER, 
			ThreadType.Feeder => THREAD_TYPE.FEEDER, 
			ThreadType.Stream => THREAD_TYPE.STREAM, 
			ThreadType.File => THREAD_TYPE.FILE, 
			ThreadType.Nonblocking => THREAD_TYPE.NONBLOCKING, 
			ThreadType.Record => THREAD_TYPE.RECORD, 
			ThreadType.Geometry => THREAD_TYPE.GEOMETRY, 
			ThreadType.Profiler => THREAD_TYPE.PROFILER, 
			ThreadType.Studio_Update => THREAD_TYPE.STUDIO_UPDATE, 
			ThreadType.Studio_Load_Bank => THREAD_TYPE.STUDIO_LOAD_BANK, 
			ThreadType.Studio_Load_Sample => THREAD_TYPE.STUDIO_LOAD_SAMPLE, 
			ThreadType.Convolution_1 => THREAD_TYPE.CONVOLUTION1, 
			ThreadType.Convolution_2 => THREAD_TYPE.CONVOLUTION2, 
			_ => throw new ArgumentException("Unrecognised thread type '" + threadType.ToString() + "'"), 
		};
	}

	public static string DisplayName(this ThreadType thread)
	{
		return thread.ToString().Replace('_', ' ');
	}

	public static THREAD_AFFINITY ToFMODThreadAffinity(ThreadAffinity affinity)
	{
		THREAD_AFFINITY fmodAffinity = THREAD_AFFINITY.CORE_ALL;
		SetFMODAffinityBit(affinity, ThreadAffinity.Core0, THREAD_AFFINITY.CORE_0, ref fmodAffinity);
		SetFMODAffinityBit(affinity, ThreadAffinity.Core1, THREAD_AFFINITY.CORE_1, ref fmodAffinity);
		SetFMODAffinityBit(affinity, ThreadAffinity.Core2, THREAD_AFFINITY.CORE_2, ref fmodAffinity);
		SetFMODAffinityBit(affinity, ThreadAffinity.Core3, THREAD_AFFINITY.CORE_3, ref fmodAffinity);
		SetFMODAffinityBit(affinity, ThreadAffinity.Core4, THREAD_AFFINITY.CORE_4, ref fmodAffinity);
		SetFMODAffinityBit(affinity, ThreadAffinity.Core5, THREAD_AFFINITY.CORE_5, ref fmodAffinity);
		SetFMODAffinityBit(affinity, ThreadAffinity.Core6, THREAD_AFFINITY.CORE_6, ref fmodAffinity);
		SetFMODAffinityBit(affinity, ThreadAffinity.Core7, THREAD_AFFINITY.CORE_7, ref fmodAffinity);
		SetFMODAffinityBit(affinity, ThreadAffinity.Core8, THREAD_AFFINITY.CORE_8, ref fmodAffinity);
		SetFMODAffinityBit(affinity, ThreadAffinity.Core9, THREAD_AFFINITY.CORE_9, ref fmodAffinity);
		SetFMODAffinityBit(affinity, ThreadAffinity.Core10, THREAD_AFFINITY.CORE_10, ref fmodAffinity);
		SetFMODAffinityBit(affinity, ThreadAffinity.Core11, THREAD_AFFINITY.CORE_11, ref fmodAffinity);
		SetFMODAffinityBit(affinity, ThreadAffinity.Core12, THREAD_AFFINITY.CORE_12, ref fmodAffinity);
		SetFMODAffinityBit(affinity, ThreadAffinity.Core13, THREAD_AFFINITY.CORE_13, ref fmodAffinity);
		SetFMODAffinityBit(affinity, ThreadAffinity.Core14, THREAD_AFFINITY.CORE_14, ref fmodAffinity);
		SetFMODAffinityBit(affinity, ThreadAffinity.Core15, THREAD_AFFINITY.CORE_15, ref fmodAffinity);
		return fmodAffinity;
	}

	private static void SetFMODAffinityBit(ThreadAffinity affinity, ThreadAffinity mask, THREAD_AFFINITY fmodMask, ref THREAD_AFFINITY fmodAffinity)
	{
		if ((affinity & mask) != 0)
		{
			fmodAffinity |= fmodMask;
		}
	}

	public static void EnforceLibraryOrder()
	{
		Memory.GetStats(out var _, out var _);
		Util.parseID("", out var _);
	}

	public static void DebugLog(string message)
	{
		if (!Settings.IsInitialized() || Settings.Instance.LoggingLevel == DEBUG_FLAGS.LOG)
		{
			UnityEngine.Debug.Log(message);
		}
	}

	public static void DebugLogFormat(string format, params object[] args)
	{
		if (!Settings.IsInitialized() || Settings.Instance.LoggingLevel == DEBUG_FLAGS.LOG)
		{
			UnityEngine.Debug.LogFormat(format, args);
		}
	}

	public static void DebugLogWarning(string message)
	{
		if (!Settings.IsInitialized() || Settings.Instance.LoggingLevel >= DEBUG_FLAGS.WARNING)
		{
			UnityEngine.Debug.LogWarning(message);
		}
	}

	public static void DebugLogWarningFormat(string format, params object[] args)
	{
		if (!Settings.IsInitialized() || Settings.Instance.LoggingLevel >= DEBUG_FLAGS.WARNING)
		{
			UnityEngine.Debug.LogWarningFormat(format, args);
		}
	}

	public static void DebugLogError(string message)
	{
		if (!Settings.IsInitialized() || Settings.Instance.LoggingLevel >= DEBUG_FLAGS.ERROR)
		{
			UnityEngine.Debug.LogError(message);
		}
	}

	public static void DebugLogErrorFormat(string format, params object[] args)
	{
		if (!Settings.IsInitialized() || Settings.Instance.LoggingLevel >= DEBUG_FLAGS.ERROR)
		{
			UnityEngine.Debug.LogErrorFormat(format, args);
		}
	}

	public static void DebugLogException(Exception e)
	{
		if (!Settings.IsInitialized() || Settings.Instance.LoggingLevel >= DEBUG_FLAGS.ERROR)
		{
			UnityEngine.Debug.LogException(e);
		}
	}
}
