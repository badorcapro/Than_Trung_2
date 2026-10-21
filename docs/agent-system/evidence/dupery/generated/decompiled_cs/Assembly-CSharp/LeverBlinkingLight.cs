using System.Collections;
using GRGLib.Coroutines;
using GRGLib.Extensions.Unity;
using UnityEngine;
using UnityEngine.UI;

public class LeverBlinkingLight : MonoBehaviour
{
	[SerializeField]
	private Image blinking_light;

	[SerializeField]
	private AnimationCurve curve;

	private bool light_on;

	private CoroutineRunner flicker_runner;

	private void Start()
	{
		flicker_runner = new CoroutineRunner(this);
	}

	public void toggleLightState()
	{
		light_on = !light_on;
		flicker_runner.run(doLightFlicker(light_on));
	}

	public void setLightState(bool _light_state)
	{
		if (light_on != _light_state)
		{
			toggleLightState();
		}
	}

	private IEnumerator doLightFlicker(bool flicker_off)
	{
		float e_time = 0f;
		float duration = 1f;
		while (e_time < duration)
		{
			e_time += Time.deltaTime;
			float time = (flicker_off ? e_time : (duration - e_time));
			blinking_light.color = blinking_light.color.setAlpha(curve.Evaluate(time));
			yield return null;
		}
		blinking_light.color = blinking_light.color.setAlpha(curve.Evaluate(flicker_off ? duration : 0f));
	}
}
