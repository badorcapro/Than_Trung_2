using System.Collections.Generic;
using System.IO;
using UnityEngine;

namespace FMODUnity;

public class PlatformMac : Platform
{
	private static List<CodecChannelCount> staticCodecChannels;

	internal override string DisplayName => "macOS";

	internal override List<CodecChannelCount> DefaultCodecChannels => staticCodecChannels;

	static PlatformMac()
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
		Settings.AddPlatformTemplate<PlatformMac>("52eb9df5db46521439908db3a29a1bbb");
	}

	internal override void DeclareRuntimePlatforms(Settings settings)
	{
		settings.DeclareRuntimePlatform(RuntimePlatform.OSXPlayer, this);
	}

	internal override string GetPluginPath(string pluginName)
	{
		string text = $"{GetPluginBasePath()}/{pluginName}.bundle";
		if (Directory.Exists(text))
		{
			return text;
		}
		return $"{GetPluginBasePath()}/{pluginName}.dylib";
	}
}
