using System.Collections;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class GlobalVolumeHandler : MonoBehaviour
{
	private static float film_grain_multi = 1f;

	private static float chromatic_aberation_multi = 0.08f;

	[Header("References")]
	[SerializeField]
	private Volume global_volume;

	public static GlobalVolumeHandler instance { get; private set; }

	private void Awake()
	{
		if (instance != null && instance != this)
		{
			Object.Destroy(base.gameObject);
			return;
		}
		Object.DontDestroyOnLoad(base.gameObject);
		instance = this;
		StartCoroutine(startNextFrame());
	}

	private IEnumerator startNextFrame()
	{
		yield return new WaitForEndOfFrame();
		onStartup();
	}

	private void onStartup()
	{
		setFilmGrain(SettingsHandler.film_grain);
		setChromaticAberation(SettingsHandler.chromatic_aberation);
	}

	public void setFilmGrain(float _film_grain)
	{
		if (global_volume.profile.TryGet<FilmGrain>(out var component))
		{
			component.active = _film_grain > 0f;
			if (component.active)
			{
				component.intensity.value = _film_grain * film_grain_multi;
			}
		}
	}

	public void setChromaticAberation(float _chromatic_aberation)
	{
		if (global_volume.profile.TryGet<ChromaticAberration>(out var component))
		{
			component.active = _chromatic_aberation > 0f;
			if (component.active)
			{
				component.intensity.value = _chromatic_aberation * chromatic_aberation_multi;
			}
		}
	}

	private void Reset()
	{
		global_volume = GetComponent<Volume>();
	}
}
