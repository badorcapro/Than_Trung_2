using System;

namespace Save;

[Serializable]
public struct BackAlleyRegionUniqueSaveDatav0_5_19
{
	public int region_progress;

	public int health;

	public int money;

	public BackAlleyPouchSaveData pouch;

	public BackAlleyRegionUniqueSaveDatav0_5_19(int _prog, int _health, int _money, BackAlleyPouchSaveData _pouch)
	{
		region_progress = _prog;
		health = _health;
		money = _money;
		pouch = _pouch;
	}
}
