using System;
using System.Collections;
using GRGLib.Coroutines;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace GRGLib.Mono;

public class AsyncSceneLoader
{
	private bool allow_scene_activation;

	public bool is_loading_scene { get; private set; }

	public AsyncSceneLoader(MonoBehaviour _mono, string _scene_name, Action _callback, bool _allow_immidiate_activation = false)
	{
		LoadScene(_scene_name, _allow_immidiate_activation, delegate
		{
		}, () => true, _callback).start(_mono);
	}

	public AsyncSceneLoader(MonoBehaviour _mono, string _scene_name, Action _callback, Action<float> _progress, bool _allow_immidiate_activation = false)
	{
		LoadScene(_scene_name, _allow_immidiate_activation, _progress, () => true, _callback).start(_mono);
	}

	public AsyncSceneLoader(MonoBehaviour _mono, string _scene_name, Action _callback, Action<float> _progress, Func<bool> _additional_activation_check, bool _allow_immidiate_activation = false)
	{
		LoadScene(_scene_name, _allow_immidiate_activation, _progress, _additional_activation_check, _callback).start(_mono);
	}

	private IEnumerator LoadScene(string _scene, bool _allow_immidiate_scene_activation, Action<float> _progress, Func<bool> _additional_activation_check, Action _callback)
	{
		is_loading_scene = true;
		yield return null;
		Debug.Log("Starting Async Scene Load: " + _scene);
		AsyncOperation asyncOperation = SceneManager.LoadSceneAsync(_scene);
		asyncOperation.allowSceneActivation = false;
		allow_scene_activation = _allow_immidiate_scene_activation;
		while (!asyncOperation.isDone || !_additional_activation_check())
		{
			_progress(asyncOperation.progress);
			if (asyncOperation.progress >= 0.9f && allow_scene_activation)
			{
				asyncOperation.allowSceneActivation = true;
			}
			yield return null;
		}
		is_loading_scene = false;
		_callback();
	}

	public void allowSceneActivation()
	{
		allow_scene_activation = true;
	}

	public IEnumerator waitForSceneLoad()
	{
		while (is_loading_scene)
		{
			yield return null;
		}
	}
}
