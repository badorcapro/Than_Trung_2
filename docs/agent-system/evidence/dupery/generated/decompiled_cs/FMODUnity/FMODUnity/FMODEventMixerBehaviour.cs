using System;
using UnityEngine;
using UnityEngine.Playables;

namespace FMODUnity;

[Serializable]
public class FMODEventMixerBehaviour : PlayableBehaviour
{
	[Range(0f, 1f)]
	public float volume = 1f;

	public override void ProcessFrame(Playable playable, FrameData info, object playerData)
	{
		int inputCount = playable.GetInputCount();
		float time = (float)playable.GetGraph().GetRootPlayable(0).GetTime();
		for (int i = 0; i < inputCount; i++)
		{
			((ScriptPlayable<FMODEventPlayableBehavior>)playable.GetInput(i)).GetBehaviour().UpdateBehavior(time, volume);
		}
	}
}
