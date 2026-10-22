using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using Audio;
using GRGLib.Coroutines;
using GRGLib.Extensions.Unity;
using GRGLib.Resolution;
using GRGLocalisation;
using Localisation;
using TMPro;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;
using Visual;

public class SettingsMenu : MenuBase, IAmLocalised
{
	private enum Sections
	{
		MAIN,
		GRAPHICS,
		AUDIO,
		GAMEPLAY,
		MISC
	}

	private enum VolumeTypes
	{
		MASTER,
		MUSIC,
		ATMO,
		SFX
	}

	[Header("Animation")]
	[SerializeField]
	private BackgroundMenuAnimationManager animation_manager;

	[SerializeField]
	private CanvasGroup main_group;

	[Header("Overarching")]
	[SerializeField]
	private Selectable section_back_button;

	[SerializeField]
	private Color controller_selected_colour;

	[SerializeField]
	private ConfirmationMenu confirmation_menu;

	[Header("Graphic Settings References")]
	[SerializeField]
	private CanvasGroup graphics_group;

	[SerializeField]
	private GameObject graphics_group_active;

	[SerializeField]
	private TMP_Dropdown screen_mode;

	[SerializeField]
	private TMP_Dropdown screen_resolution;

	[SerializeField]
	private TMP_Text fps_handle_text;

	[SerializeField]
	private Slider fps_limiter;

	[SerializeField]
	private TMP_Text film_grain_handle_text;

	[SerializeField]
	private Slider screen_film_grain;

	[SerializeField]
	private TMP_Text chromatic_aberation_handle_text;

	[SerializeField]
	private Slider chromatic_aberation;

	[SerializeField]
	private TMP_Text font_size_handle_text;

	[SerializeField]
	private Slider font_size;

	[SerializeField]
	private CameraResolution cam_res;

	[SerializeField]
	private Button graphics_button;

	[Header("Audio Settings References")]
	[SerializeField]
	private CanvasGroup audio_group;

	[SerializeField]
	private GameObject audio_group_active;

	[SerializeField]
	private Slider master_volume;

	[SerializeField]
	private TMP_Text master_volume_handle_text;

	[SerializeField]
	private Slider music_volume;

	[SerializeField]
	private TMP_Text music_volume_handle_text;

	[SerializeField]
	private Slider atmo_volume;

	[SerializeField]
	private TMP_Text atmo_volume_handle_text;

	[SerializeField]
	private Slider sfx_volume;

	[SerializeField]
	private TMP_Text sfx_volume_handle_text;

	[SerializeField]
	private Button audio_button;

	[Header("Gameplay Settings References")]
	[SerializeField]
	private CanvasGroup gameplay_group;

	[SerializeField]
	private GameObject gameplay_group_active;

	[SerializeField]
	private TMP_Dropdown language;

	[SerializeField]
	private TMP_Dropdown show_tooltips;

	[SerializeField]
	private TMP_Dropdown clear_notes_on_reveal_all;

	[SerializeField]
	private TMP_Dropdown show_truth_symbols;

	[SerializeField]
	private TMP_Dropdown show_pin_symbols;

	[SerializeField]
	private GameObject casino_settings_parent;

	[SerializeField]
	private TMP_Dropdown casino_lights;

	[SerializeField]
	private GameObject docks_settings_parent;

	[SerializeField]
	private TMP_Dropdown docks_lever;

	[SerializeField]
	private Button gameplay_button;

	[Header("MISC Settings References")]
	[SerializeField]
	private CanvasGroup misc_group;

	[SerializeField]
	private GameObject misc_group_active;

	[SerializeField]
	private Button misc_button;

	private List<Vector2Int> resolutions;

	private Sections current_section;

	private bool moving_section;

	private bool can_play_tick = true;

	private AssetKey localisation_asset => LocalisationHelper.ui_asset;

	private string loc_smaller_key => "Settings [smaller]";

	private string loc_default_key => "Settings [default]";

	private string loc_bigger_key => "Settings [bigger]";

	private string loc_fps_unlimited_key => "Settings [fps_unlmt]";

	private string loc_set_language_key => "Settings [lang_conf]";

	public void Start()
	{
		setUpGraphicsSettings();
		setUpAudioSettings();
		setUpGameplaySettings();
		setUpMiscSettings();
		setSliderSelectionColour(GameHandler.instance.using_gamepad);
		input.onControlsChanged += swapControls;
		confirmation_menu.setPlayerInput(input);
	}

	public void tryClose(InputAction.CallbackContext _context)
	{
		if (_context.canceled && base.is_open)
		{
			if (current_section == Sections.MAIN)
			{
				closeMenu();
			}
			else
			{
				closeSection();
			}
		}
	}

	public void moveToGraphics()
	{
		moveToSection(Sections.GRAPHICS);
	}

	public void moveToAudio()
	{
		moveToSection(Sections.AUDIO);
	}

	public void moveToGameplay()
	{
		moveToSection(Sections.GAMEPLAY);
	}

	public void moveToMisc()
	{
		moveToSection(Sections.MISC);
	}

	public void closeSection()
	{
		if (current_section != 0 && !moving_section)
		{
			if (GameHandler.instance.current_scene != "MainMenuScene" && current_section == Sections.AUDIO)
			{
				AudioHandler.instance.setGlobalParameter(GlobalParams.GAME_PAUSE, 1f);
			}
			closeSection(getGroup(current_section), getButtonActive(current_section)).start(this);
			if (GameHandler.instance.using_gamepad)
			{
				getButton(current_section).Select();
			}
			current_section = Sections.MAIN;
		}
	}

	private void moveToSection(Sections _section)
	{
		if (GameHandler.instance.current_scene != "MainMenuScene" && _section == Sections.AUDIO)
		{
			AudioHandler.instance.setGlobalParameter(GlobalParams.GAME_PAUSE, 0f);
		}
		if (base.is_open && current_section != _section && !moving_section)
		{
			GameObject buttonActive = getButtonActive(_section);
			buttonActive.SetActive(value: true);
			openSection(getGroup(_section)).start(this);
			current_section = _section;
			section_back_button.transform.SetParent(buttonActive.transform);
			Navigation navigation = section_back_button.navigation;
			Selectable selectable = (navigation.selectOnUp = getBottomSelectable(_section));
			section_back_button.navigation = navigation;
			selectable.setNavigationDown(section_back_button);
			if (GameHandler.instance.using_gamepad)
			{
				section_back_button.Select();
			}
		}
	}

	private GameObject getButtonActive(Sections _section)
	{
		return _section switch
		{
			Sections.GRAPHICS => graphics_group_active, 
			Sections.AUDIO => audio_group_active, 
			Sections.GAMEPLAY => gameplay_group_active, 
			Sections.MISC => misc_group_active, 
			_ => throw new ArgumentException($"No button active set for section {_section}!"), 
		};
	}

	private CanvasGroup getGroup(Sections _section)
	{
		return _section switch
		{
			Sections.GRAPHICS => graphics_group, 
			Sections.AUDIO => audio_group, 
			Sections.GAMEPLAY => gameplay_group, 
			Sections.MISC => misc_group, 
			_ => throw new ArgumentException($"No group set for section {_section}!"), 
		};
	}

	private Selectable getButton(Sections _section)
	{
		return _section switch
		{
			Sections.GRAPHICS => graphics_button, 
			Sections.AUDIO => audio_button, 
			Sections.GAMEPLAY => gameplay_button, 
			Sections.MISC => misc_button, 
			_ => throw new ArgumentException($"No button set for section {_section}!"), 
		};
	}

	private Selectable getBottomSelectable(Sections _section)
	{
		return _section switch
		{
			Sections.GRAPHICS => font_size, 
			Sections.AUDIO => sfx_volume, 
			Sections.GAMEPLAY => docks_settings_parent.activeSelf ? docks_lever : (casino_settings_parent.activeSelf ? casino_lights : show_pin_symbols), 
			_ => throw new ArgumentException($"No Selectable set for section {_section}!"), 
		};
	}

	private IEnumerator openSection(CanvasGroup _group)
	{
		moving_section = true;
		animation_manager.openingMenuAnimation();
		main_group.blocksRaycasts = false;
		main_group.interactable = false;
		yield return main_group.fadeRealTime(0f, 0.25f, CoroutineExtensions.easeInOutFunc);
		yield return (animation_manager.getAnimationDuration(_in: true) - 0.35f).wait();
		yield return _group.fadeRealTime(1f, 0.35f, CoroutineExtensions.easeInOutFunc);
		_group.interactable = true;
		_group.blocksRaycasts = true;
		moving_section = false;
	}

	private IEnumerator closeSection(CanvasGroup _group, GameObject _button_active)
	{
		moving_section = true;
		_group.interactable = false;
		_group.blocksRaycasts = false;
		animation_manager.closingMenuAnimation();
		yield return _group.fadeRealTime(0f, 0.25f, CoroutineExtensions.easeInOutFunc);
		_button_active.SetActive(value: false);
		yield return (animation_manager.getAnimationDuration(_in: true) - 0.6f).wait();
		yield return main_group.fadeRealTime(1f, 0.35f, CoroutineExtensions.easeInOutFunc);
		main_group.blocksRaycasts = true;
		main_group.interactable = true;
		moving_section = false;
	}

	private void setUpGraphicsSettings()
	{
		screen_mode.value = SettingsHandler.screen_mode;
		resolutions = SettingsHandler.instance.getPossibleScreenRes();
		resolutions.Reverse();
		Vector2Int current_screen_res = SettingsHandler.screen_resolution;
		int num = resolutions.FindIndex(0, (Vector2Int _v) => _v == current_screen_res);
		if (num == -1)
		{
			num = resolutions.Count;
			resolutions.Add(current_screen_res);
		}
		screen_resolution.ClearOptions();
		screen_resolution.AddOptions(resolutions.Select((Vector2Int _vec) => _vec.x + " x " + _vec.y).ToList());
		screen_resolution.value = num;
		if (SettingsHandler.fps_target == -1)
		{
			fps_limiter.SetValueWithoutNotify(SettingsHandler.max_fps - SettingsHandler.min_fps + 1);
			fps_handle_text.text = localisation_asset.checkTranslation(loc_fps_unlimited_key, englishUnlimited);
			fps_handle_text.alignment = TextAlignmentOptions.Right;
		}
		else
		{
			fps_limiter.SetValueWithoutNotify(SettingsHandler.min_fps + SettingsHandler.fps_target);
			fps_handle_text.text = SettingsHandler.fps_target.ToString();
			fps_handle_text.alignment = TextAlignmentOptions.Center;
		}
		screen_film_grain.SetValueWithoutNotify(SettingsHandler.film_grain);
		film_grain_handle_text.text = $"{Mathf.RoundToInt(SettingsHandler.film_grain * 100f)}%";
		chromatic_aberation.SetValueWithoutNotify(SettingsHandler.chromatic_aberation);
		chromatic_aberation_handle_text.text = $"{Mathf.RoundToInt(SettingsHandler.chromatic_aberation * 100f)}%";
		font_size.SetValueWithoutNotify((float)SettingsHandler.font_size / 100f);
		setFontSizeHandleText(SettingsHandler.font_size);
	}

	public void setScreenResolution(int _value)
	{
		SettingsHandler.screen_resolution = resolutions[_value];
		cam_res.forceUpdate(resolutions[_value]);
	}

	public void setScreenMode(int _value)
	{
		SettingsHandler.screen_mode = _value;
	}

	public void setFpsLimit(float _value)
	{
		int num = Mathf.RoundToInt(_value) + SettingsHandler.min_fps;
		if (num > SettingsHandler.max_fps)
		{
			SettingsHandler.fps_target = -1;
			fps_handle_text.text = localisation_asset.checkTranslation(loc_fps_unlimited_key, englishUnlimited);
			fps_handle_text.alignment = TextAlignmentOptions.Right;
		}
		else
		{
			SettingsHandler.fps_target = num;
			fps_handle_text.text = SettingsHandler.fps_target.ToString();
			fps_handle_text.alignment = TextAlignmentOptions.Center;
		}
	}

	public void setFilmGrain(float _value)
	{
		SettingsHandler.film_grain = _value;
		film_grain_handle_text.text = $"{Mathf.RoundToInt(_value * 100f)}%";
	}

	public void setChromaticAberration(float _value)
	{
		SettingsHandler.chromatic_aberation = _value;
		chromatic_aberation_handle_text.text = $"{Mathf.RoundToInt(_value * 100f)}%";
	}

	public void setFontSize(float _value)
	{
		int fontSizeHandleText = (SettingsHandler.font_size = Mathf.RoundToInt(_value * 100f));
		setFontSizeHandleText(fontSizeHandleText);
	}

	private void setFontSizeHandleText(int _value)
	{
		if (_value < 28)
		{
			font_size_handle_text.text = localisation_asset.checkTranslation(loc_smaller_key, englishSmaller);
		}
		else if (_value < 32)
		{
			font_size_handle_text.text = localisation_asset.checkTranslation(loc_default_key, englishDefault);
		}
		else
		{
			font_size_handle_text.text = localisation_asset.checkTranslation(loc_bigger_key, englishBigger);
		}
	}

	private string englishSmaller()
	{
		return "Smaller";
	}

	private string englishDefault()
	{
		return "Default";
	}

	private string englishBigger()
	{
		return "Bigger";
	}

	private string englishUnlimited()
	{
		return "Unlimited";
	}

	public void resetGraphicsDefault()
	{
		SettingsHandler.setDefault(SettingsHandler.Settings.SCREEN_MODE);
		SettingsHandler.setDefault(SettingsHandler.Settings.SCREEN_RESOLUTION_X);
		SettingsHandler.setDefault(SettingsHandler.Settings.SCREEN_RESOLUTION_Y);
		SettingsHandler.setDefault(SettingsHandler.Settings.FILM_GRAIN);
		SettingsHandler.setDefault(SettingsHandler.Settings.CHROMATIC_ABERATION);
		SettingsHandler.setDefault(SettingsHandler.Settings.FPS_TARGET);
		setUpGraphicsSettings();
	}

	private void setUpAudioSettings()
	{
		setVolumeSlider(master_volume, master_volume_handle_text, SettingsHandler.master_volume);
		setVolumeSlider(music_volume, music_volume_handle_text, SettingsHandler.music_volume);
		setVolumeSlider(atmo_volume, atmo_volume_handle_text, SettingsHandler.atmo_volume);
		setVolumeSlider(sfx_volume, sfx_volume_handle_text, SettingsHandler.sfx_volume);
	}

	private void setVolumeSlider(Slider _slider, TMP_Text _handle, float _value)
	{
		_slider.value = _value;
		_handle.text = Mathf.RoundToInt(_value * 100f) + "%";
	}

	public void setMasterVolume(float _value)
	{
		setVolume(VolumeTypes.MASTER, master_volume_handle_text, _value);
	}

	public void setMusicVolume(float _value)
	{
		setVolume(VolumeTypes.MUSIC, music_volume_handle_text, _value);
	}

	public void setAtmoVolume(float _value)
	{
		setVolume(VolumeTypes.ATMO, atmo_volume_handle_text, _value);
	}

	public void setSfxVolume(float _value)
	{
		setVolume(VolumeTypes.SFX, sfx_volume_handle_text, _value);
	}

	private void setVolume(VolumeTypes _type, TMP_Text _handle, float _value)
	{
		_handle.text = $"{Mathf.RoundToInt(_value * 100f)}%";
		switch (_type)
		{
		case VolumeTypes.MASTER:
			SettingsHandler.master_volume = _value;
			break;
		case VolumeTypes.MUSIC:
			SettingsHandler.music_volume = _value;
			break;
		case VolumeTypes.ATMO:
			SettingsHandler.atmo_volume = _value;
			break;
		case VolumeTypes.SFX:
			SettingsHandler.sfx_volume = _value;
			if (can_play_tick)
			{
				AudioHandler.Sfx.playSfx(Sfx.TICK);
				can_play_tick = false;
				0.15f.waitReal(delegate
				{
					can_play_tick = true;
				}).start(this);
			}
			break;
		}
		AudioHandler.instance.changeVolumes();
	}

	public void resetAudioSettings()
	{
		SettingsHandler.setDefault(SettingsHandler.Settings.MASTER_VOLUME);
		SettingsHandler.setDefault(SettingsHandler.Settings.MUSIC_VOLUME);
		SettingsHandler.setDefault(SettingsHandler.Settings.ATMO_VOLUME);
		SettingsHandler.setDefault(SettingsHandler.Settings.SFX_VOLUME);
		setUpAudioSettings();
	}

	private void setUpGameplaySettings()
	{
		language.SetValueWithoutNotify((int)GRGLocalisationHandler.instance.current_language.toSetting());
		show_tooltips.SetValueWithoutNotify(SettingsHandler.display_tooltips ? 1 : 0);
		clear_notes_on_reveal_all.SetValueWithoutNotify(SettingsHandler.reveal_all_clears_drawings ? 1 : 0);
		show_truth_symbols.SetValueWithoutNotify(SettingsHandler.show_truth_symbols ? 1 : 0);
		show_pin_symbols.SetValueWithoutNotify(SettingsHandler.show_pin_symbols ? 1 : 0);
		casino_lights.SetValueWithoutNotify((int)SettingsHandler.casino_lights);
		docks_lever.SetValueWithoutNotify(SettingsHandler.docks_boat_lever);
		casino_settings_parent.SetActive(value: true);
		docks_settings_parent.SetActive(value: true);
	}

	public void setLanguage(int _value)
	{
		openConfirmationMenu(confirmation_menu, localisation_asset.checkTranslation(loc_set_language_key, englishConfirmLanguageChange), delegate
		{
			SettingsHandler.language = (LocalisationHelper.LanguageSettings)_value;
			GRGLocalisationHandler.instance.setNewLanguage(SettingsHandler.language.toLanguage());
			GameHandler.instance.moveToScene("MainMenuScene");
		}, delegate
		{
			language.SetValueWithoutNotify((int)SettingsHandler.language.toLanguage().toSetting());
			confirmation_menu.closeMenu();
		});
	}

	public void setShowTooltips(int _value)
	{
		SettingsHandler.display_tooltips = _value == 1;
	}

	public void setRevealAllClearsNotes(int _value)
	{
		SettingsHandler.reveal_all_clears_drawings = _value == 1;
	}

	public void setAllowTestRoles(int _value)
	{
		SettingsHandler.allow_test_roles = _value == 1;
	}

	public void setAllowTestQuirks(int _value)
	{
		SettingsHandler.allow_test_quirks = _value == 1;
	}

	public void setShowPinSymbols(int _value)
	{
		SettingsHandler.show_pin_symbols = _value == 1;
		if (!(GameHandler.instance.current_scene != "GameScene"))
		{
			UnityEngine.Object.FindObjectsOfType<DragPin>().ToList().ForEach(delegate(DragPin _e)
			{
				_e.pollPinSymbol();
			});
		}
	}

	public void setShowTruthSymbols(int _value)
	{
		SettingsHandler.show_truth_symbols = _value == 1;
		if (!(GameHandler.instance.current_scene != "GameScene"))
		{
			UnityEngine.Object.FindObjectsOfType<CharacterVisual>().ToList().ForEach(delegate(CharacterVisual _e)
			{
				_e.toggleTruthSymbols(SettingsHandler.show_truth_symbols);
			});
		}
	}

	public void setCasinoLights(int _value)
	{
		SettingsHandler.casino_lights = (CasinoBulb.Settings)_value;
		if (!(GameHandler.instance.current_scene != "GameScene"))
		{
			UnityEngine.Object.FindObjectsOfType<CasinoLightsManager>().ToList().ForEach(delegate(CasinoLightsManager _e)
			{
				_e.checkBulbSettings();
			});
		}
	}

	public void setDocksLever(int _value)
	{
		SettingsHandler.docks_boat_lever = _value;
	}

	public void resetGameplaySettings()
	{
		SettingsHandler.setDefault(SettingsHandler.Settings.CLEAR_DRAWINGS_ON_REVEAL_ALL);
		SettingsHandler.setDefault(SettingsHandler.Settings.SHOW_TOOLTIPS);
		SettingsHandler.setDefault(SettingsHandler.Settings.SHOW_TRUTH_SYMBOLS);
		SettingsHandler.setDefault(SettingsHandler.Settings.SHOW_PIN_SYMBOLS);
		SettingsHandler.setDefault(SettingsHandler.Settings.CASINO_LIGHTS);
		SettingsHandler.setDefault(SettingsHandler.Settings.DOCKS_BOAT_LEVER);
		setUpGameplaySettings();
	}

	private void setUpMiscSettings()
	{
	}

	public void setWantsTutorial(bool _on)
	{
	}

	public void setWantsTimer(bool _on)
	{
	}

	public void resetMiscSettings()
	{
		setUpMiscSettings();
	}

	public void swapControls(PlayerInput _play_input)
	{
		setSliderSelectionColour(_play_input.isUsingGamepad());
	}

	private void setSliderSelectionColour(bool _controller)
	{
		Color colour = (_controller ? controller_selected_colour : Color.white);
		screen_mode.setSelectedColour(colour);
		screen_resolution.setSelectedColour(colour);
		screen_film_grain.setSelectedColour(colour);
		chromatic_aberation.setSelectedColour(colour);
		font_size.setSelectedColour(colour);
		master_volume.setSelectedColour(colour);
		music_volume.setSelectedColour(colour);
		sfx_volume.setSelectedColour(colour);
		atmo_volume.setSelectedColour(colour);
		show_tooltips.setSelectedColour(colour);
		clear_notes_on_reveal_all.setSelectedColour(colour);
		show_truth_symbols.setSelectedColour(colour);
		show_pin_symbols.setSelectedColour(colour);
	}

	private string englishConfirmLanguageChange()
	{
		return "Changing language will restart the game.\nProceed?";
	}
}
