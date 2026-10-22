using System;
using System.Collections.Generic;
using FMOD;
using FMOD.Studio;
using UnityEngine;
using UnityEngine.Serialization;

namespace FMODUnity;

public abstract class Platform : ScriptableObject
{
	public class Property<T>
	{
		public T Value;

		public bool HasValue;
	}

	[Serializable]
	public class PropertyBool : Property<TriStateBool>
	{
	}

	[Serializable]
	public class PropertyScreenPosition : Property<ScreenPosition>
	{
	}

	[Serializable]
	public class PropertyInt : Property<int>
	{
	}

	[Serializable]
	public class PropertySpeakerMode : Property<SPEAKERMODE>
	{
	}

	[Serializable]
	public class PropertyString : Property<string>
	{
	}

	[Serializable]
	public class PropertyStringList : Property<List<string>>
	{
	}

	[Serializable]
	public class PropertyCallbackHandler : Property<PlatformCallbackHandler>
	{
	}

	internal interface PropertyOverrideControl
	{
		bool HasValue(Platform platform);

		void Clear(Platform platform);
	}

	internal struct PropertyAccessor<T> : PropertyOverrideControl
	{
		private readonly Func<PropertyStorage, Property<T>> Getter;

		private readonly T DefaultValue;

		public PropertyAccessor(Func<PropertyStorage, Property<T>> getter, T defaultValue)
		{
			Getter = getter;
			DefaultValue = defaultValue;
		}

		public bool HasValue(Platform platform)
		{
			if (platform.Active)
			{
				return Getter(platform.Properties).HasValue;
			}
			return false;
		}

		public T Get(Platform platform)
		{
			Platform platform2 = platform;
			while (platform2 != null)
			{
				if (platform2.Active)
				{
					Property<T> property = Getter(platform2.Properties);
					if (property.HasValue)
					{
						return property.Value;
					}
				}
				platform2 = platform2.Parent;
			}
			return DefaultValue;
		}

		public void Set(Platform platform, T value)
		{
			Property<T> property = Getter(platform.Properties);
			property.Value = value;
			property.HasValue = true;
		}

		public void Clear(Platform platform)
		{
			Getter(platform.Properties).HasValue = false;
		}
	}

	[Serializable]
	public class PropertyStorage
	{
		public PropertyBool LiveUpdate = new PropertyBool();

		public PropertyInt LiveUpdatePort = new PropertyInt();

		public PropertyBool Overlay = new PropertyBool();

		public PropertyScreenPosition OverlayPosition = new PropertyScreenPosition();

		public PropertyInt OverlayFontSize = new PropertyInt();

		public PropertyBool Logging = new PropertyBool();

		public PropertyInt SampleRate = new PropertyInt();

		public PropertyString BuildDirectory = new PropertyString();

		public PropertySpeakerMode SpeakerMode = new PropertySpeakerMode();

		public PropertyInt VirtualChannelCount = new PropertyInt();

		public PropertyInt RealChannelCount = new PropertyInt();

		public PropertyInt DSPBufferLength = new PropertyInt();

		public PropertyInt DSPBufferCount = new PropertyInt();

		public PropertyStringList Plugins = new PropertyStringList();

		public PropertyStringList StaticPlugins = new PropertyStringList();

		public PropertyCallbackHandler CallbackHandler = new PropertyCallbackHandler();
	}

	internal static class PropertyAccessors
	{
		public static readonly PropertyAccessor<TriStateBool> LiveUpdate = new PropertyAccessor<TriStateBool>((PropertyStorage properties) => properties.LiveUpdate, TriStateBool.Disabled);

		public static readonly PropertyAccessor<int> LiveUpdatePort = new PropertyAccessor<int>((PropertyStorage properties) => properties.LiveUpdatePort, 9264);

		public static readonly PropertyAccessor<TriStateBool> Overlay = new PropertyAccessor<TriStateBool>((PropertyStorage properties) => properties.Overlay, TriStateBool.Disabled);

		public static readonly PropertyAccessor<ScreenPosition> OverlayPosition = new PropertyAccessor<ScreenPosition>((PropertyStorage properties) => properties.OverlayPosition, ScreenPosition.TopLeft);

		public static readonly PropertyAccessor<int> OverlayFontSize = new PropertyAccessor<int>((PropertyStorage properties) => properties.OverlayFontSize, 14);

		public static readonly PropertyAccessor<TriStateBool> Logging = new PropertyAccessor<TriStateBool>((PropertyStorage properties) => properties.Logging, TriStateBool.Disabled);

		public static readonly PropertyAccessor<int> SampleRate = new PropertyAccessor<int>((PropertyStorage properties) => properties.SampleRate, 0);

		public static readonly PropertyAccessor<string> BuildDirectory = new PropertyAccessor<string>((PropertyStorage properties) => properties.BuildDirectory, "Desktop");

		public static readonly PropertyAccessor<SPEAKERMODE> SpeakerMode = new PropertyAccessor<SPEAKERMODE>((PropertyStorage properties) => properties.SpeakerMode, SPEAKERMODE.STEREO);

		public static readonly PropertyAccessor<int> VirtualChannelCount = new PropertyAccessor<int>((PropertyStorage properties) => properties.VirtualChannelCount, 128);

		public static readonly PropertyAccessor<int> RealChannelCount = new PropertyAccessor<int>((PropertyStorage properties) => properties.RealChannelCount, 32);

		public static readonly PropertyAccessor<int> DSPBufferLength = new PropertyAccessor<int>((PropertyStorage properties) => properties.DSPBufferLength, 0);

		public static readonly PropertyAccessor<int> DSPBufferCount = new PropertyAccessor<int>((PropertyStorage properties) => properties.DSPBufferCount, 0);

		public static readonly PropertyAccessor<List<string>> Plugins = new PropertyAccessor<List<string>>((PropertyStorage properties) => properties.Plugins, null);

		public static readonly PropertyAccessor<List<string>> StaticPlugins = new PropertyAccessor<List<string>>((PropertyStorage properties) => properties.StaticPlugins, null);

		public static readonly PropertyAccessor<PlatformCallbackHandler> CallbackHandler = new PropertyAccessor<PlatformCallbackHandler>((PropertyStorage properties) => properties.CallbackHandler, null);
	}

	[Serializable]
	public class PropertyThreadAffinityList : Property<List<ThreadAffinityGroup>>
	{
	}

	[Serializable]
	internal class PropertyCodecChannels : Property<List<CodecChannelCount>>
	{
	}

	internal const float DefaultPriority = 0f;

	internal const string RegisterStaticPluginsClassName = "StaticPluginManager";

	internal const string RegisterStaticPluginsFunctionName = "Register";

	[SerializeField]
	private string identifier;

	[SerializeField]
	private string parentIdentifier;

	[SerializeField]
	private bool active;

	[SerializeField]
	protected PropertyStorage Properties = new PropertyStorage();

	[SerializeField]
	[FormerlySerializedAs("outputType")]
	internal string OutputTypeName;

	private static List<ThreadAffinityGroup> StaticThreadAffinities = new List<ThreadAffinityGroup>();

	[SerializeField]
	private PropertyThreadAffinityList threadAffinities = new PropertyThreadAffinityList();

	[NonSerialized]
	public Platform Parent;

	private static List<CodecChannelCount> staticCodecChannels = new List<CodecChannelCount>
	{
		new CodecChannelCount
		{
			format = CodecType.FADPCM,
			channels = 32
		},
		new CodecChannelCount
		{
			format = CodecType.Vorbis,
			channels = 0
		}
	};

	[SerializeField]
	private PropertyCodecChannels codecChannels = new PropertyCodecChannels();

	internal string Identifier
	{
		get
		{
			return identifier;
		}
		set
		{
			identifier = value;
		}
	}

	internal abstract string DisplayName { get; }

	internal virtual float Priority => 0f;

	internal virtual bool MatchesCurrentEnvironment => true;

	internal virtual bool IsIntrinsic => false;

	internal string ParentIdentifier
	{
		get
		{
			return parentIdentifier;
		}
		set
		{
			parentIdentifier = value;
		}
	}

	internal bool IsLiveUpdateEnabled => LiveUpdate == TriStateBool.Enabled;

	internal bool IsOverlayEnabled => Overlay == TriStateBool.Enabled;

	internal bool Active => active;

	internal bool HasAnyOverriddenProperties
	{
		get
		{
			if (active)
			{
				if (!Properties.LiveUpdate.HasValue && !Properties.LiveUpdatePort.HasValue && !Properties.Overlay.HasValue && !Properties.OverlayPosition.HasValue && !Properties.OverlayFontSize.HasValue && !Properties.Logging.HasValue && !Properties.SampleRate.HasValue && !Properties.BuildDirectory.HasValue && !Properties.SpeakerMode.HasValue && !Properties.VirtualChannelCount.HasValue && !Properties.RealChannelCount.HasValue && !Properties.DSPBufferLength.HasValue && !Properties.DSPBufferCount.HasValue && !Properties.Plugins.HasValue)
				{
					return Properties.StaticPlugins.HasValue;
				}
				return true;
			}
			return false;
		}
	}

	public TriStateBool LiveUpdate => PropertyAccessors.LiveUpdate.Get(this);

	public int LiveUpdatePort => PropertyAccessors.LiveUpdatePort.Get(this);

	public TriStateBool Overlay => PropertyAccessors.Overlay.Get(this);

	public ScreenPosition OverlayRect => PropertyAccessors.OverlayPosition.Get(this);

	public int OverlayFontSize => PropertyAccessors.OverlayFontSize.Get(this);

	public TriStateBool Logging => PropertyAccessors.Logging.Get(this);

	public int SampleRate => PropertyAccessors.SampleRate.Get(this);

	public string BuildDirectory => PropertyAccessors.BuildDirectory.Get(this);

	public SPEAKERMODE SpeakerMode => PropertyAccessors.SpeakerMode.Get(this);

	public int VirtualChannelCount => PropertyAccessors.VirtualChannelCount.Get(this);

	public int RealChannelCount => PropertyAccessors.RealChannelCount.Get(this);

	public int DSPBufferLength => PropertyAccessors.DSPBufferLength.Get(this);

	public int DSPBufferCount => PropertyAccessors.DSPBufferCount.Get(this);

	public List<string> Plugins => PropertyAccessors.Plugins.Get(this);

	public List<string> StaticPlugins => PropertyAccessors.StaticPlugins.Get(this);

	public PlatformCallbackHandler CallbackHandler => PropertyAccessors.CallbackHandler.Get(this);

	internal virtual List<ThreadAffinityGroup> DefaultThreadAffinities => StaticThreadAffinities;

	public IEnumerable<ThreadAffinityGroup> ThreadAffinities
	{
		get
		{
			if (threadAffinities.HasValue)
			{
				return threadAffinities.Value;
			}
			return DefaultThreadAffinities;
		}
	}

	internal PropertyThreadAffinityList ThreadAffinitiesProperty => threadAffinities;

	internal virtual List<CodecChannelCount> DefaultCodecChannels => staticCodecChannels;

	internal List<CodecChannelCount> CodecChannels
	{
		get
		{
			if (codecChannels.HasValue)
			{
				return codecChannels.Value;
			}
			return DefaultCodecChannels;
		}
	}

	internal PropertyCodecChannels CodecChannelsProperty => codecChannels;

	internal abstract void DeclareRuntimePlatforms(Settings settings);

	internal virtual void PreSystemCreate(Action<RESULT, string> reportResult)
	{
	}

	internal virtual void PreInitialize(FMOD.Studio.System studioSystem)
	{
	}

	internal virtual string GetBankFolder()
	{
		return Application.streamingAssetsPath;
	}

	protected virtual string GetPluginBasePath()
	{
		return $"{Application.dataPath}/Plugins";
	}

	internal virtual string GetPluginPath(string pluginName)
	{
		throw new NotImplementedException($"Plugins are not implemented on platform {Identifier}");
	}

	internal virtual void LoadPlugins(FMOD.System coreSystem, Action<RESULT, string> reportResult)
	{
		LoadDynamicPlugins(coreSystem, reportResult);
		LoadStaticPlugins(coreSystem, reportResult);
	}

	internal virtual void LoadDynamicPlugins(FMOD.System coreSystem, Action<RESULT, string> reportResult)
	{
		List<string> plugins = Plugins;
		if (plugins == null)
		{
			return;
		}
		foreach (string item in plugins)
		{
			if (!string.IsNullOrEmpty(item))
			{
				string pluginPath = GetPluginPath(item);
				uint handle;
				RESULT arg = coreSystem.loadPlugin(pluginPath, out handle);
				reportResult(arg, $"Loading plugin '{item}' from '{pluginPath}'");
			}
		}
	}

	internal virtual void LoadStaticPlugins(FMOD.System coreSystem, Action<RESULT, string> reportResult)
	{
		if (StaticPlugins.Count > 0)
		{
			RuntimeUtils.DebugLogWarningFormat("FMOD: {0} static plugins specified, but static plugins are only supported on the IL2CPP scripting backend", StaticPlugins.Count);
		}
	}

	internal void AffirmProperties()
	{
		if (!active)
		{
			Properties = new PropertyStorage();
			InitializeProperties();
			active = true;
		}
	}

	internal void ClearProperties()
	{
		if (active)
		{
			Properties = new PropertyStorage();
			active = false;
		}
	}

	internal virtual void InitializeProperties()
	{
		if (!IsIntrinsic)
		{
			ParentIdentifier = "default";
		}
	}

	internal virtual void EnsurePropertiesAreValid()
	{
		if (!IsIntrinsic && string.IsNullOrEmpty(ParentIdentifier))
		{
			ParentIdentifier = "default";
		}
	}

	public void SetOverlayFontSize(int size)
	{
		PropertyAccessors.OverlayFontSize.Set(this, size);
	}

	internal bool InheritsFrom(Platform platform)
	{
		if (platform == this)
		{
			return true;
		}
		if (Parent != null)
		{
			return Parent.InheritsFrom(platform);
		}
		return false;
	}

	internal OUTPUTTYPE GetOutputType()
	{
		if (Enum.IsDefined(typeof(OUTPUTTYPE), OutputTypeName))
		{
			return (OUTPUTTYPE)Enum.Parse(typeof(OUTPUTTYPE), OutputTypeName);
		}
		return OUTPUTTYPE.AUTODETECT;
	}
}
