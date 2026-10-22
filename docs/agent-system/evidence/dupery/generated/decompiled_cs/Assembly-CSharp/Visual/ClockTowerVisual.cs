using System;
using System.Collections;
using System.Linq;
using Audio;
using GRGLib.Coroutines;
using GRGLib.TextAnimation;
using GRGLocalisation;
using Localisation;
using TMPro;
using UnityEngine;

namespace Visual;

public class ClockTowerVisual : LocationVisual, IAmLocalised
{
	[Header("References")]
	[SerializeField]
	private TMP_Text ring_text;

	private CoroutineRunner ring_runner;

	private CoroutineRunner ring_text_runner;

	private int last_ring = -1;

	private int last_time = -1;

	private AssetKey localisation_asset => LocalisationHelper.ui_asset;

	private string loc_ring_key => "ClockTower [ring]";

	public override void setUpLocation(LocationData _data, Action<LocationData> _use_ability)
	{
		base.setUpLocation(_data, _use_ability);
		ring_runner = new CoroutineRunner(this);
		ring_text_runner = new CoroutineRunner(this);
	}

	public override void renew(LocationData _data, CaseSnapshot _snap, Action<LocationData, Vector3> _replace_location)
	{
		if (!(_data is ClockTower clockTower) || !(_snap is ClockCaseSnapshot clockCaseSnapshot))
		{
			Debug.LogError("No clocktower/snapshot is not a clock case snapshot!! this is not allowed for the CLOCK tower!");
		}
		else
		{
			if (clockTower.recorded_rings.Count == 0)
			{
				return;
			}
			int num = clockTower.recorded_rings.Last();
			if (num <= last_ring)
			{
				if (clockCaseSnapshot.clock_payload.hour_passed > last_ring + 1)
				{
					ring(_start: false);
				}
				last_time = clockCaseSnapshot.clock_payload.hour_passed;
				return;
			}
			last_ring = num;
			last_time = clockCaseSnapshot.clock_payload.hour_passed;
			if (last_time - last_ring < 2)
			{
				ring();
			}
			else
			{
				ring(_start: false);
			}
		}
	}

	private void ring(bool _start = true)
	{
		if (_start)
		{
			ring_runner.run(ringAnimation());
		}
		else if (ring_runner.is_running)
		{
			ring_runner.stop();
			base.transform.localScale = new Vector3(1f, 1f, 1f);
			base.transform.localEulerAngles = new Vector3(0f, 0f, 0f);
			ring_text.fade(0f, 0.25f, CoroutineExtensions.easeInOutFunc).start(this);
		}
	}

	private IEnumerator ringAnimation()
	{
		AudioHandler.Sfx.playSfx(Sfx.CLOCK_TOWER_CHIME);
		ring_text.text = "";
		ring_text.alpha = 1f;
		while (true)
		{
			ring_text.bakeText(getRingText());
			ring_text_runner.run(DialogueTextWriter.writeDialogueToTextNoFade(ring_text, 0.03f, _bake_text: false));
			yield return base.transform.jiggle();
			yield return 0.5f.wait();
		}
	}

	private string getRingText()
	{
		if (GRGLocalisationHandler.needs_translation)
		{
			string _result = "";
			if (GRGLocalisationHandler.instance.translate(localisation_asset, loc_ring_key, out _result))
			{
				return _result;
			}
		}
		return ringEnglish();
	}

	private string ringEnglish()
	{
		return "RING RING!";
	}
}
