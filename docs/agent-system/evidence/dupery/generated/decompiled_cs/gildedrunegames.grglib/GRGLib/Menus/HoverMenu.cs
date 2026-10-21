using System.Collections;
using GRGLib.Coroutines;
using UnityEngine;

namespace GRGLib.Menus;

public class HoverMenu : HoverMenuBase
{
	[Header("References")]
	[SerializeField]
	protected CanvasGroup group;

	[Header("Animation Settings")]
	[SerializeField]
	protected float opening_duration = 0.6f;

	[SerializeField]
	protected float closing_duration = 0.6f;

	[Header("Misc Settings")]
	[SerializeField]
	private bool change_interactable_state = true;

	protected override IEnumerator openingAnimation()
	{
		yield return group.fadeRealTime(1f, opening_duration, CoroutineExtensions.easeInOutFunc);
	}

	protected override IEnumerator closingAnimation()
	{
		yield return group.fadeRealTime(0f, closing_duration, CoroutineExtensions.easeInOutFunc);
	}

	protected override void onMenuOpen()
	{
		base.onMenuOpen();
		if (change_interactable_state)
		{
			group.interactable = true;
			group.blocksRaycasts = true;
		}
	}

	protected override void onMenuClosing()
	{
		base.onMenuClosing();
		if (change_interactable_state)
		{
			group.interactable = false;
			group.blocksRaycasts = false;
		}
	}

	private void Reset()
	{
		group = GetComponent<CanvasGroup>();
	}
}
