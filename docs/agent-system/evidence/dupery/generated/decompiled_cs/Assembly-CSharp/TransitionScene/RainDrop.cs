using System;
using System.Collections;
using GRGLib.Coroutines;
using GRGLib.Extensions.Random;
using UnityEngine;
using UnityEngine.UI;

namespace TransitionScene;

public class RainDrop : MonoBehaviour
{
	[SerializeField]
	private Image image;

	[SerializeField]
	private Vector2 target_pos_left;

	[SerializeField]
	private Vector2 target_pos_right;

	[SerializeField]
	private float y_diff_min = 100f;

	[SerializeField]
	private float y_diff_max = 200f;

	public void startRain(Sprite _sprite, System.Random _rng)
	{
		image.sprite = _sprite;
		image.SetNativeSize();
		rainAnimation(_rng).start(this);
	}

	private IEnumerator rainAnimation(System.Random _rng)
	{
		yield return base.transform.scaleTransform(1f, 0.15f, CoroutineExtensions.easeInOutFunc);
		yield return _rng.nextFloat(0f, 2f).wait();
		float num = (base.transform.localPosition.x - target_pos_left.x) / (target_pos_right.x - target_pos_left.x);
		Vector2 final_target = new Vector2(base.transform.localPosition.x, target_pos_left.y + (target_pos_right.y - target_pos_left.y) * num);
		Vector2 vector = new Vector2(base.transform.localPosition.x, base.transform.localPosition.y - _rng.nextFloat(y_diff_min, y_diff_max));
		Func<float, float> ease_func = CoroutineExtensions.easeInFunc;
		while (vector.y > final_target.y + y_diff_min)
		{
			yield return base.transform.moveTransform(vector, _rng.nextFloat(1.25f, 1.75f), ease_func);
			ease_func = CoroutineExtensions.noEaseFunc;
			vector = new Vector2(base.transform.localPosition.x, base.transform.localPosition.y - _rng.nextFloat(y_diff_min, y_diff_max));
		}
		float num2 = _rng.nextFloat(1.65f, 2.15f);
		image.fade(0f, _rng.nextFloat(0f, num2), CoroutineExtensions.easeInOutFunc).start(this);
		yield return base.transform.moveTransform(final_target, num2, CoroutineExtensions.easeOutFunc);
		UnityEngine.Object.Destroy(base.gameObject);
	}
}
