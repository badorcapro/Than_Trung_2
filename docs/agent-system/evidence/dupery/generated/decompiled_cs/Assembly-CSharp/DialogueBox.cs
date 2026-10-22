using System;
using System.Collections;
using System.Collections.Generic;
using GRGLib.Coroutines;
using GRGLib.Maybe;
using GRGLib.TextAnimation;
using TMPro;
using UnityEngine;
using Visual;

public class DialogueBox : TextBox
{
	protected bool can_skip_dialogue;

	protected bool waiting_click;

	protected AdvancedCoroutineRunner advanced_dialogue_runner;

	protected CoroutineRunner wait_for_click_runner;

	protected CoroutineRunner fade_runner;

	protected Maybe<Action> dialogue_callback = new Maybe<Action>();

	public bool wait_for_click { get; protected set; }

	public bool writting_dialogue { get; private set; }

	protected override void Awake()
	{
		base.Awake();
		advanced_dialogue_runner = new AdvancedCoroutineRunner(this);
		advanced_dialogue_runner.addCallback(delegate
		{
			if (dialogue_callback.is_some)
			{
				dialogue_callback.value();
			}
			dialogue_callback = new Maybe<Action>();
		}, _is_unique: false);
		wait_for_click_runner = new CoroutineRunner(this);
		fade_runner = new CoroutineRunner(this);
	}

	public void trySkipDialogue(Action _on_skip, Action _on_end_wait)
	{
		if (waiting_click)
		{
			waiting_click = false;
			_on_end_wait();
		}
		else if (can_skip_dialogue)
		{
			writting_dialogue = false;
			advanced_dialogue_runner.stop();
			dialogue_text.maxVisibleCharacters = dialogue_text.textInfo.characterCount;
			can_skip_dialogue = false;
			_on_skip();
			if (dialogue_callback.is_some)
			{
				dialogue_callback.value();
			}
		}
	}

	public void writeDialogue(string _content, Action _callback, bool _can_skip, bool _wait_for_click, bool _auto_continue)
	{
		wait_for_click = _wait_for_click;
		dialogue_callback = new Maybe<Action>(delegate
		{
			if (wait_for_click)
			{
				wait_for_click_runner.run(waitForClick(_auto_continue).addCallback(_callback));
			}
			else
			{
				_callback();
			}
		});
		advanced_dialogue_runner.run(writeDialogue(_content, new List<(int, Action)>(), _can_skip));
	}

	public void writeDialogue(string _content, List<(int, Action)> _events, Action _callback, bool _can_skip, bool _wait_for_click, bool _auto_continue)
	{
		wait_for_click = _wait_for_click;
		dialogue_callback = new Maybe<Action>(delegate
		{
			if (wait_for_click)
			{
				wait_for_click_runner.run(waitForClick(_auto_continue).addCallback(_callback));
			}
			else
			{
				_callback();
			}
		});
		advanced_dialogue_runner.run(writeDialogue(_content, _events, _can_skip));
	}

	private IEnumerator writeDialogue(string _content, List<(int, Action)> _events, bool _can_skip = true)
	{
		can_skip_dialogue = _can_skip;
		if (!base.is_open || fade_runner.is_running)
		{
			can_skip_dialogue = false;
			bool opened = false;
			open(delegate
			{
				opened = true;
			});
			while (!opened)
			{
				yield return null;
			}
			can_skip_dialogue = _can_skip;
		}
		dialogue_text.bakeText(_content, bake_text);
		writting_dialogue = true;
		if (audio_sfx)
		{
			audio_runner.run(checkDialogueAudio());
		}
		yield return DialogueTextWriter.writeDialogueToText(dialogue_text, _events, TextHelper.fetchAnimationFromLink, base.write_speed, _bake_text: false, base.fade_text, base.fade_speed);
		_events.ForEach(delegate((int, Action) _e)
		{
			if (_e.Item1 >= dialogue_text.maxVisibleCharacters)
			{
				_e.Item2();
			}
		});
		writting_dialogue = false;
		if (audio_sfx)
		{
			audio_runner.stop();
		}
	}

	private IEnumerator waitForClick(bool _auto)
	{
		waiting_click = true;
		Maybe<Coroutine> auto = new Maybe<Coroutine>();
		if (_auto)
		{
			auto = waitForClickAuto().addCallback(delegate
			{
				auto = new Maybe<Coroutine>();
			}).start(this).maybe();
		}
		while (waiting_click)
		{
			yield return null;
		}
		auto.stopCoroutineIfSome(this);
		waiting_click = false;
	}

	private IEnumerator waitForClickAuto()
	{
		yield return 1f.wait();
		waiting_click = false;
	}

	private void Reset()
	{
		group = GetComponent<CanvasGroup>();
		dialogue_text = GetComponentInChildren<TMP_Text>();
	}

	public int getVisibleCharacters()
	{
		return dialogue_text.maxVisibleCharacters;
	}

	public Color getTextColour()
	{
		return dialogue_text.color;
	}
}
