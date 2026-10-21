using System.Collections.Generic;
using GRGLib.Coroutines;
using GRGLib.TextAnimation;
using TMPro;
using UnityEngine;

namespace Hover;

public class ResetTextAnimationManager : TextAnimationManager
{
	private float time;

	private float e;

	private float duration;

	private Dictionary<(int, int), (Vector3, Vector3)> starting_pos = new Dictionary<(int, int), (Vector3, Vector3)>();

	private TextAnimationManager text_animator;

	public ResetTextAnimationManager(TextAnimationManager _animator, float _duration)
		: base(_animator.text, _animator.start_index, _animator.end_index)
	{
		text_animator = _animator;
		duration = _duration;
	}

	public override void onUpdate()
	{
		if (!(time > duration))
		{
			time += Time.deltaTime;
			e = CoroutineExtensions.easeInOutFunc(time / duration);
		}
	}

	public override Vector3 VertexOffset(Vector3 _vert_origin, TMP_MeshInfo _mesh, int _char_id, int _vertex_index)
	{
		if (!starting_pos.ContainsKey((_char_id, _vertex_index)))
		{
			Vector3 vector = text_animator.VertexOffset(_vert_origin, _mesh, _char_id, _vertex_index);
			starting_pos[(_char_id, _vertex_index)] = (vector, _vert_origin - vector);
		}
		return starting_pos[(_char_id, _vertex_index)].Item1 + starting_pos[(_char_id, _vertex_index)].Item2 * e;
	}
}
