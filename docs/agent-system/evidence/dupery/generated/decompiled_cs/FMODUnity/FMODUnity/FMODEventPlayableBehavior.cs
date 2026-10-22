using System;
using System.Collections.Generic;
using FMOD.Studio;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Serialization;
using UnityEngine.Timeline;

namespace FMODUnity;

[Serializable]
public class FMODEventPlayableBehavior : PlayableBehaviour
{
	public class EventArgs : System.EventArgs
	{
		public EventInstance eventInstance { get; set; }
	}

	[FormerlySerializedAs("eventReference")]
	public EventReference EventReference;

	[FormerlySerializedAs("stopType")]
	public STOP_MODE StopType;

	[FormerlySerializedAs("parameters")]
	[NotKeyable]
	public ParamRef[] Parameters = new ParamRef[0];

	[FormerlySerializedAs("parameterLinks")]
	public List<ParameterAutomationLink> ParameterLinks = new List<ParameterAutomationLink>();

	[NonSerialized]
	public GameObject TrackTargetObject;

	[NonSerialized]
	public TimelineClip OwningClip;

	[FormerlySerializedAs("parameterAutomation")]
	public AutomatableSlots ParameterAutomation;

	private bool isPlayheadInside;

	private EventInstance eventInstance;

	public float ClipStartTime { get; private set; }

	public float CurrentVolume { get; private set; }

	public static event EventHandler<EventArgs> Enter;

	public static event EventHandler<EventArgs> Exit;

	public static event EventHandler<EventArgs> GraphStop;

	public FMODEventPlayableBehavior()
	{
		CurrentVolume = 1f;
	}

	protected void PlayEvent()
	{
		if (EventReference.IsNull)
		{
			return;
		}
		eventInstance = RuntimeManager.CreateInstance(EventReference);
		if (Application.isPlaying && (bool)TrackTargetObject)
		{
			if ((bool)TrackTargetObject.GetComponent<Rigidbody>())
			{
				RuntimeManager.AttachInstanceToGameObject(eventInstance, TrackTargetObject, TrackTargetObject.GetComponent<Rigidbody>());
			}
			else if ((bool)TrackTargetObject.GetComponent<Rigidbody2D>())
			{
				RuntimeManager.AttachInstanceToGameObject(eventInstance, TrackTargetObject, TrackTargetObject.GetComponent<Rigidbody2D>());
			}
			else
			{
				RuntimeManager.AttachInstanceToGameObject(eventInstance, TrackTargetObject);
			}
		}
		else
		{
			eventInstance.set3DAttributes(Vector3.zero.To3DAttributes());
		}
		ParamRef[] parameters = Parameters;
		foreach (ParamRef paramRef in parameters)
		{
			eventInstance.setParameterByID(paramRef.ID, paramRef.Value);
		}
		eventInstance.setVolume(CurrentVolume);
		eventInstance.setTimelinePosition((int)(ClipStartTime * 1000f));
		eventInstance.start();
	}

	protected virtual void OnEnter()
	{
		if (!isPlayheadInside)
		{
			isPlayheadInside = true;
			if (Application.isPlaying)
			{
				PlayEvent();
				return;
			}
			EventArgs eventArgs = new EventArgs();
			FMODEventPlayableBehavior.Enter(this, eventArgs);
			eventInstance = eventArgs.eventInstance;
		}
	}

	protected virtual void OnExit()
	{
		if (!isPlayheadInside)
		{
			return;
		}
		isPlayheadInside = false;
		if (Application.isPlaying)
		{
			if (eventInstance.isValid())
			{
				if (StopType != STOP_MODE.None)
				{
					eventInstance.stop((StopType == STOP_MODE.Immediate) ? FMOD.Studio.STOP_MODE.IMMEDIATE : FMOD.Studio.STOP_MODE.ALLOWFADEOUT);
				}
				eventInstance.release();
				eventInstance.clearHandle();
			}
		}
		else
		{
			EventArgs eventArgs = new EventArgs();
			eventArgs.eventInstance = eventInstance;
			FMODEventPlayableBehavior.Exit(this, eventArgs);
		}
	}

	public override void ProcessFrame(Playable playable, FrameData info, object playerData)
	{
		if (!eventInstance.isValid())
		{
			return;
		}
		foreach (ParameterAutomationLink parameterLink in ParameterLinks)
		{
			float value = ParameterAutomation.GetValue(parameterLink.Slot);
			eventInstance.setParameterByID(parameterLink.ID, value);
		}
	}

	public void UpdateBehavior(float time, float volume)
	{
		if (volume != CurrentVolume)
		{
			CurrentVolume = volume;
			if (eventInstance.isValid())
			{
				eventInstance.setVolume(volume);
			}
		}
		if ((double)time >= OwningClip.start && (double)time < OwningClip.end)
		{
			ClipStartTime = time - (float)OwningClip.start;
			OnEnter();
		}
		else
		{
			OnExit();
		}
	}

	public override void OnGraphStop(Playable playable)
	{
		isPlayheadInside = false;
		if (Application.isPlaying)
		{
			if (eventInstance.isValid())
			{
				eventInstance.stop(FMOD.Studio.STOP_MODE.IMMEDIATE);
				eventInstance.release();
				RuntimeManager.StudioSystem.update();
			}
		}
		else
		{
			EventArgs eventArgs = new EventArgs();
			eventArgs.eventInstance = eventInstance;
			FMODEventPlayableBehavior.GraphStop(this, eventArgs);
		}
	}
}
