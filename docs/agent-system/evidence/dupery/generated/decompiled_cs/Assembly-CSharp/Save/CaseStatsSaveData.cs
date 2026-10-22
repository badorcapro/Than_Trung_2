using System;
using GRGLib.Serializable;
using GameStats;

namespace Save;

[Serializable]
public class CaseStatsSaveData
{
	public SerializableDictionary<Roles, int> investigated = new SerializableDictionary<Roles, int>();

	public SerializableDictionary<Roles, int> arrested = new SerializableDictionary<Roles, int>();

	public SerializableDictionary<Alignments, int> arrested_align = new SerializableDictionary<Alignments, int>();

	public SerializableDictionary<Roles, int> died = new SerializableDictionary<Roles, int>();

	public SerializableDictionary<Alignments, int> died_align = new SerializableDictionary<Alignments, int>();

	public SerializableDictionary<Roles, int> ability_used = new SerializableDictionary<Roles, int>();

	public string region_data;

	public static CaseStats load(CaseStatsSaveData _save, CaseType _case_type)
	{
		return _case_type switch
		{
			CaseType.CLOCK => new OfficeCaseStats(_save), 
			CaseType.DOCKS => new DocksCaseStats(_save), 
			CaseType.BACK_ALLEYS => new BackAlleyCaseStats(_save), 
			CaseType.CASINO => new CasinoCaseStats(_save), 
			_ => throw new ArgumentException($"No loading function set up for case type {_case_type}"), 
		};
	}

	public CaseStatsSaveData(CaseStats _stats)
	{
		investigated = _stats.investigated.makeSerializable();
		arrested = _stats.arrested.makeSerializable();
		arrested_align = _stats.arrested_align.makeSerializable();
		died = _stats.died.makeSerializable();
		died_align = _stats.died_align.makeSerializable();
		ability_used = _stats.ability_used.makeSerializable();
		region_data = _stats.getRegionSaveData();
	}
}
