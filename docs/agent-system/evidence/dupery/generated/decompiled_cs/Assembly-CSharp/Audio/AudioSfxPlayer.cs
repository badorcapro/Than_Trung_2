using FMODUnity;

namespace Audio;

public class AudioSfxPlayer
{
	private AudioReferencesSO audio_references;

	public float Volume_Sfx => SettingsHandler.sfx_volume * SettingsHandler.master_volume;

	public AudioSfxQueuer Queuer { get; private set; }

	public AudioSfxPlayer(AudioReferencesSO _ref)
	{
		AudioSfxQueuer audioSfxQueuer = new AudioSfxQueuer(playSfx);
		audio_references = _ref;
		AudioSfxQueuer audioSfxQueuer3 = (Queuer = audioSfxQueuer);
	}

	public void playSfx(Sfx _sfx, float _volume_multi = 1f)
	{
		playSfx(audio_references[_sfx], _volume_multi);
	}

	public void playSfx(EventReference _sfx, float _volume_multiplyer = 1f)
	{
		if (_sfx.isReferenceValid())
		{
			_sfx.playOneShot(Volume_Sfx * _volume_multiplyer);
		}
	}

	public void playSfxWithParam(Sfx _sfx, string _param_key, float _param_value, float _volume_multiplyer = 1f, bool _ignore_seek_speed = true)
	{
		playSfxWithParam(audio_references[_sfx], _param_key, _param_value, _volume_multiplyer, _ignore_seek_speed);
	}

	public void playSfxWithParam(EventReference _sfx, string _param_key, float _param_value, float _volume_multiplyer = 1f, bool _ignore_seek_speed = true)
	{
		if (_sfx.isReferenceValid())
		{
			_sfx.playOneShotWithParam(_param_key, _param_value, Volume_Sfx * _volume_multiplyer, _ignore_seek_speed);
		}
	}
}
