using System.Collections.Generic;
using UnityEngine;

namespace FMODUnity;

public class PlatformLinux : Platform
{
	private static List<CodecChannelCount> staticCodecChannels;

	internal override string DisplayName => "Linux";

	internal override List<CodecChannelCount> DefaultCodecChannels => staticCodecChannels;

	static PlatformLinux()
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
		Settings.AddPlatformTemplate<PlatformLinux>("b7716510a1f36934c87976f3a81dbf3d");
	}

	internal override void DeclareRuntimePlatforms(Settings settings)
	{
		settings.DeclareRuntimePlatform(RuntimePlatform.LinuxPlayer, this);
	}

	internal override string GetPluginPath(string pluginName)
	{
		return $"{GetPluginBasePath()}/lib{pluginName}.so";
	}
}
