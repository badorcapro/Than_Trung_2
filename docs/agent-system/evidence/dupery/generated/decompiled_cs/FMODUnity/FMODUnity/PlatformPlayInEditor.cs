using System;
using System.Collections.Generic;
using System.IO;
using FMOD;
using UnityEngine;

namespace FMODUnity;

public class PlatformPlayInEditor : Platform
{
	private static List<CodecChannelCount> staticCodecChannels = new List<CodecChannelCount>
	{
		new CodecChannelCount
		{
			format = CodecType.FADPCM,
			channels = 0
		},
		new CodecChannelCount
		{
			format = CodecType.Vorbis,
			channels = 256
		}
	};

	internal override string DisplayName => "Editor";

	internal override bool IsIntrinsic => true;

	internal override List<CodecChannelCount> DefaultCodecChannels => staticCodecChannels;

	public PlatformPlayInEditor()
	{
		base.Identifier = "playInEditor";
	}

	internal override void DeclareRuntimePlatforms(Settings settings)
	{
		settings.DeclareRuntimePlatform(RuntimePlatform.OSXEditor, this);
		settings.DeclareRuntimePlatform(RuntimePlatform.WindowsEditor, this);
		settings.DeclareRuntimePlatform(RuntimePlatform.LinuxEditor, this);
	}

	internal override string GetBankFolder()
	{
		Settings instance = Settings.Instance;
		string text = instance.SourceBankPath;
		if (instance.HasPlatforms)
		{
			text = RuntimeUtils.GetCommonPlatformPath(Path.Combine(text, base.BuildDirectory));
		}
		return text;
	}

	internal override void LoadStaticPlugins(FMOD.System coreSystem, Action<RESULT, string> reportResult)
	{
	}

	internal override void InitializeProperties()
	{
		base.InitializeProperties();
		PropertyAccessors.LiveUpdate.Set(this, TriStateBool.Enabled);
		PropertyAccessors.Overlay.Set(this, TriStateBool.Enabled);
		PropertyAccessors.SampleRate.Set(this, 48000);
		PropertyAccessors.RealChannelCount.Set(this, 256);
		PropertyAccessors.VirtualChannelCount.Set(this, 1024);
	}
}
