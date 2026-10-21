using System;
using FMOD;
using UnityEngine;

namespace FMODUnity;

public class PlatformIOS : Platform
{
	internal override string DisplayName => "iOS";

	static PlatformIOS()
	{
		Settings.AddPlatformTemplate<PlatformIOS>("0f8eb3f400726694eb47beb1a9f94ce8");
	}

	internal override void DeclareRuntimePlatforms(Settings settings)
	{
		settings.DeclareRuntimePlatform(RuntimePlatform.IPhonePlayer, this);
	}

	internal override void LoadPlugins(FMOD.System coreSystem, Action<RESULT, string> reportResult)
	{
		StaticLoadPlugins(this, coreSystem, reportResult);
	}

	public static void StaticLoadPlugins(Platform platform, FMOD.System coreSystem, Action<RESULT, string> reportResult)
	{
		platform.LoadStaticPlugins(coreSystem, reportResult);
	}
}
