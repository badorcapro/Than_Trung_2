using System;
using GRGLib.Coroutines;
using GRGLib.Extensions.Random;
using GRGLib.Serializable;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace LeadSelection;

public class FootprintProgressBar : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private RectTransform footprint_parent;

	[SerializeField]
	private Image fillprint_parent;

	[SerializeField]
	private TMP_Text progress_text;

	[Header("Prefabs")]
	[SerializeField]
	private Footprint footprint_prefab;

	[Header("Settings")]
	[SerializeField]
	private STupple<Sprite, Sprite> left_footprint_sprites;

	[SerializeField]
	private STupple<Sprite, Sprite> right_footprint_sprites;

	[SerializeField]
	private float left_foot_y_pos = 32f;

	[SerializeField]
	private float right_foot_y_pos = -32f;

	[SerializeField]
	private int footprints = 32;

	private MultiCoroutineRunner fill_runner;

	private int progress;

	private void Awake()
	{
		fill_runner = new MultiCoroutineRunner(this);
		setUpFootPrints(RandomExtensions.freshRandom());
	}

	private void setUpFootPrints(System.Random _rng)
	{
		float num = fillprint_parent.rectTransform.sizeDelta.x / (float)footprints;
		for (int i = 0; i < footprints; i++)
		{
			bool flag = i % 2 == 1;
			Footprint footprint = UnityEngine.Object.Instantiate(footprint_prefab, footprint_parent);
			Footprint footprint2 = UnityEngine.Object.Instantiate(footprint_prefab, fillprint_parent.transform);
			footprint.setUp(flag ? left_footprint_sprites.Item1 : right_footprint_sprites.Item1, _rng, new Vector2(num * ((float)i + 0.5f), flag ? left_foot_y_pos : right_foot_y_pos), i != 0 && i != footprints - 1);
			footprint2.setUp(flag ? left_footprint_sprites.Item2 : right_footprint_sprites.Item2, footprint);
		}
	}

	public void setFill(float _progress, bool _animate = true)
	{
		if (_animate)
		{
			int start = progress;
			progress = Mathf.FloorToInt(_progress * 100f);
			fill_runner.run(fillprint_parent.fill(_progress, 1.1f, CoroutineExtensions.easeInOutFunc), progress_text.countdownReplace("#%", "#", start, progress, 1.1f, CoroutineExtensions.easeInOutFunc));
		}
		else
		{
			fillprint_parent.fillAmount = _progress;
			progress = Mathf.FloorToInt(_progress * 100f);
			progress_text.text = $"{progress}%";
		}
	}
}
