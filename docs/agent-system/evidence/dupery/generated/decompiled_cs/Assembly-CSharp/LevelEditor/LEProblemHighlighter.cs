using GRGLib.Extensions.Vector;
using GRGLib.Menus;
using TMPro;
using UnityEngine;

namespace LevelEditor;

public class LEProblemHighlighter : HoverMenu
{
	[Header("References")]
	[SerializeField]
	private TMP_Text text;

	public void openFromErrorMarker(LEErrorMarker _marker)
	{
		if (_marker.current_error.is_some)
		{
			tryOpen(_marker);
			base.transform.position = _marker.transform.position;
			base.transform.localPosition = base.transform.localPosition.xy() + _marker.highlighter_offset;
			text.text = _marker.current_error.value;
		}
	}

	public void openFromSuspect(LESuspect _suspect)
	{
		if (_suspect.error_string.is_some)
		{
			tryOpen(_suspect);
			base.transform.position = _suspect.transform.position;
			base.transform.localPosition = base.transform.localPosition.xy() - new Vector2((_suspect.transform as RectTransform).sizeDelta.x + 50f, 50f);
			text.text = _suspect.error_string.value;
		}
	}
}
