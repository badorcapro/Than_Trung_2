using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.String;
using GRGLib.PropertyDrawers;
using GRGLocalisation;
using Localisation;
using UnityEngine;

[CreateAssetMenu(menuName = "ScriptableObject/Case Quirk Data SO")]
public class CaseQuirkDataSO : ScriptableObject, IReadOnlyCallback, IAmLocalised
{
	[SerializeField]
	private CaseQuirks quirk;

	[SerializeField]
	private Sprite quirk_icon;

	[SerializeField]
	private Color text_colour = new Color(1f, 0.95f, 0.85f);

	[SerializeField]
	private string quirk_name;

	[SerializeField]
	private string icon_link_text;

	[SerializeField]
	[TextArea(4, 4)]
	private string quirk_description;

	[SerializeField]
	private List<KeywordInfoBuilder> description_keywords;

	[Space]
	[Space]
	[SerializeField]
	[TextArea(3, 3)]
	private string quirk_extra_description;

	[SerializeField]
	private List<KeywordInfoBuilder> extra_description_keywords;

	public CaseQuirks Quirk => quirk;

	public Sprite Icon => quirk_icon;

	public Color Colour => text_colour;

	public string Name => checkTranslation(loc_name_key, quirk_name);

	public string NameColoured => Name.sandwichWithColour(text_colour);

	public string IconLink
	{
		get
		{
			if (icon_link_text.Length <= 1)
			{
				return "";
			}
			return "<sprite name=" + icon_link_text + ">";
		}
	}

	public string Description => checkTranslation(loc_description_key, implementKeywords(quirk_description, description_keywords));

	public string ExtraDescription
	{
		get
		{
			if (!(quirk_extra_description.Trim() == ""))
			{
				return checkTranslation(loc_extra_description_key, implementKeywords(quirk_extra_description, extra_description_keywords));
			}
			return "";
		}
	}

	public List<KeywordInfo> Keywords => description_keywords.Aggregate(new List<KeywordInfo>(), (List<KeywordInfo> _a, KeywordInfoBuilder _k) => (!_a.Contains(_k.getKeyword())) ? _a.add(_k.getKeyword()) : _a);

	public AssetKey localisation_asset => LocalisationHelper.quirk_asset;

	private string loc_name_key => $"{quirk} [name]";

	private string loc_description_key => $"{quirk} [desc]";

	private string loc_extra_description_key => $"{quirk} [extra]";

	private string implementKeywords(string _main, List<KeywordInfoBuilder> _keywords)
	{
		string text = _main;
		string text2 = "";
		for (int i = 0; i < _keywords.Count; i++)
		{
			int num = text.IndexOf("{#" + (i + 1));
			int num2 = num + 3 + ((i >= 9) ? 1 : 0);
			int num3 = text.IndexOf("}", num2);
			text2 += text.Substring(0, num);
			string text3 = text.Substring(num2, num3 - num2);
			text2 = ((!(text3 == "")) ? (text2 + _keywords[i].getKeyword().asKeyword(text3)) : (text2 + _keywords[i].getKeyword().toString()));
			text = text.Substring(num3 + 1);
		}
		return text2 + text;
	}

	private string checkTranslation(string _key, string _english)
	{
		if (GRGLocalisationHandler.needs_translation)
		{
			string _result = "";
			if (GRGLocalisationHandler.instance.translate(localisation_asset, _key, out _result))
			{
				return _result;
			}
		}
		return _english;
	}
}
