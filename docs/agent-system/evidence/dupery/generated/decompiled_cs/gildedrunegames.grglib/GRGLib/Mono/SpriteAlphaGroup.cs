using System.Collections.Generic;
using GRGLib.Extensions.Collections;
using TMPro;
using UnityEngine;

namespace GRGLib.Mono;

[AddComponentMenu("GRGLib/Misc/SpriteAlphaGroup")]
public class SpriteAlphaGroup : MonoBehaviour
{
	[Header("Settings")]
	[SerializeField]
	private bool check_children_on_set;

	[SerializeField]
	private bool also_fade_text = true;

	[SerializeField]
	private float starting_alpha = 1f;

	private List<SpriteRenderer> sprites;

	private List<TMP_Text> texts;

	private float m_alpha;

	public float alpha
	{
		get
		{
			return m_alpha;
		}
		set
		{
			setAlpha(value);
			m_alpha = value;
		}
	}

	private void Awake()
	{
		resetAffected();
	}

	private void setAlpha(float _value)
	{
		if (check_children_on_set)
		{
			resetAffected();
		}
		foreach (SpriteRenderer sprite in sprites)
		{
			sprite.color = new Color(sprite.color.r, sprite.color.g, sprite.color.b, _value);
		}
		if (!also_fade_text)
		{
			return;
		}
		foreach (TMP_Text text in texts)
		{
			text.alpha = _value;
		}
	}

	public void resetAffected()
	{
		sprites = base.gameObject.GetComponentsInChildren<SpriteRenderer>().toListSafe();
		if (also_fade_text)
		{
			texts = base.gameObject.GetComponentsInChildren<TMP_Text>().toListSafe();
		}
	}
}
