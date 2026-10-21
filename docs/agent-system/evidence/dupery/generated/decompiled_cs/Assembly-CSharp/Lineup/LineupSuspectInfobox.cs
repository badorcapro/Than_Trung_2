using GRGLocalisation;
using Localisation;
using TMPro;
using UnityEngine;

namespace Lineup;

public class LineupSuspectInfobox : MonoBehaviour, IAmLocalised
{
	[SerializeField]
	private TMP_Text name_text;

	[SerializeField]
	private TMP_Text suspect_number_text;

	[SerializeField]
	private TMP_Text attribute_text;

	private AssetKey localisation_asset => LocalisationHelper.misc_asset;

	private string loc_spct_key => "SPCT#";

	public void updateText(string _name, int _suspect_number, string _age, string _height, string _gender)
	{
		name_text.text = _name;
		suspect_number_text.text = localisation_asset.checkTranslationWithData(loc_spct_key, englishSPCT, _suspect_number);
		attribute_text.text = _age + "\n" + _height + "\n" + _gender;
	}

	private string englishSPCT(string _data)
	{
		return "SPCT#" + _data;
	}
}
