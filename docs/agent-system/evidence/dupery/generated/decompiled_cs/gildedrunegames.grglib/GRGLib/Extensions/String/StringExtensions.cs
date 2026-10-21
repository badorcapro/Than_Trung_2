using System.Linq;
using GRGLib.Maybe;
using UnityEngine;

namespace GRGLib.Extensions.String;

public static class StringExtensions
{
	public static string sizeRelative(this string _content, int _size_percent)
	{
		return _content.sandwichString($"<size={_size_percent}%>", "</size>");
	}

	public static string sizeAbsolute(this string _content, int _size_percent)
	{
		return _content.sandwichString($"<size={_size_percent}>", "</size>");
	}

	public static string bold(this string _string)
	{
		return _string.sandwichString("<b>", "</b>");
	}

	public static string italics(this string _string)
	{
		return _string.sandwichString("<i>", "</i>");
	}

	public static string underline(this string _string)
	{
		return _string.sandwichString("<u>", "</u>");
	}

	public static string strikethrough(this string _string)
	{
		return _string.sandwichString("<s>", "</s>");
	}

	public static string colour(this string _string, Color _colour)
	{
		return _string.sandwichString(_colour.toStringMarker(), "</color>");
	}

	public static string alpha(this string _string, float _alpha)
	{
		return _string.sandwichString(_alpha.toStringAlphaMarker(), "</alpha>");
	}

	public static string link(this string _string, string _link)
	{
		return _string.sandwichString($"<link={'"'}{_link}{'"'}>", "</link>");
	}

	public static string waitLink(this float _time)
	{
		return "<link=\"T_Wait{" + _time + "}\">\u200b</link>";
	}

	public static string spriteLink(this string _sprite_name)
	{
		return "<sprite name=\"" + _sprite_name + "\">";
	}

	public static string spriteLink(this string _sprite_name, Color _colour)
	{
		return "<sprite name=\"" + _sprite_name + "\" color=" + ColorUtility.ToHtmlStringRGBA(_colour) + ">";
	}

	public static string firstToUpper(this string _string)
	{
		return char.ToUpper(_string[0]) + _string.Substring(1);
	}

	public static bool isCharDigit(this char _char)
	{
		return char.IsDigit(_char);
	}

	public static bool isStringNumber(this string _string, bool _include_plus_minus_first_char = true)
	{
		if (_string.Length == 0)
		{
			return false;
		}
		if (!_string[0].isCharDigit() && (!_include_plus_minus_first_char || !_string[0].equalToAny('-', '+')))
		{
			return false;
		}
		for (int i = 1; i < _string.Length; i++)
		{
			if (!_string[i].isCharDigit())
			{
				return false;
			}
		}
		return true;
	}

	public static string removeFromEnd(this string _string, int _cut_size)
	{
		return _string.Substring(0, _string.Length - _cut_size);
	}

	public static string untilSubstring(this string _string, string _sub)
	{
		if (!_string.Contains(_sub))
		{
			return _string;
		}
		return _string.Substring(0, _string.IndexOf(_sub));
	}

	public static string removeUntilSubstring(this string _string, string _sub, bool _include_sub = false)
	{
		if (!_string.Contains(_sub))
		{
			return "";
		}
		return _string.Substring(_string.IndexOf(_sub) + ((!_include_sub) ? _sub.Length : 0));
	}

	public static string removeAllBetween(this string _text, string _start, string _end)
	{
		int length = _end.Length;
		string text = _text;
		int num = text.IndexOf(_start);
		int num2 = text.IndexOf(_end);
		while (num > 0 && num2 > num)
		{
			text = text.Substring(0, num) + text.Substring(num2 + length);
			num = text.IndexOf(_start);
			num2 = text.IndexOf(_end);
		}
		return text;
	}

	public static string removeRichTextTags(this string _text, params string[] _tags)
	{
		return _text.removeTags("<", ">", '/'.maybe(), _tags);
	}

	public static string removeTags(this string _text, string _tag_start, string _tag_end, Maybe<char> _check_end_tags, params string[] _tags)
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
			string add_start = ((!_check_end_tags.is_some) ? "" : ((check_tag[0] == _check_end_tags.value) ? _check_end_tags.value.ToString() : ""));
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

	public static string addPlusSignIfPositive(this int _number)
	{
		if (_number <= 0)
		{
			return _number.ToString();
		}
		return $"+{_number}";
	}

	public static string addPlusSignIfPositive(this float _number)
	{
		if (!(_number > 0f))
		{
			return _number.ToString();
		}
		return $"+{_number}";
	}

	public static string toLowerButFirst(this string _string)
	{
		return _string[0] + _string.ToLower().Substring(1);
	}

	public static string addLeading0If1Digit(int _value)
	{
		if (_value < 10)
		{
			return "0" + _value;
		}
		return _value.ToString();
	}

	public static string blingify(this string _string)
	{
		return _string.Replace("S", "$").Replace("s", "$");
	}

	public static string toStringMarker(this Color _colour)
	{
		return "<color=#" + ColorUtility.ToHtmlStringRGBA(_colour) + ">";
	}

	public static string toStringAlphaMarker(this float _alpha)
	{
		return "<alpha=#" + Mathf.RoundToInt(_alpha * 255f).ToString("X") + ">";
	}

	public static string sandwichString(this string _orginal, string _left, string _right)
	{
		return _left + _orginal + _right;
	}

	public static string sandwichString(this string _orginal, (string, string) _data)
	{
		return _orginal.sandwichString(_data.Item1, _data.Item2);
	}

	public static string sandwichWithColour(this string _text, Color _colour)
	{
		return _text.sandwichString(_colour.toStringMarker(), "</color>");
	}

	public static string sandwitchWithColourIfSome(this string _string, Maybe<Color> _colour)
	{
		if (!_colour.is_some)
		{
			return _string;
		}
		return _string.sandwichWithColour(_colour.value);
	}

	public static string toTime(this double _time_in_seconds, int _decimals = 2, bool _show_hours = true, bool _show_minutes = true)
	{
		return _time_in_seconds.toTime(_decimals, _show_hours, _show_minutes);
	}

	public static string toTime(this float _time_in_seconds, int _decimals = 2, bool _show_hours = true, bool _show_minutes = true)
	{
		int num = Mathf.FloorToInt(_time_in_seconds);
		string text;
		if (_show_minutes)
		{
			int num2 = Mathf.FloorToInt(num / 60);
			if (_show_hours)
			{
				int value = Mathf.FloorToInt(num2 / 60);
				text = addLeading0If1Digit(value) + ":" + addLeading0If1Digit(num2 % 60) + ":" + addLeading0If1Digit(num % 60);
			}
			else
			{
				text = addLeading0If1Digit(num2) + ":" + addLeading0If1Digit(num % 60);
			}
		}
		else
		{
			text = addLeading0If1Digit(num);
		}
		if (_decimals <= 0)
		{
			return text;
		}
		float num3 = _time_in_seconds - (float)num;
		text += ".";
		for (int i = 0; i < _decimals; i++)
		{
			num3 *= 10f;
			int num4 = Mathf.FloorToInt(num3);
			text += num4;
			num3 -= (float)num4;
		}
		return text;
	}
}
