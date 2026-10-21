using System;
using System.Collections.Generic;
using GRGLib.Serializable;

namespace Save;

[Serializable]
public struct BackAlleyCaseUniqueSaveData
{
	public int health;

	public BackAlleyPouchSaveData pouch;

	public SerializableDictionary<BackAlleysItemType, int> items_used;

	public BackAlleyCaseUniqueSaveData(int _health, BackAlleyPouchSaveData _pouch, Dictionary<BackAlleysItemType, int> _used)
	{
		health = _health;
		pouch = _pouch;
		items_used = _used.makeSerializable();
	}
}
