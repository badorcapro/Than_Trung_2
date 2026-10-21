using System;
using System.Collections.Generic;
using FMODUnity;
using GRGLib.Coroutines;
using UnityEngine;

namespace Audio;

public class AudioHandler : MonoBehaviour
{
	[SerializeField]
	private AudioReferencesSO audio_references;

	private AudioMusicPlayer m_music_player;

	private AudioAtmoPlayer m_atmo_player;

	private AudioSfxPlayer m_sfx_player;

	private AudioCutscenePlayer m_cutscene_player;

	private Dictionary<AudioBanks, Coroutine> unload_queue = new Dictionary<AudioBanks, Coroutine>();

	public static AudioHandler instance { get; private set; }

	public static AudioMusicPlayer Music => instance.m_music_player;

	public static AudioAtmoPlayer Atmo => instance.m_atmo_player;

	public static AudioSfxPlayer Sfx => instance.m_sfx_player;

	public static AudioCutscenePlayer Cutscene => instance.m_cutscene_player;

	public bool allBanksLoaded => RuntimeManager.HaveAllBanksLoaded;

	private void Awake()
	{
		if (instance != null && instance != this)
		{
			UnityEngine.Object.Destroy(base.gameObject);
			return;
		}
		UnityEngine.Object.DontDestroyOnLoad(base.gameObject);
		instance = this;
		setUp();
	}

	private void setUp()
	{
		m_music_player = new AudioMusicPlayer(this, audio_references);
		m_atmo_player = new AudioAtmoPlayer(this, audio_references);
		m_sfx_player = new AudioSfxPlayer(audio_references);
		m_cutscene_player = new AudioCutscenePlayer();
	}

	public void queueUnloadBanks(float _time, params AudioBanks[] _banks)
	{
		foreach (AudioBanks _bk in _banks)
		{
			if (unload_queue.ContainsKey(_bk))
			{
				StopCoroutine(unload_queue[_bk]);
			}
			unload_queue[_bk] = _time.wait(delegate
			{
				unloadBanks(_bk);
			}).addCallback(delegate
			{
				unload_queue.Remove(_bk);
			}).start(this);
		}
	}

	public void unloadBanks(params AudioBanks[] _banks)
	{
		for (int i = 0; i < _banks.Length; i++)
		{
			RuntimeManager.UnloadBank(getBankName(_banks[i]));
		}
	}

	public void loadBanks(params AudioBanks[] _banks)
	{
		checkUnloadQueue(_banks);
		for (int i = 0; i < _banks.Length; i++)
		{
			string bankName = getBankName(_banks[i]);
			if (!RuntimeManager.HasBankLoaded(bankName))
			{
				RuntimeManager.LoadBank(bankName);
			}
		}
	}

	public bool haveBanksLoaded(List<AudioBanks> _bank)
	{
		return !_bank.Exists((AudioBanks _b) => !isBankLoaded(_b));
	}

	public bool isBankLoaded(AudioBanks _bank)
	{
		return RuntimeManager.HasBankLoaded(getBankName(_bank));
	}

	private void checkUnloadQueue(params AudioBanks[] _banks)
	{
		foreach (AudioBanks key in _banks)
		{
			if (unload_queue.ContainsKey(key))
			{
				StopCoroutine(unload_queue[key]);
				unload_queue.Remove(key);
			}
		}
	}

	public static string getBankName(AudioBanks _bank)
	{
		return _bank switch
		{
			AudioBanks.ATMOSPHERE => "Atmospheres", 
			AudioBanks.MASTER => "Master", 
			_ => throw new ArgumentException($"No bank name set up for bank {_bank}!"), 
		};
	}

	public void setGlobalParameter(GlobalParams _param, float _value)
	{
		setGlobalParameter(_param.toFmodParamName(), _value);
	}

	public void setGlobalParameter(string _param, float _value)
	{
		RuntimeManager.StudioSystem.setParameterByName(_param, _value);
	}

	public void changeVolumes()
	{
		m_music_player.refreshVolume();
		m_atmo_player.refreshVolume();
	}
}
