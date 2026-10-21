using System;
using GRGLib.Extensions.String;
using GRGLocalisation;
using Localisation;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.InputSystem.DualShock;
using UnityEngine.InputSystem.Switch;
using UnityEngine.InputSystem.XInput;

public static class InputsHelper
{
	private static string english_press => "press";

	private static string english_hold => "hold";

	private static string english_click => "click";

	private static AssetKey localisation_asset => LocalisationHelper.ui_asset;

	private static string loc_press_key => "Input [press]";

	private static string loc_hold_key => "Input [hold]";

	private static string loc_click_key => "Input [click]";

	public static InputType getInputType(this PlayerInput _input)
	{
		return _input.getInputType(_input.currentControlScheme);
	}

	public static InputType getInputType(this PlayerInput _input, string _control_scheme)
	{
		if (_control_scheme.Contains("Keyboard"))
		{
			return InputType.KBM;
		}
		if (_control_scheme.Contains("Gamepad"))
		{
			InputType result = (SteamHandler.onSteamDeck() ? InputType.STEAM_DECK : InputType.G_UNKNOWN);
			if (_input.devices.Count == 0)
			{
				return result;
			}
			if (_input.devices[0] is DualShockGamepad)
			{
				return InputType.G_PS;
			}
			if (_input.devices[0] is XInputController)
			{
				return InputType.G_XBOX;
			}
			if (_input.devices[0] is SwitchProControllerHID)
			{
				return InputType.G_SWITCH;
			}
			return result;
		}
		return InputType.UNKNOWN;
	}

	public static string getInputTextAsset(this TextAssetsGenericInputs _input)
	{
		return getInputTextAsset((int)_input);
	}

	public static string getInputTextAsset(this TextAssetsKBMInputs _input)
	{
		return getInputTextAsset((int)_input);
	}

	public static string getInputTextAsset(this TextAssetsPSInputs _input)
	{
		return getInputTextAsset((int)_input);
	}

	public static string getInputTextAsset(this TextAssetsSDInputs _input)
	{
		return getInputTextAsset((int)_input);
	}

	public static string getInputTextAsset(this TextAssetsSwInputs _input)
	{
		return getInputTextAsset((int)_input);
	}

	public static string getInputTextAsset(this TextAssetsXBInputs _input)
	{
		return getInputTextAsset((int)_input);
	}

	private static string getInputTextAsset(int _index)
	{
		return $"<sprite=\"inputs\" index={_index}>";
	}

	public static string getInputTextAsset(this TextAssetsGenericInputs _input, Color _colour, bool _force = false)
	{
		return getInputTextAsset((int)_input, _colour, _force);
	}

	public static string getInputTextAsset(this TextAssetsKBMInputs _input, Color _colour, bool _force = false)
	{
		return getInputTextAsset((int)_input, _colour, _force);
	}

	public static string getInputTextAsset(this TextAssetsPSInputs _input, Color _colour, bool _force = false)
	{
		return getInputTextAsset((int)_input, _colour, _force);
	}

	public static string getInputTextAsset(this TextAssetsSDInputs _input, Color _colour, bool _force = false)
	{
		return getInputTextAsset((int)_input, _colour, _force);
	}

	public static string getInputTextAsset(this TextAssetsSwInputs _input, Color _colour, bool _force = false)
	{
		return getInputTextAsset((int)_input, _colour, _force);
	}

	public static string getInputTextAsset(this TextAssetsXBInputs _input, Color _colour, bool _force = false)
	{
		return getInputTextAsset((int)_input, _colour, _force);
	}

	private static string getInputTextAsset(int _index, Color _colour, bool _force = false)
	{
		if (!_force && !canSwapColour(_index))
		{
			return getInputTextAsset(_index);
		}
		return $"<sprite=\"inputs\" index={_index} color=#{ColorUtility.ToHtmlStringRGBA(_colour)}>";
	}

	private static bool canSwapColour(int _input_index)
	{
		return _input_index switch
		{
			48 => false, 
			49 => false, 
			50 => false, 
			51 => false, 
			52 => false, 
			53 => false, 
			54 => false, 
			55 => false, 
			126 => false, 
			128 => false, 
			130 => false, 
			132 => false, 
			_ => true, 
		};
	}

	public static string toString(this InputActionType _action, bool _kbm, bool _capital_first)
	{
		if (!_capital_first)
		{
			return _action.toString(_kbm);
		}
		return _action.toString(_kbm).firstToUpper();
	}

	public static string toString(this InputActionType _action, bool _kbm)
	{
		return _action switch
		{
			InputActionType.CLICK_OR_PRESS => localisation_asset.checkTranslation(_kbm ? loc_click_key : loc_press_key, () => (!_kbm) ? english_press : english_click), 
			InputActionType.PRESS => localisation_asset.checkTranslation(loc_press_key, () => english_press), 
			InputActionType.HOLD => localisation_asset.checkTranslation(loc_hold_key, () => english_hold), 
			_ => throw new ArgumentException($"No string set up for input action type {_action}"), 
		};
	}
}
