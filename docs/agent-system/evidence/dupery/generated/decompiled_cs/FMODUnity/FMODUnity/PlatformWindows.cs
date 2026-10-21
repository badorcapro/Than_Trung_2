using System;
using System.Collections.Generic;
using System.Globalization;
using UnityEngine;

namespace FMODUnity;

public class PlatformWindows : Platform
{
	private static List<CodecChannelCount> staticCodecChannels;

	internal override string DisplayName => "Windows";

	internal override List<CodecChannelCount> DefaultCodecChannels => staticCodecChannels;

	static PlatformWindows()
	{
		staticCodecChannels = new List<CodecChannelCount>
		{
			new CodecChannelCount
			{
				format = CodecType.FADPCM,
				channels = 0
			},
			new CodecChannelCount
			{
				format = CodecType.Vorbis,
				channels = 32
			}
		};
		Settings.AddPlatformTemplate<PlatformWindows>("2c5177b11d81d824dbb064f9ac8527da");
	}

	internal override void DeclareRuntimePlatforms(Settings settings)
	{
		settings.DeclareRuntimePlatform(RuntimePlatform.WindowsPlayer, this);
		settings.DeclareRuntimePlatform(RuntimePlatform.MetroPlayerX86, this);
		settings.DeclareRuntimePlatform(RuntimePlatform.MetroPlayerX64, this);
		settings.DeclareRuntimePlatform(RuntimePlatform.MetroPlayerARM, this);
	}

	internal override string GetPluginPath(string pluginName)
	{
		string arg = "x86_64";
		if (IsArm64())
		{
			if (!Environment.Is64BitProcess)
			{
				throw new NotSupportedException("[FMOD] Attempted to load FMOD plugins on a 32 bit ARM platform.");
			}
			arg = "arm64";
		}
		else if (!Environment.Is64BitProcess)
		{
			arg = "x86";
		}
		return $"{GetPluginBasePath()}/{arg}/{pluginName}.dll";
	}

	private static bool IsArm64()
	{
		return CultureInfo.InvariantCulture.CompareInfo.IndexOf(SystemInfo.processorType, "ARM", CompareOptions.IgnoreCase) >= 0;
	}
}
