using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;

namespace GRGLib.Extensions.Unity;

public static class UnityExtensions
{
	public static List<GameObject> children(this Transform _trans)
	{
		List<GameObject> list = new List<GameObject>();
		for (int i = 0; i < _trans.childCount; i++)
		{
			list.Add(_trans.GetChild(i).gameObject);
		}
		return list;
	}

	public static List<Transform> childTransforms(this Transform _trans)
	{
		List<Transform> list = new List<Transform>();
		for (int i = 0; i < _trans.childCount; i++)
		{
			list.Add(_trans.GetChild(i));
		}
		return list;
	}

	public static T getFirstOccurenceInParents<T>(this Transform _start, int _max_depth = 10)
	{
		Transform transform = _start;
		for (int i = 0; i < _max_depth; i++)
		{
			if (transform.GetComponent<T>() != null)
			{
				return transform.GetComponent<T>();
			}
			transform = transform.parent;
		}
		throw new ArgumentException($"There is no type '{typeof(T)}' in any of this transforms parent. (in GenericHelper.getFirstHostileUIInParents)");
	}

	public static bool isPrefab(this GameObject _obj)
	{
		return _obj.scene.rootCount == 0;
	}

	public static AnimationCurve makeCurveLinear(this AnimationCurve _curve)
	{
		Vector2 vector = default(Vector2);
		Vector2 vector2 = default(Vector2);
		for (int i = 0; i < _curve.keys.Length; i++)
		{
			float inTangent = 0f;
			float outTangent = 0f;
			bool flag = false;
			bool flag2 = false;
			Keyframe key = _curve[i];
			if (i == 0)
			{
				inTangent = 0f;
				flag = true;
			}
			if (i == _curve.keys.Length - 1)
			{
				outTangent = 0f;
				flag2 = true;
			}
			if (!flag)
			{
				vector.x = _curve.keys[i - 1].time;
				vector.y = _curve.keys[i - 1].value;
				vector2.x = _curve.keys[i].time;
				vector2.y = _curve.keys[i].value;
				Vector2 vector3 = vector2 - vector;
				inTangent = vector3.y / vector3.x;
			}
			if (!flag2)
			{
				vector.x = _curve.keys[i].time;
				vector.y = _curve.keys[i].value;
				vector2.x = _curve.keys[i + 1].time;
				vector2.y = _curve.keys[i + 1].value;
				Vector2 vector3 = vector2 - vector;
				outTangent = vector3.y / vector3.x;
			}
			key.inTangent = inTangent;
			key.outTangent = outTangent;
			_curve.MoveKey(i, key);
		}
		return _curve;
	}

	public static RectTransform setAnchorAndOffset(this RectTransform _trans)
	{
		return _trans.setAnchorAndOffset(Vector2.zero, Vector2.one, Vector2.zero, Vector2.zero);
	}

	public static RectTransform setAnchorAndOffset(this RectTransform _trans, Vector2 _anchor_min, Vector2 _anchor_max, Vector2 _offset_min, Vector2 _offset_max)
	{
		_trans.anchorMin = _anchor_min;
		_trans.anchorMax = _anchor_max;
		_trans.offsetMin = _offset_min;
		_trans.offsetMax = _offset_max;
		return _trans;
	}

	public static UnityEvent<T> addListenerSmartly<T>(this UnityEvent<T> _u_event, UnityAction<T> _delegate)
	{
		_u_event.AddListener(_delegate);
		return _u_event;
	}

	public static UnityEvent<T1, T2> addListenerSmartly<T1, T2>(this UnityEvent<T1, T2> _u_event, UnityAction<T1, T2> _delegate)
	{
		_u_event.AddListener(_delegate);
		return _u_event;
	}

	public static UnityEvent<T> addFunction<T>(this UnityAction<T> _delegate)
	{
		return new UnityEvent<T>().addListenerSmartly(_delegate);
	}

	public static UnityEvent<T1, T2> addFunction<T1, T2>(this UnityAction<T1, T2> _delegate)
	{
		return new UnityEvent<T1, T2>().addListenerSmartly(_delegate);
	}

	public static CanvasGroup putOn(this CanvasGroup _group, bool _on = true)
	{
		_group.alpha = (_on ? 1 : 0);
		_group.interactable = _on;
		_group.blocksRaycasts = _on;
		return _group;
	}

	public static Image setAlpha(this Image _image, float _alpha)
	{
		_image.color = _image.color.setAlpha(_alpha);
		return _image;
	}

	public static SpriteRenderer setAlpha(this SpriteRenderer _sprite, float _alpha)
	{
		_sprite.color = _sprite.color.setAlpha(_alpha);
		return _sprite;
	}

	public static Color setAlpha(this Color _colour, float _alpha)
	{
		return new Color(_colour.r, _colour.g, _colour.b, _alpha);
	}

	public static Color invert(this Color _col)
	{
		Color.RGBToHSV(_col, out var H, out var S, out var V);
		return Color.HSVToRGB((H + 0.5f) % 1f, S, V);
	}

	public static void sizeToFit(this Image _image)
	{
		_image.sizeToFit(_image.rectTransform.sizeDelta);
	}

	public static void sizeToFit(this Image _image, float _size)
	{
		_image.sizeToFit(new Vector2(_size, _size));
	}

	public static void sizeToFit(this Image _image, Vector2 _size)
	{
		_image.SetNativeSize();
		Vector2 sizeDelta = _image.rectTransform.sizeDelta;
		Vector2 vector = new Vector2(_size.x / sizeDelta.x, _size.y / sizeDelta.y);
		float num = ((vector.x < vector.y) ? vector.x : vector.y);
		_image.rectTransform.sizeDelta *= num;
	}

	public static void sizeDownToFit(this Image _image, float _size)
	{
		_image.sizeDownToFit(new Vector2(_size, _size));
	}

	public static void sizeDownToFit(this Image _image, Vector2 _size)
	{
		_image.sizeToFitConditional(_size, (Vector2 _ns, Vector2 _s) => _ns.x > _s.x || _ns.y > _s.y);
	}

	public static void sizeUpToFit(this Image _image, float _size)
	{
		_image.sizeUpToFit(new Vector2(_size, _size));
	}

	public static void sizeUpToFit(this Image _image, Vector2 _size)
	{
		_image.sizeToFitConditional(_size, (Vector2 _ns, Vector2 _s) => _ns.x < _s.x && _ns.y < _s.y);
	}

	public static void sizeToFitConditional(this Image _image, Vector2 _size, Func<Vector2, Vector2, bool> _condition)
	{
		_image.SetNativeSize();
		Vector2 sizeDelta = _image.rectTransform.sizeDelta;
		if (_condition(sizeDelta, _size))
		{
			Vector2 vector = new Vector2(_size.x / sizeDelta.x, _size.y / sizeDelta.y);
			float num = ((vector.x < vector.y) ? vector.x : vector.y);
			_image.rectTransform.sizeDelta *= num;
		}
	}

	public static Selectable setNormalColour(this Selectable _selectable, Color _colour)
	{
		ColorBlock colors = _selectable.colors;
		colors.normalColor = _colour;
		_selectable.colors = colors;
		return _selectable;
	}

	public static Selectable setSelectedColour(this Selectable _selectable, Color _colour)
	{
		ColorBlock colors = _selectable.colors;
		colors.selectedColor = _colour;
		_selectable.colors = colors;
		return _selectable;
	}

	public static Selectable setHighlightedColour(this Selectable _selectable, Color _colour)
	{
		ColorBlock colors = _selectable.colors;
		colors.highlightedColor = _colour;
		_selectable.colors = colors;
		return _selectable;
	}

	public static Selectable setPressedColour(this Selectable _selectable, Color _colour)
	{
		ColorBlock colors = _selectable.colors;
		colors.pressedColor = _colour;
		_selectable.colors = colors;
		return _selectable;
	}

	public static Selectable setDisabledColour(this Selectable _selectable, Color _colour)
	{
		ColorBlock colors = _selectable.colors;
		colors.disabledColor = _colour;
		_selectable.colors = colors;
		return _selectable;
	}

	public static void setNavigationUp(this Selectable _selectable, Selectable _up)
	{
		Navigation navigation = _selectable.navigation;
		navigation.selectOnUp = _up;
		_selectable.navigation = navigation;
	}

	public static void setNavigationDown(this Selectable _selectable, Selectable _down)
	{
		Navigation navigation = _selectable.navigation;
		navigation.selectOnDown = _down;
		_selectable.navigation = navigation;
	}

	public static void setNavigationLeft(this Selectable _selectable, Selectable _left)
	{
		Navigation navigation = _selectable.navigation;
		navigation.selectOnLeft = _left;
		_selectable.navigation = navigation;
	}

	public static void setNavigationRight(this Selectable _selectable, Selectable _right)
	{
		Navigation navigation = _selectable.navigation;
		navigation.selectOnRight = _right;
		_selectable.navigation = navigation;
	}

	public static void setNavigationVertical(this Selectable _selectable, Selectable _up, Selectable _down)
	{
		Navigation navigation = _selectable.navigation;
		navigation.selectOnUp = _up;
		navigation.selectOnDown = _down;
		_selectable.navigation = navigation;
	}

	public static void setNavigationHorizontal(this Selectable _selectable, Selectable _left, Selectable _right)
	{
		Navigation navigation = _selectable.navigation;
		navigation.selectOnLeft = _left;
		navigation.selectOnRight = _right;
		_selectable.navigation = navigation;
	}

	public static void setNavigation(this Selectable _selectable, Selectable _up, Selectable _down, Selectable _left, Selectable _right)
	{
		Navigation navigation = _selectable.navigation;
		navigation.selectOnUp = _up;
		navigation.selectOnDown = _down;
		navigation.selectOnLeft = _left;
		navigation.selectOnRight = _right;
		_selectable.navigation = navigation;
	}

	public static void clearNavigation(this Selectable _selectable)
	{
		_selectable.setNavigation(null, null, null, null);
	}

	public static Vector3Int worldToTerrainSpace(this Vector3 _world_space, Terrain _t)
	{
		TerrainData terrainData = _t.terrainData;
		Vector3 vector = _world_space - _t.GetPosition();
		return new Vector3Int(Mathf.RoundToInt(vector.x / terrainData.size.x * (float)terrainData.alphamapWidth), 0, Mathf.RoundToInt(vector.z / terrainData.size.z * (float)terrainData.alphamapHeight));
	}

	public static Vector2 getPositionToUI(this Canvas _canvas, Vector2 _position)
	{
		return (_canvas.transform as RectTransform).sizeDelta.getPositionToUI(_position);
	}

	public static Vector2 getPositionToUI(this Vector2 _canvas_size, Vector2 _position)
	{
		float num = _canvas_size.x / _canvas_size.y;
		float num2 = (float)Screen.width / (float)Screen.height;
		Vector2 vector = _canvas_size;
		if (num2 > num)
		{
			vector.x *= num2 / num;
		}
		else if (num2 < num)
		{
			vector.y /= num2 / num;
		}
		Vector2 vector2 = (_canvas_size - vector) / 2f;
		return _position * new Vector2(vector.x / (float)Screen.width, vector.y / (float)Screen.height) + vector2 - _canvas_size / 2f;
	}
}
