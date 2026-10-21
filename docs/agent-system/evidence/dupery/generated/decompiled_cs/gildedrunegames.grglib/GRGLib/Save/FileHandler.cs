using System;
using System.IO;
using System.Linq;
using UnityEngine;

namespace GRGLib.Save;

public static class FileHandler
{
	public static bool deleteAllFilesInSaveFolder(string _folder, bool _recursive = true)
	{
		string text = Application.persistentDataPath + "/" + _folder;
		if (!Directory.Exists(text))
		{
			return true;
		}
		try
		{
			Directory.Delete(text, _recursive);
			return true;
		}
		catch (Exception arg)
		{
			Debug.Log($"Failed to delete directory at path: {text}. Due to error: {arg}");
			return false;
		}
	}

	public static bool deleteAllFilesInSetFolder(string _folder, bool _recursive = true)
	{
		if (!Directory.Exists(_folder))
		{
			return true;
		}
		try
		{
			Directory.Delete(_folder, _recursive);
			return true;
		}
		catch (Exception arg)
		{
			Debug.Log($"Failed to delete directory at path: {_folder}. Due to error: {arg}");
			return false;
		}
	}

	public static bool deleteFile(string _file_name, string _path = "", bool _persistent_data = true)
	{
		string text = (_persistent_data ? (Application.persistentDataPath + "/") : "") + _path + _file_name;
		if (!File.Exists(text))
		{
			Debug.Log("Trying to delete a file that does not exists! File " + text);
			return false;
		}
		File.Delete(text);
		return true;
	}

	public static string[] getFilesInDirectory(string _path, string _extension, bool _return_full_path = true, bool _persistent_data = true)
	{
		string directory_path = (_persistent_data ? (Application.persistentDataPath + "/") : "") + _path;
		if (!Directory.Exists(directory_path))
		{
			return new string[0];
		}
		string[] files = Directory.GetFiles(directory_path, "*" + _extension);
		if (_return_full_path)
		{
			return files;
		}
		return files.Select((string _path) => _path.Replace(directory_path, "")).ToArray();
	}

	public static void writeStringToFile(string _to_write, string _file_name, string _path)
	{
		try
		{
			Directory.CreateDirectory(_path);
			using (StreamWriter streamWriter = new StreamWriter(File.Create(_path + _file_name)))
			{
				streamWriter.Write(_to_write);
			}
			Debug.Log("Wrote String to file " + _path + _file_name);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Something went wrong when writing string to file! {arg}");
		}
	}

	public static string readFile(string _file_path_and_name)
	{
		if (!File.Exists(_file_path_and_name))
		{
			return "";
		}
		try
		{
			using StreamReader streamReader = new StreamReader(_file_path_and_name);
			return streamReader.ReadToEnd();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to read file: {_file_path_and_name} due to error: {arg}");
			return "";
		}
	}
}
