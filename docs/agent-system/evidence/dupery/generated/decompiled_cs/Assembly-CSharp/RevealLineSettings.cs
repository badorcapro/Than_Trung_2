using System;
using UnityEngine;
using Visual;

public class RevealLineSettings
{
	public Func<BoardVisualManager, Vector2> get_from;

	public Func<BoardVisualManager, Vector2> get_to;

	public RevealLineColour colour;

	public RevealLineSettings(Vector2Int _from, Vector2Int _to, RevealLineColour _colour)
	{
		get_from = (BoardVisualManager _b) => _b.getPointingPosition(_from, _to, _prioritise_x: false);
		get_to = (BoardVisualManager _b) => _b.getPointingPosition(_to, _from, _prioritise_x: true);
		colour = _colour;
	}

	public RevealLineSettings(Vector2Int _from, int _target_address, RevealLineColour _colour, CaseSnapshot _snapshot)
		: this(_from, _snapshot.address_occupents[_target_address].getBoardPosition(), _colour)
	{
	}
}
