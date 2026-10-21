using System.Collections.Generic;
using GRGLib.Extensions.String;
using GRGLib.Extensions.Unity;
using GRGLocalisation;
using Localisation;
using TMPro;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;

namespace Codex;

public class CodexRoleShortcuts : CodexPage, IAmLocalised
{
	public enum ShortcutType
	{
		INVESTIGATE = 0,
		ARREST = 1,
		TOOL_COLOUR = 2,
		BOAT_LEVER_TOGGLE = 3,
		LOCK_KEYWORD_HOVER = 4,
		ROTATE_STAMP = 5,
		PAUSE = 6,
		CROSS_OUT_SUSPECT = 7,
		PEN_TOGGLE = 100,
		ERASER_TOGGLE = 101,
		TICK_SUSPECT = 200,
		SELECT_SUSPECT = 201,
		PLACE_PIN = 202,
		INSPECT_KEYWORDS = 203,
		CONNECT_PINS = 204
	}

	private JiggleButton close_button;

	private PlayerInput player_input;

	[SerializeField]
	private InputShortcutsSO shortcuts_data;

	[Header("References")]
	[SerializeField]
	private TMP_Text title_text;

	[SerializeField]
	private TMP_Text short_cut_text;

	[SerializeField]
	private TMP_Text short_cut_text_2;

	[SerializeField]
	private Button keyboard_button;

	[SerializeField]
	private Button controller_button;

	[Header("Settings")]
	[SerializeField]
	private List<ShortcutType> kbm_shortcuts;

	[SerializeField]
	private List<ShortcutType> kbm_shortcuts_p2;

	[SerializeField]
	private List<ShortcutType> controller_shortcuts;

	[SerializeField]
	private List<ShortcutType> controller_shortcuts_p2;

	private InputType last_controller_input = InputType.G_XBOX;

	private AssetKey localisation_asset => LocalisationHelper.ui_asset;

	private string loc_kbm_title_key => "KBM";

	private string loc_controller_title_key => "Controller";

	public void setupPage(JiggleButton _close_button, PlayerInput _player_input)
	{
		player_input = _player_input;
		InputType inputType = player_input.getInputType();
		close_button = _close_button;
		close_button.setNavigationDown(keyboard_button);
		keyboard_button.setNavigationUp(close_button);
		if (inputType == InputType.KBM)
		{
			setKeyboardCGOn();
			return;
		}
		last_controller_input = inputType;
		setControllerCGOn();
		close_button.Select();
	}

	private string getText(List<ShortcutType> shortcuts, bool _kbm)
	{
		InputType input = ((!_kbm) ? last_controller_input : InputType.KBM);
		string text = "";
		int i;
		for (i = 0; i < shortcuts.Count; i++)
		{
			text = text + localisation_asset.checkTranslation(getLocKey(shortcuts[i]), () => englishTitle(shortcuts[i]), _check_keywords: false).bold() + "\n" + shortcuts_data[shortcuts[i], input, true] + "\n";
		}
		return text;
	}

	private string englishTitle(ShortcutType _shortcut)
	{
		return _shortcut switch
		{
			ShortcutType.INVESTIGATE => "Investigate/Interact", 
			ShortcutType.ARREST => "Arrest", 
			ShortcutType.TOOL_COLOUR => "Change Tool Colour", 
			ShortcutType.BOAT_LEVER_TOGGLE => "Toggle Boat Lever", 
			ShortcutType.LOCK_KEYWORD_HOVER => "Lock Keywords Hover", 
			ShortcutType.ROTATE_STAMP => "Rotate Stamps", 
			ShortcutType.PAUSE => "Pause", 
			ShortcutType.CROSS_OUT_SUSPECT => "Cross Out Suspect", 
			ShortcutType.PEN_TOGGLE => "Toggle Pen", 
			ShortcutType.ERASER_TOGGLE => "Toggle Rubber", 
			ShortcutType.TICK_SUSPECT => "Tick Suspect", 
			ShortcutType.SELECT_SUSPECT => "Select Suspect", 
			ShortcutType.PLACE_PIN => "Place Pin", 
			ShortcutType.INSPECT_KEYWORDS => "Inspect Keywords", 
			ShortcutType.CONNECT_PINS => "Connect Pins", 
			_ => "", 
		};
	}

	public void setKeyboardCGOn()
	{
		title_text.text = localisation_asset.checkTranslation(loc_kbm_title_key, englishKBM, _check_keywords: false);
		checkSpacing();
		short_cut_text.text = getText(kbm_shortcuts, _kbm: true);
		short_cut_text_2.text = getText(kbm_shortcuts_p2, _kbm: true);
	}

	public void setControllerCGOn()
	{
		title_text.text = localisation_asset.checkTranslation(loc_controller_title_key, englishController, _check_keywords: false);
		checkSpacing();
		short_cut_text.text = getText(controller_shortcuts, _kbm: false);
		short_cut_text_2.text = getText(controller_shortcuts_p2, _kbm: false);
	}

	private void checkSpacing()
	{
		if (GRGLocalisationHandler.instance.current_language == Languages.THAI)
		{
			short_cut_text.lineSpacing = -5f;
			short_cut_text_2.lineSpacing = -5f;
		}
		else
		{
			short_cut_text.lineSpacing = 0f;
			short_cut_text_2.lineSpacing = 0f;
		}
	}

	private string englishKBM()
	{
		return "Keyboard And Mouse";
	}

	private string englishController()
	{
		return "Controller";
	}

	public override void immidiateDestroy()
	{
		close_button.clearUpSelectable();
		base.immidiateDestroy();
	}

	public override void fadeOutAndDestroy()
	{
		close_button.clearUpSelectable();
		base.fadeOutAndDestroy();
	}

	private string getLocKey(ShortcutType _type)
	{
		return $"{_type} [sc_name]";
	}
}
