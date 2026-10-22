using System;
using UnityEngine;

namespace Save;

[Serializable]
public struct PinSaveData
{
	public Vector2 position;

	public bool position_as_board_pos;

	public int pin_colour;

	public int m_pin_index;

	public int PinIndex => m_pin_index;

	public PinSaveData(Vector2 _position, int _colour, int _pin_index)
	{
		position = _position;
		position_as_board_pos = false;
		pin_colour = _colour;
		m_pin_index = _pin_index;
	}

	public PinSaveData(Vector2Int _position, int _colour, int _pin_index)
	{
		position = _position;
		position_as_board_pos = true;
		pin_colour = _colour;
		m_pin_index = _pin_index;
	}
}
