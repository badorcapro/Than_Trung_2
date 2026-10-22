using System;
using System.Collections.Generic;
using FMOD.Studio;
using FMODUnity;
using UnityEngine;

namespace Audio;

public static class AudioHelper
{
	public static void play(this Music _music)
	{
		AudioHandler.Music.playMusic(_music);
	}

	public static void play(this Music _music, List<(string, float)> _params, float _volume = 1f)
	{
		AudioHandler.Music.playMusic(_music, _params, _volume);
	}

	public static void play(this Atmo _atmo, float _volume = 1f)
	{
		AudioHandler.Atmo.playAtmo(_atmo, _volume);
	}

	public static void playAsSfx(this Atmo _atmo, float _volume = 1f)
	{
		AudioHandler.Atmo.playAtmoAsSfx(_atmo, _volume);
	}

	public static void playSolo(this Atmo _atmo, float _volume = 1f)
	{
		AudioHandler.Atmo.stopAllAtmoAndStart(_atmo, _volume);
	}

	public static void stop(this Atmo _atmo)
	{
		AudioHandler.Atmo.stopAtmo(_atmo);
	}

	public static void stopIfPlaying(this Atmo _atmo)
	{
		AudioHandler.Atmo.stopAtmoIfPlaying(_atmo);
	}

	public static void play(this Sfx _sfx, float _volume = 1f)
	{
		AudioHandler.Sfx.playSfx(_sfx, _volume);
	}

	public static string toFmodParamName(this GlobalParams _param)
	{
		if (_param == GlobalParams.GAME_PAUSE)
		{
			return "GamePause";
		}
		throw new ArgumentException($"No toFmodParamName set up for GlobalParam {_param}");
	}

	public static void playOneShot(this EventReference _event, float _volume)
	{
		EventInstance eventInstance = RuntimeManager.CreateInstance(_event);
		eventInstance.setVolume(_volume);
		eventInstance.start();
		eventInstance.release();
	}

	public static void playOneShotWithParam(this EventReference _event, string _param_key, float _param_value, float _volume, bool _ignore_seek_speed = true)
	{
		EventInstance eventInstance = RuntimeManager.CreateInstance(_event);
		eventInstance.setVolume(_volume);
		eventInstance.setParameterByName(_param_key, _param_value, _ignore_seek_speed);
		eventInstance.start();
		eventInstance.release();
	}

	public static bool isPlaying(this EventInstance instance)
	{
		instance.getPlaybackState(out var state);
		return state != PLAYBACK_STATE.STOPPED;
	}

	public static void stopAndReleaseInstance(this EventInstance _instance, FMOD.Studio.STOP_MODE _stop_mode = FMOD.Studio.STOP_MODE.ALLOWFADEOUT)
	{
		_instance.stop(_stop_mode);
		_instance.release();
	}

	public static bool isReferenceValid(this EventReference _ref)
	{
		if (_ref.IsNull)
		{
			Debug.LogError("Trying to play invalid fmod reference!");
			return false;
		}
		return true;
	}

	private static bool isPathValid(this string _path)
	{
		EventDescription _event = default(EventDescription);
		RuntimeManager.StudioSystem.getEvent(_path, out _event);
		return _event.isValid();
	}
}
