namespace GRGLocalisation;

public static class GRGLocalisationHelper
{
	public static string options_marker = "{#";

	public static string checkPlural(this string _text, int _nb)
	{
		return _text.checkPlural(_nb == 1);
	}

	public static string checkPlural(this string _text, bool _singular)
	{
		return _text.checkOption(_singular);
	}

	public static string checkOption(this string _text, bool _first_option)
	{
		int num = _text.IndexOf(options_marker);
		if (num == -1)
		{
			return _text;
		}
		int num2 = _text.IndexOf("/", num);
		int num3 = _text.IndexOf("}", num2);
		string text = _text.Substring(0, num);
		string text2 = _text.Substring(num3 + 1);
		if (_first_option)
		{
			if (num2 == num + 1)
			{
				return text + text2;
			}
			return (text + _text.Substring(num + 2, num2 - num - 2) + text2).checkOption(_first_option);
		}
		if (num2 == num3 - 1)
		{
			return text + text2;
		}
		return (text + _text.Substring(num2 + 1, num3 - num2 - 1) + text2).checkOption(_first_option);
	}

	public static string createOption(this string _op_1, string _op_2)
	{
		return "{#" + _op_1 + "/" + _op_2 + "}";
	}

	public static string createTextMarker(int _nb)
	{
		return $"{{{_nb}}}";
	}

	public static Languages getLanguageFromSteam(string _steam_api_language_code)
	{
		return _steam_api_language_code switch
		{
			"english" => Languages.ENGLISH, 
			"arabic" => Languages.ARABIC, 
			"bulgarian" => Languages.BULGARIAN, 
			"schinese" => Languages.CHINESE_SIMPLIFIED, 
			"tchinese" => Languages.CHINESE_TRADITIONAL, 
			"czech" => Languages.CZECH, 
			"danish" => Languages.DANISH, 
			"dutch" => Languages.DUTCH, 
			"finnish" => Languages.FINNISH, 
			"french" => Languages.FRENCH, 
			"german" => Languages.GERMAN, 
			"greek" => Languages.GREEK, 
			"hungarian" => Languages.HUNGARIAN, 
			"indonesian" => Languages.INDONESIAN, 
			"italian" => Languages.ITALIAN, 
			"japanese" => Languages.JAPANESE, 
			"koreana" => Languages.KOREAN, 
			"norwegian" => Languages.NORWEGIAN, 
			"polish" => Languages.POLISH, 
			"portuguese" => Languages.PORTUGUESE, 
			"brazilian" => Languages.PORTUGUESE_BRAZIL, 
			"romanian" => Languages.ROMANIAN, 
			"russian" => Languages.RUSSIAN, 
			"spanish" => Languages.SPANISH, 
			"latam" => Languages.SPANISH_LATIN_AMERICA, 
			"swedish" => Languages.SWEDISH, 
			"thai" => Languages.THAI, 
			"turkish" => Languages.TURKISH, 
			"ukrainian" => Languages.UKRAINIAN, 
			"vietnamese" => Languages.VIETNAMESE, 
			_ => Languages.ENGLISH, 
		};
	}
}
