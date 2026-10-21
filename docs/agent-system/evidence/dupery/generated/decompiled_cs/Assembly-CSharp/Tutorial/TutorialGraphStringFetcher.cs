using Nodes;
using UnityEngine;
using UnityEngine.InputSystem;

namespace Tutorial;

public class TutorialGraphStringFetcher : IStringFetcher
{
	public Color default_text_colour;

	public PlayerInput player_input { get; private set; }

	public TutorialGraphStringFetcher(PlayerInput _input, Color _text_colour)
	{
		player_input = _input;
		default_text_colour = _text_colour;
	}
}
