using GRGLib.Generic;
using GRGLib.Maybe;
using TMPro;
using UnityEngine;

public class AdjustableText : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private TMP_Text text;

	private Maybe<MinMaxFloat> m_font_size = new Maybe<MinMaxFloat>();

	public MinMaxFloat DefaultFontSize
	{
		get
		{
			calculateDefaultFontSize();
			return m_font_size.value;
		}
	}

	public TMP_Text getText()
	{
		return text;
	}

	private void OnEnable()
	{
		TextSettingsHandler.instance.addText(this);
	}

	private void OnDisable()
	{
		TextSettingsHandler.instance.removeText(this);
	}

	private void calculateDefaultFontSize()
	{
		if (!m_font_size.is_some)
		{
			m_font_size = (text.enableAutoSizing ? new MinMaxFloat(text.fontSizeMin, text.fontSizeMax) : new MinMaxFloat(text.fontSize, text.fontSize)).maybe();
		}
	}

	private void Reset()
	{
		text = GetComponent<TMP_Text>();
	}
}
