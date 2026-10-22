using System;

namespace Save;

[Serializable]
public struct BackAlleyRegionUniqueSaveData
{
	public int health;

	public int credits;

	public BackAlleyPouchSaveData pouch;

	public BackAlleyRegionUniqueSaveData(int _health, int _money, BackAlleyPouchSaveData _pouch)
	{
		health = _health;
		credits = _money;
		pouch = _pouch;
	}
}
