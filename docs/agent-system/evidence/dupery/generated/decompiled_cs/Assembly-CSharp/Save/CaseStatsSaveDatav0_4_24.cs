using System;
using GRGLib.Serializable;
using GameStats;

namespace Save;

[Serializable]
public class CaseStatsSaveDatav0_4_24
{
	public int time_passed;

	public SerializableDictionary<Alignments, int> investigated = new SerializableDictionary<Alignments, int>();

	public SerializableDictionary<Alignments, int> arrested = new SerializableDictionary<Alignments, int>();

	public SerializableDictionary<Alignments, int> died = new SerializableDictionary<Alignments, int>();

	public SerializableDictionary<Roles, int> ability_used = new SerializableDictionary<Roles, int>();

	public CaseStatsSaveData convertNewer()
	{
		return new CaseStatsSaveData(new OfficeCaseStats
		{
			ability_used = ability_used.unserialize(),
			time_passed = time_passed
		});
	}
}
