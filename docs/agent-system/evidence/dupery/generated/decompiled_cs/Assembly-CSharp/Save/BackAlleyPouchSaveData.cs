using System;
using System.Collections.Generic;

namespace Save;

[Serializable]
public struct BackAlleyPouchSaveData
{
	public List<string> item_slots;

	public List<string> info;

	public BackAlleyPouchSaveData(List<string> _items, List<string> _info)
	{
		item_slots = _items;
		info = _info;
	}
}
