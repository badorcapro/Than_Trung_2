using System.Collections.Generic;
using GRGLib.Extensions.Collections;
using UnityEngine;

namespace GRGLib.TextAnimation;

[AddComponentMenu("GRGLib/TextAnimations/ShakeText")]
public class ShakeText : TextAnimation
{
	[SerializeField]
	private float power = 1f;

	[SerializeField]
	private bool shake_vertices_seperatly;

	private ShakeTextAnimationManager manager;

	protected override List<TextAnimationManager> animation_manager => ((TextAnimationManager)manager).makeListFromItem();

	public void Start()
	{
		manager = new ShakeTextAnimationManager(text_base, power, shake_vertices_seperatly);
	}
}
