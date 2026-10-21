using System;
using System.Collections;
using GRGLib.Coroutines;
using GRGLib.Extensions.Random;
using TMPro;
using UnityEngine;

namespace Visual;

public class CasinoChipsChangeMarker : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private CanvasGroup group;

	[SerializeField]
	private TMP_Text text;

	[Header("Settings")]
	[SerializeField]
	private Color gain_colour;

	[SerializeField]
	private Color lose_colour;

	public void setUpAndAnimate(int _change)
	{
		text.text = ((_change >= 0) ? "+" : "") + _change + TextHelper.chips_sprite_link_white.addColourToSpriteLinks((_change >= 0) ? gain_colour : lose_colour);
		text.color = ((_change >= 0) ? gain_colour : lose_colour);
		moveAndDestroy(RandomExtensions.freshRandom()).start(this);
	}

	public Color getColour()
	{
		return text.color;
	}

	private IEnumerator moveAndDestroy(System.Random _rng)
	{
		Vector2 target_pos;
		Vector2 start_target_pos = (target_pos = base.transform.localPosition + new Vector3(0f, 100 + _rng.Next(0, 100), 0f));
		Vector2 diff = new Vector2(-_rng.Next(75, 175), 0f);
		float duration = 1.05f;
		base.transform.moveTransformToMovingTarget(() => target_pos, duration, CoroutineExtensions.easeOutFunc).start(this);
		(duration - 0.4f).wait(delegate
		{
			group.fade(0f, 0.4f).start(this);
		}).start(this);
		float e = 0f;
		while (e < duration)
		{
			e += Time.deltaTime;
			target_pos = start_target_pos + e / duration * diff;
			yield return null;
		}
		StopAllCoroutines();
		UnityEngine.Object.Destroy(base.gameObject);
	}
}
