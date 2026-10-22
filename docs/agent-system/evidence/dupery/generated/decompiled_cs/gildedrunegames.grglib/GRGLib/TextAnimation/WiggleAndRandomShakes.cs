using System;
using GRGLib.Extensions.Random;
using TMPro;
using UnityEngine;

namespace GRGLib.TextAnimation;

public class WiggleAndRandomShakes : CurveTextAnimationManager
{
	private static float min_time_between_shakes = 0.4f;

	private static float max_time_between_shakes = 0.75f;

	private static float shake_time = 0.3f;

	private ShakeTextAnimationManager shake_manager;

	private float time_remaining;

	private bool shake;

	private System.Random rng = RandomExtensions.freshRandom();

	public WiggleAndRandomShakes(TMP_Text _text, ShakeTextAnimationManager _shake_manager, AnimationCurve _curve)
		: base(_text, _curve)
	{
		time_remaining = rng.nextFloat(min_time_between_shakes, max_time_between_shakes);
		shake = false;
		shake_manager = _shake_manager;
	}

	public override Vector3 VertexOffset(Vector3 _vert_origin, TMP_MeshInfo _mesh, int _char_id, int _vertex_index)
	{
		if (shake)
		{
			_vert_origin = shake_manager.VertexOffset(_vert_origin, _mesh, _char_id, _vertex_index);
		}
		return base.VertexOffset(_vert_origin, _mesh, _char_id, _vertex_index);
	}

	public override void onUpdate()
	{
		time_remaining -= Time.deltaTime;
		if (time_remaining <= 0f)
		{
			if (shake)
			{
				time_remaining = rng.nextFloat(min_time_between_shakes, max_time_between_shakes);
			}
			else
			{
				time_remaining = shake_time;
			}
			shake = !shake;
		}
		if (shake)
		{
			shake_manager.onUpdate();
		}
		base.onUpdate();
	}
}
