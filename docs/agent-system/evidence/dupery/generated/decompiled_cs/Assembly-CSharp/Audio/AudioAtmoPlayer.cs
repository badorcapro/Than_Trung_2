using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using FMOD.Studio;
using FMODUnity;
using GRGLib.Coroutines;
using GRGLib.Extensions.Collections;
using UnityEngine;

namespace Audio;

public class AudioAtmoPlayer
{
	private class AtmoInstanceData
	{
		public EventInstance instance;

		public float volume;

		public CoroutineRunner volume_runner;

		private Func<float> volume_setting;

		public AtmoInstanceData(EventReference _event, float _volume, Func<float> _volume_multi, MonoBehaviour _mono, bool _start = true)
		{
			instance = RuntimeManager.CreateInstance(_event);
			volume = _volume;
			volume_setting = _volume_multi;
			instance.setVolume(volume_setting() * volume);
			volume_runner = new CoroutineRunner(_mono);
			if (_start)
			{
				instance.start();
			}
		}

		public void refreshVolume()
		{
			setVolumeImmidiate(volume);
		}

		public void changeVolume(float _volume, float _duration = 1f)
		{
			changeVolume(_volume, _duration, delegate
			{
			});
		}

		public void changeVolume(float _volume, float _duration, Action _callback)
		{
			if (volume != _volume)
			{
				if (_duration > 0f)
				{
					volume_runner.run(changeVolumeCoroutine(volume, _duration).addCallback(_callback));
					return;
				}
				setVolumeImmidiate(_volume);
				_callback();
			}
		}

		private IEnumerator changeVolumeCoroutine(float _volume_multi, float _duration)
		{
			float starting_volume = volume;
			float diff = _volume_multi - starting_volume;
			yield return CoroutineLibrary.doActionForTime(delegate(float _f)
			{
				setVolumeImmidiate(starting_volume + diff * _f);
			}, _duration);
			setVolumeImmidiate(_volume_multi);
		}

		private void setVolumeImmidiate(float _volume)
		{
			volume = _volume;
			instance.setVolume(volume_setting() * volume);
		}
	}

	private AudioHandler audio_handler;

	private AudioReferencesSO audio_references;

	private Dictionary<EventReference, AtmoInstanceData> atmo_instances = new Dictionary<EventReference, AtmoInstanceData>();

	public float Volume => SettingsHandler.atmo_volume * SettingsHandler.master_volume;

	public float VolumeAsSfx => SettingsHandler.sfx_volume * SettingsHandler.master_volume;

	public AudioAtmoPlayer(AudioHandler _handler, AudioReferencesSO _ref)
	{
		audio_handler = _handler;
		audio_references = _ref;
	}

	public void playAtmo(Atmo _atmo, float _volume_multi = 1f)
	{
		playAtmo(audio_references[_atmo], _volume_multi);
	}

	public void playAtmo(EventReference _atmo, float _volume_multi = 1f)
	{
		playAtmo(_atmo, () => Volume, _volume_multi);
	}

	public void playAtmoAsSfx(Atmo _atmo, float _volume_multi = 1f)
	{
		playAtmoAsSfx(audio_references[_atmo], _volume_multi);
	}

	public void playAtmoAsSfx(EventReference _atmo, float _volume_multi = 1f)
	{
		playAtmo(_atmo, () => VolumeAsSfx, _volume_multi);
	}

	public void playAtmo(EventReference _atmo, Func<float> _get_volume, float _volume_multi)
	{
		if (!_atmo.isReferenceValid())
		{
			return;
		}
		if (atmo_instances.ContainsKey(_atmo))
		{
			atmo_instances[_atmo].changeVolume(_volume_multi);
			return;
		}
		atmo_instances[_atmo] = new AtmoInstanceData(_atmo, _volume_multi, () => Volume, audio_handler);
	}

	public void playAtmo(List<(Atmo, float)> _atmos)
	{
		playAtmo(_atmos.Select(((Atmo, float) _a) => (audio_references[_a.Item1], _a.Item2)).toListSafe());
	}

	public void playAtmo(List<(EventReference, float)> _atmos)
	{
		_atmos.ForEach(delegate((EventReference, float) _er)
		{
			playAtmo(_er.Item1, _er.Item2);
		});
	}

	public bool isAtmoPlaying(Atmo _atmo)
	{
		return isAtmoPlaying(audio_references[_atmo]);
	}

	public bool isAtmoPlaying(EventReference _atmo)
	{
		return atmo_instances.ContainsKey(_atmo);
	}

	public void atmoParam(Atmo _atmo, string _param, float _value, bool _ignore_seek_speed = false)
	{
		atmoParam(audio_references[_atmo], _param, _value, _ignore_seek_speed);
	}

	public void atmoParam(EventReference _atmo, string _param, float _value, bool _ignore_seek_speed = false)
	{
		if (!atmo_instances.ContainsKey(_atmo))
		{
			Debug.LogError($"Cannot set param of atmo {_atmo} as it is not playing!");
		}
		else
		{
			atmo_instances[_atmo].instance.setParameterByName(_param, _value, _ignore_seek_speed);
		}
	}

	public void changeVolume(Atmo _atmo, float _volume_multi, float _duration = 1f)
	{
		changeVolume(audio_references[_atmo], _volume_multi, _duration);
	}

	public void changeVolume(EventReference _atmo, float _volume_multi, float _duration = 1f)
	{
		if (!atmo_instances.ContainsKey(_atmo))
		{
			Debug.LogError("Trying to change volume of non-existing atmo!");
		}
		else
		{
			atmo_instances[_atmo].changeVolume(_volume_multi, _duration);
		}
	}

	public void changeAllVolume(float _volume_multi, float _duration, bool _relative = true)
	{
		foreach (KeyValuePair<EventReference, AtmoInstanceData> atmo_instance in atmo_instances)
		{
			atmo_instance.Value.changeVolume(_relative ? (_volume_multi * atmo_instance.Value.volume) : _volume_multi, _duration);
		}
	}

	public void refreshVolume()
	{
		foreach (KeyValuePair<EventReference, AtmoInstanceData> atmo_instance in atmo_instances)
		{
			atmo_instance.Value.refreshVolume();
		}
	}

	public void stopAtmoIfPlaying(Atmo _atmo)
	{
		if (isAtmoPlaying(_atmo))
		{
			stopAtmo(_atmo);
		}
	}

	public void stopAtmoIfPlaying(EventReference _atmo)
	{
		if (isAtmoPlaying(_atmo))
		{
			stopAtmo(_atmo);
		}
	}

	public void stopAtmo(Atmo _atmo)
	{
		stopAtmo(audio_references[_atmo]);
	}

	public void stopAtmo(EventReference _atmo)
	{
		if (_atmo.isReferenceValid())
		{
			if (!atmo_instances.ContainsKey(_atmo))
			{
				Debug.LogError("Trying to stop atmosphere that isnt playing/doesnt exist!");
				return;
			}
			atmo_instances[_atmo].instance.stopAndReleaseInstance();
			atmo_instances.Remove(_atmo);
		}
	}

	public void stopAtmo(List<Atmo> _atmos)
	{
		stopAtmo(_atmos.Select((Atmo _a) => audio_references[_a]).toListSafe());
	}

	public void stopAtmo(List<EventReference> _atmos)
	{
		_atmos.ForEach(delegate(EventReference _a)
		{
			stopAtmo(_a);
		});
	}

	public void stopAllAtmo()
	{
		foreach (KeyValuePair<EventReference, AtmoInstanceData> atmo_instance in atmo_instances)
		{
			atmo_instance.Value.instance.stopAndReleaseInstance();
		}
		atmo_instances.Clear();
	}

	public void stopAllAtmo(List<Atmo> _exceptions)
	{
		stopAllAtmo(_exceptions.Select((Atmo _e) => audio_references[_e]).toListSafe());
	}

	public void stopAllAtmo(List<EventReference> _exceptions)
	{
		List<EventReference> list = new List<EventReference>();
		foreach (KeyValuePair<EventReference, AtmoInstanceData> atmo_instance in atmo_instances)
		{
			if (!_exceptions.Contains(atmo_instance.Key))
			{
				atmo_instance.Value.instance.stopAndReleaseInstance();
				list.add(atmo_instance.Key);
			}
		}
		list.ForEach(delegate(EventReference _tr)
		{
			atmo_instances.Remove(_tr);
		});
	}

	public void stopAllAtmoAndStart(Atmo _atmo, float _volume = 1f)
	{
		stopAllAtmoAndStart(audio_references[_atmo], _volume);
	}

	public void stopAllAtmoAndStart(EventReference _ref, float _vol = 1f)
	{
		stopAllAtmoAndStart((_ref, _vol).makeListFromItem());
	}

	public void stopAllAtmoAndStart(List<(Atmo, float)> _atmos)
	{
		stopAllAtmoAndStart(_atmos.Select(((Atmo, float) _a) => (audio_references[_a.Item1], _a.Item2)).toListSafe());
	}

	public void stopAllAtmoAndStart(List<(EventReference, float)> _to_start)
	{
		stopAllAtmo(_to_start.Select(((EventReference, float) _er) => _er.Item1).toListSafe());
		_to_start.ForEach(delegate((EventReference, float) _er)
		{
			playAtmo(_er.Item1, _er.Item2);
		});
	}
}
