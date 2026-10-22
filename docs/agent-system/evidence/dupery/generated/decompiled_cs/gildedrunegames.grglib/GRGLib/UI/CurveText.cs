using TMPro;
using UnityEngine;

namespace GRGLib.UI;

public class CurveText : CustomShapeText
{
	[SerializeField]
	protected AnimationCurve curve = new AnimationCurve(new Keyframe(0f, -1f, 0f, 4.2f), new Keyframe(0.5f, 1f), new Keyframe(1f, -1f, -4.2f, 0f));

	public AnimationCurve Curve
	{
		get
		{
			return curve;
		}
		set
		{
			setCurve(value);
		}
	}

	private void Awake()
	{
		curve.preWrapMode = WrapMode.Once;
		curve.postWrapMode = WrapMode.Once;
	}

	public void setCurve(AnimationCurve _curve)
	{
		if (curve != _curve)
		{
			curve = _curve;
			warpText();
		}
	}

	protected override void warpText(TMP_TextInfo _text_info, float _scale)
	{
		int characterCount = _text_info.characterCount;
		float x = text.bounds.min.x;
		float x2 = text.bounds.max.x;
		float num = actual_curve_scale;
		for (int i = 0; i < characterCount; i++)
		{
			if (_text_info.characterInfo[i].isVisible)
			{
				int vertexIndex = _text_info.characterInfo[i].vertexIndex;
				int materialReferenceIndex = _text_info.characterInfo[i].materialReferenceIndex;
				Vector3[] vertices = _text_info.meshInfo[materialReferenceIndex].vertices;
				Vector3 vector = new Vector2((vertices[vertexIndex].x + vertices[vertexIndex + 2].x) / 2f, _text_info.characterInfo[i].baseLine);
				vertices[vertexIndex] += -vector;
				vertices[vertexIndex + 1] += -vector;
				vertices[vertexIndex + 2] += -vector;
				vertices[vertexIndex + 3] += -vector;
				float num2 = (vector.x - x) / (x2 - x);
				float num3 = num2 + 0.0001f;
				float y = curve.Evaluate(num2) * num;
				float y2 = curve.Evaluate(num3) * num;
				Vector3 lhs = new Vector3(1f, 0f, 0f);
				Vector3 rhs = new Vector3(num3 * (x2 - x) + x, y2) - new Vector3(vector.x, y);
				float num4 = Mathf.Acos(Vector3.Dot(lhs, rhs.normalized)) * 57.29578f;
				float z = ((Vector3.Cross(lhs, rhs).z > 0f) ? num4 : (360f - num4));
				Matrix4x4 matrix4x = Matrix4x4.TRS(new Vector3(0f, y, 0f), Quaternion.Euler(0f, 0f, z), Vector3.one);
				vertices[vertexIndex] = matrix4x.MultiplyPoint3x4(vertices[vertexIndex]);
				vertices[vertexIndex + 1] = matrix4x.MultiplyPoint3x4(vertices[vertexIndex + 1]);
				vertices[vertexIndex + 2] = matrix4x.MultiplyPoint3x4(vertices[vertexIndex + 2]);
				vertices[vertexIndex + 3] = matrix4x.MultiplyPoint3x4(vertices[vertexIndex + 3]);
				vertices[vertexIndex] += vector;
				vertices[vertexIndex + 1] += vector;
				vertices[vertexIndex + 2] += vector;
				vertices[vertexIndex + 3] += vector;
			}
		}
		text.UpdateVertexData();
	}
}
