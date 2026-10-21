using System;
using System.Collections.Generic;

namespace Save;

[Serializable]
public class PinsSave
{
	public List<PinSaveData> pins_data;

	public bool is_empty => pins_data.Count == 0;

	public PinsSave(List<PinSaveData> _pins)
	{
		pins_data = _pins;
	}

	public void addPin(PinSaveData _pins)
	{
		pins_data.Add(_pins);
	}

	public void removePin(int _index)
	{
		pins_data.RemoveAll((PinSaveData _p) => _p.PinIndex == _index);
	}

	public void resetPin(int _index, PinSaveData _pin)
	{
		removePin(_index);
		addPin(_pin);
	}
}
