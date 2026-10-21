using System.Collections.Generic;
using System.Linq;
using GRGLib.Mono;
using TMPro;
using UnityEngine;

namespace GRGLib.UI;

[RequireComponent(typeof(SplineHandler))]
public class SplineText : CustomShapeText
{
	[SerializeField]
	private SplineHandler spline;

	private float getSplineDistance(List<Vector3> _points)
	{
		return _points.Aggregate((0f, _points[0]), ((float, Vector3) _a, Vector3 _p) => (_a.Item1 + (_a.Item2 - _p).magnitude, _p)).Item1;
	}

	protected override void warpText(TMP_TextInfo _text_info, float _scale)
	{
		int characterCount = _text_info.characterCount;
		List<Vector3> cubicCurve = spline.getCubicCurve();
		float splineDistance = getSplineDistance(cubicCurve);
		float num = 0f;
		int num2 = 1;
		float x = text.bounds.min.x;
		float x2 = text.bounds.max.x;
		for (int i = 0; i < characterCount; i++)
		{
			if (_text_info.characterInfo[i].isVisible)
			{
				int vertexIndex = _text_info.characterInfo[i].vertexIndex;
				int materialReferenceIndex = _text_info.characterInfo[i].materialReferenceIndex;
				Vector3[] vertices = _text_info.meshInfo[materialReferenceIndex].vertices;
				Vector3 vector = new Vector2((vertices[vertexIndex].x + vertices[vertexIndex + 2].x) / 2f, _text_info.characterInfo[i].baseLine);
				float num3 = (vector.x - x) / (x2 - x) * splineDistance;
				float num4 = 0f;
				while (num < num3 && num2 < cubicCurve.Count)
				{
					float magnitude = (cubicCurve[num2 - 1] - cubicCurve[num2]).magnitude;
					num4 = num;
					num += magnitude;
					num2++;
				}
				Vector3 vector2 = cubicCurve[num2 - 2] * _scale;
				Vector3 vector3 = cubicCurve[num2 - 1] * _scale;
				float num5 = (num3 - num4) / (num - num4);
				Vector3 vector4 = vector2 + (vector3 - vector2) * num5;
				vertices[vertexIndex] -= vector;
				vertices[vertexIndex + 1] -= vector;
				vertices[vertexIndex + 2] -= vector;
				vertices[vertexIndex + 3] -= vector;
				float z = 0f - Vector2.SignedAngle(to: new Vector3(1f, 0f, 0f), from: (vector3 - vector2).normalized);
				Matrix4x4 matrix4x = Matrix4x4.TRS(new Vector3(vector4.x, vector4.y, 0f), Quaternion.Euler(0f, 0f, z), Vector3.one);
				vertices[vertexIndex] = matrix4x.MultiplyPoint3x4(vertices[vertexIndex]);
				vertices[vertexIndex + 1] = matrix4x.MultiplyPoint3x4(vertices[vertexIndex + 1]);
				vertices[vertexIndex + 2] = matrix4x.MultiplyPoint3x4(vertices[vertexIndex + 2]);
				vertices[vertexIndex + 3] = matrix4x.MultiplyPoint3x4(vertices[vertexIndex + 3]);
				vertices[vertexIndex] += new Vector3(0f, vector.y);
				vertices[vertexIndex + 1] += new Vector3(0f, vector.y);
				vertices[vertexIndex + 2] += new Vector3(0f, vector.y);
				vertices[vertexIndex + 3] += new Vector3(0f, vector.y);
			}
		}
		text.UpdateVertexData();
	}

	protected override void Reset()
	{
		base.Reset();
		spline = GetComponent<SplineHandler>();
	}
}
