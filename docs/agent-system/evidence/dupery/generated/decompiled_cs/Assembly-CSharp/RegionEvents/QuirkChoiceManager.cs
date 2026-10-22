using System;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace RegionEvents;

public class QuirkChoiceManager : MenuBase
{
	[Header("Choice References")]
	[SerializeField]
	private Image quirk_icon;

	[SerializeField]
	private TMP_Text quirk_text;

	private CaseQuirks quirk;

	private Action<CaseQuirks> on_click;

	public void setUpChoice(Sprite _icon, string _text, CaseQuirks _quirk, Action<CaseQuirks> _on_click, bool _open = true)
	{
		quirk_icon.sprite = _icon;
		quirk_text.text = _text;
		quirk = _quirk;
		on_click = _on_click;
		if (_open)
		{
			openMenu();
		}
	}

	public void onClick()
	{
		on_click(quirk);
	}
}
