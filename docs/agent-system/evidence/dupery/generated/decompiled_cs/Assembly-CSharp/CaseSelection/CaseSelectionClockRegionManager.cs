using System.Collections;
using Audio;
using ControllerSupport;
using GRGLib.Coroutines;
using GRGLib.UI;
using UnityEngine;

namespace CaseSelection;

public class CaseSelectionClockRegionManager : CaseSelectionRegionSpecificManager
{
	[Header("References")]
	[SerializeField]
	private CaseSelectionHandler handler;

	[SerializeField]
	private ProgressBar region_progress;

	[SerializeField]
	private CaseSelectionReputationManager reputation_manager;

	[SerializeField]
	private CaseSelectionRegionControllerSupport selection_controller_support;

	public override void setUp(_dep_RegionState _region, CaseSelectionInputHandler _input_handler)
	{
		handler.setUp(_input_handler.getPlayerInput());
		selection_controller_support.setUp(_input_handler);
		if (_region is _dep_ClockRegionState dep_ClockRegionState)
		{
			reputation_manager.setReputation(dep_ClockRegionState.reputation);
		}
	}

	private IEnumerator setProgress(float _last_region, int _current)
	{
		region_progress.setProgressInstant(_last_region, 100f);
		yield return 0.5f.wait();
		region_progress.setProgress(_current, 100f);
		progressPop(_last_region, _current).start(this);
	}

	private IEnumerator progressPop(float _starting_prog, int _progress)
	{
		if (_starting_prog == (float)_progress)
		{
			yield break;
		}
		float e = 0f;
		float duration = 1f;
		float next = 0f;
		float start_pop = (_starting_prog * 2f - 100f) * 0.01f;
		float final_pop = (float)(_progress * 2 - 100) * 0.01f;
		while (e < duration)
		{
			if (e >= next)
			{
				next += 0.1f;
				float param_value = start_pop + (final_pop - start_pop) * (e / duration);
				AudioHandler.Sfx.playSfxWithParam(Sfx.POP, "PopPitch", param_value, 0.65f);
			}
			e += Time.deltaTime;
			yield return null;
		}
	}
}
