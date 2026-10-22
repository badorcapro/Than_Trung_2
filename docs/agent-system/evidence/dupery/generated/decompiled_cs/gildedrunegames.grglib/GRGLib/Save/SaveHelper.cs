using System;
using System.IO;
using System.Linq;
using UnityEngine;

namespace GRGLib.Save;

public static class SaveHelper
{
	public enum SaveVersionState
	{
		INVALID,
		UNSAFE,
		SAFE
	}

	public static bool isSaveVersionSafe(string _version_number, string _earliest_safe_verion = "current")
	{
		return getSaveVersionState(_version_number, _earliest_safe_verion, _earliest_safe_verion) == SaveVersionState.SAFE;
	}

	public static bool isSaveVersionInvalid(string _version_number, string _earliest_valid_version = "current")
	{
		return getSaveVersionState(_version_number, _earliest_valid_version) == SaveVersionState.INVALID;
	}

	public static SaveVersionState getSaveVersionState(string _version_number, string _earliest_valid_version = "current", string _earliest_safe_version = "current")
	{
		string text = ((_earliest_valid_version == "current") ? Application.version : _earliest_valid_version);
		string obj = ((_earliest_safe_version == "current") ? Application.version : _earliest_safe_version);
		string[] array = text.Split('.');
		string[] array2 = obj.Split('.');
		string[] array3 = _version_number.Split('.');
		int num = 0;
		bool flag = true;
		string[] array4 = array2;
		for (int i = 0; i < array4.Length; i++)
		{
			int num2 = int.Parse(array4[i]);
			flag = flag && array.Length > num;
			int num3 = (flag ? int.Parse(array[num]) : 0);
			try
			{
				int num4 = int.Parse(array3[num]);
				if (flag && num3 > num4)
				{
					return SaveVersionState.INVALID;
				}
				if (flag && num3 < num4)
				{
					flag = false;
				}
				if (num2 > num4)
				{
					return SaveVersionState.UNSAFE;
				}
				if (num2 < num4)
				{
					return SaveVersionState.SAFE;
				}
			}
			catch (Exception)
			{
				return (!flag) ? SaveVersionState.UNSAFE : SaveVersionState.INVALID;
			}
			num++;
		}
		return SaveVersionState.SAFE;
	}

	public static bool isSaveSafe<T>(this SaveFile<T> _save_file, string _earliest_safe_verion = "current")
	{
		return isSaveVersionSafe(_save_file.version, _earliest_safe_verion);
	}

	public static bool isSaveInvalid<T>(this SaveFile<T> _save_file, string _earliest_valid_version = "current")
	{
		return isSaveVersionInvalid(_save_file.version, _earliest_valid_version);
	}

	public static SaveVersionState getSaveVersionState<T>(this SaveFile<T> _save_file, string _earliest_valid_version = "current", string _earliest_safe_version = "current")
	{
		return getSaveVersionState(_save_file.version, _earliest_valid_version, _earliest_safe_version);
	}

	public static string getNextFileName(string _path, string _file_name_base, string _extension, bool _persistent_data = true)
	{
		return getNextFileName(FileHandler.getFilesInDirectory(_path, _extension, _return_full_path: false, _persistent_data), _file_name_base, _extension);
	}

	public static string getNextFileName(string[] _current_save_file_names, string _file_name_base, string _extension)
	{
		int num = 0;
		string text = _file_name_base + num;
		while (_current_save_file_names.Contains(text + _extension))
		{
			text = _file_name_base + num;
			num++;
		}
		return text + _extension;
	}

	public static string readUntil(StreamReader _reader, string _read_until)
	{
		string text = "";
		int length = _read_until.Length;
		int num = _reader.Read();
		while (num != -1 && text.Length < length)
		{
			text += (char)num;
			num = _reader.Read();
		}
		while (num != -1)
		{
			text += (char)num;
			if (text.Substring(text.Length - length, length) == _read_until)
			{
				return text;
			}
			num = _reader.Read();
		}
		return text;
	}
}
