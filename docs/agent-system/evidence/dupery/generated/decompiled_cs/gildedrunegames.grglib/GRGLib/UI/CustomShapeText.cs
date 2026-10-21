using TMPro;
using UnityEngine;

namespace GRGLib.UI;

public abstract class CustomShapeText : MonoBehaviour
{
	[SerializeField]
	protected TMP_Text text;

	[Header("Settings")]
	[SerializeField]
	private bool set_on_start = true;

	[SerializeField]
	[Range(0.1f, 100f)]
	protected float curve_scale = 1f;

	public float CurveScale
	{
		get
		{
			return curve_scale;
		}
		set
		{
			setScale(value);
		}
	}

	protected virtual float actual_curve_scale => curve_scale * 5f;

	protected virtual void Start()
	{
		if (set_on_start)
		{
			warpText();
		}
	}

	public void setScale(float _curve_scale)
	{
		if (curve_scale != _curve_scale)
		{
			curve_scale = _curve_scale;
			warpText();
		}
	}

	public void setText(string _text)
	{
		if (!(_text == text.text))
		{
			text.text = _text;
			warpText();
		}
	}

	public void warpText()
	{
		text.ForceMeshUpdate();
		TMP_TextInfo textInfo = text.textInfo;
		if (textInfo.characterCount != 0)
		{
			warpText(textInfo, actual_curve_scale);
		}
	}

	protected abstract void warpText(TMP_TextInfo _text_info, float _scale);

	protected virtual void Reset()
	{
		text = GetComponent<TMP_Text>();
	}
}
