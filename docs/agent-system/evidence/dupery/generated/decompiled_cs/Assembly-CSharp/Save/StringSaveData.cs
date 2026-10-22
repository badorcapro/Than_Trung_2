using System;
using GRGLib.Serializable;

namespace Save;

[Serializable]
public struct StringSaveData
{
	public STupple<int, int> pin_connection;

	public int colour;

	public StringSaveData(int _start_pin_id, int _end_pin_id, int _colour)
	{
		pin_connection = new STupple<int, int>(_start_pin_id, _end_pin_id);
		colour = _colour;
	}
}
