using System;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class MultiConfirmationMenu : MenuBase
{
	[Serializable]
	public struct ConfirmationButton
	{
		public GameObject game_object;

		public TMP_Text text;
	}

	[Header("References")]
	[SerializeField]
	private TMP_Text confirmation_text;

	[SerializeField]
	private List<ConfirmationButton> buttons;

	[SerializeField]
	private Selectable on_back_selectable;

	public List<Action> button_callbacks = new List<Action>();

	public void setUp(string _confirm_text, params (Action, string)[] _button_settings)
	{
		button_callbacks = new List<Action>();
		confirmation_text.text = _confirm_text;
		for (int i = 0; i < buttons.Count; i++)
		{
			if (i >= _button_settings.Length)
			{
				buttons[i].game_object.SetActive(value: false);
				continue;
			}
			button_callbacks.Add(_button_settings[i].Item1);
			buttons[i].game_object.SetActive(value: true);
			buttons[i].text.text = _button_settings[i].Item2;
		}
		if (_button_settings.Length > buttons.Count)
		{
			Debug.LogError("There are more buttons wanting to be set up then available buttons in the menu");
		}
	}

	public void setSelectableButtons(int _first_x)
	{
		for (int i = 0; i < buttons.Count; i++)
		{
			buttons[i].game_object.SetActive(i < _first_x);
		}
	}

	public void choice(int _button_nb)
	{
		if (_button_nb < button_callbacks.Count && buttons.Count > _button_nb && buttons[_button_nb].game_object.activeSelf)
		{
			button_callbacks[_button_nb]();
		}
	}

	public void close()
	{
		closeMenu();
		if (GameHandler.instance.using_gamepad)
		{
			on_back_selectable.Select();
		}
	}
}
