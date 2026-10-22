using System;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class RunStatsViewerRegionButton : MonoBehaviour
{
	[Header("References")]
	public JiggleButton button;

	public TMP_Text text;

	[SerializeField]
	private Image image;

	[SerializeField]
	private List<Image> dots;

	[Header("Settings")]
	[SerializeField]
	private Sprite on_sprite;

	[SerializeField]
	private Sprite dot_on_sprite;

	[SerializeField]
	private Sprite off_sprite;

	[SerializeField]
	private Sprite dot_off_sprite;

	[SerializeField]
	private Color default_text_colour;

	[SerializeField]
	private Color selected_text_colour;

	private Func<int, bool> on_press;

	public int lead_number { get; private set; }

	public void setUpCallback(int _lead, Func<int, bool> _on_press)
	{
		lead_number = _lead;
		on_press = _on_press;
	}

	public void onPress()
	{
		toggle(on_press(lead_number));
	}

	public void toggle(bool _on)
	{
		if (_on)
		{
			text.color = selected_text_colour;
			image.sprite = on_sprite;
			dots.ForEach(delegate(Image _d)
			{
				_d.sprite = dot_on_sprite;
			});
		}
		else
		{
			text.color = default_text_colour;
			image.sprite = off_sprite;
			dots.ForEach(delegate(Image _d)
			{
				_d.sprite = dot_off_sprite;
			});
		}
		image.SetNativeSize();
		dots.ForEach(delegate(Image _d)
		{
			_d.SetNativeSize();
		});
	}
}
