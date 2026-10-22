using System.Collections.Generic;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Random;
using UnityEngine;

namespace GRGLib.TextAnimation;

[AddComponentMenu("GRGLib/TextAnimations/WobblyText")]
public class WobblyText : TextAnimation
{
	[SerializeField]
	private float speed = 4f;

	[SerializeField]
	private float strength = 0.03f;

	[SerializeField]
	private bool allow_random_offset = true;

	private WobbleTextAnimationManager manager;

	private int last_index;

	protected override List<TextAnimationManager> animation_manager => ((TextAnimationManager)manager).makeListFromItem();

	protected override bool update_this_frame
	{
		get
		{
			int offsetModulos = manager.getOffsetModulos();
			if (last_index == offsetModulos)
			{
				return false;
			}
			last_index = offsetModulos;
			return true;
		}
	}

	private void Start()
	{
		manager = new WobbleTextAnimationManager(text_base, RandomExtensions.freshRandom(), speed, strength, !allow_random_offset);
	}
}
