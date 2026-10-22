using System;
using System.Collections.Generic;
using Codex;
using GRGLib.Serializable;
using UnityEngine;
using UnityEngine.InputSystem;

[CreateAssetMenu(menuName = "ScriptableObject/Input Shorcuts SO")]
public class InputShortcutsSO : ScriptableObject
{
	public abstract class ShortcutKeybinds
	{
		public abstract string getInputText(InputType _input);

		protected string getKeyboardKey(string _input)
		{
			return Keyboard.current.FindKeyOnCurrentKeyboardLayout(_input).displayName;
		}
	}

	[Serializable]
	public class SimpleSK : ShortcutKeybinds
	{
		public List<InputAssetPerType> inputs;

		public override string getInputText(InputType _input)
		{
			string text = "";
			for (int i = 0; i < inputs.Count; i++)
			{
				text = text + ((i == 0) ? "" : " / ") + inputs[i].getTextAsset(_input);
			}
			return text;
		}
	}

	[Serializable]
	public class SimpleKBMSK : ShortcutKeybinds
	{
		public List<Key> inputs;

		public override string getInputText(InputType _input)
		{
			string text = "";
			for (int i = 0; i < inputs.Count; i++)
			{
				text = text + ((i == 0) ? "" : " / ") + Keyboard.current[inputs[i]].displayName;
			}
			return text;
		}
	}

	[Serializable]
	public class ControllerColourSK : ShortcutKeybinds
	{
		public InputAssetPerType main;

		public List<STupple<InputAssetPerType, InputAssetPerType>> other_inputs;

		public override string getInputText(InputType _input)
		{
			string text = main.getTextAsset(InputType.G_UNKNOWN);
			for (int i = 0; i < other_inputs.Count; i++)
			{
				text = text + " / " + other_inputs[i].Item1.getTextAsset(_input) + " - " + other_inputs[i].Item2.getTextAsset(_input);
			}
			return text;
		}
	}

	[Serializable]
	public class KBMColourSK : ShortcutKeybinds
	{
		public InputAssetPerType main;

		public List<STupple<Key, Key>> keyboard_inputs;

		public List<STupple<InputAssetPerType, InputAssetPerType>> other_inputs;

		public override string getInputText(InputType _input)
		{
			string text = main.getTextAsset(_input);
			if (_input == InputType.KBM)
			{
				for (int i = 0; i < keyboard_inputs.Count; i++)
				{
					text = text + " / " + Keyboard.current[keyboard_inputs[i].Item1].displayName + " - " + Keyboard.current[keyboard_inputs[i].Item2].displayName;
				}
			}
			for (int j = 0; j < other_inputs.Count; j++)
			{
				text = text + " / " + other_inputs[j].Item1.getTextAsset(_input) + " - " + other_inputs[j].Item2.getTextAsset(_input);
			}
			return text;
		}
	}

	[Header("Keybinds")]
	[SerializeField]
	private SimpleSK investigate;

	[SerializeField]
	private SimpleSK arrest;

	[SerializeField]
	private SimpleKBMSK toggle_pen;

	[SerializeField]
	private SimpleKBMSK toggle_rubber;

	[SerializeField]
	private KBMColourSK kbm_colour_tool;

	[SerializeField]
	private ControllerColourSK controller_colour;

	[SerializeField]
	private SimpleSK lock_keyword;

	[SerializeField]
	private SimpleSK rotate_stamp;

	[SerializeField]
	private SimpleSK boat_lever;

	[SerializeField]
	private SimpleSK pause;

	[SerializeField]
	private SimpleSK cross_out_suspect;

	[SerializeField]
	private SimpleSK tick_suspect;

	[SerializeField]
	private SimpleSK select_suspect;

	[SerializeField]
	private SimpleKBMSK place_pin_kbm;

	[SerializeField]
	private SimpleSK place_pin;

	[SerializeField]
	private SimpleSK inspect_keywords;

	[SerializeField]
	private SimpleSK connect_pins;

	public string this[CodexRoleShortcuts.ShortcutType _shortcut, InputType _input, bool _colour_black = true]
	{
		get
		{
			if (!_colour_black)
			{
				return getInputForShorcut(_shortcut, _input);
			}
			return getInputForShorcut(_shortcut, _input).addColourToSpriteLinks(Color.black);
		}
	}

	public string getInputForShorcut(CodexRoleShortcuts.ShortcutType _shortcut, InputType _input)
	{
		return _shortcut switch
		{
			CodexRoleShortcuts.ShortcutType.INVESTIGATE => investigate.getInputText(_input), 
			CodexRoleShortcuts.ShortcutType.ARREST => arrest.getInputText(_input), 
			CodexRoleShortcuts.ShortcutType.TOOL_COLOUR => (_input == InputType.KBM) ? kbm_colour_tool.getInputText(_input) : controller_colour.getInputText(_input), 
			CodexRoleShortcuts.ShortcutType.BOAT_LEVER_TOGGLE => boat_lever.getInputText(_input), 
			CodexRoleShortcuts.ShortcutType.LOCK_KEYWORD_HOVER => lock_keyword.getInputText(_input), 
			CodexRoleShortcuts.ShortcutType.ROTATE_STAMP => (_input == InputType.KBM) ? rotate_stamp.getInputText(_input) : rotate_stamp.getInputText(InputType.G_UNKNOWN), 
			CodexRoleShortcuts.ShortcutType.PAUSE => pause.getInputText(_input), 
			CodexRoleShortcuts.ShortcutType.CROSS_OUT_SUSPECT => cross_out_suspect.getInputText(_input), 
			CodexRoleShortcuts.ShortcutType.PLACE_PIN => (_input == InputType.KBM) ? place_pin_kbm.getInputText(_input) : place_pin.getInputText(_input), 
			CodexRoleShortcuts.ShortcutType.PEN_TOGGLE => toggle_pen.getInputText(_input), 
			CodexRoleShortcuts.ShortcutType.ERASER_TOGGLE => toggle_rubber.getInputText(_input), 
			CodexRoleShortcuts.ShortcutType.TICK_SUSPECT => tick_suspect.getInputText(_input), 
			CodexRoleShortcuts.ShortcutType.SELECT_SUSPECT => select_suspect.getInputText(_input), 
			CodexRoleShortcuts.ShortcutType.INSPECT_KEYWORDS => inspect_keywords.getInputText(_input), 
			CodexRoleShortcuts.ShortcutType.CONNECT_PINS => connect_pins.getInputText(_input), 
			_ => "", 
		};
	}
}
