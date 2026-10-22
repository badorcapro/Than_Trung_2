using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using GRGLib.PropertyDrawers;
using Save;
using UnityEngine;
using UnityEngine.UI;

public class ModifiedUILineRenderer : Graphic
{
	[Serializable]
	public class UILineRendererTextureTileSettings
	{
		public bool force_tile_amount;

		[ConditionalField("force_tile_amount")]
		public Vector2 tile_amount = Vector2.one;

		[ConditionalField("force_tile_amount", false, new object[] { false })]
		public bool force_y_uv_1;

		public Vector2 getMaxUV(Texture _texture, float _total_distance, float _line_width)
		{
			if (force_tile_amount)
			{
				return tile_amount;
			}
			float num = (force_y_uv_1 ? ((float)_texture.height / _line_width) : 1f);
			return new Vector2(y: force_y_uv_1 ? 1f : (_line_width / (float)_texture.height), x: num * _total_distance / (float)_texture.width);
		}
	}

	[Header("Main")]
	[SerializeField]
	private Image dot_image;

	[SerializeField]
	private Image end_dot_image;

	[SerializeField]
	private float line_width = 1f;

	[SerializeField]
	private List<Vector2> points;

	[Header("Gradient")]
	[SerializeField]
	private bool use_gradient;

	[SerializeField]
	[ConditionalField("use_gradient")]
	private Gradient m_colour_gradient;

	[Header("Texture Settings")]
	[SerializeField]
	private Texture m_texture;

	[SerializeField]
	[ConditionalField("m_texture")]
	private bool tile_texture;

	[SerializeField]
	[MultiFieldConditional(new string[] { "tile_texture", "m_texture" })]
	private UILineRendererTextureTileSettings tile_settings;

	private HashSet<int> invisible_points = new HashSet<int>();

	public override Texture mainTexture
	{
		get
		{
			if (!(m_texture == null))
			{
				return m_texture;
			}
			return Graphic.s_WhiteTexture;
		}
	}

	public Gradient colour_gradient
	{
		get
		{
			return m_colour_gradient;
		}
		set
		{
			m_colour_gradient = value;
			SetVerticesDirty();
		}
	}

	protected bool try_tile
	{
		get
		{
			if (!(m_texture == null))
			{
				return tile_texture;
			}
			return false;
		}
	}

	public bool special_preset { get; private set; }

	public void setLineWidth(float _width)
	{
		line_width = _width;
		SetVerticesDirty();
	}

	public void setDotImage(Vector2 _position, Color _colour)
	{
		dot_image.color = _colour;
		dot_image.transform.localPosition = _position;
		end_dot_image.color = _colour;
	}

	public void setPoints(List<Vector2> _points)
	{
		points = _points;
		end_dot_image.transform.localPosition = _points[_points.Count - 1];
		SetVerticesDirty();
	}

	public void setSpecialPreset()
	{
		special_preset = true;
	}

	public void addPointWithIntermidiate(Vector2 _point, float _max_point_dist)
	{
		if (points.Count == 0)
		{
			addPoint(_point);
			return;
		}
		Vector2 vector = points[points.Count - 1];
		Vector2 vector2 = _point - vector;
		float magnitude = vector2.magnitude;
		if (magnitude <= _max_point_dist)
		{
			addPoint(_point);
			return;
		}
		List<Vector2> list = new List<Vector2>();
		while (magnitude > _max_point_dist)
		{
			vector += vector2.normalized * _max_point_dist;
			list.Add(vector);
			magnitude = (_point - vector).magnitude;
		}
		list.Add(_point);
		addPoints(list);
	}

	public void addPoint(Vector2 _point)
	{
		points.Add(_point);
		end_dot_image.transform.localPosition = _point;
		SetVerticesDirty();
	}

	public void addPoints(List<Vector2> _points)
	{
		points.AddRange(_points);
		if (points.Count > LineSaveData.max_points_save)
		{
			int count = points.Count - LineSaveData.max_points_save;
			points.RemoveRange(0, count);
			dot_image.transform.localPosition = points[0];
		}
		end_dot_image.transform.localPosition = _points[_points.Count - 1];
		SetVerticesDirty();
	}

	public List<Vector2> getPoints()
	{
		return points;
	}

	public void refreshVertices()
	{
		SetVerticesDirty();
	}

	public void makePointVisible(int _point)
	{
		invisible_points.Remove(_point);
		if (_point == 0)
		{
			dot_image.enabled = true;
		}
		else if (_point == points.Count - 1)
		{
			end_dot_image.enabled = true;
		}
		refreshVertices();
	}

	public void makeAllPointsInvisible()
	{
		dot_image.enabled = false;
		end_dot_image.enabled = false;
		for (int i = 0; i < points.Count; i++)
		{
			invisible_points.add(i);
		}
	}

	public void setInvisiblePoints(int _point)
	{
		invisible_points.Add(_point);
		if (_point == 0)
		{
			dot_image.enabled = false;
		}
		else if (_point == points.Count - 1)
		{
			end_dot_image.enabled = false;
		}
	}

	public bool isAllInvisible()
	{
		return invisible_points.Count == points.Count;
	}

	protected override void OnPopulateMesh(VertexHelper _vh)
	{
		_vh.Clear();
		if (points.Count == 0)
		{
			points = new List<Vector2>
			{
				Vector2.zero,
				Vector2.one
			};
		}
		float item = points.Aggregate((points[0], 0f), ((Vector2, float) _a, Vector2 _p) => (_p, _a.Item2 + (_p - _a.Item1).magnitude)).Item2;
		float num = 0f;
		Vector2 vector = (try_tile ? tile_settings.getMaxUV(mainTexture, item, line_width) : Vector2.one);
		Vector2 uv_ = new Vector2(0f, 0f);
		Vector2 uv_2 = new Vector2(0f, vector.y);
		int num2 = 0;
		Vector2 obj = addPointVertices(points[0], new Maybe<Vector2>(), calculateAngle(points[1], points[0]), _vh, uv_, uv_2, getPointColour(0, 0f));
		for (int i = 1; i < points.Count; i++)
		{
			num += (points[i] - points[i - 1]).magnitude;
			uv_ = new Vector2(num / item * vector.x, 0f);
			uv_2 = new Vector2(num / item * vector.x, vector.y);
			if (i < points.Count - 1)
			{
				calculateAngle(points[i], points[i + 1]);
			}
			obj = addPointVertices(points[i], obj.maybe(), calculateAngle(points[i - 1], points[i]), _vh, uv_, uv_2, getPointColour(i, num / item));
			_vh.AddTriangle(num2, num2 + 1, num2 + 2);
			_vh.AddTriangle(num2 + 2, num2 + 3, num2 + 1);
			num2 += 2;
		}
		UpdateMaterial();
	}

	private Color getPointColour(int _point, float _t)
	{
		Color result = (use_gradient ? (color * colour_gradient.Evaluate(_t)) : color);
		if (!invisible_points.Contains(_point))
		{
			return result;
		}
		result.a = 0f;
		return result;
	}

	private float calculateAngle(Vector2 _target, Vector2 _me)
	{
		return Mathf.Atan2(_target.y - _me.y, _target.x - _me.x) * (180f / MathF.PI) + 90f;
	}

	private Vector2 addPointVertices(Vector2 _point, Maybe<Vector2> _previous_upper, float _angle_pre, VertexHelper _vh, Vector2 _uv_1, Vector2 _uv_2, Color _colour)
	{
		UIVertex simpleVert = UIVertex.simpleVert;
		simpleVert.color = _colour;
		Vector2 vector = Quaternion.Euler(0f, 0f, _angle_pre) * new Vector2(line_width / 2f, 0f);
		if (_previous_upper.is_some)
		{
			float magnitude = (vector - (_previous_upper.value - _point)).magnitude;
			if ((-vector - (_previous_upper.value - _point)).magnitude > magnitude)
			{
				vector = -vector;
			}
		}
		simpleVert.position = _point - vector;
		simpleVert.uv0 = _uv_1;
		_vh.AddVert(simpleVert);
		Vector3 position = simpleVert.position;
		simpleVert.position = _point + vector;
		simpleVert.uv0 = _uv_2;
		_vh.AddVert(simpleVert);
		return position;
	}

	public bool tryGetSaveData(out LineSaveData _data)
	{
		if (points.Count < LineSaveData.max_points_save)
		{
			_data = new LineSaveData(points.copy(), invisible_points.toListSafe(), color);
			return true;
		}
		Debug.Log($"Line was too big and will not be saved! (Line Points: {points.Count}!)");
		_data = default(LineSaveData);
		return false;
	}

	public void setUpFromSave(LineSaveData _save_data)
	{
		points = _save_data.points.copy();
		invisible_points = _save_data.invisible.toHashSet();
		setDotImage(points[0], _save_data.line_colour);
		end_dot_image.color = _save_data.line_colour;
		end_dot_image.transform.localPosition = points[points.Count - 1];
		color = _save_data.line_colour;
		SetVerticesDirty();
	}
}
