using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using GRGLib.Coroutines;
using GRGLib.Extensions;
using GRGLib.Extensions.Collections;
using GRGLib.Generic;
using GRGLib.Maybe;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;

public static class StaticHelper
{
	private static float resolution_ratio => (float)Screen.width / (float)Screen.height;

	private static float comparative_resolution_ratio => resolution_ratio / 1.7777778f;

	public static Vector2 ui_ratio
	{
		get
		{
			if (comparative_resolution_ratio > 1.005f)
			{
				float num = 1f / comparative_resolution_ratio;
				return new Vector2((float)Screen.width * num, Screen.height);
			}
			if (comparative_resolution_ratio < 0.995f)
			{
				float num2 = comparative_resolution_ratio;
				return new Vector2(Screen.width, (float)Screen.height * num2);
			}
			return new Vector2(Screen.width, Screen.height);
		}
	}

	public static bool isUsingGamepad(this PlayerInput _player_input)
	{
		return _player_input.currentControlScheme.equalToAny("Gamepad", "SwitchGamepad");
	}

	public static void openUrl(this string _url)
	{
		Application.OpenURL(_url);
	}

	public static List<int> fromStringCommaSeperate(this string _string)
	{
		if (_string == "")
		{
			return new List<int>();
		}
		try
		{
			return (from _n in _string.Split(",")
				where _n != ""
				select int.Parse(_n)).ToList();
		}
		catch (Exception)
		{
			Debug.LogError("Failed to get string from comma seperated values!");
			return new List<int>();
		}
	}

	public static string toStringCommaSeperated(this List<int> _list)
	{
		string text = "";
		foreach (int item in _list)
		{
			text = text + item + ",";
		}
		if (text.Length > 0)
		{
			text.Substring(0, text.Length - 1);
		}
		return text;
	}

	public static string getOrdinalSuffix(this int _int)
	{
		if (!new List<int> { 11, 12, 13 }.Contains(_int % 100))
		{
			return new List<string> { "th", "st", "nd", "rd", "th", "th", "th", "th", "th", "th" }[_int % 10];
		}
		return "th";
	}

	public static Regions fromType(this CaseType _type)
	{
		return _type switch
		{
			CaseType.CLOCK => Regions.OFFICE, 
			CaseType.DOCKS => Regions.DOCKS, 
			CaseType.CASINO => Regions.CASINO, 
			CaseType.BACK_ALLEYS => Regions.BACK_ALLEYS, 
			_ => throw new ArgumentException($"No region set for case type {_type}!"), 
		};
	}

	public static CaseType fromRegion(this Regions _type)
	{
		return _type switch
		{
			Regions.OFFICE => CaseType.CLOCK, 
			Regions.DOCKS => CaseType.DOCKS, 
			Regions.CASINO => CaseType.CASINO, 
			Regions.BACK_ALLEYS => CaseType.BACK_ALLEYS, 
			_ => throw new ArgumentException($"No region set for case type {_type}!"), 
		};
	}

	public static Maybe<(T, int)> getMaxFiltered<T>(this Dictionary<T, int> _dict, Func<T, bool> _filter)
	{
		return _dict.where((T _k, int _v) => _filter(_k)).getMax();
	}

	public static bool inRange(this MinMaxInt _min_max, int _value)
	{
		if (_value >= _min_max.min)
		{
			return _value <= _min_max.max;
		}
		return false;
	}

	public static IEnumerator rotateTransformToSmartMovingTarget(this Transform _trans, Func<float> _target, float _duration, Func<float, float> _ease)
	{
		return _trans.rotateTransformToSmartMovingTarget(_target, _duration, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator rotateTransformToSmartMovingTarget(this Transform _trans, Func<float> _target, float _duration, Func<float, float> _ease, Func<float> _delta_time)
	{
		float starting_angle;
		for (starting_angle = _trans.localEulerAngles.z; starting_angle > 180f; starting_angle -= 360f)
		{
		}
		for (; starting_angle < -180f; starting_angle += 360f)
		{
		}
		float e = 0f;
		while (e < _duration)
		{
			float num = _target() - starting_angle;
			_trans.localRotation = Quaternion.Euler(0f, 0f, starting_angle + num * _ease(e / _duration));
			e += _delta_time();
			yield return null;
		}
		_trans.localRotation = Quaternion.Euler(0f, 0f, _target());
	}

	public static List<int> addUntil(this List<int> _list, int _start, int _end, bool _inclusive_end = true)
	{
		for (int i = _start; i < _end; i++)
		{
			_list.Add(i);
		}
		if (_inclusive_end)
		{
			_list.Add(_end);
		}
		return _list;
	}

	public static List<T> addAll<T>(this List<T> _l, Func<T, bool> _condition) where T : Enum
	{
		foreach (T value in Enum.GetValues(typeof(T)))
		{
			if (_condition(value))
			{
				_l.Add(value);
			}
		}
		return _l;
	}

	public static List<T> removeFirst<T>(this List<T> _l, Predicate<T> _predicate)
	{
		for (int i = 0; i < _l.Count; i++)
		{
			if (_predicate(_l[i]))
			{
				return _l.remove(_l[i]);
			}
		}
		return _l;
	}

	public static List<T2> whereSelect<T, T2>(this List<T> _l, Predicate<T> _predicate, Func<T, T2> _select)
	{
		return _l.Aggregate(new List<T2>(), (List<T2> _a, T _e) => (!_predicate(_e)) ? _a : _a.add(_select(_e)));
	}

	public static Selectable setSelectedColour(this Selectable _selectable, Color _colour)
	{
		ColorBlock colors = _selectable.colors;
		colors.selectedColor = _colour;
		_selectable.colors = colors;
		return _selectable;
	}

	public static Maybe<T> firstIfSome<T>(this List<T> _l, Predicate<T> _predicate)
	{
		for (int i = 0; i < _l.Count; i++)
		{
			if (_predicate(_l[i]))
			{
				return _l[i].maybe();
			}
		}
		return new Maybe<T>();
	}

	public static Dictionary<T3, T2> keySelect<T, T2, T3>(this Dictionary<T, T2> _dict, Func<T, T3> _select)
	{
		Dictionary<T3, T2> dictionary = new Dictionary<T3, T2>();
		foreach (KeyValuePair<T, T2> item in _dict)
		{
			dictionary[_select(item.Key)] = item.Value;
		}
		return dictionary;
	}

	public static string removeCommonRichTextTags(this string _text)
	{
		return _text.removeTags("<", ">", true, "color", "b", "i", "link");
	}

	public static string removeTags(this string _text, string _tag_start, string _tag_end, bool _check_end_tag, params string[] _tags)
	{
		string text = _text;
		int num = text.IndexOf(_tag_start);
		if (num == -1)
		{
			return text;
		}
		int length = _tag_start.Length;
		int length2 = _tag_end.Length;
		int num2 = text.IndexOf(_tag_end, num);
		while (num >= 0 && num2 > num)
		{
			string check_tag = text.Substring(num + length, num2 - num - length);
			string add_start = ((!_check_end_tag) ? "" : ((check_tag[0] == '/') ? "/" : ""));
			if (_tags.Any((string _t) => check_tag.StartsWith(add_start + _t)))
			{
				text = text.Substring(0, num) + text.Substring(num2 + length2);
				num = 0;
			}
			num = text.IndexOf(_tag_start, num + 1);
			num2 = text.IndexOf(_tag_end, num + 1);
		}
		return text;
	}

	public static string replaceTags(this string _text, string _tag_start, string _tag_end, Func<string, string, string> _replace_func, params (string, string)[] _tags)
	{
		List<(string, string)> l = _tags.ToList();
		string text = _text;
		int num = text.IndexOf(_tag_start);
		if (num == -1)
		{
			return text;
		}
		int length = _tag_start.Length;
		int length2 = _tag_end.Length;
		int num2 = text.IndexOf(_tag_end, num);
		while (num >= 0 && num2 > num)
		{
			string check_tag = text.Substring(num + length, num2 - num - length);
			Maybe<(string, string)> maybe = l.firstIfSome(((string, string) _t) => check_tag.StartsWith(_t.Item1));
			if (maybe.is_some)
			{
				try
				{
					string arg = text.Substring(num + length, num2 - num - length);
					if (maybe.value.Item2 == "")
					{
						text = text.Substring(0, num) + _replace_func("", arg) + text.Substring(num2 + length2);
					}
					else
					{
						int num3 = text.IndexOf(_tag_start + maybe.value.Item2, num2);
						int num4 = text.IndexOf(_tag_end, num3);
						string arg2 = text.Substring(num2 + length2, num3 - num2 - length2);
						text = text.Substring(0, num) + _replace_func(arg2, arg) + text.Substring(num4 + length2);
					}
					num = 0;
				}
				catch (Exception arg3)
				{
					Debug.LogError($"Tag found but failed to parse end section! {maybe.value}\nError: {arg3}");
					text = text.Substring(0, num) + text.Substring(num + check_tag.Length + 2);
				}
			}
			num = text.IndexOf(_tag_start, num + 1);
			num2 = text.IndexOf(_tag_end, num + 1);
		}
		return text;
	}

	public static string[] getFilesInDirectory(string _path, string _extension, bool _return_full_path = true, bool _recursive = true, bool _persistent_data = true)
	{
		string directory_path = (_persistent_data ? (Application.persistentDataPath + "/") : "") + _path;
		if (!Directory.Exists(directory_path))
		{
			return new string[0];
		}
		string[] files = Directory.GetFiles(directory_path, "*" + _extension, _recursive ? SearchOption.AllDirectories : SearchOption.TopDirectoryOnly);
		if (_return_full_path)
		{
			return files;
		}
		return files.Select((string _path) => _path.Replace(directory_path, "")).ToArray();
	}
}
