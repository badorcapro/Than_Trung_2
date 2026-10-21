using System;
using TMPro;
using UnityEngine;

public class ConfirmationMenu : MenuBase
{
	[SerializeField]
	private TMP_Text confirmation_text;

	private Action comfirm_callback;

	private Action cancel_callback;

	public void setUp(string _text, Action _on_yes, Action _on_no)
	{
		confirmation_text.text = _text;
		comfirm_callback = _on_yes;
		cancel_callback = _on_no;
	}

	public void setUpAndOpen(Action _on_yes, Action _on_no)
	{
		comfirm_callback = _on_yes;
		cancel_callback = _on_no;
		openMenu();
	}

	public void comfirm()
	{
		comfirm_callback();
	}

	public void cancel()
	{
		cancel_callback();
	}
}
