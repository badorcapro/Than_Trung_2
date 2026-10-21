using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Nodes;
using UnityEngine;
using Visual;

namespace TransitionScene;

public class StoryGraphNavigator : IStoryGraphNavigator
{
	public TextBox text_box;

	private Action on_story_finish;

	private Maybe<Action> on_click = new Maybe<Action>();

	private Maybe<Action<IStoryGraphNavigator>> continue_story = new Maybe<Action<IStoryGraphNavigator>>();

	private bool can_skip;

	public IStringFetcher string_fetcher { get; private set; }

	public IEventsRunner events_runner { get; private set; }

	public StoryGraphNavigator(MonoBehaviour _mono, System.Random _rng, TextBox _text_box, TransitionSceneDecor _decor, Action _on_finish)
	{
		text_box = _text_box;
		on_story_finish = _on_finish;
		string_fetcher = new StoryStringFetcher();
		events_runner = new StoryEventRunner(_mono, _rng, _decor);
	}

	public bool onClick()
	{
		if (on_click.is_some)
		{
			on_click.value();
			on_click = new Maybe<Action>();
			return true;
		}
		if (text_box.is_writing)
		{
			if (!can_skip)
			{
				return false;
			}
			text_box.forceEnd();
			return true;
		}
		if (continue_story.is_some)
		{
			Action<IStoryGraphNavigator> value = continue_story.value;
			continue_story = new Maybe<Action<IStoryGraphNavigator>>();
			value(this);
			return true;
		}
		return false;
	}

	public void closeText()
	{
		text_box.close();
	}

	public void debugProgress(StoryNodeBase _node)
	{
	}

	public Maybe<string> getVariable(string _key)
	{
		throw new NotImplementedException();
	}

	public void onStoryFinish()
	{
		Debug.Log("STORY FINISHED!");
		on_story_finish();
	}

	public void resetStory()
	{
		throw new NotImplementedException();
	}

	public void setVariable(string _key, string _value)
	{
		throw new NotImplementedException();
	}

	public void waitForClick(Action _callback)
	{
		on_click = _callback.maybe();
	}

	public void writeDialogue(DialogueSpeachers _speacher, string _content, List<StoryEventNodeBase> _events, Action<IStoryGraphNavigator> _callback, bool _can_skip, bool _wait_for_click)
	{
		text_box.setDialogue("");
		text_box.writeDialogue(_content, _events.Select((StoryEventNodeBase _e) => ((int at_char, Action))(at_char: _e.at_char, delegate
		{
			events_runner.startEvent(_e, _e.eventCoroutine(events_runner));
		})).ToList());
		can_skip = _can_skip;
		if (_wait_for_click)
		{
			continue_story = _callback.maybe();
			return;
		}
		waitForTextEnd(delegate
		{
			_callback(this);
		});
	}

	private IEnumerator waitForTextEnd(Action _callback)
	{
		while (text_box.is_writing)
		{
			yield return null;
		}
		_callback();
	}
}
