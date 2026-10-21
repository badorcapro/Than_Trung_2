using System;
using System.Collections;
using System.Collections.Generic;
using GRGLib.Coroutines;
using GRGLib.Maybe;
using Steamworks;
using UnityEngine;

public class SteamHandler : MonoBehaviour
{
	public struct SteamAchievementsData
	{
		public string name;

		public string description;

		public bool hidden;

		public bool achieved;

		public Sprite icon;

		public bool is_icon_setup => icon != null;

		public SteamAchievementsData(string _achievement_ID, Sprite _icon = null)
		{
			name = getAchievementName(_achievement_ID);
			description = getAchivementDescription(_achievement_ID);
			hidden = getAchievementHidden(_achievement_ID);
			achieved = isAchieved(_achievement_ID);
			icon = _icon;
		}
	}

	protected Callback<UserStatsReceived_t> m_UserStatRecieved;

	protected Callback<GamepadTextInputDismissed_t> gamepad_text_recieved;

	protected Maybe<Action<string>> gamepad_input_field_callback = new Maybe<Action<string>>();

	protected Maybe<SteamWorkshopHandler> workshop = new Maybe<SteamWorkshopHandler>();

	public static SteamHandler instance { get; private set; }

	public bool current_stats_initialised { get; private set; }

	private void Awake()
	{
		if (instance != null && instance != this)
		{
			UnityEngine.Object.Destroy(this);
			return;
		}
		UnityEngine.Object.DontDestroyOnLoad(base.gameObject);
		instance = this;
	}

	public static bool isSteamInitialized()
	{
		return SteamManager.Initialized;
	}

	private void Start()
	{
		m_UserStatRecieved = Callback<UserStatsReceived_t>.Create(statsRequestedCallback);
		gamepad_text_recieved = Callback<GamepadTextInputDismissed_t>.Create(recievedGamepadTextInput);
		waitForInitialisation().addCallback(delegate
		{
			SteamUserStats.RequestUserStats(SteamUser.GetSteamID());
		}).start(this);
	}

	public void waitForInitialisation(Action _callback)
	{
		if (isSteamInitialized())
		{
			_callback();
		}
		else
		{
			waitForInitialisation().addCallback(_callback).start(this);
		}
	}

	public IEnumerator waitForInitialisation()
	{
		while (!isSteamInitialized())
		{
			yield return 0.05f.wait();
		}
	}

	public IEnumerator waitForCurrentStats()
	{
		while (!current_stats_initialised)
		{
			yield return 0.05f.wait();
		}
	}

	public void statsRequestedCallback(UserStatsReceived_t _recieved)
	{
		current_stats_initialised = true;
		Debug.Log("Steam Stats initialised!");
	}

	public void recievedGamepadTextInput(GamepadTextInputDismissed_t _text_input)
	{
		if (gamepad_input_field_callback.is_some && _text_input.m_bSubmitted)
		{
			string pchText = "";
			if (SteamUtils.GetEnteredGamepadTextInput(out pchText, 65u))
			{
				gamepad_input_field_callback.value(pchText);
			}
		}
		gamepad_input_field_callback = new Maybe<Action<string>>();
	}

	public static string getUser64BitID()
	{
		if (!isSteamInitialized())
		{
			throw new Exception("SteamManager is not initialized!");
		}
		ulong steamID = SteamUser.GetSteamID().m_SteamID;
		return steamID.ToString();
	}

	public static string getUserName()
	{
		return SteamFriends.GetPersonaName();
	}

	public static void openUrlInSteamOverlay(string _url)
	{
		SteamFriends.ActivateGameOverlayToWebPage(_url);
	}

	public static void incremementStat(string _stat, int _value, bool _store = true)
	{
		int stat = getStat(_stat);
		setStat(_stat, stat + _value, _store);
	}

	public static void setStat(string _stat, int _value, bool _store = true)
	{
		SteamUserStats.SetStat(_stat, _value);
		if (_store && instance.current_stats_initialised)
		{
			SteamUserStats.StoreStats();
		}
	}

	public static int getStat(string _stat)
	{
		if (SteamUserStats.GetStat(_stat, out int pData))
		{
			return pData;
		}
		Debug.Log("Steam Stat '" + _stat + "' could not be fetched!");
		return 0;
	}

	public static void unlockAchievement(string _achievement, bool _store = true)
	{
		SteamUserStats.SetAchievement(_achievement);
		if (_store && instance.current_stats_initialised)
		{
			SteamUserStats.StoreStats();
		}
	}

	public static bool isAchieved(string _achievement)
	{
		if (SteamUserStats.GetAchievement(_achievement, out var pbAchieved))
		{
			return pbAchieved;
		}
		Debug.Log("Steam Achievement '" + _achievement + "' completion could not be checked!");
		return false;
	}

	public static string getAchievementName(string _achievement_ID)
	{
		return SteamUserStats.GetAchievementDisplayAttribute(_achievement_ID, "name");
	}

	public static string getAchivementDescription(string _achievement_ID)
	{
		return SteamUserStats.GetAchievementDisplayAttribute(_achievement_ID, "desc");
	}

	public static bool getAchievementHidden(string _achievement_ID)
	{
		return SteamUserStats.GetAchievementDisplayAttribute(_achievement_ID, "hidden") == "1";
	}

	public static bool onSteamDeck()
	{
		return SteamUtils.IsSteamRunningOnSteamDeck();
	}

	public static bool inBigPictureMode()
	{
		return SteamUtils.IsSteamInBigPictureMode();
	}

	public static void openSteamKeyboard(Action<string> _on_close_callback, string _text, uint _character_limit)
	{
		SteamUtils.ShowGamepadTextInput(EGamepadTextInputMode.k_EGamepadTextInputModeNormal, EGamepadTextInputLineMode.k_EGamepadTextInputLineModeSingleLine, _text, _character_limit, "");
		instance.gamepad_input_field_callback = _on_close_callback.maybe();
	}

	public static void openSteamFloatingKeyboard(int _x_pos, int _y_pos, int _width, int _height)
	{
		SteamUtils.ShowFloatingGamepadTextInput(EFloatingGamepadTextInputMode.k_EFloatingGamepadTextInputModeModeSingleLine, _x_pos, _y_pos, _width, _height);
	}

	public static void setStatusRichPresence(RichPresenceStatus _status)
	{
		setStatusRichPresence("#Status_" + _status);
	}

	public static void setStatusRichPresence(string _key)
	{
		if (SteamFriends.SetRichPresence("steam_display", _key))
		{
			Debug.Log("RICH PRESENCE SET TO " + _key);
		}
		else
		{
			Debug.Log("RICH PRESENCE FAILED TO SET TO " + _key);
		}
	}

	public static void setStatusRichPresenceData(string _key, string _data)
	{
		if (SteamFriends.SetRichPresence(_key, _data))
		{
			Debug.Log("Rich presence " + _key + " data set to " + _data);
		}
		else
		{
			Debug.Log("Rich presence " + _key + " data failed to set data to " + _data);
		}
	}

	public static string getSteamGameLanguage()
	{
		string currentGameLanguage = SteamApps.GetCurrentGameLanguage();
		Debug.Log("Steam Wanted Language: " + currentGameLanguage);
		return currentGameLanguage;
	}

	public static string getSteamInterfaceLanguage()
	{
		return SteamUtils.GetSteamUILanguage();
	}

	public static SteamWorkshopHandler getSteamWorkshopHandler()
	{
		if (!instance.workshop.is_some)
		{
			instance.workshop = new SteamWorkshopHandler().maybe();
		}
		return instance.workshop.value;
	}

	public static uint getSubscribedWorkshopItems()
	{
		return SteamWorkshopHandler.getNumSubscribedItems();
	}

	public static Maybe<T> loadWorkshopItem<T>(Func<string, Maybe<T>> _load_function)
	{
		return SteamWorkshopHandler.tryLoadItem(_load_function);
	}

	public static List<T> loadAllWorkshopItems<T>(Func<string, Maybe<T>> _load_function)
	{
		return SteamWorkshopHandler.loadAllInstalledItemsOfType(_load_function);
	}
}
