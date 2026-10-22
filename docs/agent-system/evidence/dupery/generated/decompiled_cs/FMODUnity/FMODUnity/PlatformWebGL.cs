using UnityEngine;

namespace FMODUnity;

public class PlatformWebGL : Platform
{
	internal override string DisplayName => "WebGL";

	static PlatformWebGL()
	{
		Settings.AddPlatformTemplate<PlatformWebGL>("46fbfdf3fc43db0458918377fd40293e");
	}

	internal override void DeclareRuntimePlatforms(Settings settings)
	{
		settings.DeclareRuntimePlatform(RuntimePlatform.WebGLPlayer, this);
	}

	internal override string GetPluginPath(string pluginName)
	{
		return $"{GetPluginBasePath()}/{pluginName}.a";
	}
}
