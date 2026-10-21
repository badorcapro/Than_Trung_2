using System;
using System.Collections;
using Audio;
using FMODUnity;
using GRGLib.Coroutines;
using GRGLib.Serializable;
using GRGLocalisation;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;
using UnityEngine.Video;

public class IntroCutsceneManager : MonoBehaviour
{
	[Serializable]
	public struct CutsceneSettings
	{
		public VideoClip video;

		public EventReference audio_track;
	}

	[Header("References")]
	[SerializeField]
	private VideoPlayer video_player;

	[SerializeField]
	private SerializableDictionary<Languages, CutsceneSettings> clips;

	[SerializeField]
	private CutsceneSettings backup_clip;

	[SerializeField]
	private Image skip_circle;

	private bool paused;

	private CoroutineRunner skip_runner;

	private void Awake()
	{
		skip_runner = new CoroutineRunner(this);
	}

	private void Start()
	{
		AudioHandler.Music.stopMusic();
		AudioHandler.Atmo.stopAllAtmo();
		playVideoSoon().start(this);
	}

	private IEnumerator playVideoSoon()
	{
		yield return 0.5f.wait();
		CutsceneSettings settings = (clips.ContainsKey(GRGLocalisationHandler.instance.current_language) ? clips[GRGLocalisationHandler.instance.current_language] : backup_clip);
		video_player.clip = settings.video;
		video_player.Prepare();
		while (!video_player.isPrepared)
		{
			yield return null;
		}
		video_player.Play();
		AudioHandler.Cutscene.playCutscene(settings.audio_track);
		waitForEnd(video_player, moveOn).start(this);
	}

	private IEnumerator waitForEnd(VideoPlayer _player, Action _callback)
	{
		while (!_player.isPlaying)
		{
			yield return null;
		}
		float e = 0f;
		while ((_player.isPlaying && e < 48f) || paused)
		{
			if (!paused)
			{
				e += Time.deltaTime;
			}
			yield return null;
		}
		_callback();
	}

	private void moveOn()
	{
		Music.D.play();
		GameHandler.instance.moveToScene("GameScene");
		GameHandler.MetaData.intro_cutscene_played = true;
	}

	public void onSkip(InputAction.CallbackContext _context)
	{
		if (_context.performed)
		{
			startSkip();
		}
		else if (_context.canceled)
		{
			endSkip();
		}
	}

	public void startSkip()
	{
		skip_runner.run(skip_circle.fill(1f, 2f, CoroutineExtensions.easeInOutFunc).addCallback(delegate
		{
			video_player.Stop();
			AudioHandler.Cutscene.stopCutscene();
			moveOn();
		}));
	}

	public void endSkip()
	{
		skip_runner.run(skip_circle.fill(0f, 0.25f, CoroutineExtensions.easeOutFunc));
	}
}
