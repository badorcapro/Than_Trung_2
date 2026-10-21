using System;
using GRGLib.Extensions.String;
using GRGLib.PropertyDrawers;
using Localisation;
using UnityEngine;
using UnityEngine.InputSystem;

[Serializable]
public struct InputAssetPerType
{
	public TextAssetsKBMInputs kbm;

	public TextAssetsPSInputs psController;

	public TextAssetsSDInputs steamdeck;

	public TextAssetsSwInputs switchController;

	public TextAssetsXBInputs xboxController;

	public TextAssetsGenericInputs controller_fallback;

	public bool action_word;

	[ConditionalField("action_word")]
	public InputActionType action_type;

	public string getText(PlayerInput _input, bool _capital_first)
	{
		return getText(_input.getInputType(), _capital_first);
	}

	public string getText(InputType _input_type, bool _capital_first)
	{
		if (LocalisationHelper.reverseInputActionWord())
		{
			return getTextAsset(_input_type) + (action_word ? (action_type.toString(_input_type == InputType.KBM || _input_type == InputType.UNKNOWN, _capital_first) + " ") : "");
		}
		return (action_word ? (action_type.toString(_input_type == InputType.KBM || _input_type == InputType.UNKNOWN, _capital_first) + " ") : "") + getTextAsset(_input_type);
	}

	public string getText(PlayerInput _input, Color _colour, bool _capital_first)
	{
		return getText(_input.getInputType(), _colour, _capital_first);
	}

	public string getText(InputType _input_type, Color _colour, bool _capital_first)
	{
		if (LocalisationHelper.reverseInputActionWord())
		{
			return getTextAsset(_input_type, _colour) + (action_word ? (action_type.toString(_input_type == InputType.KBM || _input_type == InputType.UNKNOWN, _capital_first) + " ") : "");
		}
		return (action_word ? (action_type.toString(_input_type == InputType.KBM || _input_type == InputType.UNKNOWN, _capital_first) + " ") : "") + getTextAsset(_input_type, _colour);
	}

	public string getTextAsset(PlayerInput _input)
	{
		return getTextAsset(_input.getInputType());
	}

	public string getTextAsset(InputType _input)
	{
		return _input switch
		{
			InputType.UNKNOWN => kbm.getInputTextAsset().sandwichString("<size=125%>", "</size>"), 
			InputType.KBM => kbm.getInputTextAsset().sandwichString("<size=125%>", "</size>"), 
			InputType.G_PS => psController.getInputTextAsset().sandwichString("<size=125%>", "</size>"), 
			InputType.G_XBOX => xboxController.getInputTextAsset().sandwichString("<size=125%>", "</size>"), 
			InputType.G_SWITCH => switchController.getInputTextAsset().sandwichString("<size=125%>", "</size>"), 
			InputType.STEAM_DECK => steamdeck.getInputTextAsset().sandwichString("<size=125%>", "</size>"), 
			InputType.G_UNKNOWN => controller_fallback.getInputTextAsset().sandwichString("<size=125%>", "</size>"), 
			_ => throw new ArgumentException($"No text asset set up for input type {_input}!"), 
		};
	}

	public string getTextAsset(InputType _input, Color _colour, bool _force = false)
	{
		return _input switch
		{
			InputType.UNKNOWN => kbm.getInputTextAsset(_colour).sandwichString("<size=125%>", "</size>"), 
			InputType.KBM => kbm.getInputTextAsset(_colour).sandwichString("<size=125%>", "</size>"), 
			InputType.G_PS => psController.getInputTextAsset(_colour).sandwichString("<size=125%>", "</size>"), 
			InputType.G_XBOX => xboxController.getInputTextAsset(_colour).sandwichString("<size=125%>", "</size>"), 
			InputType.G_SWITCH => switchController.getInputTextAsset(_colour).sandwichString("<size=125%>", "</size>"), 
			InputType.STEAM_DECK => steamdeck.getInputTextAsset(_colour).sandwichString("<size=125%>", "</size>"), 
			InputType.G_UNKNOWN => controller_fallback.getInputTextAsset(_colour).sandwichString("<size=125%>", "</size>"), 
			_ => throw new ArgumentException($"No text asset set up for input type {_input}!"), 
		};
	}
}
