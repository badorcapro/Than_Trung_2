using System;
using FMOD;
using UnityEngine;

namespace FMODUnity;

public class PlatformAppleTV : Platform
{
	internal override string DisplayName => "Apple TV";

	static PlatformAppleTV()
	{
		Settings.AddPlatformTemplate<PlatformAppleTV>("e7a046c753c3c3d4aacc91f6597f310d");
	}

	internal override void DeclareRuntimePlatforms(Settings settings)
	{
		settings.DeclareRuntimePlatform(RuntimePlatform.tvOS, this);
	}

	internal override void LoadPlugins(FMOD.System coreSystem, Action<RESULT, string> reportResult)
	{
		PlatformIOS.StaticLoadPlugins(this, coreSystem, reportResult);
	}
}
