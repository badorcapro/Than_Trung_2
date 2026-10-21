using GRGLib.PropertyDrawers;
using TMPro;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

namespace GRGLib.UI;

[AddComponentMenu("GRGLib/UI/ExtendedSlider")]
public class ExtendedSlider : Slider
{
	[Header("Extended Slider")]
	[SerializeField]
	private Image handle;

	[Header("Handle Text")]
	[SerializeField]
	private bool has_text;

	[SerializeField]
	[ConditionalField("has_text")]
	private TMP_Text slider_text;

	[SerializeField]
	[ConditionalField("has_text")]
	private bool set_text_to_value;

	[SerializeField]
	[ConditionalField("set_text_to_value")]
	private string value_format = "0.00";

	[SerializeField]
	private Color normal_colour;

	[SerializeField]
	private Color selected_colour;

	protected override void Start()
	{
		base.Start();
		checkAndSetText(value);
	}

	public override void SetValueWithoutNotify(float input)
	{
		base.SetValueWithoutNotify(input);
		checkAndSetText(input);
	}

	public override void OnSelect(BaseEventData eventData)
	{
		base.OnSelect(eventData);
		setColour(selected_colour);
	}

	public override void OnDeselect(BaseEventData eventData)
	{
		base.OnDeselect(eventData);
		setColour(normal_colour);
	}

	private void setColour(Color _colour)
	{
		if (has_text)
		{
			slider_text.color = _colour;
		}
		handle.color = _colour;
	}

	public override void OnDrag(PointerEventData eventData)
	{
		base.OnDrag(eventData);
		checkAndSetText(value);
	}

	private void checkAndSetText(float _value)
	{
		if (has_text && set_text_to_value)
		{
			slider_text.text = _value.ToString(value_format);
		}
	}
}
