using System;
using System.Collections;
using System.Collections.Generic;
using GRGLib.Coroutines;
using GRGLib.Extensions.Random;
using Nodes;
using UnityEngine;

namespace Tutorial;

public class TutorialEventsRunner : IEventsRunner
{
	private RectTransform tutorial_parent;

	private RectTransform tutorial_parent_above;

	private Dictionary<string, Coroutine> event_coroutines = new Dictionary<string, Coroutine>();

	private Dictionary<RectTransform, (Transform, int)> initial_hierachal_position = new Dictionary<RectTransform, (Transform, int)>();

	private Dictionary<string, GameObject> tutorial_objects = new Dictionary<string, GameObject>();

	public HashSet<DialogueSpeachers> to_ignore = new HashSet<DialogueSpeachers>();

	public MonoBehaviour coroutine_mono => tutorial_handler;

	public System.Random random { get; private set; } = RandomExtensions.freshRandom();

	public TutorialHandler tutorial_handler { get; private set; }

	public TutorialReferences tutorial_references { get; private set; }

	public TutorialEventsRunner(TutorialHandler _handler, TutorialReferences _references, RectTransform _tutorial_parent, RectTransform _parent_above)
	{
		TutorialHandler tutorialHandler2 = (tutorial_handler = _handler);
		TutorialReferences tutorialReferences2 = (tutorial_references = _references);
		tutorial_parent = _tutorial_parent;
		tutorial_parent_above = _parent_above;
	}

	public void doEvents(List<StoryEventNodeBase> _event_nodes, EventTrigger _trigger, Action _callback)
	{
		multiEventsAnim(_event_nodes, _trigger).addCallback(_callback).start(tutorial_handler);
	}

	public IEnumerator multiEventsAnim(List<StoryEventNodeBase> _event_nodes, EventTrigger _trigger)
	{
		switch (_trigger)
		{
		case EventTrigger.ALL_IMMIDIATE:
			_event_nodes.ForEach(delegate(StoryEventNodeBase _e)
			{
				_e.immidiateEvent(this);
			});
			break;
		case EventTrigger.ALL_NO_WAIT:
			_event_nodes.ForEach(delegate(StoryEventNodeBase _e)
			{
				_e.doEvent(this);
			});
			break;
		case EventTrigger.SEQUENTIAL:
			yield return doEventsSequential(_event_nodes).start(tutorial_handler);
			break;
		case EventTrigger.ALL_WAIT_FIRST_FINISH:
			yield return doEventsAllWaitFirstFinish(_event_nodes).start(tutorial_handler);
			break;
		case EventTrigger.ALL_WAIT_ALL_FINISH:
			yield return doEventsAllWaitAllFinish(_event_nodes).start(tutorial_handler);
			break;
		default:
			Debug.LogError($"No doEvents function set up for trigger type {_trigger}!");
			break;
		}
	}

	private IEnumerator doEventsSequential(List<StoryEventNodeBase> _event_nodes)
	{
		for (int i = 0; i < _event_nodes.Count; i++)
		{
			yield return _event_nodes[i].eventCoroutine(this);
		}
	}

	private IEnumerator doEventsAllWaitFirstFinish(List<StoryEventNodeBase> _event_nodes)
	{
		bool move_on = false;
		_event_nodes.ForEach(delegate(StoryEventNodeBase _e)
		{
			startEvent(_e, _e.eventCoroutine(this).addCallback(delegate
			{
				move_on = true;
			}));
		});
		while (!move_on)
		{
			yield return null;
		}
	}

	private IEnumerator doEventsAllWaitAllFinish(List<StoryEventNodeBase> _event_nodes)
	{
		_event_nodes.ForEach(delegate(StoryEventNodeBase _e)
		{
			startEvent(_e, _e.eventCoroutine(this));
		});
		while (_event_nodes.Exists((StoryEventNodeBase _e) => event_coroutines.ContainsKey(_e.event_id)))
		{
			yield return null;
		}
	}

	public void startEvent(StoryEventNodeBase _node, IEnumerator _coroutine)
	{
		event_coroutines[_node.event_id] = _coroutine.addCallback(delegate
		{
			event_coroutines.Remove(_node.event_id);
		}).start(tutorial_handler);
	}

	public void displace(RectTransform _trans, bool _reset, bool _above)
	{
		if (_reset)
		{
			if (!initial_hierachal_position.ContainsKey(_trans))
			{
				Debug.LogError("Cannot reset transform giving to initial position as it is not set!");
				return;
			}
			(Transform, int) tuple = initial_hierachal_position[_trans];
			_trans.SetParent(tuple.Item1);
			_trans.SetSiblingIndex(tuple.Item2);
		}
		else
		{
			initial_hierachal_position[_trans] = (_trans.parent, _trans.GetSiblingIndex());
			_trans.SetParent(_above ? tutorial_parent_above : tutorial_parent);
		}
	}

	public GameObject createObject(GameObject _prefab, string _key, bool _above = false)
	{
		if (tutorial_objects.ContainsKey(_key))
		{
			Debug.LogError("Object with key " + _key + " already exists!");
			return tutorial_objects[_key];
		}
		GameObject gameObject = UnityEngine.Object.Instantiate(_prefab, _above ? tutorial_parent_above : tutorial_parent);
		tutorial_objects[_key] = gameObject;
		return gameObject;
	}

	public void deleteObject(string _key)
	{
		if (!tutorial_objects.ContainsKey(_key))
		{
			Debug.LogError("Object with key " + _key + " does not exist. Cannot delete it!");
			return;
		}
		UnityEngine.Object.Destroy(tutorial_objects[_key]);
		tutorial_objects.Remove(_key);
	}

	public void messageObjectForRemoval(string _key, string _message)
	{
		if (!tutorial_objects.ContainsKey(_key))
		{
			Debug.LogError("Object with key " + _key + " does not exist. Cannot delete it!");
			return;
		}
		tutorial_objects[_key].SendMessage(_message);
		tutorial_objects.Remove(_key);
	}

	public bool ignoreSpeacher(DialogueSpeachers _speacher)
	{
		return to_ignore.Contains(_speacher);
	}
}
