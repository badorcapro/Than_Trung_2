using System;
using GRGLib.Serializable;

namespace Save;

[Serializable]
public class CaseStatsSaveDatav0_5_62
{
	public SerializableDictionary<Alignments, int> investigated = new SerializableDictionary<Alignments, int>();

	public SerializableDictionary<Alignments, int> arrested = new SerializableDictionary<Alignments, int>();

	public SerializableDictionary<Alignments, int> died = new SerializableDictionary<Alignments, int>();

	public SerializableDictionary<Roles, int> ability_used = new SerializableDictionary<Roles, int>();

	public string region_data;
}
