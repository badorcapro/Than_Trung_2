using UnityEngine;

namespace FMODUnity;

public class PlatformGroup : Platform
{
	[SerializeField]
	private string displayName;

	[SerializeField]
	private Legacy.Platform legacyIdentifier;

	internal override string DisplayName => displayName;

	internal override void DeclareRuntimePlatforms(Settings settings)
	{
	}
}
