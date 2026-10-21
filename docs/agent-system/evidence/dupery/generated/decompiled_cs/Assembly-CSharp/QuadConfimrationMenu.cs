using System;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class QuadConfimrationMenu : MenuBase
{
	[SerializeField]
	private TMP_Text confirmation_text;

	[SerializeField]
	private GameObject a_button;

	[SerializeField]
	private TMP_Text a_text;

	[SerializeField]
	private GameObject b_button;

	[SerializeField]
	private TMP_Text b_text;

	[SerializeField]
	private GameObject c_button;

	[SerializeField]
	private TMP_Text c_text;

	[SerializeField]
	private GameObject d_button;

	[SerializeField]
	private TMP_Text d_text;

	[SerializeField]
	private Selectable on_back_selectable;

	private Action a_callback;

	private Action b_callback;

	private Action c_callback;

	private Action d_callback;

	public void setUp(string _text, Action _a_callback, string _a_text, Action _b_callback, string _b_text, Action _c_callback, string _c_text, Action _d_callback, string _d_text)
	{
		confirmation_text.text = _text;
		a_callback = _a_callback;
		b_callback = _b_callback;
		c_callback = _c_callback;
		d_callback = _d_callback;
		a_text.text = _a_text;
		b_text.text = _b_text;
		c_text.text = _c_text;
		d_text.text = _d_text;
		c_button.SetActive(c_text.text != "");
		d_button.SetActive(d_text.text != "");
	}

	public void choiceA()
	{
		a_callback();
	}

	public void choiceB()
	{
		b_callback();
	}

	public void choiceC()
	{
		c_callback();
	}

	public void choiceD()
	{
		d_callback();
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
