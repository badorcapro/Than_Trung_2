using System;

namespace Save;

[Serializable]
public class CaseRewardSave
{
	public bool syndicate_clue;

	public string data;

	public CaseRewardSave(bool _clue, string _data)
	{
		syndicate_clue = _clue;
		data = _data;
	}

	public static CaseReward load(CaseRewardSave _save, CaseType _type)
	{
		return _type switch
		{
			CaseType.CLOCK => new ClockCaseReward(_save), 
			CaseType.DOCKS => new DocksCaseReward(_save), 
			CaseType.CASINO => new CasinoCaseReward(_save), 
			CaseType.BACK_ALLEYS => new BackAlleysCaseReward(_save), 
			_ => throw new ArgumentException($"No reward found for case type {_type}!"), 
		};
	}
}
