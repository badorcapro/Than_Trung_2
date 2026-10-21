using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Coroutines;
using GRGLib.Maybe;
using Nodes;
using TMPro;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;

namespace Tutorial;

public class TutorialStoryGraphNavigator : IStoryGraphNavigator
{
	private Dictionary<DialogueSpeachers, DialogueBox> text_boxes;

	private Dictionary<DialogueSpeachers, Image> speacher_images;

	private TMP_Text debug_progress_text;

	private Action graph_finish;

	private Selectable text_box_selectable;

	public TutorialHandler handler;

	public TutorialReferences tutorial_references { get; private set; }

	public IStringFetcher string_fetcher { get; private set; }

	public IEventsRunner events_runner { get; private set; }

	public TutorialStoryGraphNavigator(TutorialHandler _handler, Dictionary<DialogueSpeachers, DialogueBox> _boxes, Color _text_colour, Dictionary<DialogueSpeachers, Image> _speachers, TutorialReferences _references, PlayerInput _player_input, RectTransform _parent, RectTransform _parent_above, TMP_Text _debug_prog, Action _on_finish, Selectable _selectable)
	{
		text_boxes = _boxes;
		speacher_images = _speachers;
		tutorial_references = _references;
		debug_progress_text = _debug_prog;
		graph_finish = _on_finish;
		events_runner = new TutorialEventsRunner(_handler, _references, _parent, _parent_above);
		string_fetcher = new TutorialGraphStringFetcher(_player_input, _text_colour);
		handler = _handler;
		text_box_selectable = _selectable;
	}

	public void closeText()
	{
		foreach (KeyValuePair<DialogueSpeachers, DialogueBox> text_box in text_boxes)
		{
			text_box.Value.close();
		}
		foreach (KeyValuePair<DialogueSpeachers, Image> speacher_image in speacher_images)
		{
			speacher_image.Value.StopAllCoroutines();
			speacher_image.Value.fade(0f, 0.15f, CoroutineExtensions.easeInOutFunc).start(speacher_image.Value);
		}
	}

	public void closeExcept(DialogueSpeachers _speacher)
	{
		foreach (KeyValuePair<DialogueSpeachers, DialogueBox> text_box in text_boxes)
		{
			if (text_box.Key != _speacher)
			{
				text_box.Value.close();
				if (!events_runner.ignoreSpeacher(text_box.Key))
				{
					speacher_images[text_box.Key].StopAllCoroutines();
					speacher_images[text_box.Key].fadeToColour(Color.grey, 0.15f, CoroutineExtensions.easeInOutFunc).start(speacher_images[text_box.Key]);
				}
			}
			else if (speacher_images.ContainsKey(text_box.Key) && !events_runner.ignoreSpeacher(text_box.Key))
			{
				speacher_images[text_box.Key].StopAllCoroutines();
				speacher_images[text_box.Key].fadeToColour(Color.white, 0.15f, CoroutineExtensions.easeInOutFunc).start(speacher_images[text_box.Key]);
			}
		}
	}

	public void debugProgress(StoryNodeBase _node)
	{
		debug_progress_text.text = $"{_node.graph.name} | Node [{_node.UID}]";
	}

	public Maybe<string> getVariable(string _key)
	{
		throw new NotImplementedException();
	}

	public void onStoryFinish()
	{
		graph_finish();
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
		throw new NotImplementedException();
	}

	public void writeDialogue(DialogueSpeachers _speacher, string _content, List<StoryEventNodeBase> _events, Action<IStoryGraphNavigator> _callback, bool _can_skip, bool _wait_for_click)
	{
		closeExcept(_speacher);
		text_boxes[_speacher].writeDialogue(_content, delegate
		{
			_callback(this);
		}, _can_skip, _wait_for_click, _auto_continue: false);
		text_box_selectable.Select();
		_events = _events.OrderBy((StoryEventNodeBase _e) => _e.at_char).ToList();
		_events.ForEach(delegate(StoryEventNodeBase _e)
		{
			_e.doEvent(events_runner);
		});
	}

	public void onClick()
	{
		foreach (KeyValuePair<DialogueSpeachers, DialogueBox> text_box in text_boxes)
		{
			if (text_box.Value.is_open)
			{
				text_box.Value.trySkipDialogue(delegate
				{
				}, delegate
				{
				});
			}
		}
	}

	public void waitForCaseState(Func<CaseSnapshot, bool> _state_check, Action<CaseSnapshot> _callback)
	{
		handler.waitForCaseState(_state_check, _callback);
	}
}
