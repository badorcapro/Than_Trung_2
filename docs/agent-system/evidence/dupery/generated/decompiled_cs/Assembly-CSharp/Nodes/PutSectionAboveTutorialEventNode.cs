using System;
using GRGLib.PropertyDrawers;
using Tutorial;
using UnityEngine;

namespace Nodes;

public class PutSectionAboveTutorialEventNode : StoryEventNodeBase
{
	private enum TransformType
	{
		RATIO = 0,
		SUSPECT_LIST = 1,
		BOARD = 2,
		CLOCK = 3,
		MAGNIFYING_GLASS = 4,
		NEWSPAPER = 5,
		BOAT_LEVER = 101,
		DOCK_FINISH_BUTTON = 102,
		COST_MULTI = 201,
		CARDS = 202
	}

	[SerializeField]
	[NodeEnum]
	private TransformType transform;

	[SerializeField]
	private bool reset_to_initial;

	[SerializeField]
	[ConditionalField("reset_to_initial", false, new object[] { false })]
	private bool above_all;

	public override void immidiateEvent(IEventsRunner _controller)
	{
		if (_controller is TutorialEventsRunner tutorialEventsRunner)
		{
			tutorialEventsRunner.displace(transform switch
			{
				TransformType.RATIO => tutorialEventsRunner.tutorial_references.ratio, 
				TransformType.SUSPECT_LIST => tutorialEventsRunner.tutorial_references.suspect_list, 
				TransformType.BOARD => tutorialEventsRunner.tutorial_references.board, 
				TransformType.CLOCK => tutorialEventsRunner.tutorial_references.clock, 
				TransformType.MAGNIFYING_GLASS => tutorialEventsRunner.tutorial_references.magnifying_glass, 
				TransformType.NEWSPAPER => tutorialEventsRunner.tutorial_references.newspaper, 
				TransformType.BOAT_LEVER => tutorialEventsRunner.tutorial_references.dock_lever, 
				TransformType.DOCK_FINISH_BUTTON => tutorialEventsRunner.tutorial_references.dock_finish, 
				TransformType.COST_MULTI => tutorialEventsRunner.tutorial_references.cost_multi_parent, 
				TransformType.CARDS => tutorialEventsRunner.tutorial_references.cards_parent, 
				_ => throw new ArgumentException($"No transform set up for type {transform}!"), 
			}, reset_to_initial, above_all);
		}
		else
		{
			Debug.LogError("Trying to use a tutorial event node without a tutorial event runner!");
		}
	}
}
