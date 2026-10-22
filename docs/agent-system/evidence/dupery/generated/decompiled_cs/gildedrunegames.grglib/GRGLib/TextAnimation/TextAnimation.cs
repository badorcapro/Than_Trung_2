using System.Collections.Generic;
using TMPro;
using UnityEngine;

namespace GRGLib.TextAnimation;

public abstract class TextAnimation : MonoBehaviour
{
	[SerializeField]
	protected TMP_Text text_base;

	[SerializeField]
	private bool start_animated = true;

	protected string text_string => text_base.text;

	public bool animated { get; protected set; } = true;

	protected abstract List<TextAnimationManager> animation_manager { get; }

	protected virtual bool update_this_frame => true;

	private void Awake()
	{
		animated = start_animated;
	}

	public void toggleAnimation()
	{
		animated = !animated;
	}

	public void startAnimation()
	{
		animated = true;
	}

	public void stopAnimation()
	{
		animated = false;
	}

	private void Update()
	{
		if (animated && update_this_frame)
		{
			text_base.updateGeometry(animation_manager);
		}
	}
}
