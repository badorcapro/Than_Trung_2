using System.Collections.Generic;
using GRGLib.Extensions.Vector;
using GRGLib.TextAnimation;
using TMPro;
using UnityEngine;

namespace Hover;

public class HoveringTextAnimationManager : TextAnimationManager
{
	public float power;

	private Dictionary<int, Vector2> center_pos = new Dictionary<int, Vector2>();

	private Dictionary<(int, int), (Vector2, Vector2)> verts_pos = new Dictionary<(int, int), (Vector2, Vector2)>();

	private Dictionary<int, float> wave = new Dictionary<int, float>();

	private float animation_time;

	private float speed;

	private int breadth = 2;

	private int char_count;

	private bool animation_start = true;

	private float base_scale_up;

	private float init_scale_up;

	public HoveringTextAnimationManager(TMP_Text _text, float _init_scale, float _power, float _duration, int _start_index = 0, int _end_index = -1)
		: base(_text, _start_index, _end_index)
	{
		power = _power;
		init_scale_up = _init_scale;
		char_count = end_index - start_index;
		speed = (float)char_count / _duration;
		breadth = ((char_count % 2 == 1) ? (char_count / 2) : (char_count / 2 - 1));
		animation_time -= breadth;
		animation_start = true;
	}

	public override void onUpdate()
	{
		wave.Clear();
		animation_time += Time.deltaTime * speed;
		animation_time %= char_count;
		if (animation_start)
		{
			base_scale_up = 1f - Mathf.Min(((float)breadth - animation_time) / (2f * (float)breadth), 1f);
			verts_pos.Clear();
			for (int i = start_index; i < end_index; i++)
			{
				wave[i] = 0f;
			}
		}
		int num = ((!animation_start) ? (Mathf.FloorToInt(animation_time) - breadth) : 0);
		int num2 = Mathf.CeilToInt(animation_time) + breadth;
		for (int j = num; j <= num2; j++)
		{
			int num3 = ((j < 0) ? (j + char_count) : j) % char_count;
			wave[start_index + num3] = Mathf.Max(((float)breadth - Mathf.Abs(animation_time - (float)j)) / (float)breadth, 0f);
		}
		if (animation_start && (animation_time > (float)breadth || num2 >= char_count))
		{
			animation_start = false;
		}
	}

	public override Vector3 VertexOffset(Vector3 _vert_origin, TMP_MeshInfo _mesh, int _char_id, int _vertex_index)
	{
		if (!wave.ContainsKey(_char_id))
		{
			return _vert_origin;
		}
		if (!verts_pos.ContainsKey((_char_id, _vertex_index)))
		{
			if (!center_pos.ContainsKey(_char_id))
			{
				int vertexIndex = text.textInfo.characterInfo[_char_id].vertexIndex;
				Vector3[] vertices = _mesh.vertices;
				center_pos[_char_id] = (vertices[vertexIndex] + vertices[vertexIndex + 2]) / 2f;
			}
			Vector2 vector = _vert_origin.addVector2(-center_pos[_char_id]);
			verts_pos[(_char_id, _vertex_index)] = (_vert_origin.addVector2(vector * base_scale_up * init_scale_up), vector * power);
		}
		return verts_pos[(_char_id, _vertex_index)].Item1 + verts_pos[(_char_id, _vertex_index)].Item2 * wave[_char_id];
	}
}
