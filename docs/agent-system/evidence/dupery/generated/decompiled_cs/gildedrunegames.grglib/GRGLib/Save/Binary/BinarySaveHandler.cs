using System;
using System.Collections.Generic;
using System.IO;
using System.Runtime.Serialization.Formatters.Binary;
using GRGLib.Maybe;
using UnityEngine;

namespace GRGLib.Save.Binary;

public static class BinarySaveHandler
{
	public static string getSaveVersionOfFile<T>(string _file_path_and_name)
	{
		return getSaveVersionOfSetFile<T>(Application.persistentDataPath + "/" + _file_path_and_name);
	}

	public static string getSaveVersionOfSetFile<T>(string _file_path_and_name)
	{
		if (!File.Exists(_file_path_and_name))
		{
			return "";
		}
		try
		{
			BinaryFormatter binaryFormatter = new BinaryFormatter();
			FileStream fileStream = File.Open(_file_path_and_name, FileMode.Open);
			SaveFile<T> obj = (SaveFile<T>)binaryFormatter.Deserialize(fileStream);
			fileStream.Close();
			return obj.version;
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
			BinaryFormatter binaryFormatter = new BinaryFormatter();
			FileStream fileStream = File.Create(_path_to_save + _file_name);
			if (_use_save_file)
			{
				binaryFormatter.Serialize(fileStream, new SaveFile<T>(_data));
			}
			else
			{
				binaryFormatter.Serialize(fileStream, _data);
			}
			fileStream.Close();
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

	public static Maybe<T> LoadDataFromSetFolder<T>(string _file_path_and_name, bool _used_save_file = true)
	{
		if (!File.Exists(_file_path_and_name))
		{
			return new Maybe<T>();
		}
		try
		{
			BinaryFormatter binaryFormatter = new BinaryFormatter();
			FileStream fileStream = File.Open(_file_path_and_name, FileMode.Open);
			SaveFile<T> obj = (SaveFile<T>)binaryFormatter.Deserialize(fileStream);
			fileStream.Close();
			return obj.data.maybe();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load save file: {_file_path_and_name} due to error: {arg}");
			return new Maybe<T>();
		}
	}

	public static Maybe<(T, string)> LoadDataWithVersion<T>(string _file_path_and_name)
	{
		return LoadDataWithVersionFromSetFolder<T>(Application.persistentDataPath + "/" + _file_path_and_name);
	}

	public static Maybe<(T, string)> LoadDataWithVersionFromSetFolder<T>(string _file_path_and_name)
	{
		if (!File.Exists(_file_path_and_name))
		{
			return new Maybe<(T, string)>();
		}
		try
		{
			BinaryFormatter binaryFormatter = new BinaryFormatter();
			FileStream fileStream = File.Open(_file_path_and_name, FileMode.Open);
			SaveFile<T> saveFile = (SaveFile<T>)binaryFormatter.Deserialize(fileStream);
			fileStream.Close();
			return (saveFile.data, saveFile.version).maybe();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load save file: {_file_path_and_name} due to error: {arg}");
			return new Maybe<(T, string)>();
		}
	}

	public static List<T> LoadAllData<T>(string _path, string _extension)
	{
		return LoadAllFromSetFolderData<T>(Application.persistentDataPath + "/" + _path, _extension);
	}

	public static List<T> LoadAllFromSetFolderData<T>(string _path, string _extension)
	{
		if (!Directory.Exists(_path))
		{
			return new List<T>();
		}
		try
		{
			List<T> list = new List<T>();
			string[] files = Directory.GetFiles(_path, "*" + _extension);
			BinaryFormatter binaryFormatter = new BinaryFormatter();
			string[] array = files;
			for (int i = 0; i < array.Length; i++)
			{
				FileStream fileStream = File.Open(array[i], FileMode.Open);
				SaveFile<T> saveFile = (SaveFile<T>)binaryFormatter.Deserialize(fileStream);
				fileStream.Close();
				list.Add(saveFile.data);
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

	public static T Deserialize<T>(byte[] _data)
	{
		using MemoryStream serializationStream = new MemoryStream(_data);
		return (T)new BinaryFormatter().Deserialize(serializationStream);
	}
}
