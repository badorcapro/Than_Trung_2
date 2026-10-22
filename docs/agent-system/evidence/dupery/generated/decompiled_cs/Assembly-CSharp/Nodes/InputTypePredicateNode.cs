using Tutorial;
using UnityEngine;
using UnityEngine.InputSystem;

namespace Nodes;

public class InputTypePredicateNode : StoryPredicateNodeBase
{
	[NodeEnum]
	public InputType wanted_type;

	[SerializeField]
	private bool use_game_handler = true;

	public override bool predicateResult(IStoryGraphNavigator _graph_navigator)
	{
		if (_graph_navigator is TutorialStoryGraphNavigator tutorialStoryGraphNavigator)
		{
			PlayerInput player_input = (tutorialStoryGraphNavigator.string_fetcher as TutorialGraphStringFetcher).player_input;
			return (use_game_handler ? player_input.getInputType(GameHandler.instance.most_recent_control_scheme) : player_input.getInputType()) == wanted_type;
		}
		Debug.LogError("Could not get current input because graph navigator is not a TutorialStoryGraphNavigator!");
		return false;
	}
}
