using UnityEngine;

namespace FMODUnity;

public class PlatformMobileLow : Platform
{
	internal override string DisplayName => "Low-End Mobile";

	internal override float Priority => 1f;

	internal override bool MatchesCurrentEnvironment => base.Active;

	static PlatformMobileLow()
	{
		Settings.AddPlatformTemplate<PlatformMobileLow>("c88d16e5272a4e241b0ef0ac2e53b73d");
	}

	internal override void DeclareRuntimePlatforms(Settings settings)
	{
		settings.DeclareRuntimePlatform(RuntimePlatform.IPhonePlayer, this);
		settings.DeclareRuntimePlatform(RuntimePlatform.Android, this);
	}
}
