using System;
using System.Collections;
using System.Collections.Generic;
using GRGLib.Coroutines;
using GRGLib.Extensions.Random;
using GRGLib.Extensions.Vector;
using UnityEngine;
using UnityEngine.UI;

namespace MainMenu;

public class BackgroundRain : MonoBehaviour
{
	[Header("Prefabs")]
	[SerializeField]
	private Image rain_prefab;

	[Header("Settings")]
	[SerializeField]
	private List<Sprite> rain_sprites;

	[SerializeField]
	private float rain_density;

	[SerializeField]
	private Vector2 min_starting_pos;

	[SerializeField]
	private Vector2 max_starting_pos;

	[SerializeField]
	private Vector2 rain_traversal;

	[SerializeField]
	private float rain_speed;

	private void Start()
	{
		rain(RandomExtensions.freshRandom()).start(this);
	}

	private IEnumerator rain(System.Random _rng)
	{
		while (true)
		{
			yield return _rng.nextFloat(0f, 1f / rain_density).wait();
			Image rain_particle = UnityEngine.Object.Instantiate(rain_prefab, base.transform);
			rain_particle.sprite = rain_sprites.getRandomElementFromList(_rng);
			rain_particle.SetNativeSize();
			rain_particle.transform.localPosition = _rng.nextVector2(min_starting_pos, max_starting_pos);
			rain_particle.transform.moveTransform(rain_particle.transform.localPosition.addVector2(rain_traversal), 1f / rain_speed, CoroutineExtensions.noEaseFunc).addCallback(delegate
			{
				UnityEngine.Object.Destroy(rain_particle.gameObject);
			}).start(this);
		}
	}
}
