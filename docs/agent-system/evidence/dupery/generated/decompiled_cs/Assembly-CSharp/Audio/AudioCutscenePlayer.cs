using System;
using FMOD.Studio;
using FMODUnity;
using UnityEngine;

namespace Audio;

public class AudioCutscenePlayer
{
	private float specific_cutscene_volume = 1f;

	private EventInstance cutscene_instance;

	public float Volume => SettingsHandler.master_volume * specific_cutscene_volume;

	public float Volume_True => SettingsHandler.master_volume;

	public void playCutscene(EventReference _event, float _volume = 1f)
	{
		specific_cutscene_volume = _volume;
		createCutsceneInstance(_event);
	}

	public void pauseCutscene(bool _pause = true)
	{
		cutscene_instance.setPaused(_pause);
	}

	public void unpauseAtTime(int _time_milli)
	{
		cutscene_instance.setTimelinePosition(_time_milli);
		cutscene_instance.setPaused(paused: false);
	}

	public void stopCutscene(bool _allow_fadeout = true)
	{
		stopAndReleaseInstance(_allow_fadeout);
	}

	private bool createCutsceneInstance(EventReference _event, bool _start = true)
	{
		try
		{
			cutscene_instance = RuntimeManager.CreateInstance(_event);
			cutscene_instance.setVolume(Volume);
			if (_start)
			{
				cutscene_instance.start();
			}
			return true;
		}
		catch (Exception message)
		{
			Debug.LogError(message);
			Debug.Log(string.Format("Map Bank: {0}", RuntimeManager.HasBankLoaded("MapMusic")) + string.Format("\nQuest Bank: {0}", RuntimeManager.HasBankLoaded("QuestSceneMusic")) + string.Format("\nMain Bank: {0}", RuntimeManager.HasBankLoaded("MainTheme&Variations")));
			return false;
		}
	}

	private void stopAndReleaseInstance(bool _allow_fade)
	{
		stopAndReleaseInstance((!_allow_fade) ? FMOD.Studio.STOP_MODE.IMMEDIATE : FMOD.Studio.STOP_MODE.ALLOWFADEOUT);
	}

	private void stopAndReleaseInstance(FMOD.Studio.STOP_MODE _stop_mode = FMOD.Studio.STOP_MODE.ALLOWFADEOUT)
	{
		cutscene_instance.stopAndReleaseInstance(_stop_mode);
	}
}
