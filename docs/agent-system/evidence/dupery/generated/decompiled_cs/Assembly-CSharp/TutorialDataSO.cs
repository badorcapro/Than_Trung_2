using System;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using GRGLib.Serializable;
using Nodes;
using UnityEngine;

[CreateAssetMenu(menuName = "ScriptableObject/Tutorial Data SO")]
public class TutorialDataSO : ScriptableObject
{
	[Header("Data")]
	[SerializeField]
	private SerializableDictionary<int, StoryNodeGraph> office_tutorial_graphs;

	[SerializeField]
	private SerializableDictionary<int, StoryNodeGraph> docks_tutorial_graphs;

	[SerializeField]
	private SerializableDictionary<int, StoryNodeGraph> casino_tutorial_graphs;

	[SerializeField]
	private SerializableDictionary<int, StoryNodeGraph> back_alleys_tutorial_graphs;

	public Maybe<StoryNodeGraph> this[CaseType _case_type, int _case] => getTutorialGraph(_case_type, _case);

	private Maybe<StoryNodeGraph> getTutorialGraph(CaseType _case_type, int _case)
	{
		return _case_type switch
		{
			CaseType.CLOCK => office_tutorial_graphs.tryGet(_case), 
			CaseType.DOCKS => docks_tutorial_graphs.tryGet(_case), 
			CaseType.CASINO => casino_tutorial_graphs.tryGet(_case), 
			CaseType.BACK_ALLEYS => back_alleys_tutorial_graphs.tryGet(_case), 
			_ => throw new ArgumentException($"Could not get tutorial graph for case type {_case_type}! (TutorialDataSo.getTutorialGraph)"), 
		};
	}
}
