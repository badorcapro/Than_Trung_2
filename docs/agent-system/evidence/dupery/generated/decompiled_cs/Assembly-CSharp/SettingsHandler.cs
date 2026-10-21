using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Save;
using Localisation;
using Save;
using UnityEngine;
using Visual;

public class SettingsHandler : MonoBehaviour
{
	public enum Settings
	{
		SCREEN_RESOLUTION_X = 1,
		SCREEN_RESOLUTION_Y = 2,
		SCREEN_MODE = 3,
		FILM_GRAIN = 4,
		CHROMATIC_ABERATION = 5,
		FONT_SIZE = 6,
		FPS_TARGET = 7,
		MASTER_VOLUME = 101,
		MUSIC_VOLUME = 102,
		ATMO_VOLUME = 103,
		SFX_VOLUME = 104,
		SHOW_TOOLTIPS = 201,
		CLEAR_DRAWINGS_ON_REVEAL_ALL = 202,
		SHOW_PIN_SYMBOLS = 203,
		SHOW_TRUTH_SYMBOLS = 204,
		CASINO_LIGHTS = 205,
		DOCKS_BOAT_LEVER = 206,
		TEST_ROLES = 299,
		TEST_QUIRKS = 298,
		LANGUAGE = 301,
		SAVE_NUMBER = 901
	}

	private Dictionary<Settings, int> settings = new Dictionary<Settings, int>();

	public static SettingsHandler instance { get; private set; }

	public static Vector2Int screen_resolution
	{
		get
		{
			return new Vector2Int(instance.getSetting(Settings.SCREEN_RESOLUTION_X), instance.getSetting(Settings.SCREEN_RESOLUTION_Y));
		}
		set
		{
			if (!(value == screen_resolution))
			{
				instance.setSetting(Settings.SCREEN_RESOLUTION_X, value.x);
				instance.setSetting(Settings.SCREEN_RESOLUTION_Y, value.y);
				instance.setScreenResolution(value);
			}
		}
	}

	public static int screen_mode
	{
		get
		{
			return instance.getSetting(Settings.SCREEN_MODE);
		}
		set
		{
			if (value != screen_mode)
			{
				instance.setScreenMode(value);
				instance.setSetting(Settings.SCREEN_MODE, value);
			}
		}
	}

	public static int min_fps => 30;

	public static int max_fps => 240;

	public static int fps_target
	{
		get
		{
			return instance.getSetting(Settings.FPS_TARGET);
		}
		set
		{
			if (value != fps_target)
			{
				instance.setSetting(Settings.FPS_TARGET, value);
				instance.setFPSTarget(value);
			}
		}
	}

	public static float film_grain
	{
		get
		{
			return instance.getSettingAsPercentage(Settings.FILM_GRAIN);
		}
		set
		{
			if (value != film_grain)
			{
				GlobalVolumeHandler.instance.setFilmGrain(value);
				instance.setSettingAsPercentage(Settings.FILM_GRAIN, value);
			}
		}
	}

	public static float chromatic_aberation
	{
		get
		{
			return instance.getSettingAsPercentage(Settings.CHROMATIC_ABERATION);
		}
		set
		{
			if (value != chromatic_aberation)
			{
				GlobalVolumeHandler.instance.setChromaticAberation(value);
				instance.setSettingAsPercentage(Settings.CHROMATIC_ABERATION, value);
			}
		}
	}

	public static int font_size
	{
		get
		{
			return instance.getSetting(Settings.FONT_SIZE);
		}
		set
		{
			TextSettingsHandler.instance.setFontSize(value);
			instance.setSetting(Settings.FONT_SIZE, value);
		}
	}

	public static float master_volume
	{
		get
		{
			return (float)instance.getSetting(Settings.MASTER_VOLUME) / 100f;
		}
		set
		{
			instance.setSetting(Settings.MASTER_VOLUME, Mathf.FloorToInt(value * 100f));
		}
	}

	public static float music_volume
	{
		get
		{
			return (float)instance.getSetting(Settings.MUSIC_VOLUME) / 100f;
		}
		set
		{
			instance.setSetting(Settings.MUSIC_VOLUME, Mathf.FloorToInt(value * 100f));
		}
	}

	public static float atmo_volume
	{
		get
		{
			return (float)instance.getSetting(Settings.ATMO_VOLUME) / 100f;
		}
		set
		{
			instance.setSetting(Settings.ATMO_VOLUME, Mathf.FloorToInt(value * 100f));
		}
	}

	public static float sfx_volume
	{
		get
		{
			return (float)instance.getSetting(Settings.SFX_VOLUME) / 100f;
		}
		set
		{
			instance.setSetting(Settings.SFX_VOLUME, Mathf.FloorToInt(value * 100f));
		}
	}

	public static LocalisationHelper.LanguageSettings language
	{
		get
		{
			return (LocalisationHelper.LanguageSettings)instance.getSetting(Settings.LANGUAGE);
		}
		set
		{
			instance.setSetting(Settings.LANGUAGE, (int)value);
		}
	}

	public static bool display_tooltips
	{
		get
		{
			return instance.getSetting(Settings.SHOW_TOOLTIPS) == 1;
		}
		set
		{
			instance.setSetting(Settings.SHOW_TOOLTIPS, value ? 1 : 0);
		}
	}

	public static bool reveal_all_clears_drawings
	{
		get
		{
			return instance.getSetting(Settings.CLEAR_DRAWINGS_ON_REVEAL_ALL) == 1;
		}
		set
		{
			instance.setSetting(Settings.CLEAR_DRAWINGS_ON_REVEAL_ALL, value ? 1 : 0);
		}
	}

	public static bool show_truth_symbols
	{
		get
		{
			return instance.getSetting(Settings.SHOW_TRUTH_SYMBOLS) == 1;
		}
		set
		{
			instance.setSetting(Settings.SHOW_TRUTH_SYMBOLS, value ? 1 : 0);
		}
	}

	public static bool show_pin_symbols
	{
		get
		{
			return instance.getSetting(Settings.SHOW_PIN_SYMBOLS) == 1;
		}
		set
		{
			instance.setSetting(Settings.SHOW_PIN_SYMBOLS, value ? 1 : 0);
		}
	}

	public static CasinoBulb.Settings casino_lights
	{
		get
		{
			return (CasinoBulb.Settings)instance.getSetting(Settings.CASINO_LIGHTS);
		}
		set
		{
			if (value != casino_lights)
			{
				instance.setSetting(Settings.CASINO_LIGHTS, (int)value);
			}
		}
	}

	public static int docks_boat_lever
	{
		get
		{
			return instance.getSetting(Settings.DOCKS_BOAT_LEVER);
		}
		set
		{
			if (value != docks_boat_lever)
			{
				instance.setSetting(Settings.DOCKS_BOAT_LEVER, value);
			}
		}
	}

	public static bool allow_test_roles
	{
		get
		{
			return instance.getSetting(Settings.TEST_ROLES) == 1;
		}
		set
		{
			instance.setSetting(Settings.TEST_ROLES, value ? 1 : 0);
		}
	}

	public static bool allow_test_quirks
	{
		get
		{
			return instance.getSetting(Settings.TEST_QUIRKS) == 1;
		}
		set
		{
			instance.setSetting(Settings.TEST_QUIRKS, value ? 1 : 0);
		}
	}

	public static int save_number
	{
		get
		{
			return instance.getSetting(Settings.SAVE_NUMBER);
		}
		set
		{
			if (value != save_number)
			{
				if (SaveHandler.instance.trySwitchSaveFileNumber(value))
				{
					instance.setSetting(Settings.SAVE_NUMBER, value);
				}
				else
				{
					instance.setSetting(Settings.SAVE_NUMBER, SaveHandler.instance.save_file_number);
				}
			}
		}
	}

	private void Awake()
	{
		if (instance != null && instance != this)
		{
			UnityEngine.Object.Destroy(base.gameObject);
			return;
		}
		UnityEngine.Object.DontDestroyOnLoad(base.gameObject);
		instance = this;
		applicationStartSetup();
	}

	public void applicationStartSetup()
	{
		setScreenMode(screen_mode);
		setScreenResolution(screen_resolution);
		setFPSTarget(fps_target);
	}

	public void setSetting(Settings _setting, int _value, bool _save = true)
	{
		settings[_setting] = _value;
		if (_save)
		{
			PlayerPrefsHandler.savePlayerPref(getPlayerPrefName(_setting), _value, _save);
		}
	}

	public int getSetting(Settings _setting)
	{
		if (!settings.ContainsKey(_setting))
		{
			settings[_setting] = loadOrGetDefault(_setting);
		}
		return settings[_setting];
	}

	public void setSettingAsPercentage(Settings _setting, float _value, bool _save = true)
	{
		setSetting(_setting, Mathf.RoundToInt(_value * 100f), _save);
	}

	public float getSettingAsPercentage(Settings _setting)
	{
		return (float)getSetting(_setting) * 0.01f;
	}

	private void setScreenMode(int _screen_mode)
	{
		switch (_screen_mode)
		{
		case 0:
			Screen.fullScreen = true;
			Screen.SetResolution(Screen.currentResolution.width, Screen.currentResolution.height, fullscreen: true);
			Screen.fullScreenMode = FullScreenMode.ExclusiveFullScreen;
			Application.runInBackground = false;
			break;
		case 1:
			Screen.fullScreen = true;
			Screen.SetResolution(Screen.currentResolution.width, Screen.currentResolution.height, fullscreen: true);
			Screen.fullScreenMode = FullScreenMode.FullScreenWindow;
			Application.runInBackground = true;
			break;
		case 2:
			Screen.fullScreen = false;
			Screen.fullScreenMode = FullScreenMode.Windowed;
			Application.runInBackground = true;
			break;
		default:
			Debug.LogError($"Could not find screen mode {_screen_mode} in SettingsHandler.setScreenMode()");
			break;
		}
	}

	private void setScreenResolution(Vector2Int _res)
	{
		Screen.SetResolution(_res.x, _res.y, Screen.fullScreenMode);
	}

	private void setFPSTarget(int _fps)
	{
		if (_fps == -1)
		{
			QualitySettings.vSyncCount = 1;
			return;
		}
		QualitySettings.vSyncCount = 0;
		Application.targetFrameRate = _fps;
	}

	public List<Vector2Int> getPossibleScreenRes()
	{
		List<Vector2Int> list = new List<Vector2Int>();
		Resolution[] resolutions = Screen.resolutions;
		for (int i = 0; i < resolutions.Length; i++)
		{
			Resolution resolution = resolutions[i];
			list.Add(new Vector2Int(resolution.width, resolution.height));
		}
		return list.Distinct().ToList();
	}

	private static int loadOrGetDefault(Settings _setting)
	{
		return PlayerPrefsHandler.getPlayerPrefsInt(getPlayerPrefName(_setting), getDefault(_setting));
	}

	private static string getPlayerPrefName(Settings _setting)
	{
		return _setting switch
		{
			Settings.SCREEN_MODE => "Gr_Mode", 
			Settings.SCREEN_RESOLUTION_X => "Gr_Res_x", 
			Settings.SCREEN_RESOLUTION_Y => "Gr_Res_y", 
			Settings.FILM_GRAIN => "Gr_FilmGrain", 
			Settings.CHROMATIC_ABERATION => "Gr_ChromaticAberation", 
			Settings.FONT_SIZE => "Gr_FontSize", 
			Settings.FPS_TARGET => "Gr_FPS", 
			Settings.MASTER_VOLUME => "A_Master", 
			Settings.MUSIC_VOLUME => "A_Music", 
			Settings.ATMO_VOLUME => "A_Atmo", 
			Settings.SFX_VOLUME => "A_Sfx", 
			Settings.SHOW_TOOLTIPS => "GD_ShowTooltips", 
			Settings.CLEAR_DRAWINGS_ON_REVEAL_ALL => "GD_ClearRevealAll", 
			Settings.SHOW_TRUTH_SYMBOLS => "GD_ShowTruthSymbols", 
			Settings.SHOW_PIN_SYMBOLS => "GD_ShowPinSymbols", 
			Settings.CASINO_LIGHTS => "GD_CasinoLights", 
			Settings.DOCKS_BOAT_LEVER => "GD_DocksLever", 
			Settings.TEST_ROLES => "GD_TestRoles", 
			Settings.TEST_QUIRKS => "GD_TestQuirks", 
			Settings.LANGUAGE => "GD_Language", 
			Settings.SAVE_NUMBER => "SAVE_nb", 
			_ => throw new ArgumentException($"No name set for settings {_setting}! in SettingHandler.getPlayerPrefName()"), 
		};
	}

	public static int getDefault(Settings _setting)
	{
		return _setting switch
		{
			Settings.SCREEN_MODE => 0, 
			Settings.SCREEN_RESOLUTION_X => Screen.currentResolution.width, 
			Settings.SCREEN_RESOLUTION_Y => Screen.currentResolution.height, 
			Settings.FILM_GRAIN => 0, 
			Settings.CHROMATIC_ABERATION => 80, 
			Settings.FONT_SIZE => TextSettingsHandler.default_size_setting, 
			Settings.FPS_TARGET => -1, 
			Settings.MASTER_VOLUME => 70, 
			Settings.MUSIC_VOLUME => 90, 
			Settings.ATMO_VOLUME => 90, 
			Settings.SFX_VOLUME => 90, 
			Settings.SHOW_TOOLTIPS => 1, 
			Settings.CLEAR_DRAWINGS_ON_REVEAL_ALL => 0, 
			Settings.SHOW_PIN_SYMBOLS => 0, 
			Settings.SHOW_TRUTH_SYMBOLS => 1, 
			Settings.CASINO_LIGHTS => 0, 
			Settings.DOCKS_BOAT_LEVER => 0, 
			Settings.TEST_ROLES => 0, 
			Settings.TEST_QUIRKS => 0, 
			Settings.LANGUAGE => -1, 
			Settings.SAVE_NUMBER => 0, 
			_ => throw new ArgumentException($"No default set for settings {_setting}! in SettingHandler.getDefault()"), 
		};
	}

	public static void setDefault(Settings _settings)
	{
		instance.setSetting(_settings, getDefault(_settings));
	}
}
