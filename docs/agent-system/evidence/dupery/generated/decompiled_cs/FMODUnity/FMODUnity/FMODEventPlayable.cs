using System;
using System.Collections.Generic;
using FMOD.Studio;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Serialization;
using UnityEngine.Timeline;

namespace FMODUnity;

[Serializable]
public class FMODEventPlayable : PlayableAsset, ITimelineClipAsset
{
	[FormerlySerializedAs("template")]
	public FMODEventPlayableBehavior Template = new FMODEventPlayableBehavior();

	[FormerlySerializedAs("eventLength")]
	public float EventLength;

	[Obsolete("Use the eventReference field instead")]
	[SerializeField]
	public string eventName;

	[FormerlySerializedAs("eventReference")]
	[SerializeField]
	public EventReference EventReference;

	[FormerlySerializedAs("stopType")]
	[SerializeField]
	public STOP_MODE StopType;

	[FormerlySerializedAs("parameters")]
	[SerializeField]
	public ParamRef[] Parameters = new ParamRef[0];

	[NonSerialized]
	public bool CachedParameters;

	private FMODEventPlayableBehavior behavior;

	public GameObject TrackTargetObject { get; set; }

	public override double duration
	{
		get
		{
			if (EventReference.IsNull)
			{
				return base.duration;
			}
			return EventLength;
		}
	}

	public ClipCaps clipCaps => ClipCaps.None;

	public TimelineClip OwningClip { get; set; }

	public static event EventHandler<EventArgs> OnCreatePlayable;

	public void LinkParameters(EventDescription eventDescription)
	{
		if (!CachedParameters && !EventReference.IsNull)
		{
			for (int i = 0; i < Parameters.Length; i++)
			{
				eventDescription.getParameterDescriptionByName(Parameters[i].Name, out var parameter);
				Parameters[i].ID = parameter.id;
			}
			List<ParameterAutomationLink> parameterLinks = Template.ParameterLinks;
			for (int j = 0; j < parameterLinks.Count; j++)
			{
				eventDescription.getParameterDescriptionByName(parameterLinks[j].Name, out var parameter2);
				parameterLinks[j].ID = parameter2.id;
			}
			CachedParameters = true;
		}
	}

	public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
	{
		if (Application.isPlaying)
		{
			LinkParameters(RuntimeManager.GetEventDescription(EventReference));
		}
		else
		{
			EventArgs e = new EventArgs();
			FMODEventPlayable.OnCreatePlayable(this, e);
		}
		ScriptPlayable<FMODEventPlayableBehavior> scriptPlayable = ScriptPlayable<FMODEventPlayableBehavior>.Create(graph, Template);
		behavior = scriptPlayable.GetBehaviour();
		behavior.TrackTargetObject = TrackTargetObject;
		behavior.EventReference = EventReference;
		behavior.StopType = StopType;
		behavior.Parameters = Parameters;
		behavior.OwningClip = OwningClip;
		return scriptPlayable;
	}
}
