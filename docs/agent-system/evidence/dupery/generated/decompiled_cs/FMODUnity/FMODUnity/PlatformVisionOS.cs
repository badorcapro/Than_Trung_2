using System;
using FMOD;

namespace FMODUnity;

public class PlatformVisionOS : Platform
{
	internal override string DisplayName => "visionOS";

	static PlatformVisionOS()
	{
		Settings.AddPlatformTemplate<PlatformVisionOS>("de700ef3f37a49b58a57ae3addf01ad9");
	}

	internal override void DeclareRuntimePlatforms(Settings settings)
	{
	}

	internal override void LoadPlugins(FMOD.System coreSystem, Action<RESULT, string> reportResult)
	{
		PlatformIOS.StaticLoadPlugins(this, coreSystem, reportResult);
	}
}
