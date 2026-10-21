using System.Collections.Generic;
using GRGLib.Extensions.Vector;
using GRGLib.Maybe;
using TMPro;
using UnityEngine;

namespace GRGLib.TextAnimation;

public class ShakeTextAnimationManager : TextAnimationManager
{
	public float power;

	public bool shake_vertices_seperatly;

	private Maybe<Dictionary<int, Vector2>> shake_pos = new Maybe<Dictionary<int, Vector2>>();

	public ShakeTextAnimationManager(TMP_Text _text, float _power, bool _shake_vertices_seperatly = false, int _start_index = 0, int _end_index = -1)
		: base(_text, _start_index, _end_index)
	{
		power = _power;
		shake_vertices_seperatly = _shake_vertices_seperatly;
	}

	public override void onUpdate()
	{
		base.onUpdate();
		if (shake_pos.is_some)
		{
			shake_pos = new Dictionary<int, Vector2>().maybe();
		}
	}

	public override Vector3 VertexOffset(Vector3 _vert_origin, TMP_MeshInfo _mesh, int _char_id, int _vertex_index)
	{
		if (shake_vertices_seperatly)
		{
			return _vert_origin.addVector2(Random.insideUnitCircle * power);
		}
		if (!shake_pos.is_some)
		{
			shake_pos = new Dictionary<int, Vector2>().maybe();
		}
		Vector2 vector;
		if (shake_pos.value.ContainsKey(_char_id))
		{
			vector = shake_pos.value[_char_id];
		}
		else
		{
			vector = Random.insideUnitCircle * power;
			shake_pos.value[_char_id] = vector;
		}
		return _vert_origin.addVector2(vector);
	}
}
