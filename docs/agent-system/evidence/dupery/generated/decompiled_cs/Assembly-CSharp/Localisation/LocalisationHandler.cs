using GRGLib.Serializable;
using GRGLocalisation;
using TMPro;
using UnityEngine;

namespace Localisation;

public class LocalisationHandler : GRGLocalisationHandler
{
	[Header("Fonts")]
	[SerializeField]
	private TMP_FontAsset main_font;

	[SerializeField]
	private SerializableDictionary<Languages, TMP_FontAsset> language_fonts;

	protected override LanguageKey default_language => Languages.ENGLISH;

	protected override LanguageKey getInitialLanguage()
	{
		if (SettingsHandler.language == LocalisationHelper.LanguageSettings.DEFAULT)
		{
			Languages languageFromSteam = LocalisationHelper.getLanguageFromSteam();
			if (isLanguageSupported(languageFromSteam))
			{
				return languageFromSteam;
			}
			return default_language;
		}
		return SettingsHandler.language.toLanguage();
	}

	public override bool isLanguageSupported(LanguageKey _key)
	{
		if (!_key.isSupported())
		{
			return false;
		}
		if (data != null)
		{
			return base.isLanguageSupported(_key);
		}
		return _key == default_language;
	}

	protected override void onLanguageChange()
	{
		base.onLanguageChange();
		if (language_fonts.ContainsKey(base.current_language))
		{
			main_font.fallbackFontAssetTable.Sort((TMP_FontAsset _a, TMP_FontAsset _b) => (!(_a == language_fonts[base.current_language])) ? ((_b == language_fonts[base.current_language]) ? 1 : 0) : (-1));
		}
	}
}
