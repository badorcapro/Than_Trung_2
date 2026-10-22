using UnityEngine;

namespace Nodes;

public class AdvancedStringNode : StringNodeBase
{
	[TextArea(8, 8)]
	public string content = "";

	public TextColour colour;

	public bool isBold;

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
		return createString(content, isBold, isItalic, colour, animation, textSpeed, sizePercent);
	}

	protected override string localisationReplacements(string _localised_text, IStringFetcher _fetcher, DialogueSpeachers _speacher)
	{
		return _localised_text;
	}
}
