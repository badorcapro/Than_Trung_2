namespace Leads;

public interface IClueRemovalFilterEvent
{
	bool canClueBeRemoved(Clue _clue);
}
