using System.Collections;
using System.Collections.Generic;
using GRGLib.Generic;
using TMPro;
using UnityEngine;

public class TextSettingsHandler : MonoBehaviour
{
	public static int default_size_setting = 30;

	public static float font_increase_per_setting = 0.2f;

	private bool font_diff_ever_changed;

	private HashSet<AdjustableText> scene_texts = new HashSet<AdjustableText>();

	public static TextSettingsHandler instance { get; private set; }

	public float current_font_size_diff { get; private set; }

	private void Awake()
	{
		if (instance != null && instance != this)
		{
			Object.Destroy(base.gameObject);
			return;
		}
		Object.DontDestroyOnLoad(base.gameObject);
		instance = this;
		StartCoroutine(startNextFrame());
	}

	private IEnumerator startNextFrame()
	{
		yield return new WaitForEndOfFrame();
		onStartup();
	}

	private void onStartup()
	{
		setFontSize(SettingsHandler.font_size);
	}

	public void addText(AdjustableText _text)
	{
		scene_texts.Add(_text);
		if (font_diff_ever_changed)
		{
			setTextFontSize(_text.getText(), _text.DefaultFontSize, current_font_size_diff);
		}
	}

	public void removeText(AdjustableText _text)
	{
		scene_texts.Remove(_text);
	}

	public void setFontSize(int _size_setting)
	{
		int num = _size_setting - default_size_setting;
		float num2 = font_increase_per_setting * (float)num;
		if (current_font_size_diff != num2)
		{
			current_font_size_diff = num2;
			font_diff_ever_changed = true;
			updateAllTexts();
		}
	}

	private void updateAllTexts()
	{
		foreach (AdjustableText scene_text in scene_texts)
		{
			if (scene_text != null)
			{
				setTextFontSize(scene_text.getText(), scene_text.DefaultFontSize, current_font_size_diff);
			}
		}
	}

	private void setTextFontSize(TMP_Text _text, MinMaxFloat _default_size, float _diff)
	{
		if (_text.enableAutoSizing)
		{
			MinMaxFloat minMaxFloat = _default_size + new MinMaxFloat(0f, _diff);
			_text.fontSizeMin = minMaxFloat.min;
			_text.fontSizeMax = minMaxFloat.max;
		}
		else
		{
			_text.fontSize = _default_size.min + _diff;
		}
	}
}
