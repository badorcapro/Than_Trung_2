using GRGLib.Extensions.Collections;
using GRGLib.PropertyDrawers;
using GRGLib.Serializable;
using GRGLocalisation;
using TMPro;
using UnityEngine;

public class LocalisationFontChoice : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private TMP_Text text;

	[SerializeField]
	private SerializableDictionary<Languages, TMP_FontAsset> language_font;

	[SerializeField]
	private TMP_FontAsset backup_font;

	[SerializeField]
	private bool set_bold;

	[SerializeField]
	[ConditionalField("set_bold")]
	private bool bold;

	[SerializeField]
	[ConditionalField("set_bold")]
	private ListStruct<Languages> opposite_bold;

	private void Awake()
	{
		text.font = language_font.getOrDefault(GRGLocalisationHandler.instance.current_language, backup_font);
		if (set_bold)
		{
			if (opposite_bold.list.Contains(GRGLocalisationHandler.instance.current_language))
			{
				text.fontStyle = ((!bold) ? FontStyles.Bold : FontStyles.Normal);
			}
			else
			{
				text.fontStyle = (bold ? FontStyles.Bold : FontStyles.Normal);
			}
		}
	}

	private void Reset()
	{
		text = GetComponent<TMP_Text>();
	}
}
