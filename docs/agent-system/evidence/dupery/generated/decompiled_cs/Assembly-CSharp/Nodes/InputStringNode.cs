using Tutorial;
using UnityEngine;

namespace Nodes;

public class InputStringNode : StringNodeBase
{
	public InputAssetPerType input_assets;

	public bool capital_first;

	public bool italics;

	protected override string fetchNodeString(IStringFetcher _fetcher, DialogueSpeachers _speacher)
	{
		if (_fetcher is TutorialGraphStringFetcher tuto)
		{
			return createString(getString(tuto), _bold: false, italics, TextColour.DEFAULT, TextAnimationType.NONE);
		}
		Debug.LogError("Fetcher is not tutorial graph string fetcher! This nodes doesnt work!!!");
		return input_assets.kbm.getInputTextAsset();
	}

	private string getString(TutorialGraphStringFetcher _tuto)
	{
		Color default_text_colour = _tuto.default_text_colour;
		if (default_text_colour == Color.white)
		{
			return input_assets.getText(_tuto.player_input, capital_first);
		}
		return input_assets.getText(_tuto.player_input, default_text_colour, capital_first);
	}

	protected override string localisationReplacements(string _localised_text, IStringFetcher _fetcher, DialogueSpeachers _speacher)
	{
		return _localised_text.Replace(getStringKey(), fetchNodeString(_fetcher, _speacher));
	}

	private string getStringKey()
	{
		return $"{{I_{UID}}}";
	}
}
