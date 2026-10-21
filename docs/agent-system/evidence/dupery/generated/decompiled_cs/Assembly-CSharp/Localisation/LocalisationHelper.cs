using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.String;
using GRGLocalisation;
using UnityEngine;

namespace Localisation;

public static class LocalisationHelper
{
	public enum LanguageSettings
	{
		DEFAULT = -1,
		ENGLISH,
		CHINESE_SIMPLIFIED,
		CHINESE_TRADITIONAL,
		JAPANESE,
		KOREAN,
		THAI,
		FRENCH,
		GERMAN,
		SPANISH,
		RUSSIAN,
		PORTUGUESE_BRAZIL
	}

	public static string options_marker = "{#";

	public static string text_marker_1 => "{1}";

	public static string text_marker_2 => "{2}";

	public static string text_marker_3 => "{3}";

	public static string text_marker_4 => "{4}";

	public static LanguageKey english_key => new LanguageKey(Languages.ENGLISH);

	public static AssetKey ui_asset => new AssetKey(0);

	public static AssetKey innocent_role_asset => new AssetKey(0);

	public static AssetKey meddler_role_asset => new AssetKey(0);

	public static AssetKey underling_role_asset => new AssetKey(0);

	public static AssetKey traitor_role_asset => new AssetKey(0);

	public static AssetKey quirk_asset => new AssetKey(0);

	public static AssetKey general_case_asset => new AssetKey(0);

	public static AssetKey misc_asset => new AssetKey(0);

	public static AssetKey stories_asset => new AssetKey(0);

	public static AssetKey lineup_asset => new AssetKey(0);

	public static Languages toLanguage(this LanguageSettings _language)
	{
		return _language switch
		{
			LanguageSettings.DEFAULT => getLanguageFromSteamIfSupported(), 
			LanguageSettings.ENGLISH => Languages.ENGLISH, 
			LanguageSettings.CHINESE_SIMPLIFIED => Languages.CHINESE_SIMPLIFIED, 
			LanguageSettings.CHINESE_TRADITIONAL => Languages.CHINESE_TRADITIONAL, 
			LanguageSettings.THAI => Languages.THAI, 
			LanguageSettings.JAPANESE => Languages.JAPANESE, 
			LanguageSettings.KOREAN => Languages.KOREAN, 
			LanguageSettings.FRENCH => Languages.FRENCH, 
			LanguageSettings.GERMAN => Languages.GERMAN, 
			LanguageSettings.SPANISH => Languages.SPANISH, 
			LanguageSettings.RUSSIAN => Languages.RUSSIAN, 
			LanguageSettings.PORTUGUESE_BRAZIL => Languages.PORTUGUESE_BRAZIL, 
			_ => throw new ArgumentException($"No language set up for settings language {_language}!"), 
		};
	}

	public static LanguageSettings toSetting(this LanguageKey _key)
	{
		return ((Languages)_key).toSetting();
	}

	public static LanguageSettings toSetting(this Languages _language)
	{
		return _language switch
		{
			Languages.ENGLISH => LanguageSettings.ENGLISH, 
			Languages.CHINESE_SIMPLIFIED => LanguageSettings.CHINESE_SIMPLIFIED, 
			Languages.CHINESE_TRADITIONAL => LanguageSettings.CHINESE_TRADITIONAL, 
			Languages.THAI => LanguageSettings.THAI, 
			Languages.JAPANESE => LanguageSettings.JAPANESE, 
			Languages.KOREAN => LanguageSettings.KOREAN, 
			Languages.FRENCH => LanguageSettings.FRENCH, 
			Languages.SPANISH => LanguageSettings.SPANISH, 
			Languages.GERMAN => LanguageSettings.GERMAN, 
			Languages.RUSSIAN => LanguageSettings.RUSSIAN, 
			Languages.PORTUGUESE_BRAZIL => LanguageSettings.PORTUGUESE_BRAZIL, 
			_ => throw new ArgumentException($"No settings language set up for language {_language}!"), 
		};
	}

	public static bool isSupported(this LanguageKey _key)
	{
		return ((Languages)_key).isSupported();
	}

	public static bool isSupported(this Languages _language)
	{
		return _language switch
		{
			Languages.ENGLISH => true, 
			Languages.CHINESE_SIMPLIFIED => true, 
			Languages.CHINESE_TRADITIONAL => true, 
			Languages.JAPANESE => true, 
			Languages.KOREAN => true, 
			Languages.THAI => true, 
			Languages.FRENCH => true, 
			Languages.GERMAN => true, 
			Languages.SPANISH => true, 
			Languages.RUSSIAN => true, 
			Languages.PORTUGUESE_BRAZIL => true, 
			_ => false, 
		};
	}

	public static bool reverseInputActionWord()
	{
		return GRGLocalisationHandler.instance.current_language == Languages.JAPANESE;
	}

	public static char getQuotationMark(bool _start)
	{
		Languages languages = GRGLocalisationHandler.instance.current_language;
		switch (languages)
		{
		case Languages.ENGLISH:
		case Languages.KOREAN:
		case Languages.THAI:
			return '"';
		case Languages.CHINESE_SIMPLIFIED:
			if (!_start)
			{
				return '”';
			}
			return '“';
		case Languages.CHINESE_TRADITIONAL:
		case Languages.JAPANESE:
			if (!_start)
			{
				return '」';
			}
			return '「';
		default:
			Debug.LogError($"Could not find quotation marks for language {languages}!");
			return '"';
		}
	}

	public static string inQuotes(this string _string)
	{
		return getQuotationMark(_start: true) + _string + getQuotationMark(_start: false);
	}

	public static AssetKey defaultRoleAsset()
	{
		return general_case_asset;
	}

	public static AssetKey getAssetForRole(this RoleData _data)
	{
		return _data.role.getClassificationFromRoleType().getAssetForRole();
	}

	public static AssetKey getAssetForRole(this RoleClassifications _classification)
	{
		return _classification switch
		{
			RoleClassifications.INNOCENT => innocent_role_asset, 
			RoleClassifications.MEDDLER => meddler_role_asset, 
			RoleClassifications.UNDERLING => underling_role_asset, 
			RoleClassifications.TRAITOR => traitor_role_asset, 
			_ => throw new ArgumentException($"No asset set up for classification {_classification}!"), 
		};
	}

	public static string getLocNameKey(this RoleData _role)
	{
		return $"{_role.role} [name]";
	}

	public static string getLocDescriptionKey(this RoleData _role)
	{
		return $"{_role.role} [desc]";
	}

	public static string getLocExtraDescriptionKey(this RoleData _role)
	{
		return $"{_role.role} [extra]";
	}

	public static string getLocExtraDescriptionKey(this RoleData _role, DescriptionType _type, int _id)
	{
		return string.Format("{0} [{1}{2}]", _role.role, toLocKeyPart(_type), (_id > 0) ? $"_{_id}" : "");
	}

	private static string toLocKeyPart(DescriptionType _type)
	{
		return _type switch
		{
			DescriptionType.MAIN => "edesc", 
			DescriptionType.LYING_OR_TAINTED => "elie", 
			DescriptionType.SPECIAL => "espe", 
			_ => $"e{_type}", 
		};
	}

	public static string getLocNameKey(this LocationData _location)
	{
		return $"{_location.location_type} [name]";
	}

	public static string getLocDescriptionKey(this LocationData _location)
	{
		return $"{_location.location_type} [desc]";
	}

	public static string getLocNameKey(this Keywords _keyword)
	{
		return $"{_keyword} [name]";
	}

	public static string getLocDescriptionKey(this Keywords _keyword)
	{
		return $"{_keyword} [desc]";
	}

	public static string getLocNameKey(this RoleClassifications _class)
	{
		return $"{_class} [name]";
	}

	public static string getLocDescriptionKey(this RoleClassifications _class)
	{
		return $"{_class} [desc]";
	}

	public static string getLocNameKey(this Alignments _alignment)
	{
		return $"{_alignment} [name]";
	}

	public static string getLocDescriptionKey(this Alignments _alignment)
	{
		return $"{_alignment} [desc]";
	}

	public static string getLocNameKey(this ReputationStatus _status)
	{
		return $"{_status} [name]";
	}

	public static string getLocNameKey(this BackAlleysItemColour _colour)
	{
		return $"{_colour} [name]";
	}

	public static string checkRoleTranslation(this RoleData _role, string _key, Func<string> _english, bool _check_keywords = true)
	{
		return _role.localisation_asset.checkTranslation(_key, _english, _check_keywords);
	}

	public static string checkTranslation(this AssetKey _localisation_asset, string _key, Func<string> _english, bool _check_keywords = true)
	{
		if (GRGLocalisationHandler.needs_translation)
		{
			string _result = "";
			if (GRGLocalisationHandler.instance.translate(_localisation_asset, _key, out _result))
			{
				if (_check_keywords)
				{
					return _result.checkKeywordLocMarkers();
				}
				return _result;
			}
			Debug.LogError($"Something went wrong with the localisation of:  Key: {_key} || Asset: {_localisation_asset} ||| Setting english as backup.");
		}
		return _english();
	}

	public static string checkRoleTranslationWithData(this RoleData _role, string _key, Func<string, string> _english, int _replace, bool _check_keywords = true)
	{
		return _role.localisation_asset.checkTranslationWithData(_key, _english, _replace.ToString(), _check_keywords);
	}

	public static string checkTranslationWithData(this AssetKey _localisation_asset, string _key, Func<string, string> _english, int _replace, bool _check_keywords = true)
	{
		return _localisation_asset.checkTranslationWithData(_key, _english, _replace.ToString(), _check_keywords);
	}

	public static string checkRoleTranslationWithData(this RoleData _role, string _key, Func<string, string> _english, string _replace, bool _check_keywords = true)
	{
		return _role.localisation_asset.checkTranslationWithData(_key, _english, _replace, _check_keywords);
	}

	public static string checkTranslationWithData(this AssetKey _localisation_asset, string _key, Func<string, string> _english, string _replace, bool _check_keywords = true)
	{
		if (GRGLocalisationHandler.needs_translation)
		{
			if (GRGLocalisationHandler.instance.translateAndReplace(_localisation_asset, _key, out var _result, _replace))
			{
				if (_check_keywords)
				{
					return _result.checkKeywordLocMarkers();
				}
				return _result;
			}
			Debug.LogError($"Something went wrong with the localisation of:  Key: {_key} || Asset: {_localisation_asset} ||| Setting english as backup.");
		}
		return _english(_replace);
	}

	public static string checkTranslationWithData(this AssetKey _localisation_asset, string _key, Func<string, string, string> _english, string _replace_1, string _replace_2, bool _check_keywords = true)
	{
		if (GRGLocalisationHandler.needs_translation)
		{
			if (GRGLocalisationHandler.instance.translateAndReplace(_localisation_asset, _key, out var _result, _replace_1, _replace_2))
			{
				if (_check_keywords)
				{
					return _result.checkKeywordLocMarkers();
				}
				return _result;
			}
			Debug.LogError($"Something went wrong with the localisation of:  Key: {_key} || Asset: {_localisation_asset} ||| Setting english as backup.");
		}
		return _english(_replace_1, _replace_2);
	}

	public static string checkRoleTranslationWithReplace(this RoleData _role, string _key, Func<string> _english, bool _check_keywords, params int[] _replace)
	{
		return _role.localisation_asset.checkTranslationWithReplace(_key, _english, _check_keywords, ((IEnumerable<int>)_replace).Select((Func<int, Func<string>>)((int _r) => () => _r.ToString())).ToArray());
	}

	public static string checkTranslationWithReplace(this AssetKey _localisation_asset, string _key, Func<string> _english, bool _check_keywords, params int[] _replace)
	{
		return _localisation_asset.checkTranslationWithReplace(_key, _english, _check_keywords, ((IEnumerable<int>)_replace).Select((Func<int, Func<string>>)((int _r) => () => _r.ToString())).ToArray());
	}

	public static string checkRoleTranslationWithReplace(this RoleData _role, string _key, Func<string> _english, bool _check_keywords, params Func<string>[] _replace)
	{
		return _role.localisation_asset.checkTranslationWithReplace(_key, _english, _check_keywords, _replace);
	}

	public static string checkTranslationWithReplace(this AssetKey _localisation_asset, string _key, Func<string> _english, bool _check_keywords, params Func<string>[] _replace)
	{
		if (GRGLocalisationHandler.needs_translation)
		{
			if (GRGLocalisationHandler.instance.translateAndReplace(_localisation_asset, _key, out var _result, _replace.Select((Func<string> _r) => _r()).ToArray()))
			{
				if (_check_keywords)
				{
					return _result.checkKeywordLocMarkers();
				}
				return _result;
			}
			Debug.LogError($"Something went wrong with the localisation of:  Key: {_key} || Asset: {_localisation_asset} ||| Setting english as backup.");
		}
		return _english();
	}

	public static string checkTranslationWithReplace(this AssetKey _localisation_asset, string _key, Func<string> _english, bool _check_keywords, params string[] _replace)
	{
		if (GRGLocalisationHandler.needs_translation)
		{
			if (GRGLocalisationHandler.instance.translateAndReplace(_localisation_asset, _key, out var _result, _replace))
			{
				if (_check_keywords)
				{
					return _result.checkKeywordLocMarkers();
				}
				return _result;
			}
			Debug.LogError($"Something went wrong with the localisation of:  Key: {_key} || Asset: {_localisation_asset} ||| Setting english as backup.");
		}
		return _english();
	}

	private static string giveRichText(this string _text, string _marker)
	{
		try
		{
			if (_marker.StartsWith("K"))
			{
				Keywords keyword = (Keywords)int.Parse(_marker.Substring(1));
				return GameHandler.Text.giveRichText(_text, keyword);
			}
			if (_marker.StartsWith("A"))
			{
				Alignments align = (Alignments)int.Parse(_marker.Substring(1));
				return GameHandler.Text.giveRichText(_text, align);
			}
			if (_marker.StartsWith("C"))
			{
				RoleClassifications @class = (RoleClassifications)int.Parse(_marker.Substring(1));
				return GameHandler.Text.giveRichText(_text, @class);
			}
			if (_marker.StartsWith("L"))
			{
				LocationTypes loc = (LocationTypes)int.Parse(_marker.Substring(1));
				return GameHandler.Text.giveRichText(_text, loc);
			}
			if (_marker.StartsWith("R"))
			{
				Roles role = (Roles)int.Parse(_marker.Substring(1));
				return GameHandler.Text.giveRichText(_text, role);
			}
			throw new ArgumentException("No rich text giver function set up for marker: " + _marker + "!");
		}
		catch (Exception arg)
		{
			Debug.LogError($"Could not give text rich text markers! {_marker}\nError: {arg}");
			return _text.bold();
		}
	}

	public static string checkKeywordLocMarkers(this string _text)
	{
		return _text.replaceTags("{", "}", giveRichText, ("K", "/K"), ("A", "/A"), ("C", "/C"), ("L", "/L"), ("R", "/R"));
	}

	public static string getRoleName(this RoleData _role)
	{
		if (GRGLocalisationHandler.needs_translation)
		{
			string _result = "";
			if (GRGLocalisationHandler.instance.translate(_role.getAssetForRole(), _role.getLocNameKey(), out _result))
			{
				return _result;
			}
		}
		return _role.english_name;
	}

	public static string getRoleDescription(this RoleData _role)
	{
		if (GRGLocalisationHandler.needs_translation)
		{
			string _result = "";
			if (GRGLocalisationHandler.instance.translate(_role.getAssetForRole(), _role.getLocDescriptionKey(), out _result))
			{
				return _result.checkKeywordLocMarkers();
			}
		}
		return _role.english_description;
	}

	public static List<(DescriptionType, string)> getRoleExtraDescriptions(this RoleData _role, Func<string, DescriptionType, string> _fill)
	{
		if (_role.english_extra_descriptions.Count == 0)
		{
			return new List<(DescriptionType, string)>();
		}
		if (!GRGLocalisationHandler.needs_translation)
		{
			return _role.english_extra_descriptions.Select(((DescriptionType, string) _d) => (_d.Item1, _fill(_d.Item2, _d.Item1))).ToList();
		}
		Dictionary<DescriptionType, int> dictionary = new Dictionary<DescriptionType, int>();
		List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
		for (int i = 0; i < _role.english_extra_descriptions.Count; i++)
		{
			(DescriptionType, string) desc = _role.english_extra_descriptions[i];
			int orCreate = dictionary.getOrCreate(desc.Item1, 0);
			list.Add((desc.Item1, _fill(_role.checkRoleTranslation(_role.getLocExtraDescriptionKey(desc.Item1, orCreate), () => desc.Item2), desc.Item1)));
			dictionary[desc.Item1]++;
		}
		return list;
	}

	public static string checkPlural(string _text, int _nb)
	{
		return checkPlural(_text, _nb == 1);
	}

	public static string checkPlural(string _text, bool _singular)
	{
		return _text.checkOption(_singular);
	}

	public static string checkOption(string _text, bool _first_option)
	{
		return _text.checkOption(_first_option);
	}

	public static string checkOptionIfNotAsian(string _text, bool _first_option)
	{
		return checkOptionIfNotLanguage(_text, _first_option, Languages.CHINESE_SIMPLIFIED, Languages.CHINESE_TRADITIONAL, Languages.THAI, Languages.KOREAN, Languages.JAPANESE);
	}

	public static string checkOptionIfNotLanguage(string _text, bool _first_option, params Languages[] _languages)
	{
		if (((Languages)GRGLocalisationHandler.instance.current_language).equalToAny(_languages))
		{
			return _text;
		}
		return checkOption(_text, _first_option);
	}

	public static Languages getLanguageFromSteamIfSupported()
	{
		Languages languageFromSteam = getLanguageFromSteam();
		if (languageFromSteam.isSupported())
		{
			return languageFromSteam;
		}
		return Languages.ENGLISH;
	}

	public static Languages getLanguageFromSteam()
	{
		return GRGLocalisationHelper.getLanguageFromSteam(SteamHandler.getSteamInterfaceLanguage());
	}
}
