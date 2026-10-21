using System.Collections.Generic;

namespace FMODUnity;

public class PlatformDefault : Platform
{
	public const string ConstIdentifier = "default";

	internal override string DisplayName => "Default";

	internal override bool IsIntrinsic => true;

	public PlatformDefault()
	{
		base.Identifier = "default";
	}

	internal override void DeclareRuntimePlatforms(Settings settings)
	{
	}

	internal override void InitializeProperties()
	{
		base.InitializeProperties();
		PropertyAccessors.Plugins.Set(this, new List<string>());
		PropertyAccessors.StaticPlugins.Set(this, new List<string>());
	}

	internal override void EnsurePropertiesAreValid()
	{
		base.EnsurePropertiesAreValid();
		if (base.StaticPlugins == null)
		{
			PropertyAccessors.StaticPlugins.Set(this, new List<string>());
		}
	}
}
