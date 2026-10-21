using GRGLib.Menus;
using GRGLocalisation;
using Localisation;
using TMPro;
using UnityEngine;
using UnityEngine.InputSystem;

namespace Visual;

public class GameInstructionsManager : MenuController, IAmLocalised
{
	[Space]
	[Header("Instructions")]
	[SerializeField]
	private TMP_Text instruction_text;

	[SerializeField]
	private InputAssetPerType select_input;

	[SerializeField]
	private InputAssetPerType cancel_input;

	private PlayerInput player_input;

	private static string loc_tooltip_key => "AbilityInstructionManager [tooltip]";

	private static AssetKey localisation_asset => LocalisationHelper.ui_asset;

	public void setUpReferences(PlayerInput _input)
	{
		player_input = _input;
	}

	public void setInstructions(string _instruction)
	{
		instruction_text.text = _instruction + (SettingsHandler.display_tooltips ? ("\n<size=90%>" + getTooltipText() + "</size>") : "");
		openMenu();
	}

	private string getTooltipText()
	{
		return localisation_asset.checkTranslationWithData(loc_tooltip_key, englishTooltip, select_input.getText(player_input, _capital_first: true), cancel_input.getText(player_input, _capital_first: true));
	}

	private string englishTooltip(string _data_1, string _data_2)
	{
		return _data_1 + " to select role. " + _data_2 + " to cancel.";
	}
}
