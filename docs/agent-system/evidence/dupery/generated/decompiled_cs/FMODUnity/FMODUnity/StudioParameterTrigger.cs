using FMOD.Studio;
using UnityEngine;

namespace FMODUnity;

[AddComponentMenu("FMOD Studio/FMOD Studio Parameter Trigger")]
public class StudioParameterTrigger : EventHandler
{
	public EmitterRef[] Emitters;

	public EmitterGameEvent TriggerEvent;

	private void Awake()
	{
		for (int i = 0; i < Emitters.Length; i++)
		{
			EmitterRef emitterRef = Emitters[i];
			if (!(emitterRef.Target != null) || emitterRef.Target.EventReference.IsNull)
			{
				continue;
			}
			EventDescription eventDescription = RuntimeManager.GetEventDescription(emitterRef.Target.EventReference);
			if (eventDescription.isValid())
			{
				for (int j = 0; j < Emitters[i].Params.Length; j++)
				{
					eventDescription.getParameterDescriptionByName(emitterRef.Params[j].Name, out var parameter);
					emitterRef.Params[j].ID = parameter.id;
				}
			}
		}
	}

	protected override void HandleGameEvent(EmitterGameEvent gameEvent)
	{
		if (TriggerEvent == gameEvent)
		{
			TriggerParameters();
		}
	}

	public void TriggerParameters()
	{
		for (int i = 0; i < Emitters.Length; i++)
		{
			EmitterRef emitterRef = Emitters[i];
			if (emitterRef.Target != null && emitterRef.Target.EventInstance.isValid())
			{
				for (int j = 0; j < Emitters[i].Params.Length; j++)
				{
					emitterRef.Target.EventInstance.setParameterByID(Emitters[i].Params[j].ID, Emitters[i].Params[j].Value);
				}
			}
		}
	}
}
