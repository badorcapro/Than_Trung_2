using System.Collections.Generic;
using GRGLib.Extensions;
using GRGLib.Extensions.Collections;
using UnityEngine;

namespace GRGLib.TextAnimation;

[AddComponentMenu("GRGLib/TextAnimations/AnimationCurveText")]
public class AnimationCurveText : TextAnimation
{
	[SerializeField]
	private AnimationCurve curve;

	[SerializeField]
	private float speed = 0.1f;

	[SerializeField]
	private float scale = 3f;

	private CurveTextAnimationManager manager;

	private int loop_time
	{
		get
		{
			if (!curve.postWrapMode.equalToAny(WrapMode.Loop, WrapMode.PingPong))
			{
				return 1;
			}
			return 2;
		}
	}

	protected override List<TextAnimationManager> animation_manager => ((TextAnimationManager)manager).makeListFromItem();

	public void Start()
	{
		manager = new CurveTextAnimationManager(text_base, curve, speed, scale, loop_time);
	}
}
