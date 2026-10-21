using System;
using System.Collections;
using System.Collections.Generic;
using GRGLib.Coroutines;
using Nodes;
using UnityEngine;

namespace TransitionScene;

public class StoryEventRunner : IEventsRunner
{
	private Dictionary<StoryEventNodeBase, Coroutine> running_coroutine = new Dictionary<StoryEventNodeBase, Coroutine>();

	public TransitionSceneDecor decor { get; private set; }

	public MonoBehaviour coroutine_mono { get; private set; }

	public System.Random random { get; private set; }

	public StoryEventRunner(MonoBehaviour _mono, System.Random _rng, TransitionSceneDecor _decor)
	{
		coroutine_mono = _mono;
		random = _rng;
		decor = _decor;
	}

	public void doEvents(List<StoryEventNodeBase> _nodes, EventTrigger _trigger, Action _callback)
	{
		throw new NotImplementedException();
	}

	public void startEvent(StoryEventNodeBase _node, IEnumerator _coroutine)
	{
		running_coroutine[_node] = _coroutine.addCallback(delegate
		{
			running_coroutine.Remove(_node);
		}).start(coroutine_mono);
	}

	public bool ignoreSpeacher(DialogueSpeachers _speacher)
	{
		return false;
	}
}
