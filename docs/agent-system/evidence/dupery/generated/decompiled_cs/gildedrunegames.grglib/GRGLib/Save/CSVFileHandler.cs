using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using UnityEngine;

namespace GRGLib.Save;

public static class CSVFileHandler
{
	public static void printToCSV(this List<List<string>> _data, string _file_name, string _path)
	{
		string text = "";
		for (int i = 0; i < _data.Count; i++)
		{
			for (int j = 0; j < _data[i].Count; j++)
			{
				text = text + "\"" + _data[i][j].Replace("\"", "\"\"") + "\"" + ((j == _data[i].Count - 1) ? ((i == _data.Count - 1) ? "" : "\n") : ",");
			}
		}
		FileHandler.writeStringToFile(text, _file_name, _path);
	}

	public static void printToCSV(this Dictionary<string, string> _data, string _file_name, string _path)
	{
		_data.printToCSV(_file_name, _path, "");
	}

	private static void printToCSV(this Dictionary<string, string> _data, string _file_name, string _path, string _to_print)
	{
		foreach (KeyValuePair<string, string> _datum in _data)
		{
			_to_print = _to_print + "\"" + _datum.Key.Replace("\"", "\"\"") + "\",\"" + _datum.Value.Replace("\"", "\"\"") + "\"\n";
		}
		FileHandler.writeStringToFile(_to_print, _file_name, _path);
	}

	public static void printToCSV(this Dictionary<string, (string, string)> _data, string _file_name, string _path)
	{
		_data.printToCSV(_file_name, _path, "");
	}

	private static void printToCSV(this Dictionary<string, (string, string)> _data, string _file_name, string _path, string _to_print)
	{
		foreach (KeyValuePair<string, (string, string)> _datum in _data)
		{
			_to_print = _to_print + "\"" + _datum.Key.Replace("\"", "\"\"") + "\",\"" + _datum.Value.Item1.Replace("\"", "\"\"") + "\",\"" + _datum.Value.Item2.Replace("\"", "\"\"") + "\"\n";
		}
		FileHandler.writeStringToFile(_to_print, _file_name, _path);
	}

	public static void printToCSV(this Dictionary<string, List<string>> _data, string _file_name, string _path)
	{
		_data.printToCSV(_file_name, _path, "");
	}

	private static void printToCSV(this Dictionary<string, List<string>> _data, string _file_name, string _path, string _to_print)
	{
		foreach (KeyValuePair<string, List<string>> _datum in _data)
		{
			_to_print = _to_print + "\"" + _datum.Key.Replace("\"", "\"\"") + "\"" + ((_datum.Value.Count > 0) ? "," : "\n");
			for (int i = 0; i < _datum.Value.Count; i++)
			{
				_to_print = _to_print + "\"" + _datum.Value[i].Replace("\"", "\"\"") + "\"" + ((i == _datum.Value.Count - 1) ? "\n" : ",");
			}
		}
		_to_print.TrimEnd('\n');
		FileHandler.writeStringToFile(_to_print, _file_name, _path);
	}

	public static void printToCSVWithHeader(this Dictionary<string, string> _data, string _file_name, string _path, params string[] _headers)
	{
		_data.printToCSV(_file_name, _path, getHeaderString(_headers));
	}

	public static void printToCSVWithHeader(this Dictionary<string, (string, string)> _data, string _file_name, string _path, params string[] _headers)
	{
		_data.printToCSV(_file_name, _path, getHeaderString(_headers));
	}

	public static void printToCSVWithHeader(this Dictionary<string, List<string>> _data, string _file_name, string _path, params string[] _headers)
	{
		_data.printToCSV(_file_name, _path, getHeaderString(_headers));
	}

	private static string getHeaderString(params string[] _headers)
	{
		string text = "";
		for (int i = 0; i < _headers.Length; i++)
		{
			text = text + "\"" + _headers[i] + "\"" + ((i + 1 == _headers.Length) ? "\n" : ",");
		}
		return text;
	}

	public static List<List<string>> readFromCSV(string _file_path_and_name)
	{
		try
		{
			char[] anyOf = new char[2] { ',', '\n' };
			string text = FileHandler.readFile(_file_path_and_name).Trim();
			bool flag = true;
			int index = -1;
			List<List<string>> list = new List<List<string>>();
			while (text.Length > 1)
			{
				if (flag)
				{
					flag = false;
					list.Add(new List<string>());
					index = list.Count - 1;
				}
				if (text[0] == '"')
				{
					int indexOfNextRealQuote = getIndexOfNextRealQuote(text, 1);
					string item = text.Substring(1, indexOfNextRealQuote - 1).Replace("\"\"", "\"").TrimEnd('\r');
					list[index].Add(item);
					int num = text.IndexOfAny(anyOf, indexOfNextRealQuote + 1);
					if (num == -1)
					{
						return list;
					}
					flag = text[num] == '\n';
					text = text.Substring(num + 1).TrimStart(' ');
					continue;
				}
				int num2 = text.IndexOfAny(anyOf);
				if (num2 == -1)
				{
					if (text.Length > 0)
					{
						list[index].Add(text);
					}
					return list;
				}
				flag = text[num2] == '\n';
				string item2 = text.Substring(0, num2).Replace("\"\"", "\"").TrimEnd('\r');
				list[index].Add(item2);
				text = text.Substring(num2 + 1).TrimStart(' ');
			}
			return list;
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to get data from csv file at {_file_path_and_name}! Error:\n{arg}");
			return new List<List<string>>();
		}
	}

	public static Dictionary<string, string> readFromCSVAsDictionary(string _file_path_and_name, int _value_offset = 0, int _start_offset = 0, bool _add_empty_values = true)
	{
		try
		{
			return convertCSVStringAsDictionary(FileHandler.readFile(_file_path_and_name).Trim(), _value_offset, _start_offset, _add_empty_values);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to get data from csv file at {_file_path_and_name}! Error:\n{arg}");
			return new Dictionary<string, string>();
		}
	}

	public static Dictionary<string, string> readFromCSVAsDictionary(TextAsset _asset, int _value_offset = 0, int _start_offset = 0, bool _add_empty_values = true)
	{
		return convertCSVStringAsDictionary(_asset.text.Trim(), _value_offset, _start_offset, _add_empty_values);
	}

	private static Dictionary<string, string> convertCSVStringAsDictionary(string _csv_data, int _value_offset = 0, int _start_offset = 0, bool _add_empty_values = true)
	{
		try
		{
			char[] anyOf = new char[2] { ',', '\n' };
			string text = _csv_data;
			Maybe<string> maybe = new Maybe<string>();
			int num = 0;
			bool flag = false;
			Dictionary<string, string> dictionary = new Dictionary<string, string>();
			while (text.Length > 1)
			{
				bool num2 = text[0] == '"';
				int num3 = (num2 ? 1 : 0);
				int num4 = (num2 ? getIndexOfNextRealQuote(text, 1) : text.IndexOfAny(anyOf));
				int num5 = (num2 ? text.IndexOfAny(anyOf, num4 + 1) : num4);
				if (!num2 && num4 == -1)
				{
					num4 = text.Length;
				}
				if (_start_offset > 0)
				{
					if (num5 == -1)
					{
						return dictionary;
					}
					if (text[num5] == '\n')
					{
						_start_offset--;
					}
				}
				else if (flag)
				{
					if (num5 == -1)
					{
						return dictionary;
					}
					if (text[num5] == '\n')
					{
						flag = false;
					}
				}
				else if (maybe.is_some)
				{
					if (num == _value_offset)
					{
						string value = text.Substring(num3, num4 - num3).Replace("\"\"", "\"").TrimEnd('\r');
						dictionary[maybe.value] = value;
						if (num5 == -1)
						{
							return dictionary;
						}
						flag = text[num5] != '\n';
						maybe = new Maybe<string>();
					}
					else
					{
						num++;
						if (num5 == -1 || text[num5] == '\n')
						{
							if (_add_empty_values)
							{
								dictionary[maybe.value] = "";
							}
							if (num5 == -1)
							{
								return dictionary;
							}
							maybe = new Maybe<string>();
							flag = false;
						}
					}
				}
				else
				{
					string text2 = text.Substring(num3, num4 - num3).Replace("\"\"", "\"").TrimEnd('\r');
					if (num5 == -1 || text[num5] == '\n')
					{
						if (_add_empty_values)
						{
							dictionary[text2] = "";
						}
						if (num5 == -1)
						{
							return dictionary;
						}
					}
					else
					{
						maybe = text2.maybe();
					}
					num = 0;
				}
				text = text.Substring(num5 + 1).TrimStart(' ');
			}
			return dictionary;
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to get data from csv string! Error:\n{arg}");
			return new Dictionary<string, string>();
		}
	}

	public static Dictionary<string, List<string>> readFullFromCSVAsDictionary(TextAsset _asset)
	{
		return convertCSVStringAsDictionary(_asset.text);
	}

	public static Dictionary<string, List<string>> readFullFromCSVAsDictionary(string _file_path_and_name)
	{
		try
		{
			return convertCSVStringAsDictionary(FileHandler.readFile(_file_path_and_name));
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to get data from csv file at {_file_path_and_name}! Error:\n{arg}");
			return new Dictionary<string, List<string>>();
		}
	}

	private static Dictionary<string, List<string>> convertCSVStringAsDictionary(string _csv_data)
	{
		try
		{
			char[] anyOf = new char[2] { ',', '\n' };
			string text = _csv_data.Trim();
			bool flag = true;
			string key = "";
			Dictionary<string, List<string>> dictionary = new Dictionary<string, List<string>>();
			while (text.Length > 1)
			{
				if (text[0] == '"')
				{
					int indexOfNextRealQuote = getIndexOfNextRealQuote(text, 1);
					string text2 = text.Substring(1, indexOfNextRealQuote - 1).Replace("\"\"", "\"").TrimEnd('\r');
					if (flag)
					{
						key = text2;
						dictionary[key] = new List<string>();
					}
					else
					{
						dictionary[key].Add(text2);
					}
					int num = text.IndexOfAny(anyOf, indexOfNextRealQuote + 1);
					if (num == -1)
					{
						return dictionary;
					}
					flag = text[num] == '\n';
					text = text.Substring(num + 1).TrimStart(' ');
					continue;
				}
				int num2 = text.IndexOfAny(anyOf);
				if (num2 == -1)
				{
					if (text.Length > 0)
					{
						if (flag)
						{
							key = text;
							dictionary[key] = new List<string>();
						}
						else
						{
							dictionary[key].Add(text);
						}
					}
					return dictionary;
				}
				string text3 = text.Substring(0, num2).Replace("\"\"", "\"").TrimEnd('\r');
				if (flag)
				{
					key = text3;
					dictionary[text3] = new List<string>();
				}
				else
				{
					dictionary[key].Add(text3);
				}
				flag = text[num2] == '\n';
				text = text.Substring(num2 + 1).TrimStart(' ');
			}
			return dictionary;
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to read csv data! Error:\n{arg}");
			return new Dictionary<string, List<string>>();
		}
	}

	private static int getIndexOfNextRealQuote(string _text, int _starting_index)
	{
		while (_starting_index < _text.Length)
		{
			int num = _text.IndexOf('"', _starting_index);
			if (num < 0 || _text.Length <= num + 1 || _text[num + 1] != '"')
			{
				return num;
			}
			_starting_index = num + 2;
		}
		return -1;
	}
}
