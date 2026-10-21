using FMOD;
using FMOD.Studio;
using UnityEngine;
using UnityEngine.Serialization;

namespace FMODUnity;

[AddComponentMenu("FMOD Studio/FMOD Studio Global Parameter Trigger")]
public class StudioGlobalParameterTrigger : EventHandler
{
	[ParamRef]
	[FormerlySerializedAs("parameter")]
	public string Parameter;

	public EmitterGameEvent TriggerEvent;

	[FormerlySerializedAs("value")]
	public float Value;

	private PARAMETER_DESCRIPTION parameterDescription;

	public PARAMETER_DESCRIPTION ParameterDescription => parameterDescription;

	protected override void HandleGameEvent(EmitterGameEvent gameEvent)
	{
		if (TriggerEvent == gameEvent)
		{
			TriggerParameters();
		}
	}

	public void TriggerParameters()
	{
		if (string.IsNullOrEmpty(Parameter))
		{
			return;
		}
		RESULT rESULT = RESULT.OK;
		if (string.IsNullOrEmpty(parameterDescription.name))
		{
			rESULT = RuntimeManager.StudioSystem.getParameterDescriptionByName(Parameter, out parameterDescription);
			if (rESULT != 0)
			{
				RuntimeUtils.DebugLogError($"[FMOD] StudioGlobalParameterTrigger failed to lookup parameter {Parameter} : result = {rESULT}");
				return;
			}
		}
		rESULT = RuntimeManager.StudioSystem.setParameterByID(parameterDescription.id, Value);
		if (rESULT != 0)
		{
			RuntimeUtils.DebugLogError($"[FMOD] StudioGlobalParameterTrigger failed to set parameter {Parameter} : result = {rESULT}");
		}
	}
}
