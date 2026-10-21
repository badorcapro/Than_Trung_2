using System;
using TMPro;
using UnityEngine;

namespace LevelEditor;

public class LEChips : MonoBehaviour
{
	private const int min_chips = 10;

	[Header("References")]
	[SerializeField]
	private LevelEditorManager manager;

	[SerializeField]
	private TMP_InputField input_field;

	public void onSetUp(LevelEditorManager _manager, bool _save)
	{
		if (_save)
		{
			if (!(_manager.creating_case is CasinoCase casinoCase))
			{
				Debug.LogError("Cannot load chips when not creating casino case!");
			}
			else
			{
				input_field.SetTextWithoutNotify(casinoCase.chips.ToString());
			}
		}
	}

	public void onInput(string _text)
	{
		int value = 50;
		try
		{
			value = int.Parse(_text);
			if (value < 0)
			{
				value = -value;
				input_field.SetTextWithoutNotify(value.ToString());
			}
			if (value < 10)
			{
				value = 10;
				input_field.SetTextWithoutNotify(value.ToString());
			}
		}
		catch (Exception arg)
		{
			Debug.LogError($"Input failed to parse! Setting chips to default (50)\nError: {arg}");
			value = 50;
			input_field.SetTextWithoutNotify(value.ToString());
		}
		manager.setSpecial(delegate(LevelEditorManager _m, Case _c)
		{
			if (!(_c is CasinoCase casinoCase))
			{
				Debug.LogError("Trying to set chips while not creating a casino case!");
			}
			else
			{
				casinoCase.setChipsFromLevelEditor(_m, value);
			}
		});
	}
}
