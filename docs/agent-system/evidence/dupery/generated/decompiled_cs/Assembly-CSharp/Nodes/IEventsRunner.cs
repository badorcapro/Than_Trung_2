using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Nodes;

public interface IEventsRunner
{
	MonoBehaviour coroutine_mono { get; }

	System.Random random { get; }

	void startEvent(StoryEventNodeBase _node, IEnumerator _coroutine);

	void doEvents(List<StoryEventNodeBase> _nodes, EventTrigger _trigger, Action _callback);

	bool ignoreSpeacher(DialogueSpeachers _speacher);
}
