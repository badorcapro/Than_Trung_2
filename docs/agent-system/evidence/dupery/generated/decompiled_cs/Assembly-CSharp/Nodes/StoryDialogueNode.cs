using System.Collections.Generic;
using GRGLib.Maybe;
using GRGLocalisation;
using Localisation;
using UnityEngine;
using XNode;

namespace Nodes;

public class StoryDialogueNode : StoryNodeBase, INodeActionMarker, IAmLocalised
{
	[SerializeField]
	[NodeEnum]
	protected DialogueSpeachers speacher;

	[Input(ShowBackingValue.Never, ConnectionType.Override, TypeConstraint.None, false)]
	public StringNodeBase content;

	[SerializeField]
	protected bool can_skip = true;

	[Input(ShowBackingValue.Never, ConnectionType.Multiple, TypeConstraint.None, false)]
	public StoryEventNodeBase events;

	[Input(ShowBackingValue.Never, ConnectionType.Multiple, TypeConstraint.None, false)]
	public StoryNodeBase enter;

	[Output(ShowBackingValue.Never, ConnectionType.Multiple, TypeConstraint.None, false)]
	public StoryNodeBase exit;

	public bool narrator => speacher == DialogueSpeachers.NARRATOR;

	protected virtual bool wait_for_click => true;

	protected AssetKey localisation_asset => LocalisationHelper.stories_asset;

	protected string loc_node_key => $"{base.story_graph.localisation_graph_id} Dialogue [{UID}]";

	protected string getContent(IStringFetcher _fetcher)
	{
		if (GRGLocalisationHandler.needs_translation)
		{
			if (GRGLocalisationHandler.instance.translate(localisation_asset, loc_node_key, out var _result))
			{
				return getInputValues<StringNodeBase>("content")[0].checkForLocalisationReplacements(_result, _fetcher, speacher).checkKeywordLocMarkers();
			}
			Debug.LogError("Failed to find localisation for story node! (Key: " + loc_node_key + ")");
		}
		return getInputValues<StringNodeBase>("content")[0].fetchString(_fetcher, speacher);
	}

	protected List<StoryEventNodeBase> getEventNodes()
	{
		return getInputValues<StoryEventNodeBase>("events");
	}

	public override void progressImmidiate(IStoryGraphNavigator _navigator)
	{
		getEventNodes().ForEach(delegate(StoryEventNodeBase _ev)
		{
			_ev.immidiateEvent(_navigator.events_runner);
		});
	}

	public override void progress(IStoryGraphNavigator _navigator)
	{
		_navigator.writeDialogue(speacher, getContent(_navigator.string_fetcher), getEventNodes(), progressNextAction, can_skip, wait_for_click);
	}

	protected override void progressNextAction(IStoryGraphNavigator _navigator)
	{
		if (checkBranch(_navigator))
		{
			return;
		}
		Maybe<StoryNodeBase> nextNode = getNextNode(_navigator);
		if (!nextNode.is_some)
		{
			_navigator.onStoryFinish();
			return;
		}
		if (!(nextNode.value is StoryDialogueNode))
		{
			_navigator.closeText();
		}
		nextNode.value.progress(_navigator);
	}
}
