using System.Collections.Generic;
using GRGLib.Coroutines;
using GRGLib.Extensions.Vector;
using GRGLib.Generic;
using GRGLib.TextAnimation;
using TMPro;
using UnityEngine;

namespace Hover;

public class BobTextAnimationManager : TextAnimationManager
{
	private float animation_time;

	private float duration;

	private MinMaxFloat target_scale;

	private float scale;

	private Dictionary<int, Vector2> center_pos = new Dictionary<int, Vector2>();

	private Dictionary<(int, int), (Vector2, Vector2)> verts_pos = new Dictionary<(int, int), (Vector2, Vector2)>();

	public BobTextAnimationManager(TMP_Text _text, MinMaxFloat _target_scale, float _duration, int _start_index = 0, int _end_index = -1)
		: base(_text, _start_index, _end_index)
	{
		animation_time = 0f - _duration;
		duration = _duration;
		target_scale = _target_scale;
		scale = 0f;
	}

	public override void onUpdate()
	{
		animation_time += Time.deltaTime;
		animation_time %= 2f * duration;
		if (animation_time < 0f)
		{
			scale = target_scale.max * CoroutineExtensions.easeInOutFunc((duration + animation_time) / duration);
		}
		else if (animation_time < duration)
		{
			scale = target_scale.max + (target_scale.min - target_scale.max) * CoroutineExtensions.easeInOutFunc(animation_time / duration);
		}
		else
		{
			scale = target_scale.min + (target_scale.max - target_scale.min) * CoroutineExtensions.easeInOutFunc((animation_time - duration) / duration);
		}
	}

	public override Vector3 VertexOffset(Vector3 _vert_origin, TMP_MeshInfo _mesh, int _char_id, int _vertex_index)
	{
		if (!verts_pos.ContainsKey((_char_id, _vertex_index)))
		{
			if (!center_pos.ContainsKey(_char_id))
			{
				int vertexIndex = text.textInfo.characterInfo[_char_id].vertexIndex;
				Vector3[] vertices = _mesh.vertices;
				center_pos[_char_id] = (vertices[vertexIndex] + vertices[vertexIndex + 2]) / 2f;
			}
			Vector2 item = _vert_origin.addVector2(-center_pos[_char_id]);
			verts_pos[(_char_id, _vertex_index)] = (_vert_origin, item);
		}
		return verts_pos[(_char_id, _vertex_index)].Item1 + verts_pos[(_char_id, _vertex_index)].Item2 * scale;
	}
}
