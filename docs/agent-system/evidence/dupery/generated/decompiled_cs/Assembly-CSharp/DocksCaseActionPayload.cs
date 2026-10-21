public class DocksCaseActionPayload : CaseActionPayload
{
	public int correct_arrests;

	public bool traitor_arrested;

	public int reputation;

	public DocksBoat boat;

	public DocksCaseActionPayload(int _rep, DocksBoat _boat, int _arrests, bool _traitor_arrested)
	{
		bool flag = _traitor_arrested;
		reputation = _rep;
		boat = _boat;
		correct_arrests = _arrests;
		traitor_arrested = flag;
	}
}
