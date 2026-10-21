using System;
using GRGLib.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace LeadSelection;

public class Footprint : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private Image image;

	[Header("Settings")]
	[SerializeField]
	private MinMaxFloat rotation = new MinMaxFloat(-5f, 5f);

	[SerializeField]
	private MinMaxFloat offset_x = new MinMaxFloat(-10f, 10f);

	[SerializeField]
	private MinMaxFloat offset_y = new MinMaxFloat(-2f, 2f);

	public RectTransform rect_trans => base.transform as RectTransform;

	public void setUp(Sprite _sprite, System.Random _rng, Vector2 _init_pos, bool _allow_pos_displacement)
	{
		image.sprite = _sprite;
		image.SetNativeSize();
		rect_trans.anchoredPosition = _init_pos + (_allow_pos_displacement ? new Vector2(offset_x.get(_rng), offset_y.get(_rng)) : Vector2.zero);
		base.transform.localEulerAngles = new Vector3(0f, 0f, rotation.get(_rng));
	}

	public void setUp(Sprite _sprite, Footprint _print)
	{
		image.sprite = _sprite;
		image.SetNativeSize();
		rect_trans.anchoredPosition = _print.rect_trans.anchoredPosition;
		base.transform.localEulerAngles = _print.transform.localEulerAngles;
	}

	private void Reset()
	{
		image = GetComponent<Image>();
	}
}
