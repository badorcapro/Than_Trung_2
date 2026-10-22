public class BackAlleysCaseActionPayload : CaseActionPayload
{
	public int current_health;

	public int max_health;

	public BackAlleysPouch pouch;

	public BackAlleysCaseActionPayload(int _health, int _max_health, BackAlleysPouch _pouch)
	{
		current_health = _health;
		max_health = _max_health;
		pouch = _pouch;
	}
}
