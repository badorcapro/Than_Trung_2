using GRGLib.Maybe;
using UnityEngine;
using XNode;

namespace Nodes;

public class WrapPreviousStringNode : StringNodeBase
{
	[Input(ShowBackingValue.Never, ConnectionType.Multiple, TypeConstraint.None, false)]
	public StringNodeBase target;

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
		Maybe<StringNodeBase> maybe = tryGetInputValue<StringNodeBase>("target");
		if (maybe.is_some)
		{
			return createString(maybe.value.fetchString(_fetcher, _speacher), isBold, isItalic, colour, animation, textSpeed, sizePercent);
		}
		return "";
	}

	protected override string localisationReplacements(string _localised_text, IStringFetcher _fetcher, DialogueSpeachers _speacher)
	{
		Maybe<StringNodeBase> maybe = tryGetInputValue<StringNodeBase>("target");
		if (maybe.is_some)
		{
			return maybe.value.checkForLocalisationReplacements(_localised_text, _fetcher, _speacher);
		}
		return _localised_text;
	}
}
