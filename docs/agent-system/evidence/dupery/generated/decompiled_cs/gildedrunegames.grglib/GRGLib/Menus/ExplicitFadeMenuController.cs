using System.Collections;
using GRGLib.Coroutines;
using UnityEngine;

namespace GRGLib.Menus;

[AddComponentMenu("GRGLib/Menu/Menu Controller (Explicit Fade)")]
public class ExplicitFadeMenuController : MenuController
{
	[Header("Animation Settings")]
	[SerializeField]
	private bool unscaled_delta_time = true;

	[SerializeField]
	[Range(0f, 1f)]
	private float open_alpha = 1f;

	[SerializeField]
	[Range(0f, 1f)]
	private float close_alpha;

	[SerializeField]
	private float open_anim_duration = 0.35f;

	[SerializeField]
	private float close_anim_duration = 0.35f;

	protected override IEnumerator openingMenuAnimation()
	{
		if (!unscaled_delta_time)
		{
			return menu_group.fade(open_alpha, open_anim_duration, CoroutineExtensions.easeInOutFunc);
		}
		return menu_group.fadeRealTime(open_alpha, open_anim_duration, CoroutineExtensions.easeInOutFunc);
	}

	protected override IEnumerator closingMenuAnimation()
	{
		if (!unscaled_delta_time)
		{
			return menu_group.fade(close_alpha, close_anim_duration, CoroutineExtensions.easeInOutFunc);
		}
		return menu_group.fadeRealTime(close_alpha, close_anim_duration, CoroutineExtensions.easeInOutFunc);
	}
}
