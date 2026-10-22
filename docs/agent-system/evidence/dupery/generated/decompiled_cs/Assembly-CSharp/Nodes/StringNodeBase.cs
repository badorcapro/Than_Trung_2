using GRGLib.Extensions.String;
using GRGLib.Maybe;
using UnityEngine;
using XNode;

namespace Nodes;

public abstract class StringNodeBase : NodeBase, INodeStringMarker
{
	[Input(ShowBackingValue.Never, ConnectionType.Multiple, TypeConstraint.None, false)]
	public StringNodeBase enter;

	[Output(ShowBackingValue.Never, ConnectionType.Multiple, TypeConstraint.None, false)]
	public NodeBase exit;

	public string fetchString(IStringFetcher _fetcher, DialogueSpeachers _speacher)
	{
		Maybe<StringNodeBase> maybe = tryGetInputValue<StringNodeBase>("enter");
		if (maybe.is_some)
		{
			return maybe.value.fetchString(_fetcher, _speacher) + fetchNodeString(_fetcher, _speacher);
		}
		return fetchNodeString(_fetcher, _speacher);
	}

	protected abstract string fetchNodeString(IStringFetcher _fetcher, DialogueSpeachers _speacher);

	protected string buildLink(TextAnimationType _animation, float _speed)
	{
		return $"<link={'"'}{_animation.toTag()}{getSpeedTag(_speed)}{'"'}>";
	}

	private string getSpeedTag(float _speed)
	{
		if (_speed != 1f)
		{
			return "T{" + ((_speed <= 0f) ? 100f : (1f / _speed)) + "}";
		}
		return "";
	}

	protected string createString(string _content, bool _bold, bool _italic, TextColour _colour, TextAnimationType _animation, float _speed = 1f, int _size = 100)
	{
		return createString(_content, _bold, _italic, (_colour == TextColour.DEFAULT) ? new Maybe<Color>() : _colour.get().maybe(), _animation, _speed, _size);
	}

	protected string createString(string _content, bool _bold, bool _italic, Maybe<Color> _colour, TextAnimationType _animation, float _speed = 1f, int _size = 100)
	{
		(string, string) data = getData(_bold, _italic, _colour, _animation, _speed, _size);
		return _content.sandwichString(data);
	}

	protected (string, string) getData(bool _bold, bool _italic, Maybe<Color> _colour, TextAnimationType _animation = TextAnimationType.NONE, float _speed = 1f, int _size = 100)
	{
		string text = "";
		string text2 = "";
		if (_bold)
		{
			text = "<b>" + text;
			text2 += "</b>";
		}
		if (_italic)
		{
			text = "<i>" + text;
			text2 += "</i>";
		}
		if (_animation != 0 || _speed != 1f)
		{
			text = buildLink(_animation, _speed) + text;
			text2 += "</link>";
		}
		if (_size != 100)
		{
			text = $"<size={_size}%>" + text;
			text2 += "</size>";
		}
		if (_colour.is_some)
		{
			text = "<color=#" + ColorUtility.ToHtmlStringRGBA(_colour.value) + ">" + text;
			text2 += "</color>";
		}
		return (text, text2);
	}

	public string checkForLocalisationReplacements(string _localised_text, IStringFetcher _fetcher, DialogueSpeachers _speacher)
	{
		Maybe<StringNodeBase> maybe = tryGetInputValue<StringNodeBase>("enter");
		if (maybe.is_some)
		{
			return localisationReplacements(maybe.value.checkForLocalisationReplacements(_localised_text, _fetcher, _speacher), _fetcher, _speacher);
		}
		return localisationReplacements(_localised_text, _fetcher, _speacher);
	}

	protected abstract string localisationReplacements(string _localised_text, IStringFetcher _fetcher, DialogueSpeachers _speacher);
}
