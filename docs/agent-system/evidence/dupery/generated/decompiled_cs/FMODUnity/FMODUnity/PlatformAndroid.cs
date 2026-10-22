using UnityEngine;

namespace FMODUnity;

public class PlatformAndroid : Platform
{
	internal override string DisplayName => "Android";

	static PlatformAndroid()
	{
		Settings.AddPlatformTemplate<PlatformAndroid>("2fea114e74ecf3c4f920e1d5cc1c4c40");
	}

	internal override void DeclareRuntimePlatforms(Settings settings)
	{
		settings.DeclareRuntimePlatform(RuntimePlatform.Android, this);
	}

	internal override string GetBankFolder()
	{
		return StaticGetBankFolder();
	}

	internal static string StaticGetBankFolder()
	{
		if (!Settings.Instance.AndroidUseOBB && !Settings.Instance.AndroidPatchBuild)
		{
			return "file:///android_asset";
		}
		return Application.streamingAssetsPath;
	}

	internal override string GetPluginPath(string pluginName)
	{
		return StaticGetPluginPath(pluginName);
	}

	internal static string StaticGetPluginPath(string pluginName)
	{
		return $"lib{pluginName}.so";
	}
}
