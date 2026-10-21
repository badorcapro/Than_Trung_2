using TMPro;
using UnityEngine;

namespace GRGLib.TextAnimation;

public class CurveTextAnimationManager : TextAnimationManager
{
	public AnimationCurve curve;

	public float speed = 1f;

	public float strength = 1f;

	public int loop_after = 2;

	private float animate_time;

	private int char_count;

	public CurveTextAnimationManager(TMP_Text _text, AnimationCurve _curve, float _speed = 1f, float _strength = 1f, int _loop_after = 2, int _start_index = 0, int _end_index = -1)
		: base(_text, _start_index, _end_index)
	{
		curve = _curve;
		speed = _speed;
		strength = _strength;
		loop_after = _loop_after;
		char_count = text.text.Length;
	}

	public override Vector3 VertexOffset(Vector3 _vert_origin, TMP_MeshInfo _mesh, int _char_id, int _vertex_index)
	{
		float y = curve.Evaluate((float)_char_id / (float)char_count + animate_time) * strength;
		return _vert_origin + new Vector3(0f, y, 0f);
	}

	public override void onUpdate()
	{
		base.onUpdate();
		char_count = text.text.Length;
		animate_time += Time.deltaTime * speed;
		animate_time %= curve[curve.length - 1].time * (float)loop_after;
	}
}
