namespace Nodes;

public class WaitingStringNode : StringNodeBase
{
	public float wait_duration = 1f;

	protected override string fetchNodeString(IStringFetcher _fetcher, DialogueSpeachers _speacher)
	{
		return $"<link={'"'}{getWaitingTag()}{'"'}>\u200b</link>";
	}

	private string getWaitingTag()
	{
		return "T_Wait{" + wait_duration + "}";
	}

	protected override string localisationReplacements(string _localised_text, IStringFetcher _fetcher, DialogueSpeachers _speacher)
	{
		return _localised_text.Replace(getStringKey(), fetchNodeString(_fetcher, _speacher));
	}

	private string getStringKey()
	{
		return $"{{W_{UID}}}";
	}
}
