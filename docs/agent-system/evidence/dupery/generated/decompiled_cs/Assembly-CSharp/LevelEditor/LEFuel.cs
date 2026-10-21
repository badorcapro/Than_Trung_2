using System;
using TMPro;
using UnityEngine;

namespace LevelEditor;

public class LEFuel : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private LevelEditorManager manager;

	[SerializeField]
	private TMP_InputField input_field;

	private int min_fuel = 3;

	public void onSetUp(LevelEditorManager _manager, bool _save)
	{
		if (!(_manager.creating_case is DocksCase docksCase))
		{
			Debug.LogError("Cannot load fuel when not creating docks case!");
			return;
		}
		min_fuel = Mathf.CeilToInt((docksCase.board_size.x + docksCase.board_size.y) / 2);
		if (_save)
		{
			input_field.SetTextWithoutNotify(docksCase.boat.fuel.ToString());
		}
	}

	public void onInput(string _text)
	{
		int value = 10;
		try
		{
			value = int.Parse(_text);
			if (value < 0)
			{
				value = -value;
				input_field.SetTextWithoutNotify(value.ToString());
			}
			if (value < min_fuel)
			{
				value = min_fuel;
				input_field.SetTextWithoutNotify(value.ToString());
			}
		}
		catch (Exception arg)
		{
			Debug.LogError($"Input failed to parse! Setting fuel to default (10)\nError: {arg}");
			value = 10;
			input_field.SetTextWithoutNotify(value.ToString());
		}
		manager.setSpecial(delegate(LevelEditorManager _m, Case _c)
		{
			if (!(_c is DocksCase docksCase))
			{
				Debug.LogError("Trying to set fuel while not creating a docks case!");
			}
			else
			{
				docksCase.setFuelFromLevelEditor(_m, value);
			}
		});
	}
}
