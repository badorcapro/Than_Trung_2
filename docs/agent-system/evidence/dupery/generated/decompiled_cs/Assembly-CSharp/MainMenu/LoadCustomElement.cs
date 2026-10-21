using System;
using TMPro;
using UnityEngine;

namespace MainMenu;

public class LoadCustomElement : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private TMP_Text name_text;

	[SerializeField]
	private TMP_Text extra_text;

	private int file_number;

	private Action<int> callback;

	public void setUp(int _data, string _name, string _extra, Action<int> _callback)
	{
		file_number = _data;
		name_text.text = _name;
		extra_text.text = _extra;
		callback = _callback;
	}

	public void checkAgainstSearch(string _input)
	{
		base.gameObject.SetActive(name_text.text.ToLower().StartsWith(_input.ToLower()));
	}

	public void onClick()
	{
		callback(file_number);
	}
}
