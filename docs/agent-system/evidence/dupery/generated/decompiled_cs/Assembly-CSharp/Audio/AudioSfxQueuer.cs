using System;
using System.Collections.Generic;

namespace Audio;

public class AudioSfxQueuer
{
	private Action<Sfx, float> play_sfx;

	private HashSet<Sfx> vetoed = new HashSet<Sfx>();

	private Dictionary<Sfx, float> to_play = new Dictionary<Sfx, float>();

	public AudioSfxQueuer(Action<Sfx, float> _play_sfx)
	{
		play_sfx = _play_sfx;
	}

	public void addVeto(Sfx _sfx)
	{
		if (to_play.ContainsKey(_sfx))
		{
			to_play.Remove(_sfx);
		}
		vetoed.Add(_sfx);
	}

	public void queueSfx(Sfx _sfx, float _volume_multi = 1f)
	{
		if (!vetoed.Contains(_sfx))
		{
			to_play[_sfx] = _volume_multi;
		}
	}

	public void resetQueue()
	{
		to_play = new Dictionary<Sfx, float>();
		vetoed = new HashSet<Sfx>();
	}

	public void playAndEmptyQueue()
	{
		foreach (KeyValuePair<Sfx, float> item in to_play)
		{
			play_sfx(item.Key, item.Value);
		}
		to_play.Clear();
		vetoed.Clear();
	}
}
