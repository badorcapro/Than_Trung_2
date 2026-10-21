using GRGLib.PropertyDrawers;
using UnityEngine;

namespace Nodes;

public class KeywordStringNode : StringNodeBase
{
	public KeywordInfoBuilder keyword;

	public bool override_string;

	[ConditionalField("override_string")]
	public string keyword_override;

	[Space]
	public string additional_content = "";

	public bool isItalic;

	public int sizePercent = 100;

	[Tooltip("Higher is faster, lower is slower")]
	public float textSpeed = 1f;

	[NodeEnum]
	public TextAnimationType animation;

	protected override string fetchNodeString(IStringFetcher _fetcher, DialogueSpeachers _speacher)
	{
		return getString();
	}

	private string getString()
	{
		return createString((override_string ? keyword.getKeyword().asKeyword(keyword_override) : keyword.getKeyword().toString()) + additional_content, _bold: false, isItalic, TextColour.DEFAULT, animation, textSpeed, sizePercent);
	}

	protected override string localisationReplacements(string _localised_text, IStringFetcher _fetcher, DialogueSpeachers _speacher)
	{
		return _localised_text;
	}
}
