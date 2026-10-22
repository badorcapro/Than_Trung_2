using System;

namespace Save;

[Serializable]
public abstract class BaseSaveData
{
	public string reload_scene;

	public BaseSaveData(string _scene)
	{
		reload_scene = _scene;
	}

	public abstract GameState toGameState();

	public abstract void onLoaded();
}
