using System;
using System.Collections.Generic;
using FMOD.Studio;
using UnityEngine;
using UnityEngine.Serialization;

namespace FMODUnity;

[AddComponentMenu("FMOD Studio/FMOD Studio Event Emitter")]
public class StudioEventEmitter : EventHandler
{
	public EventReference EventReference;

	[Obsolete("Use the EventReference field instead")]
	public string Event = "";

	[FormerlySerializedAs("PlayEvent")]
	public EmitterGameEvent EventPlayTrigger;

	[FormerlySerializedAs("StopEvent")]
	public EmitterGameEvent EventStopTrigger;

	public bool AllowFadeout = true;

	public bool TriggerOnce;

	public bool Preload;

	[FormerlySerializedAs("AllowNonRigidbodyDoppler")]
	public bool NonRigidbodyVelocity;

	public ParamRef[] Params = new ParamRef[0];

	public bool OverrideAttenuation;

	public float OverrideMinDistance = -1f;

	public float OverrideMaxDistance = -1f;

	protected EventDescription eventDescription;

	protected EventInstance instance;

	private bool hasTriggered;

	private bool isQuitting;

	private bool isOneshot;

	private List<ParamRef> cachedParams = new List<ParamRef>();

	private static List<StudioEventEmitter> activeEmitters = new List<StudioEventEmitter>();

	private const string SnapshotString = "snapshot";

	[Obsolete("Use the EventPlayTrigger field instead")]
	public EmitterGameEvent PlayEvent
	{
		get
		{
			return EventPlayTrigger;
		}
		set
		{
			EventPlayTrigger = value;
		}
	}

	[Obsolete("Use the EventStopTrigger field instead")]
	public EmitterGameEvent StopEvent
	{
		get
		{
			return EventStopTrigger;
		}
		set
		{
			EventStopTrigger = value;
		}
	}

	public EventDescription EventDescription => eventDescription;

	public EventInstance EventInstance => instance;

	public bool IsActive { get; private set; }

	private float MaxDistance
	{
		get
		{
			if (OverrideAttenuation)
			{
				return OverrideMaxDistance;
			}
			if (!eventDescription.isValid())
			{
				Lookup();
			}
			eventDescription.getMinMaxDistance(out var _, out var max);
			return max;
		}
	}

	public static void UpdateActiveEmitters()
	{
		foreach (StudioEventEmitter activeEmitter in activeEmitters)
		{
			activeEmitter.UpdatePlayingStatus();
		}
	}

	private static void RegisterActiveEmitter(StudioEventEmitter emitter)
	{
		if (!activeEmitters.Contains(emitter))
		{
			activeEmitters.Add(emitter);
		}
	}

	private static void DeregisterActiveEmitter(StudioEventEmitter emitter)
	{
		activeEmitters.Remove(emitter);
	}

	private void UpdatePlayingStatus(bool force = false)
	{
		bool flag = StudioListener.DistanceSquaredToNearestListener(base.transform.position) <= MaxDistance * MaxDistance;
		if (force || flag != IsPlaying())
		{
			if (flag)
			{
				PlayInstance();
			}
			else
			{
				StopInstance();
			}
		}
	}

	protected override void Start()
	{
		RuntimeUtils.EnforceLibraryOrder();
		if (Preload)
		{
			Lookup();
			eventDescription.loadSampleData();
		}
		HandleGameEvent(EmitterGameEvent.ObjectStart);
		if (NonRigidbodyVelocity && (bool)GetComponent<Rigidbody>())
		{
			Debug.LogWarning($"[FMOD] Non-Rigidbody Velocity is enabled on Emitter attached to GameObject \"{base.name}\", which also has a Rigidbody component attached - this will be disabled in favor of velocity from Rigidbody component.");
			NonRigidbodyVelocity = false;
		}
		if (NonRigidbodyVelocity && (bool)GetComponent<Rigidbody2D>())
		{
			Debug.LogWarning($"[FMOD] Non-Rigidbody Velocity is enabled on Emitter attached to GameObject \"{base.name}\", which also has a Rigidbody2D component attached - this will be disabled in favor of velocity from Rigidbody2D component.");
			NonRigidbodyVelocity = false;
		}
	}

	private void OnApplicationQuit()
	{
		isQuitting = true;
	}

	protected override void OnDestroy()
	{
		if (isQuitting)
		{
			return;
		}
		HandleGameEvent(EmitterGameEvent.ObjectDestroy);
		if (instance.isValid())
		{
			RuntimeManager.DetachInstanceFromGameObject(instance);
			if (eventDescription.isValid() && isOneshot)
			{
				instance.release();
				instance.clearHandle();
			}
		}
		DeregisterActiveEmitter(this);
		if (Preload)
		{
			eventDescription.unloadSampleData();
		}
	}

	protected override void HandleGameEvent(EmitterGameEvent gameEvent)
	{
		if (EventPlayTrigger == gameEvent)
		{
			Play();
		}
		if (EventStopTrigger == gameEvent)
		{
			Stop();
		}
	}

	private void Lookup()
	{
		eventDescription = RuntimeManager.GetEventDescription(EventReference);
		if (eventDescription.isValid())
		{
			for (int i = 0; i < Params.Length; i++)
			{
				eventDescription.getParameterDescriptionByName(Params[i].Name, out var parameter);
				Params[i].ID = parameter.id;
			}
		}
	}

	public void Play()
	{
		if ((TriggerOnce && hasTriggered) || EventReference.IsNull)
		{
			return;
		}
		cachedParams.Clear();
		if (!eventDescription.isValid())
		{
			Lookup();
		}
		eventDescription.isSnapshot(out var snapshot);
		if (!snapshot)
		{
			eventDescription.isOneshot(out isOneshot);
		}
		eventDescription.is3D(out var is3D);
		IsActive = true;
		if (is3D && Settings.Instance.StopEventsOutsideMaxDistance)
		{
			if (!isOneshot)
			{
				RegisterActiveEmitter(this);
			}
			UpdatePlayingStatus(force: true);
		}
		else
		{
			PlayInstance();
		}
	}

	private void PlayInstance()
	{
		if (!instance.isValid())
		{
			instance.clearHandle();
		}
		if (isOneshot && instance.isValid())
		{
			instance.release();
			instance.clearHandle();
		}
		eventDescription.is3D(out var is3D);
		if (!instance.isValid())
		{
			eventDescription.createInstance(out instance);
			if (is3D)
			{
				GetComponent<Transform>();
				if ((bool)GetComponent<Rigidbody>())
				{
					Rigidbody component = GetComponent<Rigidbody>();
					instance.set3DAttributes(RuntimeUtils.To3DAttributes(base.gameObject, component));
					RuntimeManager.AttachInstanceToGameObject(instance, base.gameObject, component);
				}
				else if ((bool)GetComponent<Rigidbody2D>())
				{
					Rigidbody2D component2 = GetComponent<Rigidbody2D>();
					instance.set3DAttributes(RuntimeUtils.To3DAttributes(base.gameObject, component2));
					RuntimeManager.AttachInstanceToGameObject(instance, base.gameObject, component2);
				}
				else
				{
					instance.set3DAttributes(base.gameObject.To3DAttributes());
					RuntimeManager.AttachInstanceToGameObject(instance, base.gameObject, NonRigidbodyVelocity);
				}
			}
		}
		ParamRef[] @params = Params;
		foreach (ParamRef paramRef in @params)
		{
			instance.setParameterByID(paramRef.ID, paramRef.Value);
		}
		foreach (ParamRef cachedParam in cachedParams)
		{
			instance.setParameterByID(cachedParam.ID, cachedParam.Value);
		}
		if (is3D && OverrideAttenuation)
		{
			instance.setProperty(EVENT_PROPERTY.MINIMUM_DISTANCE, OverrideMinDistance);
			instance.setProperty(EVENT_PROPERTY.MAXIMUM_DISTANCE, OverrideMaxDistance);
		}
		instance.start();
		hasTriggered = true;
	}

	public void Stop()
	{
		DeregisterActiveEmitter(this);
		IsActive = false;
		cachedParams.Clear();
		StopInstance();
	}

	private void StopInstance()
	{
		if (TriggerOnce && hasTriggered)
		{
			DeregisterActiveEmitter(this);
		}
		if (instance.isValid())
		{
			instance.stop((!AllowFadeout) ? FMOD.Studio.STOP_MODE.IMMEDIATE : FMOD.Studio.STOP_MODE.ALLOWFADEOUT);
			instance.release();
			if (!AllowFadeout)
			{
				instance.clearHandle();
			}
		}
	}

	public void SetParameter(string name, float value, bool ignoreseekspeed = false)
	{
		if (Settings.Instance.StopEventsOutsideMaxDistance && IsActive)
		{
			string findName = name;
			ParamRef paramRef = cachedParams.Find((ParamRef x) => x.Name == findName);
			if (paramRef == null)
			{
				eventDescription.getParameterDescriptionByName(name, out var parameter);
				paramRef = new ParamRef();
				paramRef.ID = parameter.id;
				paramRef.Name = parameter.name;
				cachedParams.Add(paramRef);
			}
			paramRef.Value = value;
		}
		if (instance.isValid())
		{
			instance.setParameterByName(name, value, ignoreseekspeed);
		}
	}

	public void SetParameter(PARAMETER_ID id, float value, bool ignoreseekspeed = false)
	{
		if (Settings.Instance.StopEventsOutsideMaxDistance && IsActive)
		{
			PARAMETER_ID findId = id;
			ParamRef paramRef = cachedParams.Find((ParamRef x) => x.ID.Equals(findId));
			if (paramRef == null)
			{
				eventDescription.getParameterDescriptionByID(id, out var parameter);
				paramRef = new ParamRef();
				paramRef.ID = parameter.id;
				paramRef.Name = parameter.name;
				cachedParams.Add(paramRef);
			}
			paramRef.Value = value;
		}
		if (instance.isValid())
		{
			instance.setParameterByID(id, value, ignoreseekspeed);
		}
	}

	public bool IsPlaying()
	{
		if (instance.isValid())
		{
			instance.getPlaybackState(out var state);
			return state != PLAYBACK_STATE.STOPPED;
		}
		return false;
	}
}
