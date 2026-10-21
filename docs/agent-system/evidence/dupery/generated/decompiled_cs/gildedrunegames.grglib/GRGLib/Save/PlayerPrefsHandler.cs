using UnityEngine;

namespace GRGLib.Save;

public static class PlayerPrefsHandler
{
	public static string getPlayerPrefsString(string _key, string _default)
	{
		if (PlayerPrefs.HasKey(_key))
		{
			return PlayerPrefs.GetString(_key);
		}
		return _default;
	}

	public static float getPlayerPrefsFloat(string _key, float _default = -1f)
	{
		if (PlayerPrefs.HasKey(_key))
		{
			return PlayerPrefs.GetFloat(_key);
		}
		return _default;
	}

	public static int getPlayerPrefsInt(string _key, int _default = -1)
	{
		if (PlayerPrefs.HasKey(_key))
		{
			return PlayerPrefs.GetInt(_key);
		}
		return _default;
	}

	public static bool getPlayerPrefsBool(string _key, bool _default = false)
	{
		int playerPrefsInt = getPlayerPrefsInt(_key);
		if (playerPrefsInt != -1)
		{
			return playerPrefsInt == 1;
		}
		return _default;
	}

	public static void savePlayerPref(string _key, string _value, bool _save = true)
	{
		PlayerPrefs.SetString(_key, _value);
		if (_save)
		{
			PlayerPrefs.Save();
		}
	}

	public static void savePlayerPref(string _key, float _value, bool _save = true)
	{
		PlayerPrefs.SetFloat(_key, _value);
		if (_save)
		{
			PlayerPrefs.Save();
		}
	}

	public static void savePlayerPref(string _key, int _value, bool _save = true)
	{
		PlayerPrefs.SetInt(_key, _value);
		if (_save)
		{
			PlayerPrefs.Save();
		}
	}

	public static void savePlayerPref(string _key, bool _value, bool _save = true)
	{
		savePlayerPref(_key, _value ? 1 : 0, _save);
	}

	public static void removePlayerPref(string _key)
	{
		if (PlayerPrefs.HasKey(_key))
		{
			PlayerPrefs.DeleteKey(_key);
		}
	}

	public static void removeAllPlayerPrefs()
	{
		PlayerPrefs.DeleteAll();
	}
}
