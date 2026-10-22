using System;
using System.Collections.Generic;
using System.IO;
using GRGLib.Maybe;
using UnityEngine;

namespace GRGLib.Save.Json;

public static class JsonSaveHandler
{
	public static SaveHelper.SaveVersionState getSaveVersionStateOfSetFile(string _file_path_and_name, string _earliest_valid_version = "current", string _earliest_safe_version = "current")
	{
		return SaveHelper.getSaveVersionState(getSaveVersionOfSetFile(_file_path_and_name), _earliest_valid_version, _earliest_safe_version);
	}

	public static SaveHelper.SaveVersionState getSaveVersionStateOfFile(string _file_path_and_name, string _earliest_valid_version = "current", string _earliest_safe_version = "current")
	{
		return SaveHelper.getSaveVersionState(getSaveVersionOfFile(_file_path_and_name), _earliest_valid_version, _earliest_safe_version);
	}

	public static bool isSaveSafe(string _file_path_and_name, string _earliest_safe_version = "current")
	{
		return getSaveVersionStateOfFile(_file_path_and_name, _earliest_safe_version, _earliest_safe_version) == SaveHelper.SaveVersionState.SAFE;
	}

	public static bool isSetSaveSafe(string _file_path_and_name, string _earliest_safe_version = "current")
	{
		return getSaveVersionStateOfSetFile(_file_path_and_name, _earliest_safe_version, _earliest_safe_version) == SaveHelper.SaveVersionState.SAFE;
	}

	public static bool isSaveInvalid(string _file_path_and_name, string _earliest_valid_version = "current")
	{
		return getSaveVersionStateOfFile(_file_path_and_name, _earliest_valid_version, _earliest_valid_version) == SaveHelper.SaveVersionState.INVALID;
	}

	public static bool isSetSaveInvalid(string _file_path_and_name, string _earliest_valid_version = "current")
	{
		return getSaveVersionStateOfSetFile(_file_path_and_name, _earliest_valid_version, _earliest_valid_version) == SaveHelper.SaveVersionState.INVALID;
	}

	public static string getSaveVersionOfFile(string _file_path_and_name)
	{
		return getSaveVersionOfSetFile(Application.persistentDataPath + "/" + _file_path_and_name);
	}

	public static string getSaveVersionOfSetFile(string _file_path_and_name)
	{
		if (!File.Exists(_file_path_and_name))
		{
			return "";
		}
		try
		{
			using StreamReader reader = new StreamReader(_file_path_and_name);
			SaveHelper.readUntil(reader, "version\":");
			string text = SaveHelper.readUntil(reader, "\",");
			int num = text.IndexOf('"') + 1;
			return text.Substring(num, text.IndexOf('"', num) - num);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load save file: {_file_path_and_name} due to error: {arg}");
			return "";
		}
	}

	public static bool SaveDataToSetFolderAndNewFile<T>(this T _data, string _file_name, string _extension, string _path_to_save = "/", bool _use_save_file = true)
	{
		return _data.SaveDataToSetFolder(SaveHelper.getNextFileName(_path_to_save, _file_name, _extension, _persistent_data: false), _path_to_save, _use_save_file);
	}

	public static bool SaveDataToNewFile<T>(this T _data, string _file_name, string _extension, string _path_to_save = "", bool _use_save_file = true)
	{
		return _data.SaveData(SaveHelper.getNextFileName(_path_to_save, _file_name, _extension), _path_to_save, _use_save_file);
	}

	public static bool SaveData<T>(this T _data, string _file_name, string _path_to_save = "", bool _use_save_file = true)
	{
		return _data.SaveDataToSetFolder(_file_name, Application.persistentDataPath + "/" + _path_to_save, _use_save_file);
	}

	public static bool SaveDataToSetFolder<T>(this T _data, string _file_name, string _path_to_save = "/", bool _use_save_file = true)
	{
		if (!typeof(T).IsSerializable)
		{
			throw new ArgumentException("Cannot save none serializable data! In SaveHandler.SaveData()");
		}
		try
		{
			Directory.CreateDirectory(_path_to_save);
			string value = (_use_save_file ? JsonUtility.ToJson(new SaveFile<T>(_data)) : JsonUtility.ToJson(_data));
			using (StreamWriter streamWriter = new StreamWriter(File.Create(_path_to_save + _file_name)))
			{
				streamWriter.Write(value);
			}
			return true;
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to save file: {_file_name} due to error: {arg}");
			return false;
		}
	}

	public static Maybe<T> LoadData<T>(string _file_path_and_name, bool _used_save_file = true)
	{
		return LoadDataFromSetFolder<T>(Application.persistentDataPath + "/" + _file_path_and_name, _used_save_file);
	}

	public static List<T> LoadAllData<T>(string _path, string _extension, bool _used_save_file = true)
	{
		return LoadAllDataFromSetFolder<T>(Application.persistentDataPath + "/" + _path, _extension, _used_save_file);
	}

	public static Maybe<T> LoadDataFromSetFolder<T>(string _file_path_and_name, bool _used_save_file = true)
	{
		if (!File.Exists(_file_path_and_name))
		{
			return new Maybe<T>();
		}
		try
		{
			using StreamReader streamReader = new StreamReader(_file_path_and_name);
			string json = streamReader.ReadToEnd();
			return (_used_save_file ? JsonUtility.FromJson<SaveFile<T>>(json).data : JsonUtility.FromJson<T>(json)).maybe();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load save file: {_file_path_and_name} due to error: {arg}");
			return new Maybe<T>();
		}
	}

	public static List<T> LoadAllDataFromSetFolder<T>(string _path, string _extension, bool _used_save_file = true)
	{
		if (!Directory.Exists(_path))
		{
			return new List<T>();
		}
		try
		{
			List<T> list = new List<T>();
			string[] files = Directory.GetFiles(_path, "*" + _extension);
			for (int i = 0; i < files.Length; i++)
			{
				using StreamReader streamReader = new StreamReader(files[i]);
				string json = streamReader.ReadToEnd();
				T item = (_used_save_file ? JsonUtility.FromJson<SaveFile<T>>(json).data : JsonUtility.FromJson<T>(json));
				list.Add(item);
			}
			return list;
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load save file: {_path} due to error: {arg}");
			return new List<T>();
		}
	}

	public static T TryLoad<T>(string _file_path, Func<T> _default_constructor)
	{
		Maybe<T> maybe = LoadData<T>(_file_path);
		if (maybe.is_some)
		{
			return maybe.value;
		}
		Debug.Log("Failed to load file at " + _file_path + ". Setting default values instead");
		return _default_constructor();
	}

	public static T TryLoad<T, T2>(string _file_path, Func<T2, T> _converter, Func<T> _default_constructor)
	{
		Maybe<T2> maybe = LoadData<T2>(_file_path);
		if (maybe.is_some)
		{
			return _converter(maybe.value);
		}
		Debug.Log("Failed to load file at " + _file_path + ". Setting default values instead");
		return _default_constructor();
	}
}
