using System;
using System.Collections.Generic;
using System.Linq;
using FMOD;
using UnityEngine;
using UnityEngine.Serialization;

namespace FMODUnity;

public class Settings : ScriptableObject
{
	internal enum SharedLibraryUpdateStages
	{
		Start,
		DisableExistingLibraries,
		RestartUnity,
		CopyNewLibraries
	}

	internal struct PlatformTemplate
	{
		public string Identifier;

		public Func<Platform> CreateInstance;
	}

	internal const string SettingsAssetName = "FMODStudioSettings";

	private static Settings instance = null;

	private static IEditorSettings editorSettings = null;

	private static bool isInitializing = false;

	[SerializeField]
	public bool HasSourceProject = true;

	[SerializeField]
	public bool HasPlatforms = true;

	[SerializeField]
	private string sourceProjectPath;

	[SerializeField]
	private string sourceBankPath;

	[FormerlySerializedAs("SourceBankPathUnformatted")]
	[SerializeField]
	private string sourceBankPathUnformatted;

	[SerializeField]
	public int BankRefreshCooldown = 5;

	[SerializeField]
	public bool ShowBankRefreshWindow = true;

	internal const int BankRefreshPrompt = -1;

	internal const int BankRefreshManual = -2;

	[SerializeField]
	public bool AutomaticEventLoading;

	[SerializeField]
	public BankLoadType BankLoadType;

	[SerializeField]
	public bool AutomaticSampleLoading;

	[SerializeField]
	public string EncryptionKey;

	[SerializeField]
	public ImportType ImportType;

	[SerializeField]
	public string TargetAssetPath = "FMODBanks";

	[SerializeField]
	public string TargetBankFolder = "";

	[SerializeField]
	public EventLinkage EventLinkage;

	[SerializeField]
	public bool SerializeGUIDsOnly;

	[SerializeField]
	public DEBUG_FLAGS LoggingLevel = DEBUG_FLAGS.WARNING;

	[SerializeField]
	internal List<Legacy.PlatformIntSetting> SpeakerModeSettings;

	[SerializeField]
	internal List<Legacy.PlatformIntSetting> SampleRateSettings;

	[SerializeField]
	internal List<Legacy.PlatformBoolSetting> LiveUpdateSettings;

	[SerializeField]
	internal List<Legacy.PlatformBoolSetting> OverlaySettings;

	[SerializeField]
	internal List<Legacy.PlatformStringSetting> BankDirectorySettings;

	[SerializeField]
	internal List<Legacy.PlatformIntSetting> VirtualChannelSettings;

	[SerializeField]
	internal List<Legacy.PlatformIntSetting> RealChannelSettings;

	[SerializeField]
	internal List<string> Plugins = new List<string>();

	[SerializeField]
	public List<string> MasterBanks;

	[SerializeField]
	public List<string> Banks;

	[SerializeField]
	public List<string> BanksToLoad;

	[SerializeField]
	public ushort LiveUpdatePort = 9264;

	[SerializeField]
	public bool EnableMemoryTracking;

	[SerializeField]
	public bool AndroidUseOBB;

	[SerializeField]
	public bool AndroidPatchBuild;

	[SerializeField]
	public MeterChannelOrderingType MeterChannelOrdering;

	[SerializeField]
	public bool StopEventsOutsideMaxDistance;

	[SerializeField]
	internal bool BoltUnitOptionsBuildPending;

	[SerializeField]
	public bool EnableErrorCallback;

	[SerializeField]
	internal SharedLibraryUpdateStages SharedLibraryUpdateStage;

	[SerializeField]
	internal double SharedLibraryTimeSinceStart;

	[SerializeField]
	internal int CurrentVersion;

	[SerializeField]
	public bool HideSetupWizard;

	[SerializeField]
	internal int LastEventReferenceScanVersion;

	[SerializeField]
	public List<Platform> Platforms = new List<Platform>();

	internal Dictionary<RuntimePlatform, List<Platform>> PlatformForRuntimePlatform = new Dictionary<RuntimePlatform, List<Platform>>();

	[NonSerialized]
	public Platform DefaultPlatform;

	[NonSerialized]
	public Platform PlayInEditorPlatform;

	internal static List<PlatformTemplate> PlatformTemplates = new List<PlatformTemplate>();

	[NonSerialized]
	private bool hasLoaded;

	public static Settings Instance
	{
		get
		{
			if (isInitializing)
			{
				return null;
			}
			Initialize();
			return instance;
		}
	}

	internal static IEditorSettings EditorSettings
	{
		get
		{
			return editorSettings;
		}
		set
		{
			editorSettings = value;
		}
	}

	public string SourceProjectPath
	{
		get
		{
			return sourceProjectPath;
		}
		set
		{
			sourceProjectPath = value;
		}
	}

	public string SourceBankPath
	{
		get
		{
			return sourceBankPath;
		}
		set
		{
			sourceBankPath = value;
		}
	}

	internal string TargetPath
	{
		get
		{
			if (ImportType == ImportType.AssetBundle)
			{
				if (string.IsNullOrEmpty(TargetAssetPath))
				{
					return Application.dataPath;
				}
				return Application.dataPath + "/" + TargetAssetPath;
			}
			if (string.IsNullOrEmpty(TargetBankFolder))
			{
				return Application.streamingAssetsPath;
			}
			return Application.streamingAssetsPath + "/" + TargetBankFolder;
		}
	}

	public string TargetSubFolder
	{
		get
		{
			if (ImportType == ImportType.AssetBundle)
			{
				return TargetAssetPath;
			}
			return TargetBankFolder;
		}
		set
		{
			if (ImportType == ImportType.AssetBundle)
			{
				TargetAssetPath = value;
			}
			else
			{
				TargetBankFolder = value;
			}
		}
	}

	internal static void Initialize()
	{
		if (instance == null)
		{
			isInitializing = true;
			instance = Resources.Load("FMODStudioSettings") as Settings;
			if (instance == null)
			{
				RuntimeUtils.DebugLog("[FMOD] Cannot find integration settings, creating default settings");
				instance = ScriptableObject.CreateInstance<Settings>();
				instance.name = "FMOD Studio Integration Settings";
				instance.CurrentVersion = 131849;
				instance.LastEventReferenceScanVersion = 131849;
			}
			isInitializing = false;
		}
	}

	internal static bool IsInitialized()
	{
		if (!(instance == null))
		{
			return !isInitializing;
		}
		return false;
	}

	internal Platform FindPlatform(string identifier)
	{
		foreach (Platform platform in Platforms)
		{
			if (platform.Identifier == identifier)
			{
				return platform;
			}
		}
		return null;
	}

	internal bool PlatformExists(string identifier)
	{
		return FindPlatform(identifier) != null;
	}

	internal void AddPlatform(Platform platform)
	{
		if (PlatformExists(platform.Identifier))
		{
			throw new ArgumentException($"Duplicate platform identifier: {platform.Identifier}");
		}
		Platforms.Add(platform);
	}

	internal void RemovePlatform(string identifier)
	{
		Platforms.RemoveAll((Platform p) => p.Identifier == identifier);
	}

	internal void LinkPlatform(Platform platform)
	{
		LinkPlatformToParent(platform);
		platform.DeclareRuntimePlatforms(this);
	}

	internal void DeclareRuntimePlatform(RuntimePlatform runtimePlatform, Platform platform)
	{
		if (!PlatformForRuntimePlatform.TryGetValue(runtimePlatform, out var value))
		{
			value = new List<Platform>();
			PlatformForRuntimePlatform.Add(runtimePlatform, value);
		}
		value.Add(platform);
		value.Sort((Platform a, Platform b) => b.Priority.CompareTo(a.Priority));
	}

	private void LinkPlatformToParent(Platform platform)
	{
		if (!string.IsNullOrEmpty(platform.ParentIdentifier))
		{
			SetPlatformParent(platform, FindPlatform(platform.ParentIdentifier));
		}
	}

	internal Platform FindCurrentPlatform()
	{
		if (PlatformForRuntimePlatform.TryGetValue(Application.platform, out var value))
		{
			foreach (Platform item in value)
			{
				if (item.MatchesCurrentEnvironment)
				{
					return item;
				}
			}
		}
		return DefaultPlatform;
	}

	private Settings()
	{
		MasterBanks = new List<string>();
		Banks = new List<string>();
		BanksToLoad = new List<string>();
		RealChannelSettings = new List<Legacy.PlatformIntSetting>();
		VirtualChannelSettings = new List<Legacy.PlatformIntSetting>();
		LiveUpdateSettings = new List<Legacy.PlatformBoolSetting>();
		OverlaySettings = new List<Legacy.PlatformBoolSetting>();
		SampleRateSettings = new List<Legacy.PlatformIntSetting>();
		SpeakerModeSettings = new List<Legacy.PlatformIntSetting>();
		BankDirectorySettings = new List<Legacy.PlatformStringSetting>();
		ImportType = ImportType.StreamingAssets;
		AutomaticEventLoading = true;
		AutomaticSampleLoading = false;
		EnableMemoryTracking = false;
	}

	internal void AddPlatformProperties(Platform platform)
	{
		platform.AffirmProperties();
		LinkPlatformToParent(platform);
	}

	public void SetPlatformParent(Platform platform, Platform newParent)
	{
		platform.Parent = newParent;
	}

	internal static void AddPlatformTemplate<T>(string identifier) where T : Platform
	{
		PlatformTemplates.Add(new PlatformTemplate
		{
			Identifier = identifier,
			CreateInstance = () => CreatePlatformInstance<T>(identifier)
		});
	}

	private static Platform CreatePlatformInstance<T>(string identifier) where T : Platform
	{
		T val = ScriptableObject.CreateInstance<T>();
		val.InitializeProperties();
		val.Identifier = identifier;
		return val;
	}

	internal void OnEnable()
	{
		if (!hasLoaded)
		{
			hasLoaded = true;
			PopulatePlatformsFromAsset();
			DefaultPlatform = Platforms.FirstOrDefault((Platform platform) => platform is PlatformDefault);
			PlayInEditorPlatform = Platforms.FirstOrDefault((Platform platform) => platform is PlatformPlayInEditor);
			Platforms.ForEach(LinkPlatform);
		}
	}

	private void PopulatePlatformsFromAsset()
	{
		Platforms.Clear();
		Platform[] array = Resources.LoadAll<Platform>("FMODStudioSettings");
		foreach (Platform platform in array)
		{
			Platform platform2 = FindPlatform(platform.Identifier);
			if (platform2 != null)
			{
				Platform platform3;
				if (platform.Active && !platform2.Active)
				{
					RemovePlatform(platform2.Identifier);
					platform3 = platform2;
					platform2 = null;
				}
				else
				{
					platform3 = platform;
				}
				RuntimeUtils.DebugLogWarningFormat("FMOD: Cleaning up duplicate platform: ID  = {0}, name = '{1}', type = {2}", platform3.Identifier, platform3.DisplayName, platform3.GetType().Name);
				UnityEngine.Object.DestroyImmediate(platform3, allowDestroyingAssets: true);
			}
			if (platform2 == null)
			{
				platform.EnsurePropertiesAreValid();
				AddPlatform(platform);
			}
		}
	}
}
