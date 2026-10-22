using System;
using System.Collections;
using System.Collections.Generic;
using FMOD;
using FMOD.Studio;
using FMODUnity;
using GRGLib.Coroutines;
using GRGLib.Extensions.Random;
using UnityEngine;

namespace Audio;

public class AudioMusicPlayer
{
	private static string music_volume_parameter = "MusicVolume";

	private AudioReferencesSO audio_references;

	private Music last_played_music;

	private float specific_music_volume = 1f;

	private EventInstance music_instance;

	private float last_music_change;

	private CoroutineRunner volume_runner;

	private float music_volume => specific_music_volume * SettingsHandler.music_volume;

	public float Volume => SettingsHandler.master_volume * music_volume;

	public float Volume_True => SettingsHandler.master_volume * SettingsHandler.music_volume;

	public AudioMusicPlayer(AudioHandler _audio_hanler, AudioReferencesSO _refs)
	{
		volume_runner = new CoroutineRunner(_audio_hanler);
		audio_references = _refs;
	}

	public void playMusicIfTime(List<Music> _musics, System.Random _rng, float _threshold = 180f)
	{
		if (!_musics.Contains(last_played_music))
		{
			playMusic(_musics.getRandomElementFromList(_rng));
		}
		else if (!(Time.realtimeSinceStartup - last_music_change < _threshold))
		{
			if (Time.realtimeSinceStartup - last_music_change > _threshold * 2f && _musics.Count > 2)
			{
				_musics.Remove(last_played_music);
			}
			playMusic(_musics.getRandomElementFromList(_rng));
		}
	}

	public void playMusicIfTime(Music _music, float _threshold = 180f)
	{
		if (!(Time.realtimeSinceStartup - last_music_change < _threshold))
		{
			playMusic(_music);
		}
	}

	public void playMusic(Music _music)
	{
		playMusic(_music, new List<(string, float)>());
	}

	public void playMusic(Music _music, List<(string, float)> _params, float _volume_multi = 1f)
	{
		playMusic(_music, _params, 0.5f, _volume_multi);
	}

	public void playMusic(Music _music, List<(string, float)> _params, float _fade_in_duration, float _volume_multi, bool _allow_adhsr_fade_out = true)
	{
		switch (_music)
		{
		case Music.UNSET:
			UnityEngine.Debug.LogError("Trying to play UNSET music!");
			playMusic(Music.NONE);
			return;
		case Music.NONE:
			stopMusic(_allow_adhsr_fade_out);
			return;
		}
		if (music_instance.isPlaying() && last_played_music == _music)
		{
			setMusicParams(_params);
			changeVolume(_volume_multi);
			return;
		}
		stopAndReleaseMusicInstance(_allow_adhsr_fade_out);
		last_played_music = _music;
		specific_music_volume = _volume_multi;
		if (createMusicInstance(audio_references[_music]))
		{
			setMusicParam(music_volume_parameter, 1f);
			setMusicParams(_params);
			if (_fade_in_duration > 0f)
			{
				music_instance.setVolume(0f);
				specific_music_volume = 0f;
				volume_runner.run(changeVol(music_instance, _volume_multi, _fade_in_duration));
			}
			last_music_change = Time.realtimeSinceStartup;
		}
	}

	public void setMusicParams(List<(string, float)> _params, bool _ignore_seek = false)
	{
		foreach (var _param in _params)
		{
			RESULT rESULT = music_instance.setParameterByName(_param.Item1, _param.Item2, _ignore_seek);
			if (rESULT != 0)
			{
				UnityEngine.Debug.LogError($"Setting Music Param '{_param.Item1}' failed: {rESULT}");
			}
		}
	}

	public void setMusicParam(string _param, float _value, bool _ignore_seek_speed = false)
	{
		music_instance.setParameterByName(_param, _value, _ignore_seek_speed);
	}

	public float getMusicParamValue(string _param)
	{
		float value = 0f;
		RESULT parameterByName = music_instance.getParameterByName(_param, out value);
		if (parameterByName == RESULT.OK)
		{
			return value;
		}
		UnityEngine.Debug.LogError($"Could not get parameter '{_param}' value! (returning 0) Error:\n{parameterByName}");
		return 0f;
	}

	public IEnumerator setMusicParamSmooth(string _param, float _value, float _start_value, float _duration, bool _ignore_seek_speed = false)
	{
		float diff = _value - _start_value;
		yield return CoroutineLibrary.doActionForTime(delegate(float _f)
		{
			setMusicParam(_param, _f, _ignore_seek_speed);
		}, _duration, (float _f) => _start_value + diff * _f);
		setMusicParam(_param, _value, _ignore_seek_speed);
	}

	private IEnumerator changeVol(EventInstance _instance, float _volume, float _duration = 1f)
	{
		float start_volume = Volume;
		specific_music_volume = _volume;
		float vol_diff = Volume - start_volume;
		yield return CoroutineLibrary.doActionForTime(delegate(float _f)
		{
			_instance.setVolume(start_volume + vol_diff * _f);
		}, _duration, CoroutineExtensions.easeInOutFunc);
		_instance.setVolume(Volume);
	}

	public IEnumerator changeVolumeWait(float _volume, float _duration = 1f)
	{
		volume_runner.run(changeVol(music_instance, _volume, _duration));
		while (volume_runner.is_running)
		{
			yield return null;
		}
	}

	public float changeVolume(float _volume, float _duration = 1f)
	{
		float result = specific_music_volume;
		volume_runner.run(changeVol(music_instance, _volume, _duration));
		return result;
	}

	public void refreshVolume()
	{
		if (isMusicPlaying())
		{
			music_instance.setVolume(Volume);
		}
	}

	public void stopMusic(bool _allow_fadeout = true)
	{
		volume_runner.stop();
		stopAndReleaseMusicInstance(_allow_fadeout);
		last_played_music = Music.NONE;
	}

	public bool isMusicPlaying()
	{
		return music_instance.isPlaying();
	}

	private bool createMusicInstance(EventReference _event, bool _start = true)
	{
		try
		{
			music_instance = RuntimeManager.CreateInstance(_event);
			music_instance.setVolume(Volume);
			if (_start)
			{
				music_instance.start();
			}
			return true;
		}
		catch (Exception message)
		{
			UnityEngine.Debug.LogError(message);
			UnityEngine.Debug.Log(string.Format("Map Bank: {0}", RuntimeManager.HasBankLoaded("MapMusic")) + string.Format("\nQuest Bank: {0}", RuntimeManager.HasBankLoaded("QuestSceneMusic")) + string.Format("\nMain Bank: {0}", RuntimeManager.HasBankLoaded("MainTheme&Variations")));
			return false;
		}
	}

	private void stopAndReleaseMusicInstance(bool _allow_fade)
	{
		stopAndReleaseMusicInstance((!_allow_fade) ? FMOD.Studio.STOP_MODE.IMMEDIATE : FMOD.Studio.STOP_MODE.ALLOWFADEOUT);
	}

	private void stopAndReleaseMusicInstance(FMOD.Studio.STOP_MODE _stop_mode = FMOD.Studio.STOP_MODE.ALLOWFADEOUT)
	{
		music_instance.stopAndReleaseInstance(_stop_mode);
	}
}
