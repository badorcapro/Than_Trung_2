using System;
using Audio;
using GRGLib.Maybe;
using UnityEngine;
using UnityEngine.UI;

namespace Codex;

public class CodexSelection : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private Image background;

	[SerializeField]
	private Image icon;

	[SerializeField]
	private Button button;

	[Header("Optional References")]
	[SerializeField]
	private GameObject selected_visual;

	[SerializeField]
	private GameObject lock_visual;

	private bool discovered;

	private int data;

	private Action<int> callback;

	private Maybe<Func<int, bool, bool>> on_selection = new Maybe<Func<int, bool, bool>>();

	public bool selected { get; private set; }

	public bool locked { get; private set; }

	public Selectable getSelectable()
	{
		return button;
	}

	public void setUpAsSelection(int _data, Color _colour, Sprite _sprite, Action<int> _callback, Func<int, bool, bool> _toggled, bool _selected, bool _locked, float _icon_scale = 1f, bool _background = true)
	{
		on_selection = _toggled.maybe();
		selected = _selected;
		locked = _locked;
		setUp(_data, _colour, _discovered: true, _sprite, _callback, _icon_scale, _background);
		selected_visual.gameObject.SetActive(_selected);
		lock_visual.gameObject.SetActive(_locked);
	}

	public void setUp(int _data, Color _colour, bool _discovered, Sprite _role_sprite, Action<int> _callback, float _icon_scale = 1f, bool _background = true)
	{
		data = _data;
		callback = _callback;
		icon.color = _colour;
		icon.sprite = _role_sprite;
		discovered = _discovered;
		background.enabled = _background;
		if (_icon_scale != 1f)
		{
			icon.transform.localScale = new Vector3(_icon_scale, _icon_scale, 1f);
		}
	}

	public void setUpNavigation(Selectable _up, Selectable _down, Selectable _left, Selectable _right)
	{
		Navigation navigation = button.navigation;
		navigation.selectOnUp = _up;
		navigation.selectOnDown = _down;
		navigation.selectOnLeft = _left;
		navigation.selectOnRight = _right;
		button.navigation = navigation;
	}

	public void colourBackground(Sprite _sprite, Color _colour)
	{
		background.sprite = _sprite;
		background.color = _colour;
	}

	public void setSpecialRightNavigation(Selectable _right_selectable)
	{
		Navigation navigation = button.navigation;
		navigation.selectOnRight = _right_selectable;
		button.navigation = navigation;
	}

	public void setSpecialDownNavigation(Selectable _down_selectable)
	{
		Navigation navigation = button.navigation;
		navigation.selectOnDown = _down_selectable;
		button.navigation = navigation;
	}

	public void pressed()
	{
		if (on_selection.is_some)
		{
			toggled();
		}
		else if (discovered)
		{
			callback(data);
		}
	}

	public void toggled()
	{
		if (on_selection.is_some && !locked)
		{
			bool arg = !selected;
			if (on_selection.value(data, arg))
			{
				selected = arg;
				selected_visual.SetActive(selected);
			}
		}
	}

	public void onHover()
	{
		AudioHandler.Sfx.playSfx(Sfx.SUSPECT_HOVER);
	}
}
