using System;
using System.Collections.Generic;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;
using AOT;
using FMOD;
using FMOD.Studio;
using UnityEngine;

namespace FMODUnity;

[AddComponentMenu("")]
public class RuntimeManager : MonoBehaviour
{
	private struct LoadedBank
	{
		public Bank Bank;

		public int RefCount;
	}

	private class GuidComparer : IEqualityComparer<GUID>
	{
		bool IEqualityComparer<GUID>.Equals(GUID x, GUID y)
		{
			return x.Equals(y);
		}

		int IEqualityComparer<GUID>.GetHashCode(GUID obj)
		{
			return obj.GetHashCode();
		}
	}

	private class AttachedInstance
	{
		public EventInstance instance;

		public Transform transform;

		public Rigidbody rigidBody;

		public Vector3 lastFramePosition;

		public bool nonRigidbodyVelocity;

		public Rigidbody2D rigidBody2D;
	}

	public const string BankStubPrefix = "bank stub:";

	private static SystemNotInitializedException initException;

	private static RuntimeManager instance;

	private Platform currentPlatform;

	private DEBUG_CALLBACK debugCallback;

	private FMOD.SYSTEM_CALLBACK errorCallback;

	private FMOD.Studio.System studioSystem;

	private FMOD.System coreSystem;

	private DSP mixerHead;

	private bool isMuted;

	private Dictionary<GUID, EventDescription> cachedDescriptions = new Dictionary<GUID, EventDescription>(new GuidComparer());

	private Dictionary<string, LoadedBank> loadedBanks = new Dictionary<string, LoadedBank>();

	private List<string> sampleLoadRequests = new List<string>();

	private List<AttachedInstance> attachedInstances = new List<AttachedInstance>(128);

	private bool listenerWarningIssued;

	protected bool isOverlayEnabled;

	private FMODRuntimeManagerOnGUIHelper overlayDrawer;

	private Rect windowRect = new Rect(10f, 10f, 300f, 100f);

	private string lastDebugText;

	private float lastDebugUpdate;

	private int loadingBanksRef;

	private static byte[] masterBusPrefix;

	private static byte[] eventSet3DAttributes;

	private static byte[] systemGetBus;

	public static bool IsMuted => Instance.isMuted;

	private static RuntimeManager Instance
	{
		get
		{
			if (initException != null)
			{
				throw initException;
			}
			if (instance == null)
			{
				if (!Application.isPlaying)
				{
					UnityEngine.Debug.LogError("[FMOD] RuntimeManager accessed outside of runtime. Do not use RuntimeManager for Editor-only functionality, create your own System objects instead.");
					return null;
				}
				RuntimeManager[] array = Resources.FindObjectsOfTypeAll<RuntimeManager>();
				for (int i = 0; i < array.Length; i++)
				{
					UnityEngine.Object.DestroyImmediate(array[i].gameObject);
				}
				GameObject gameObject = new GameObject("FMOD.UnityIntegration.RuntimeManager");
				instance = gameObject.AddComponent<RuntimeManager>();
				if (Application.isPlaying)
				{
					UnityEngine.Object.DontDestroyOnLoad(gameObject);
				}
				gameObject.hideFlags = HideFlags.HideAndDontSave;
				try
				{
					RuntimeUtils.EnforceLibraryOrder();
					instance.Initialize();
				}
				catch (Exception ex)
				{
					initException = ex as SystemNotInitializedException;
					if (initException == null)
					{
						initException = new SystemNotInitializedException(ex);
					}
					throw initException;
				}
			}
			return instance;
		}
	}

	public static FMOD.Studio.System StudioSystem => Instance.studioSystem;

	public static FMOD.System CoreSystem => Instance.coreSystem;

	public static bool IsInitialized
	{
		get
		{
			if (instance != null)
			{
				return instance.studioSystem.isValid();
			}
			return false;
		}
	}

	public static bool HaveAllBanksLoaded => Instance.loadingBanksRef == 0;

	public static bool HaveMasterBanksLoaded
	{
		get
		{
			foreach (string masterBank in Settings.Instance.MasterBanks)
			{
				if (!HasBankLoaded(masterBank))
				{
					return false;
				}
			}
			return true;
		}
	}

	static RuntimeManager()
	{
		UTF8Encoding uTF8Encoding = new UTF8Encoding();
		masterBusPrefix = uTF8Encoding.GetBytes("bus:/, ");
		eventSet3DAttributes = uTF8Encoding.GetBytes("EventInstance::set3DAttributes");
		systemGetBus = uTF8Encoding.GetBytes("System::getBus");
	}

	[MonoPInvokeCallback(typeof(DEBUG_CALLBACK))]
	private static RESULT DEBUG_CALLBACK(DEBUG_FLAGS flags, IntPtr filePtr, int line, IntPtr funcPtr, IntPtr messagePtr)
	{
		new StringWrapper(filePtr);
		StringWrapper stringWrapper = new StringWrapper(funcPtr);
		StringWrapper stringWrapper2 = new StringWrapper(messagePtr);
		switch (flags)
		{
		case DEBUG_FLAGS.ERROR:
			RuntimeUtils.DebugLogError($"[FMOD] {(string)stringWrapper} : {(string)stringWrapper2}");
			break;
		case DEBUG_FLAGS.WARNING:
			RuntimeUtils.DebugLogWarning($"[FMOD] {(string)stringWrapper} : {(string)stringWrapper2}");
			break;
		case DEBUG_FLAGS.LOG:
		case DEBUG_FLAGS.TYPE_VIRTUAL:
			RuntimeUtils.DebugLog($"[FMOD] {(string)stringWrapper} : {(string)stringWrapper2}");
			break;
		}
		return RESULT.OK;
	}

	[MonoPInvokeCallback(typeof(FMOD.SYSTEM_CALLBACK))]
	private static RESULT ERROR_CALLBACK(IntPtr system, FMOD.SYSTEM_CALLBACK_TYPE type, IntPtr commanddata1, IntPtr commanddata2, IntPtr userdata)
	{
		ERRORCALLBACK_INFO eRRORCALLBACK_INFO = Marshal.PtrToStructure<ERRORCALLBACK_INFO>(commanddata1);
		if ((eRRORCALLBACK_INFO.instancetype == ERRORCALLBACK_INSTANCETYPE.CHANNEL || eRRORCALLBACK_INFO.instancetype == ERRORCALLBACK_INSTANCETYPE.CHANNELCONTROL) && (eRRORCALLBACK_INFO.result == RESULT.ERR_INVALID_HANDLE || eRRORCALLBACK_INFO.result == RESULT.ERR_CHANNEL_STOLEN))
		{
			return RESULT.OK;
		}
		if (eRRORCALLBACK_INFO.instancetype == ERRORCALLBACK_INSTANCETYPE.STUDIO_EVENTINSTANCE && eRRORCALLBACK_INFO.functionname.Equals(eventSet3DAttributes) && eRRORCALLBACK_INFO.result == RESULT.ERR_INVALID_HANDLE)
		{
			return RESULT.OK;
		}
		if (eRRORCALLBACK_INFO.instancetype == ERRORCALLBACK_INSTANCETYPE.STUDIO_SYSTEM && eRRORCALLBACK_INFO.functionname.Equals(systemGetBus) && eRRORCALLBACK_INFO.result == RESULT.ERR_EVENT_NOTFOUND && eRRORCALLBACK_INFO.functionparams.StartsWith(masterBusPrefix))
		{
			return RESULT.OK;
		}
		RuntimeUtils.DebugLogError(string.Format("[FMOD] {0}({1}) returned {2} for {3} (0x{4}).", (string)eRRORCALLBACK_INFO.functionname, (string)eRRORCALLBACK_INFO.functionparams, eRRORCALLBACK_INFO.result, eRRORCALLBACK_INFO.instancetype, eRRORCALLBACK_INFO.instance.ToString("X")));
		return RESULT.OK;
	}

	private void CheckInitResult(RESULT result, string cause)
	{
		if (result != 0)
		{
			ReleaseStudioSystem();
			throw new SystemNotInitializedException(result, cause);
		}
	}

	private void ReleaseStudioSystem()
	{
		if (studioSystem.isValid())
		{
			studioSystem.release();
			studioSystem.clearHandle();
		}
	}

	private RESULT Initialize()
	{
		RESULT rESULT = RESULT.OK;
		RESULT rESULT2 = RESULT.OK;
		Settings settings = Settings.Instance;
		currentPlatform = settings.FindCurrentPlatform();
		int sampleRate = currentPlatform.SampleRate;
		int softwareChannels = Math.Min(currentPlatform.RealChannelCount, 256);
		int virtualChannelCount = currentPlatform.VirtualChannelCount;
		uint dSPBufferLength = (uint)currentPlatform.DSPBufferLength;
		int dSPBufferCount = currentPlatform.DSPBufferCount;
		SPEAKERMODE speakerMode = currentPlatform.SpeakerMode;
		OUTPUTTYPE output = currentPlatform.GetOutputType();
		FMOD.ADVANCEDSETTINGS settings2 = default(FMOD.ADVANCEDSETTINGS);
		settings2.randomSeed = (uint)DateTime.UtcNow.Ticks;
		settings2.maxAT9Codecs = GetChannelCountForFormat(CodecType.AT9);
		settings2.maxFADPCMCodecs = GetChannelCountForFormat(CodecType.FADPCM);
		settings2.maxOpusCodecs = GetChannelCountForFormat(CodecType.Opus);
		settings2.maxVorbisCodecs = GetChannelCountForFormat(CodecType.Vorbis);
		settings2.maxXMACodecs = GetChannelCountForFormat(CodecType.XMA);
		SetThreadAffinities(currentPlatform);
		currentPlatform.PreSystemCreate(CheckInitResult);
		FMOD.Studio.INITFLAGS iNITFLAGS = FMOD.Studio.INITFLAGS.DEFERRED_CALLBACKS;
		if (currentPlatform.IsLiveUpdateEnabled)
		{
			iNITFLAGS |= FMOD.Studio.INITFLAGS.LIVEUPDATE;
			settings2.profilePort = (ushort)currentPlatform.LiveUpdatePort;
		}
		while (true)
		{
			rESULT = FMOD.Studio.System.create(out studioSystem);
			CheckInitResult(rESULT, "FMOD.Studio.System.create");
			rESULT = studioSystem.getCoreSystem(out coreSystem);
			CheckInitResult(rESULT, "FMOD.Studio.System.getCoreSystem");
			rESULT = coreSystem.setOutput(output);
			CheckInitResult(rESULT, "FMOD.System.setOutput");
			rESULT = coreSystem.setSoftwareChannels(softwareChannels);
			CheckInitResult(rESULT, "FMOD.System.setSoftwareChannels");
			rESULT = coreSystem.setSoftwareFormat(sampleRate, speakerMode, 0);
			CheckInitResult(rESULT, "FMOD.System.setSoftwareFormat");
			if (dSPBufferLength != 0 && dSPBufferCount > 0)
			{
				rESULT = coreSystem.setDSPBufferSize(dSPBufferLength, dSPBufferCount);
				CheckInitResult(rESULT, "FMOD.System.setDSPBufferSize");
			}
			rESULT = coreSystem.setAdvancedSettings(ref settings2);
			CheckInitResult(rESULT, "FMOD.System.setAdvancedSettings");
			if (settings.EnableErrorCallback)
			{
				errorCallback = ERROR_CALLBACK;
				rESULT = coreSystem.setCallback(errorCallback, FMOD.SYSTEM_CALLBACK_TYPE.ERROR);
				CheckInitResult(rESULT, "FMOD.System.setCallback");
			}
			if (!string.IsNullOrEmpty(settings.EncryptionKey))
			{
				rESULT = studioSystem.setAdvancedSettings(default(FMOD.Studio.ADVANCEDSETTINGS), Settings.Instance.EncryptionKey);
				CheckInitResult(rESULT, "FMOD.Studio.System.setAdvancedSettings");
			}
			if (settings.EnableMemoryTracking)
			{
				iNITFLAGS |= FMOD.Studio.INITFLAGS.MEMORY_TRACKING;
			}
			currentPlatform.PreInitialize(studioSystem);
			PlatformCallbackHandler callbackHandler = currentPlatform.CallbackHandler;
			if (callbackHandler != null)
			{
				callbackHandler.PreInitialize(studioSystem, CheckInitResult);
			}
			rESULT = studioSystem.initialize(virtualChannelCount, iNITFLAGS, FMOD.INITFLAGS.NORMAL, IntPtr.Zero);
			if (rESULT != 0 && rESULT2 == RESULT.OK)
			{
				rESULT2 = rESULT;
				output = OUTPUTTYPE.NOSOUND;
				RuntimeUtils.DebugLogErrorFormat("[FMOD] Studio::System::initialize returned {0}, defaulting to no-sound mode.", rESULT.ToString());
				continue;
			}
			CheckInitResult(rESULT, "Studio::System::initialize");
			if ((iNITFLAGS & FMOD.Studio.INITFLAGS.LIVEUPDATE) == 0)
			{
				break;
			}
			studioSystem.flushCommands();
			rESULT = studioSystem.update();
			if (rESULT != RESULT.ERR_NET_SOCKET_ERROR)
			{
				break;
			}
			iNITFLAGS = (FMOD.Studio.INITFLAGS)((uint)iNITFLAGS & 0xFFFFFFFEu);
			RuntimeUtils.DebugLogWarning("[FMOD] Cannot open network port for Live Update (in-use), restarting with Live Update disabled.");
			rESULT = studioSystem.release();
			CheckInitResult(rESULT, "FMOD.Studio.System.Release");
		}
		currentPlatform.LoadPlugins(coreSystem, CheckInitResult);
		LoadBanks(settings);
		if (currentPlatform.IsOverlayEnabled)
		{
			SetOverlayPosition();
		}
		return rESULT2;
	}

	private int GetChannelCountForFormat(CodecType format)
	{
		CodecChannelCount codecChannelCount = currentPlatform.CodecChannels.Find((CodecChannelCount x) => x.format == format);
		if (codecChannelCount != null)
		{
			return Math.Min(codecChannelCount.channels, 256);
		}
		return 0;
	}

	private static void SetThreadAffinities(Platform platform)
	{
		foreach (ThreadAffinityGroup threadAffinity in platform.ThreadAffinities)
		{
			foreach (ThreadType thread in threadAffinity.threads)
			{
				THREAD_TYPE type = RuntimeUtils.ToFMODThreadType(thread);
				THREAD_AFFINITY affinity = RuntimeUtils.ToFMODThreadAffinity(threadAffinity.affinity);
				Thread.SetAttributes(type, affinity);
			}
		}
	}

	private void Update()
	{
		if (!studioSystem.isValid())
		{
			return;
		}
		if (StudioListener.ListenerCount <= 0 && !listenerWarningIssued)
		{
			listenerWarningIssued = true;
			RuntimeUtils.DebugLogWarning("[FMOD] Please add an 'FMOD Studio Listener' component to your camera in the scene for correct 3D positioning of sounds.");
		}
		StudioEventEmitter.UpdateActiveEmitters();
		for (int i = 0; i < attachedInstances.Count; i++)
		{
			PLAYBACK_STATE state = PLAYBACK_STATE.STOPPED;
			if (attachedInstances[i].instance.isValid())
			{
				attachedInstances[i].instance.getPlaybackState(out state);
			}
			if (state == PLAYBACK_STATE.STOPPED || attachedInstances[i].transform == null)
			{
				attachedInstances[i] = attachedInstances[attachedInstances.Count - 1];
				attachedInstances.RemoveAt(attachedInstances.Count - 1);
				i--;
				continue;
			}
			if ((bool)attachedInstances[i].rigidBody)
			{
				attachedInstances[i].instance.set3DAttributes(RuntimeUtils.To3DAttributes(attachedInstances[i].transform, attachedInstances[i].rigidBody));
				continue;
			}
			if ((bool)attachedInstances[i].rigidBody2D)
			{
				attachedInstances[i].instance.set3DAttributes(RuntimeUtils.To3DAttributes(attachedInstances[i].transform, attachedInstances[i].rigidBody2D));
				continue;
			}
			if (!attachedInstances[i].nonRigidbodyVelocity)
			{
				attachedInstances[i].instance.set3DAttributes(attachedInstances[i].transform.To3DAttributes());
				continue;
			}
			Vector3 position = attachedInstances[i].transform.position;
			Vector3 velocity = Vector3.zero;
			if (Time.deltaTime != 0f)
			{
				velocity = (position - attachedInstances[i].lastFramePosition) / Time.deltaTime;
				velocity = Vector3.ClampMagnitude(velocity, 20f);
			}
			attachedInstances[i].lastFramePosition = position;
			attachedInstances[i].instance.set3DAttributes(attachedInstances[i].transform.To3DAttributes(velocity));
		}
		if (isOverlayEnabled)
		{
			if (!overlayDrawer)
			{
				overlayDrawer = Instance.gameObject.AddComponent<FMODRuntimeManagerOnGUIHelper>();
				overlayDrawer.TargetRuntimeManager = this;
			}
			else
			{
				overlayDrawer.gameObject.SetActive(value: true);
			}
		}
		else if (overlayDrawer != null && overlayDrawer.gameObject.activeSelf)
		{
			overlayDrawer.gameObject.SetActive(value: false);
		}
		studioSystem.update();
	}

	private static AttachedInstance FindOrAddAttachedInstance(EventInstance instance, Transform transform, ATTRIBUTES_3D attributes)
	{
		AttachedInstance attachedInstance = Instance.attachedInstances.Find((AttachedInstance x) => x.instance.handle == instance.handle);
		if (attachedInstance == null)
		{
			attachedInstance = new AttachedInstance();
			Instance.attachedInstances.Add(attachedInstance);
		}
		attachedInstance.instance = instance;
		attachedInstance.transform = transform;
		attachedInstance.instance.set3DAttributes(attributes);
		return attachedInstance;
	}

	public static void AttachInstanceToGameObject(EventInstance instance, GameObject gameObject, bool nonRigidbodyVelocity = false)
	{
		AttachedInstance attachedInstance = FindOrAddAttachedInstance(instance, gameObject.transform, gameObject.transform.To3DAttributes());
		if (nonRigidbodyVelocity)
		{
			attachedInstance.nonRigidbodyVelocity = nonRigidbodyVelocity;
			attachedInstance.lastFramePosition = gameObject.transform.position;
		}
	}

	[Obsolete("This overload has been deprecated in favor of passing a GameObject instead of a Transform.", false)]
	public static void AttachInstanceToGameObject(EventInstance instance, Transform transform, bool nonRigidbodyVelocity = false)
	{
		AttachedInstance attachedInstance = FindOrAddAttachedInstance(instance, transform, transform.To3DAttributes());
		if (nonRigidbodyVelocity)
		{
			attachedInstance.nonRigidbodyVelocity = nonRigidbodyVelocity;
			attachedInstance.lastFramePosition = transform.position;
		}
	}

	public static void AttachInstanceToGameObject(EventInstance instance, GameObject gameObject, Rigidbody rigidBody)
	{
		FindOrAddAttachedInstance(instance, gameObject.transform, RuntimeUtils.To3DAttributes(gameObject.transform, rigidBody)).rigidBody = rigidBody;
	}

	[Obsolete("This overload has been deprecated in favor of passing a GameObject instead of a Transform.", false)]
	public static void AttachInstanceToGameObject(EventInstance instance, Transform transform, Rigidbody rigidBody)
	{
		FindOrAddAttachedInstance(instance, transform, RuntimeUtils.To3DAttributes(transform, rigidBody)).rigidBody = rigidBody;
	}

	public static void AttachInstanceToGameObject(EventInstance instance, GameObject gameObject, Rigidbody2D rigidBody2D)
	{
		FindOrAddAttachedInstance(instance, gameObject.transform, RuntimeUtils.To3DAttributes(gameObject.transform, rigidBody2D)).rigidBody2D = rigidBody2D;
	}

	[Obsolete("This overload has been deprecated in favor of passing a GameObject instead of a Transform.", false)]
	public static void AttachInstanceToGameObject(EventInstance instance, Transform transform, Rigidbody2D rigidBody2D)
	{
		FindOrAddAttachedInstance(instance, transform, RuntimeUtils.To3DAttributes(transform, rigidBody2D)).rigidBody2D = rigidBody2D;
	}

	public static void DetachInstanceFromGameObject(EventInstance instance)
	{
		RuntimeManager runtimeManager = Instance;
		for (int i = 0; i < runtimeManager.attachedInstances.Count; i++)
		{
			if (runtimeManager.attachedInstances[i].instance.handle == instance.handle)
			{
				runtimeManager.attachedInstances[i] = runtimeManager.attachedInstances[runtimeManager.attachedInstances.Count - 1];
				runtimeManager.attachedInstances.RemoveAt(runtimeManager.attachedInstances.Count - 1);
				break;
			}
		}
	}

	internal void ExecuteOnGUI()
	{
		if (currentPlatform.OverlayRect != ScreenPosition.VR)
		{
			GUIStyle style = GUI.skin.GetStyle("window");
			style.fontSize = currentPlatform.OverlayFontSize;
			if (studioSystem.isValid() && isOverlayEnabled)
			{
				windowRect = GUI.Window(GetInstanceID(), windowRect, DrawDebugOverlay, "FMOD Studio Debug", style);
			}
		}
	}

	private void Start()
	{
		isOverlayEnabled = currentPlatform.IsOverlayEnabled;
	}

	private void UpdateDebugText()
	{
		if (!(lastDebugUpdate + 0.25f < Time.unscaledTime))
		{
			return;
		}
		if (initException != null)
		{
			lastDebugText = initException.Message;
			return;
		}
		if (!mixerHead.hasHandle())
		{
			coreSystem.getMasterChannelGroup(out var channelgroup);
			channelgroup.getDSP(0, out mixerHead);
			mixerHead.setMeteringEnabled(inputEnabled: false, outputEnabled: true);
		}
		StringBuilder stringBuilder = new StringBuilder();
		studioSystem.getCPUUsage(out var usage, out var usage_core);
		stringBuilder.AppendFormat("CPU: dsp = {0:F1}%, studio = {1:F1}%\n", usage_core.dsp, usage.update);
		Memory.GetStats(out var currentalloced, out var maxalloced);
		stringBuilder.AppendFormat("MEMORY: cur = {0}MB, max = {1}MB\n", currentalloced >> 20, maxalloced >> 20);
		coreSystem.getChannelsPlaying(out var channels, out var realchannels);
		stringBuilder.AppendFormat("CHANNELS: real = {0}, total = {1}\n", realchannels, channels);
		mixerHead.getMeteringInfo(IntPtr.Zero, out var outputInfo);
		float num = 0f;
		for (int i = 0; i < outputInfo.numchannels; i++)
		{
			num += outputInfo.rmslevel[i] * outputInfo.rmslevel[i];
		}
		num = Mathf.Sqrt(num / (float)outputInfo.numchannels);
		float num2 = ((num > 0f) ? (20f * Mathf.Log10(num * Mathf.Sqrt(2f))) : (-80f));
		if (num2 > 10f)
		{
			num2 = 10f;
		}
		stringBuilder.AppendFormat("VOLUME: RMS = {0:f2}db\n", num2);
		lastDebugText = stringBuilder.ToString();
		lastDebugUpdate = Time.unscaledTime;
	}

	private void DrawDebugOverlay(int windowID)
	{
		UpdateDebugText();
		GUIStyle style = GUI.skin.GetStyle("label");
		style.fontSize = currentPlatform.OverlayFontSize;
		float width = currentPlatform.OverlayFontSize * 20;
		float height = currentPlatform.OverlayFontSize * 7;
		GUI.Label(new Rect(30f, 20f, width, height), lastDebugText, style);
		GUI.DragWindow();
	}

	private void OnDestroy()
	{
		coreSystem.setCallback(null, ~FMOD.SYSTEM_CALLBACK_TYPE.ALL);
		ReleaseStudioSystem();
		initException = null;
		instance = null;
	}

	private void OnApplicationPause(bool pauseStatus)
	{
		if (studioSystem.isValid())
		{
			PauseAllEvents(pauseStatus);
			if (pauseStatus)
			{
				coreSystem.mixerSuspend();
			}
			else
			{
				coreSystem.mixerResume();
			}
		}
	}

	private static void ReferenceLoadedBank(string bankName, bool loadSamples)
	{
		LoadedBank value = Instance.loadedBanks[bankName];
		value.RefCount++;
		if (loadSamples)
		{
			value.Bank.loadSampleData();
		}
		Instance.loadedBanks[bankName] = value;
	}

	private void RegisterLoadedBank(LoadedBank loadedBank, string bankPath, string bankName, bool loadSamples, RESULT loadResult)
	{
		switch (loadResult)
		{
		case RESULT.OK:
			loadedBank.RefCount = 1;
			if (loadSamples)
			{
				loadedBank.Bank.loadSampleData();
			}
			Instance.loadedBanks.Add(bankName, loadedBank);
			break;
		case RESULT.ERR_EVENT_ALREADY_LOADED:
			RuntimeUtils.DebugLogWarningFormat("[FMOD] Unable to load {0} - bank already loaded. This may occur when attempting to load another localized bank before the first is unloaded, or if a bank has been loaded via the API.", bankName);
			break;
		default:
			throw new BankLoadException(bankPath, loadResult);
		}
		ExecuteSampleLoadRequestsIfReady();
	}

	private void ExecuteSampleLoadRequestsIfReady()
	{
		if (sampleLoadRequests.Count <= 0)
		{
			return;
		}
		foreach (string sampleLoadRequest in sampleLoadRequests)
		{
			if (!loadedBanks.ContainsKey(sampleLoadRequest))
			{
				return;
			}
		}
		foreach (string sampleLoadRequest2 in sampleLoadRequests)
		{
			CheckInitResult(loadedBanks[sampleLoadRequest2].Bank.loadSampleData(), $"Loading sample data for bank: {sampleLoadRequest2}");
		}
		sampleLoadRequests.Clear();
	}

	public static void LoadBank(string bankName, bool loadSamples = false)
	{
		LoadBank(bankName, loadSamples, bankName);
	}

	private static void LoadBank(string bankName, bool loadSamples, string bankId)
	{
		if (Instance.loadedBanks.ContainsKey(bankId))
		{
			ReferenceLoadedBank(bankId, loadSamples);
			return;
		}
		string text = Instance.currentPlatform.GetBankFolder();
		if (!string.IsNullOrEmpty(Settings.Instance.TargetSubFolder))
		{
			text = RuntimeUtils.GetCommonPlatformPath(Path.Combine(text, Settings.Instance.TargetSubFolder));
		}
		string text2 = ((!(Path.GetExtension(bankName) != ".bank")) ? $"{text}/{bankName}" : string.Format("{0}/{1}{2}", text, bankName, ".bank"));
		Instance.loadingBanksRef++;
		LoadedBank loadedBank = default(LoadedBank);
		RESULT loadResult = Instance.studioSystem.loadBankFile(text2, LOAD_BANK_FLAGS.NORMAL, out loadedBank.Bank);
		Instance.RegisterLoadedBank(loadedBank, text2, bankId, loadSamples, loadResult);
		Instance.loadingBanksRef--;
	}

	public static void LoadBank(TextAsset asset, bool loadSamples = false)
	{
		LoadBank(asset, loadSamples, asset.name);
	}

	private static void LoadBank(TextAsset asset, bool loadSamples, string bankId)
	{
		if (Instance.loadedBanks.ContainsKey(bankId))
		{
			ReferenceLoadedBank(bankId, loadSamples);
			return;
		}
		LoadedBank loadedBank = default(LoadedBank);
		RESULT loadResult = Instance.studioSystem.loadBankMemory(asset.bytes, LOAD_BANK_FLAGS.NORMAL, out loadedBank.Bank);
		Instance.RegisterLoadedBank(loadedBank, bankId, bankId, loadSamples, loadResult);
	}

	private void LoadBanks(Settings fmodSettings)
	{
		if (fmodSettings.ImportType != 0)
		{
			return;
		}
		if (fmodSettings.AutomaticSampleLoading)
		{
			sampleLoadRequests.AddRange(BanksToLoad(fmodSettings));
		}
		try
		{
			foreach (string item in BanksToLoad(fmodSettings))
			{
				LoadBank(item);
			}
			WaitForAllSampleLoading();
		}
		catch (BankLoadException e)
		{
			RuntimeUtils.DebugLogException(e);
		}
	}

	private IEnumerable<string> BanksToLoad(Settings fmodSettings)
	{
		switch (fmodSettings.BankLoadType)
		{
		case BankLoadType.All:
			foreach (string masterBankFileName in fmodSettings.MasterBanks)
			{
				yield return masterBankFileName + ".strings";
				yield return masterBankFileName;
			}
			foreach (string bank in fmodSettings.Banks)
			{
				yield return bank;
			}
			break;
		case BankLoadType.Specified:
			foreach (string item in fmodSettings.BanksToLoad)
			{
				if (!string.IsNullOrEmpty(item))
				{
					yield return item;
				}
			}
			break;
		}
	}

	public static void UnloadBank(string bankName)
	{
		if (Instance.loadedBanks.TryGetValue(bankName, out var value))
		{
			value.RefCount--;
			if (value.RefCount == 0)
			{
				value.Bank.unload();
				Instance.loadedBanks.Remove(bankName);
				Instance.sampleLoadRequests.Remove(bankName);
			}
			else
			{
				Instance.loadedBanks[bankName] = value;
			}
		}
	}

	public static void UnloadBank(TextAsset asset)
	{
		UnloadBank(asset.name);
	}

	[Obsolete("[FMOD] Deprecated. Use AnySampleDataLoading instead.")]
	public static bool AnyBankLoading()
	{
		return AnySampleDataLoading();
	}

	public static bool AnySampleDataLoading()
	{
		bool flag = false;
		foreach (LoadedBank value in Instance.loadedBanks.Values)
		{
			value.Bank.getSampleLoadingState(out var state);
			flag = flag || state == LOADING_STATE.LOADING;
		}
		return flag;
	}

	[Obsolete("[FMOD] Deprecated. Use WaitForAllSampleLoading instead.")]
	public static void WaitForAllLoads()
	{
		WaitForAllSampleLoading();
	}

	public static void WaitForAllSampleLoading()
	{
		Instance.studioSystem.flushSampleLoading();
	}

	public static GUID PathToGUID(string path)
	{
		GUID id;
		if (path.StartsWith("{"))
		{
			Util.parseID(path, out id);
		}
		else if (Instance.studioSystem.lookupID(path, out id) == RESULT.ERR_EVENT_NOTFOUND)
		{
			throw new EventNotFoundException(path);
		}
		return id;
	}

	public static EventReference PathToEventReference(string path)
	{
		GUID guid;
		try
		{
			guid = PathToGUID(path);
		}
		catch (EventNotFoundException)
		{
			guid = default(GUID);
		}
		EventReference result = default(EventReference);
		result.Guid = guid;
		return result;
	}

	public static EventInstance CreateInstance(EventReference eventReference)
	{
		try
		{
			return CreateInstance(eventReference.Guid);
		}
		catch (EventNotFoundException)
		{
			throw new EventNotFoundException(eventReference);
		}
	}

	public static EventInstance CreateInstance(string path)
	{
		try
		{
			return CreateInstance(PathToGUID(path));
		}
		catch (EventNotFoundException)
		{
			throw new EventNotFoundException(path);
		}
	}

	public static EventInstance CreateInstance(GUID guid)
	{
		GetEventDescription(guid).createInstance(out var result);
		return result;
	}

	public static void PlayOneShot(EventReference eventReference, Vector3 position = default(Vector3))
	{
		try
		{
			PlayOneShot(eventReference.Guid, position);
		}
		catch (EventNotFoundException)
		{
			EventReference eventReference2 = eventReference;
			RuntimeUtils.DebugLogWarning("[FMOD] Event not found: " + eventReference2.ToString());
		}
	}

	public static void PlayOneShot(string path, Vector3 position = default(Vector3))
	{
		try
		{
			PlayOneShot(PathToGUID(path), position);
		}
		catch (EventNotFoundException)
		{
			RuntimeUtils.DebugLogWarning("[FMOD] Event not found: " + path);
		}
	}

	public static void PlayOneShot(GUID guid, Vector3 position = default(Vector3))
	{
		if (CreateInstanceWithinMaxDistance(guid, position, out var eventInstance))
		{
			eventInstance.set3DAttributes(position.To3DAttributes());
			eventInstance.start();
			eventInstance.release();
		}
	}

	public static void PlayOneShotAttached(EventReference eventReference, GameObject gameObject)
	{
		try
		{
			PlayOneShotAttached(eventReference.Guid, gameObject);
		}
		catch (EventNotFoundException)
		{
			EventReference eventReference2 = eventReference;
			RuntimeUtils.DebugLogWarning("[FMOD] Event not found: " + eventReference2.ToString());
		}
	}

	public static void PlayOneShotAttached(string path, GameObject gameObject)
	{
		try
		{
			PlayOneShotAttached(PathToGUID(path), gameObject);
		}
		catch (EventNotFoundException)
		{
			RuntimeUtils.DebugLogWarning("[FMOD] Event not found: " + path);
		}
	}

	public static void PlayOneShotAttached(GUID guid, GameObject gameObject)
	{
		if (CreateInstanceWithinMaxDistance(guid, gameObject.transform.position, out var eventInstance))
		{
			AttachInstanceToGameObject(eventInstance, gameObject, gameObject.GetComponent<Rigidbody>());
			eventInstance.start();
			eventInstance.release();
		}
	}

	private static bool CreateInstanceWithinMaxDistance(GUID guid, Vector3 position, out EventInstance instance)
	{
		EventDescription eventDescription = GetEventDescription(guid);
		if (Settings.Instance.StopEventsOutsideMaxDistance)
		{
			eventDescription.is3D(out var is3D);
			if (is3D)
			{
				eventDescription.getMinMaxDistance(out var _, out var max);
				if (StudioListener.DistanceSquaredToNearestListener(position) > max * max)
				{
					instance = default(EventInstance);
					return false;
				}
			}
		}
		eventDescription.createInstance(out instance);
		return true;
	}

	public static EventDescription GetEventDescription(EventReference eventReference)
	{
		try
		{
			return GetEventDescription(eventReference.Guid);
		}
		catch (EventNotFoundException)
		{
			throw new EventNotFoundException(eventReference);
		}
	}

	public static EventDescription GetEventDescription(string path)
	{
		try
		{
			return GetEventDescription(PathToGUID(path));
		}
		catch (EventNotFoundException)
		{
			throw new EventNotFoundException(path);
		}
	}

	public static EventDescription GetEventDescription(GUID guid)
	{
		if (Instance.cachedDescriptions.ContainsKey(guid) && Instance.cachedDescriptions[guid].isValid())
		{
			return Instance.cachedDescriptions[guid];
		}
		if (Instance.studioSystem.getEventByID(guid, out var _event) != 0)
		{
			throw new EventNotFoundException(guid);
		}
		if (_event.isValid())
		{
			Instance.cachedDescriptions[guid] = _event;
		}
		return _event;
	}

	public static void SetListenerLocation(GameObject gameObject, Rigidbody rigidBody, GameObject attenuationObject = null)
	{
		SetListenerLocation(0, gameObject, rigidBody, attenuationObject);
	}

	public static void SetListenerLocation(int listenerIndex, GameObject gameObject, Rigidbody rigidBody, GameObject attenuationObject = null)
	{
		if ((bool)attenuationObject)
		{
			Instance.studioSystem.setListenerAttributes(listenerIndex, RuntimeUtils.To3DAttributes(gameObject.transform, rigidBody), attenuationObject.transform.position.ToFMODVector());
		}
		else
		{
			Instance.studioSystem.setListenerAttributes(listenerIndex, RuntimeUtils.To3DAttributes(gameObject.transform, rigidBody));
		}
	}

	public static void SetListenerLocation(GameObject gameObject, Rigidbody2D rigidBody2D, GameObject attenuationObject = null)
	{
		SetListenerLocation(0, gameObject, rigidBody2D, attenuationObject);
	}

	public static void SetListenerLocation(int listenerIndex, GameObject gameObject, Rigidbody2D rigidBody2D, GameObject attenuationObject = null)
	{
		if ((bool)attenuationObject)
		{
			Instance.studioSystem.setListenerAttributes(listenerIndex, RuntimeUtils.To3DAttributes(gameObject.transform, rigidBody2D), attenuationObject.transform.position.ToFMODVector());
		}
		else
		{
			Instance.studioSystem.setListenerAttributes(listenerIndex, RuntimeUtils.To3DAttributes(gameObject.transform, rigidBody2D));
		}
	}

	public static void SetListenerLocation(int listenerIndex, GameObject gameObject, GameObject attenuationObject = null, Vector3 velocity = default(Vector3))
	{
		if ((bool)attenuationObject)
		{
			Instance.studioSystem.setListenerAttributes(listenerIndex, gameObject.transform.To3DAttributes(velocity), attenuationObject.transform.position.ToFMODVector());
		}
		else
		{
			Instance.studioSystem.setListenerAttributes(listenerIndex, gameObject.transform.To3DAttributes(velocity));
		}
	}

	public static void SetListenerLocation(GameObject gameObject, GameObject attenuationObject = null)
	{
		SetListenerLocation(0, gameObject, attenuationObject);
	}

	public static void SetListenerLocation(int listenerIndex, GameObject gameObject, GameObject attenuationObject = null)
	{
		if ((bool)attenuationObject)
		{
			Instance.studioSystem.setListenerAttributes(listenerIndex, gameObject.transform.To3DAttributes(), attenuationObject.transform.position.ToFMODVector());
		}
		else
		{
			Instance.studioSystem.setListenerAttributes(listenerIndex, gameObject.transform.To3DAttributes());
		}
	}

	public static Bus GetBus(string path)
	{
		if (StudioSystem.getBus(path, out var bus) != 0)
		{
			throw new BusNotFoundException(path);
		}
		return bus;
	}

	public static VCA GetVCA(string path)
	{
		if (StudioSystem.getVCA(path, out var vca) != 0)
		{
			throw new VCANotFoundException(path);
		}
		return vca;
	}

	public static void PauseAllEvents(bool paused)
	{
		if (StudioSystem.getBus("bus:/", out var bus) == RESULT.OK)
		{
			bus.setPaused(paused);
		}
	}

	public static void MuteAllEvents(bool muted)
	{
		Instance.isMuted = muted;
		ApplyMuteState();
	}

	private static void ApplyMuteState()
	{
		if (StudioSystem.getBus("bus:/", out var bus) == RESULT.OK)
		{
			bus.setMute(Instance.isMuted);
		}
	}

	public static bool HasBankLoaded(string loadedBank)
	{
		return Instance.loadedBanks.ContainsKey(loadedBank);
	}

	private void SetOverlayPosition()
	{
		float num = currentPlatform.OverlayFontSize * 20;
		float num2 = currentPlatform.OverlayFontSize * 7;
		float num3 = 30f;
		switch (currentPlatform.OverlayRect)
		{
		case ScreenPosition.TopLeft:
			windowRect = new Rect(num3, num3, num, num2);
			break;
		case ScreenPosition.TopCenter:
			windowRect = new Rect((float)(Screen.width / 2) - num / 2f, num3, num, num2);
			break;
		case ScreenPosition.TopRight:
			windowRect = new Rect((float)Screen.width - (num + num3), num3, num, num2);
			break;
		case ScreenPosition.BottomLeft:
			windowRect = new Rect(num3, (float)Screen.height - (num2 + num3), num, num2);
			break;
		case ScreenPosition.BottomCenter:
			windowRect = new Rect((float)(Screen.width / 2) - num / 2f, (float)Screen.height - (num2 + num3), num, num2);
			break;
		case ScreenPosition.BottomRight:
			windowRect = new Rect((float)Screen.width - (num + num3), (float)Screen.height - (num2 + num3), num, num2);
			break;
		case ScreenPosition.Center:
			windowRect = new Rect((float)(Screen.width / 2) - num / 2f, (float)(Screen.height / 2) - num2 / 2f, num, num2);
			break;
		case ScreenPosition.VR:
			RuntimeUtils.DebugLogWarning("[FMOD] UNITY_URP_EXIST is not defined. The VR debug overlay requires the Universal Render Pipeline.");
			break;
		default:
			windowRect = new Rect(num3, num3, num, num2);
			break;
		}
	}
}
