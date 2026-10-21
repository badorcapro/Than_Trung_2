using System;
using System.Collections.Generic;
using GRGLib.Extensions.Random;
using TMPro;
using UnityEngine;

namespace GRGLib.TextAnimation;

public class WobbleTextAnimationManager : TextAnimationManager
{
	private Dictionary<int, (float, float)> long_term_random_offset_storage = new Dictionary<int, (float, float)>();

	public System.Random rng;

	public float speed;

	public float strength;

	private float base_offset;

	private float previous_offset;

	public WobbleTextAnimationManager(TMP_Text _text, System.Random _rng, float _speed, float _strength, bool _no_offset = false, int _start_index = 0, int _end_index = -1)
		: base(_text, _start_index, _end_index)
	{
		rng = _rng;
		speed = _speed;
		strength = _strength;
		base_offset = (_no_offset ? 0f : rng.nextFloat(0f, 1f));
	}

	public int getOffsetModulos()
	{
		return Mathf.FloorToInt((base_offset + Time.time * speed) % 4f);
	}

	public override Vector3 VertexOffset(Vector3 _vert_origin, TMP_MeshInfo _mesh, int _char_id, int _vertex_index)
	{
		float num = base_offset + Time.time * speed;
		num %= 4f;
		num = Mathf.Floor(num);
		num /= 4f;
		num *= strength;
		if (!long_term_random_offset_storage.ContainsKey(_char_id))
		{
			long_term_random_offset_storage[_char_id] = (-1f, -1f);
		}
		if (long_term_random_offset_storage[_char_id].Item1 != num)
		{
			long_term_random_offset_storage[_char_id] = (num, (strength * (float)rng.Next(0, 2) == 0f) ? 1 : (-1));
		}
		Vector3 vector = new Vector3(num * long_term_random_offset_storage[_char_id].Item2, num * long_term_random_offset_storage[_char_id].Item2, 0f);
		return _vert_origin + vector;
	}
}
