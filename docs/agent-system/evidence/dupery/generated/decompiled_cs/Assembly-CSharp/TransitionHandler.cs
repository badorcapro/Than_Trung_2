using System;
using System.Collections;
using Audio;
using GRGLib.Coroutines;
using GRGLib.Mono;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class TransitionHandler : MonoBehaviour
{
	[Header("Scene Loading Animation")]
	[SerializeField]
	private CanvasGroup load_group;

	[SerializeField]
	private TMP_Text loading_progress_text;

	[Header("Save Icon Animation")]
	[SerializeField]
	private CanvasGroup save_group;

	[SerializeField]
	private Image fill_image;

	[SerializeField]
	private TMP_Text save_text;

	private CoroutineRunner transition_runner;

	private CoroutineRunner save_runner;

	public static TransitionHandler instance { get; private set; }

	public bool is_transitioning => transition_runner.is_running;

	public bool is_loading { get; private set; }

	private void Awake()
	{
		if (instance != null && instance != this)
		{
			UnityEngine.Object.Destroy(base.gameObject);
			return;
		}
		UnityEngine.Object.DontDestroyOnLoad(base.gameObject);
		instance = this;
		setUpCoroutineRunners();
	}

	private void setUpCoroutineRunners()
	{
		transition_runner = new CoroutineRunner(this);
		save_runner = new CoroutineRunner(this);
	}

	public IEnumerator waitForLoading(Action _callback)
	{
		while (is_loading)
		{
			yield return null;
		}
		_callback();
	}

	public IEnumerator waitForTransition(Action _callback)
	{
		while (is_transitioning)
		{
			yield return null;
		}
		_callback();
	}

	public void moveToScene(string _scene, bool _fade_audio = true)
	{
		if (is_loading)
		{
			Debug.Log("Already Loading Scene! Cannot load scene while another scene is loading!");
			return;
		}
		AsyncSceneLoader loader = new AsyncSceneLoader(this, _scene, delegate
		{
		}, updateProgress);
		transition_runner.run(transitionAnimation(loader, _fade_audio));
	}

	private IEnumerator transitionAnimation(AsyncSceneLoader _loader, bool _fade_audio = true)
	{
		is_loading = true;
		float starting_music_volume = -1f;
		if (_fade_audio)
		{
			starting_music_volume = AudioHandler.Music.changeVolume(0.5f, 0.75f);
			AudioHandler.Atmo.changeAllVolume(0.5f, 1f);
		}
		yield return load_group.fadeRealTime(1f, 1f, CoroutineExtensions.easeInOutFunc);
		_loader.allowSceneActivation();
		yield return _loader.waitForSceneLoad();
		yield return 0.15f.wait();
		if (_fade_audio)
		{
			AudioHandler.Music.changeVolume(starting_music_volume, 1.5f);
		}
		is_loading = false;
		yield return load_group.fadeRealTime(0f, 1.5f, CoroutineExtensions.easeInOutFunc);
	}

	private void updateProgress(float _progress)
	{
	}

	public void saveGameIcon(bool _success)
	{
		if (_success && !(fill_image == null))
		{
			fill_image.fillAmount = 0f;
			save_text.text = "";
			save_runner.run(saveGameIconAnimation());
		}
	}

	private IEnumerator saveGameIconAnimation()
	{
		yield return save_group.fadeRealTime(1f, 0.35f, CoroutineExtensions.easeInOutFunc);
		yield return fill_image.fill(1f, 0.85f, CoroutineExtensions.easeInOutFunc);
		save_text.text = "Saved!";
		yield return save_group.fadeRealTime(0f, 0.6f, CoroutineExtensions.easeInOutFunc);
	}
}
