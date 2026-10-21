using GRGLib.Maybe;
using GRGLib.Serializable;
using UnityEngine;

namespace GRGLocalisation;

[CreateAssetMenu(menuName = "ScriptableObject/Localisation Data")]
public class LocalisationDataSO : ScriptableObject
{
	[Header("Languages")]
	[SerializeField]
	private SerializableDictionary<LanguageKey, LocalisationLanguageSO> languages;

	public Maybe<LocalisationLanguageSO> this[LanguageKey _lang]
	{
		get
		{
			if (!languages.ContainsKey(_lang))
			{
				return new Maybe<LocalisationLanguageSO>();
			}
			return languages[_lang].maybe();
		}
	}

	public bool isSupported(LanguageKey _lang)
	{
		return languages.ContainsKey(_lang);
	}
}
