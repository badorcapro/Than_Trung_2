using System.Collections;
using System.Collections.Generic;
using GRGLib.Coroutines;
using UnityEngine;
using UnityEngine.UI;

public class RippleEffectAnimator : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private CanvasGroup group;

	[SerializeField]
	private Image inner;

	[SerializeField]
	private Image outter;

	[Header("Settings")]
	[SerializeField]
	private List<Sprite> animation_sprites;

	private CoroutineRunner inner_image_runner;

	private CoroutineRunner outter_image_runner;

	public void setUpAndPlay()
	{
		inner_image_runner = new CoroutineRunner(this);
		outter_image_runner = new CoroutineRunner(this);
		inner_image_runner.run(changeFrameAndFade(inner, 0f));
		outter_image_runner.run(changeFrameAndFade(outter, 0.3f).addCallback(delegate
		{
			Object.Destroy(base.gameObject);
		}));
		group.fade(1f, 0.5f).start(this);
	}

	private IEnumerator changeFrameAndFade(Image _image, float _wait_start)
	{
		_image.color = new Color(1f, 1f, 1f, 0f);
		yield return _wait_start.wait();
		_image.fade(1f, 0.15f, CoroutineExtensions.easeInOutFunc).start(this);
		for (int i = 0; i < animation_sprites.Count; i++)
		{
			_image.transform.localScale = new Vector3(1f, 1f, 1f);
			_image.sprite = animation_sprites[i];
			_image.SetNativeSize();
			yield return 0.1f.wait();
		}
		yield return _image.fade(0f, 0.25f, CoroutineExtensions.easeInOutFunc);
	}
}
