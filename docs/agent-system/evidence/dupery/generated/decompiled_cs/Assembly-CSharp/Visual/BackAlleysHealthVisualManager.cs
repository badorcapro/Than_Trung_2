using System.Collections;
using System.Collections.Generic;
using GRGLib.Coroutines;
using GRGLib.UI;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace Visual;

public class BackAlleysHealthVisualManager : MonoBehaviour
{
	private class HealthPins
	{
		public Image image;

		public CoroutineRunner fade_runner;

		private Color current_colour;

		public HealthPins(MonoBehaviour _mono, Image _image)
		{
			image = _image;
			fade_runner = new CoroutineRunner(_mono);
			current_colour = _image.color;
		}

		public void fadeToColour(Color _colour)
		{
			if (!(current_colour == _colour))
			{
				current_colour = _colour;
				fade_runner.run(image.fadeToColour(current_colour, 0.35f, CoroutineExtensions.easeInOutFunc));
			}
		}

		public void destroyPin()
		{
			fade_runner.run(image.fade(0f, 0.25f, CoroutineExtensions.easeInOutFunc).addCallback(delegate
			{
				Object.Destroy(image.gameObject);
			}));
		}
	}

	[Header("References")]
	[SerializeField]
	private TMP_Text health_text;

	[SerializeField]
	private AnimatedLayoutGroup health_pins_parent;

	[Header("Prefabs")]
	[SerializeField]
	private Image health_pin_prefab;

	private List<HealthPins> health_pins = new List<HealthPins>();

	public void renew(int _current, int _max)
	{
		health_text.text = $"{_current}/{_max}";
		for (int i = 0; i < _max; i++)
		{
			if (i >= health_pins.Count)
			{
				Image image = Object.Instantiate(health_pin_prefab, health_pins_parent.transform);
				health_pins.Add(new HealthPins(this, image));
			}
			health_pins[i].fadeToColour((i < _current) ? Color.white : new Color(0.5f, 0.5f, 0.5f));
		}
		if (health_pins.Count > _max)
		{
			for (int j = _max; j < health_pins.Count; j++)
			{
				health_pins[j].destroyPin();
			}
			health_pins.RemoveRange(_max, health_pins.Count - _max);
		}
		StartCoroutine(checkLayoutEndOfFrame());
	}

	private IEnumerator checkLayoutEndOfFrame()
	{
		yield return new WaitForEndOfFrame();
		health_pins_parent.checkUpdate();
	}
}
