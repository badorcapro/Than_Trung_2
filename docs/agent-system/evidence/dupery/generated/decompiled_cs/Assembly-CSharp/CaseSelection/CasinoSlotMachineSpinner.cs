using System;
using System.Collections;
using System.Collections.Generic;
using GRGLib.Coroutines;
using GRGLib.Generic;
using GRGLib.Maybe;
using UnityEngine;
using UnityEngine.UI;

namespace CaseSelection;

public class CasinoSlotMachineSpinner : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private Image image_1;

	[SerializeField]
	private Image image_2;

	[SerializeField]
	private Image image_3;

	[Header("Settings")]
	[SerializeField]
	private MinMaxFloat y_movement;

	[SerializeField]
	private MinMaxFloat rotation;

	private List<Sprite> image_sprites;

	private CoroutineRunner spin_runner;

	private void Awake()
	{
		spin_runner = new CoroutineRunner(this);
	}

	public int spin(List<Sprite> _sprites, System.Random _rng, float _duration)
	{
		return spin(_sprites, _rng, _duration, new Maybe<int>());
	}

	public int spin(List<Sprite> _sprites, System.Random _rng, float _duration, Maybe<int> _outcome)
	{
		image_sprites = _sprites;
		image_1.sprite = image_sprites[0];
		image_2.sprite = image_sprites[1];
		image_3.sprite = image_sprites[2];
		int num = (_outcome.is_some ? _outcome.value : _rng.Next(0, image_sprites.Count));
		spin_runner.run(runSpinner(num, _rng, _duration));
		return num;
	}

	private IEnumerator runSpinner(int _target, System.Random _rng, float _duration)
	{
		float cycle_y = y_movement.max - y_movement.min;
		int num = _rng.Next(8, 12) * 3;
		num += _target - num % image_sprites.Count;
		float max_value = (float)num * (cycle_y / 3f);
		Dictionary<Image, float> value_offset = new Dictionary<Image, float>
		{
			{
				image_1,
				y_movement.estimate(0.833f)
			},
			{ image_2, y_movement.average },
			{
				image_3,
				y_movement.estimate(0.167f)
			}
		};
		Dictionary<Image, int> cycle_count = new Dictionary<Image, int>
		{
			{ image_1, 0 },
			{ image_2, 0 },
			{ image_3, 0 }
		};
		int sp_index = image_sprites.Count - 1;
		float e = 0f;
		while (e < _duration)
		{
			e += Time.deltaTime;
			float num2 = CoroutineExtensions.easeOutFunc(e / _duration) * max_value;
			foreach (KeyValuePair<Image, float> item in value_offset)
			{
				float num3 = max_value - num2 + item.Value - y_movement.min;
				int num4 = Mathf.FloorToInt(num3 / cycle_y);
				if (num4 != cycle_count[item.Key])
				{
					cycle_count[item.Key] = num4;
					item.Key.sprite = image_sprites[sp_index];
					sp_index = (sp_index + 1) % image_sprites.Count;
				}
				float num5 = num3 % cycle_y + y_movement.min;
				item.Key.transform.localPosition = new Vector3(item.Key.transform.localPosition.x, num5, 0f);
				item.Key.transform.localEulerAngles = new Vector3(rotation.estimate((num5 - y_movement.min) / (y_movement.max - y_movement.min)), 0f, 0f);
			}
			yield return null;
		}
		foreach (KeyValuePair<Image, float> item2 in value_offset)
		{
			item2.Key.transform.localPosition = new Vector3(item2.Key.transform.localPosition.x, item2.Value % cycle_y, 0f);
			item2.Key.transform.localEulerAngles = new Vector3(rotation.estimate((item2.Value % cycle_y - y_movement.min) / (y_movement.max - y_movement.min)), 0f, 0f);
		}
	}
}
