using System;
using System.Collections.Generic;
using GRGLib.Maybe;

namespace Nodes;

public interface IStoryGraphNavigator
{
	IStringFetcher string_fetcher { get; }

	IEventsRunner events_runner { get; }

	void resetStory();

	void writeDialogue(DialogueSpeachers _speacher, string _content, List<StoryEventNodeBase> _events, Action<IStoryGraphNavigator> _callback, bool _can_skip, bool _wait_for_click);

	void closeText();

	void waitForClick(Action _callback);

	void setVariable(string _key, string _value);

	Maybe<string> getVariable(string _key);

	void onStoryFinish();
}
