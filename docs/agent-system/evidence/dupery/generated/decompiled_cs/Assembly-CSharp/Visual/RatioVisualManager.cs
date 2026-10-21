using System.Collections.Generic;
using GRGLib.Coroutines;
using GRGLib.Extensions.Collections;
using GRGLib.TextAnimation;
using TMPro;
using UnityEngine;

namespace Visual;

public class RatioVisualManager : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private TMP_Text class_ratio_text;

	[Header("Settings")]
	[SerializeField]
	private bool extra_line;

	public void setUp(Dictionary<RoleClassifications, int> _ratio)
	{
		class_ratio_text.bakeText(getClassRatioString(_ratio, extra_line));
		DialogueTextWriter.writeDialogueToTextNoFade(class_ratio_text, 0.12f, _bake_text: false).addCallback(delegate
		{
			class_ratio_text.unbake();
		}).start(this);
	}

	public static string getClassRatioString(Dictionary<RoleClassifications, int> _ratio, bool _extra_line = false)
	{
		string text = "";
		List<RoleClassifications> list = new List<RoleClassifications>().addAll();
		for (int i = 0; i < list.Count; i++)
		{
			text += $"{list[i].toString()}: {_ratio[list[i]]}\n";
			if (_extra_line)
			{
				text += "\n";
			}
		}
		return text;
	}
}
