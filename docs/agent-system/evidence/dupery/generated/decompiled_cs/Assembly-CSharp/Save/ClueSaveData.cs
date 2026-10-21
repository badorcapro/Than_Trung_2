using System;
using Leads;

namespace Save;

[Serializable]
public class ClueSaveData
{
	public ClueTypes type;

	public bool immutable;

	public string unique_data;

	public ClueSaveData(Clue _clue)
	{
		type = _clue.clue_type;
		immutable = _clue.immutable;
		unique_data = _clue.uniqueSaveData();
	}
}
