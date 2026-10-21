using System;
using FMOD;
using FMOD.Studio;
using UnityEngine;

namespace FMODUnity;

public class PlatformCallbackHandler : ScriptableObject
{
	public virtual void PreInitialize(FMOD.Studio.System system, Action<RESULT, string> reportResult)
	{
	}
}
