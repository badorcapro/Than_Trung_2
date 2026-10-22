using GRGLib.Extensions.String;
using UnityEngine;

namespace Nodes;

public class BasicStringNode : StringNodeBase
{
	[TextArea(8, 8)]
	public string content;

	[NodeEnum]
	public TextColour colour;

	protected override string fetchNodeString(IStringFetcher _fetcher, DialogueSpeachers _speacher)
	{
		return getString();
	}

	protected string getString()
	{
		if (colour == TextColour.DEFAULT)
		{
			return content;
		}
		return content.sandwichWithColour(colour.get());
	}

	protected override string localisationReplacements(string _localised_text, IStringFetcher _fetcher, DialogueSpeachers _speacher)
	{
		return _localised_text;
	}
}
