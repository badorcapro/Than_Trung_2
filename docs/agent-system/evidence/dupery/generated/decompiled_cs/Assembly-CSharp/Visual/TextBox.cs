using System;
using System.Collections;
using System.Collections.Generic;
using Audio;
using GRGLib.Coroutines;
using GRGLib.Extensions.Random;
using GRGLib.Menus;
using GRGLib.TextAnimation;
using TMPro;
using UnityEngine;

namespace Visual;

public class TextBox : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	protected CanvasGroup group;

	[SerializeField]
	protected TMP_Text dialogue_text;

	[Header("Settings")]
	[SerializeField]
	protected bool audio_sfx;

	[SerializeField]
	protected float writing_speed = 0.03f;

	[SerializeField]
	protected bool bake_text = true;

	[SerializeField]
	protected bool stop_all_after_text;

	protected CoroutineRunner opening_runner;

	protected CoroutineRunner dialogue_runner;

	protected CoroutineRunner audio_runner;

	public RectTransform rect_trans => base.transform as RectTransform;

	protected virtual float open_duration => 0.35f;

	protected float close_duration => 0.5f;

	protected float write_speed => writing_speed;

	protected bool fade_text => false;

	protected float fade_speed => 2.5f;

	public bool is_open => menu_state == MenuState.OPEN;

	public MenuState menu_state { get; private set; }

	public bool is_writing => dialogue_runner.is_running;

	protected virtual void Awake()
	{
		opening_runner = new CoroutineRunner(this);
		dialogue_runner = new CoroutineRunner(this);
		audio_runner = new CoroutineRunner(this);
	}

	public void overrideTextFontMaterial(Material _material)
	{
		dialogue_text.fontMaterial = _material;
	}

	public void setWritingSpeed(float _speed)
	{
		writing_speed = _speed;
	}

	public string getWrittenText()
	{
		return dialogue_text.text;
	}

	public void forceEnd()
	{
		dialogue_runner.stop();
		dialogue_text.maxVisibleCharacters = dialogue_text.text.Length;
	}

	public virtual void open()
	{
		if (!is_open && menu_state != MenuState.OPENING)
		{
			dialogue_text.text = "";
			menu_state = MenuState.OPENING;
			opening_runner.run(group.fade(1f, open_duration, CoroutineExtensions.easeInOutFunc).addCallback(delegate
			{
				menu_state = MenuState.OPEN;
			}));
		}
	}

	public virtual void open(Action _callback)
	{
		if (!is_open && menu_state != MenuState.OPENING)
		{
			dialogue_text.text = "";
			menu_state = MenuState.OPENING;
			opening_runner.run(group.fade(1f, open_duration, CoroutineExtensions.easeInOutFunc).addCallback(delegate
			{
				menu_state = MenuState.OPEN;
				_callback();
			}));
		}
	}

	public virtual void close()
	{
		if (menu_state != 0 && menu_state != MenuState.CLOSING)
		{
			menu_state = MenuState.CLOSING;
			opening_runner.run(group.fade(0f, close_duration, CoroutineExtensions.easeInOutFunc).addCallback(delegate
			{
				menu_state = MenuState.CLOSED;
			}));
		}
	}

	public void setDialogue(string _content)
	{
		dialogue_text.text = _content;
		dialogue_text.maxVisibleCharacters = dialogue_text.textInfo.characterCount;
	}

	public void writeDialogue(string _content)
	{
		dialogue_runner.run(writeDialogueAnimation(_content));
	}

	public void writeDialogue(string _content, List<(int, Action)> _events)
	{
		dialogue_runner.run(writeDialogueAnimation(_content, _events));
	}

	private IEnumerator writeDialogueAnimation(string _content)
	{
		yield return prepareText(_content);
		if (audio_sfx)
		{
			audio_runner.run(checkDialogueAudio());
		}
		yield return DialogueTextWriter.writeDialogueToText(dialogue_text, TextHelper.fetchAnimationFromLink, write_speed, _bake_text: false, fade_text, fade_speed);
		dialogue_text.maxVisibleCharacters = dialogue_text.textInfo.characterCount;
		if (stop_all_after_text)
		{
			dialogue_text.unbake();
		}
		if (audio_sfx)
		{
			audio_runner.stop();
		}
	}

	private IEnumerator writeDialogueAnimation(string _content, List<(int, Action)> _events)
	{
		yield return prepareText(_content);
		if (audio_sfx)
		{
			audio_runner.run(checkDialogueAudio());
		}
		yield return DialogueTextWriter.writeDialogueToText(dialogue_text, _events, TextHelper.fetchAnimationFromLink, write_speed, _bake_text: false, fade_text, fade_speed);
		_events.ForEach(delegate((int, Action) _e)
		{
			if (_e.Item1 >= dialogue_text.maxVisibleCharacters)
			{
				_e.Item2();
			}
		});
		dialogue_text.maxVisibleCharacters = dialogue_text.textInfo.characterCount;
		if (stop_all_after_text)
		{
			dialogue_text.unbake();
		}
		if (audio_sfx)
		{
			audio_runner.stop();
		}
	}

	protected IEnumerator checkDialogueAudio()
	{
		int last_max_characters = 0;
		System.Random rng = RandomExtensions.freshRandom();
		while (true)
		{
			yield return null;
			if (dialogue_text.maxVisibleCharacters > last_max_characters)
			{
				last_max_characters = dialogue_text.maxVisibleCharacters;
				AudioHandler.Sfx.playSfx(Sfx.TYPE_WRITER_TICK, 0.8f);
				yield return rng.nextFloat(0.1f, 0.125f).wait();
			}
		}
	}

	private IEnumerator prepareText(string _content)
	{
		if (!is_open || opening_runner.is_running)
		{
			open();
			while (!is_open)
			{
				yield return null;
			}
		}
		dialogue_text.bakeText(_content, bake_text);
	}

	private void Reset()
	{
		group = GetComponent<CanvasGroup>();
		dialogue_text = GetComponentInChildren<TMP_Text>();
	}
}
