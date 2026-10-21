using Save;

public abstract class CaseReward
{
	public bool syndicate_clue;

	public CaseReward(bool _has_clue)
	{
		syndicate_clue = _has_clue;
	}

	public CaseReward(CaseRewardSave _save)
	{
		syndicate_clue = _save.syndicate_clue;
	}

	protected abstract string getData();

	public CaseRewardSave toSave()
	{
		return new CaseRewardSave(syndicate_clue, getData());
	}
}
