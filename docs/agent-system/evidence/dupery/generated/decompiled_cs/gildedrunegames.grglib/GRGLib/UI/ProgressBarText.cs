using GRGLib.PropertyDrawers;
using TMPro;
using UnityEngine;

namespace GRGLib.UI;

[AddComponentMenu("GRGLib/UI/ProgressBarText")]
public class ProgressBarText : ProgressBar
{
	[Header("Settings")]
	[SerializeField]
	private string text_format = "{V}/{M}";

	[SerializeField]
	private bool floor_values;

	[SerializeField]
	[ConditionalField("floor_values", false, new object[] { false })]
	private string value_format = "0.0";

	[SerializeField]
	[ConditionalField("floor_values", false, new object[] { false })]
	private string min_max_format = "0";

	[Header("Reference")]
	[SerializeField]
	private TMP_Text text;

	protected override void onProgressSet(float _value, float _min, float _max)
	{
		base.onProgressSet(_value, _min, _max);
		string newValue = (floor_values ? Mathf.FloorToInt(_value).ToString() : _value.ToString(value_format));
		string newValue2 = (floor_values ? Mathf.FloorToInt(_max).ToString() : _max.ToString(min_max_format));
		string newValue3 = (floor_values ? Mathf.FloorToInt(_min).ToString() : _min.ToString(min_max_format));
		text.text = text_format.Replace("{V}", newValue).Replace("{M}", newValue2).Replace("{m}", newValue3);
	}
}
