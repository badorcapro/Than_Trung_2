public class ClockCaseActionPayload : CaseActionPayload
{
	public int reputation;

	public int hour_passed;

	public ClockCaseActionPayload(int _rep, int _time)
	{
		reputation = _rep;
		hour_passed = _time;
	}
}
