using System;
using System.Collections;
using System.Collections.Generic;
using GRGLib.Coroutines;
using UnityEngine;

public static class Jiggler
{
	public static IEnumerator jiggle(this Transform _transform)
	{
		return _transform.jiggle((5f, 8f));
	}

	public static IEnumerator jiggle(this Transform _transform, (float, float) _rotation_range, float _rotation_base = 0f, float _scale = 1.08f, float _duration = 0.75f)
	{
		return _transform.jiggle(_rotation_range, _rotation_base, _scale, _duration, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator jiggle(this Transform _transform, (float, float) _rotation_range, float _rotation_base, float _scale, float _duration, Func<float> _delta_time)
	{
		float rotation_offset = UnityEngine.Random.Range(_rotation_range.Item1, _rotation_range.Item2);
		bool num = UnityEngine.Random.Range(0, 2) == 0;
		_transform.localScale = new Vector3(_scale, _scale, 1f);
		_transform.localRotation = Quaternion.Euler(0f, 0f, _rotation_base + rotation_offset);
		if (num)
		{
			rotation_offset *= -1f;
		}
		float scale_diff = 1f - _scale;
		yield return CoroutineLibrary.doActionForTime(delegate(float _f)
		{
			float num2 = _scale + scale_diff * _f;
			_transform.localScale = new Vector3(num2, num2, 1f);
			_transform.localEulerAngles = new Vector3(0f, 0f, _rotation_base + rotation_offset * (1f - _f));
		}, _duration, CoroutineExtensions.easeOutElasticFunc, _delta_time);
		_transform.localScale = new Vector3(1f, 1f, 1f);
		_transform.localEulerAngles = new Vector3(0f, 0f, _rotation_base);
	}

	public static IEnumerator jiggleAnim(MonoBehaviour _mono)
	{
		float num = UnityEngine.Random.Range(8f, 12f);
		bool flag = UnityEngine.Random.Range(0, 2) == 0;
		if (flag)
		{
			num *= -1f;
		}
		_mono.transform.localScale = new Vector3(1.1f, 1.1f, 1f);
		_mono.transform.rotation = Quaternion.Euler(0f, 0f, num);
		_mono.StartCoroutine(_mono.transform.scaleTransform(1f, 0.8f, CoroutineExtensions.easeOutElasticFunc));
		yield return _mono.transform.rotateTransformDirection(0f, 0.8f, !flag, CoroutineExtensions.easeOutElasticFunc);
	}

	public static IEnumerator jiggleAnim(MonoBehaviour _mono, List<Transform> _t_list, Vector2 _range)
	{
		foreach (Transform item in _t_list)
		{
			float num = UnityEngine.Random.Range(_range.x, _range.y);
			bool flag = UnityEngine.Random.Range(0, 2) == 0;
			if (flag)
			{
				num *= -1f;
			}
			item.localScale = new Vector3(1.1f, 1.1f, 1f);
			item.rotation = Quaternion.Euler(0f, 0f, num);
			item.scaleTransform(1f, 0.8f, CoroutineExtensions.easeOutElasticFunc).start(_mono);
			item.rotateTransformDirection(0f, 0.8f, !flag, CoroutineExtensions.easeOutElasticFunc).start(_mono);
		}
		yield return 0.8f.wait();
	}

	public static IEnumerator jiggleFuseAnim(MonoBehaviour _mono, Vector2 _jiggle_range, List<List<Transform>> _fuse_groups, float _fuse_length = 0.2f)
	{
		for (int i = 0; i < _fuse_groups.Count; i++)
		{
			jiggleAnim(_mono, _fuse_groups[i], _jiggle_range).start(_mono);
			yield return _fuse_length.wait();
		}
	}

	public static IEnumerator jiggleFuseAnim(MonoBehaviour _mono, List<List<JiggleRunner>> _fuse_groups, float _fuse_length = 0.2f)
	{
		for (int i = 0; i < _fuse_groups.Count; i++)
		{
			jiggle(_fuse_groups[i]);
			yield return _fuse_length.wait();
		}
	}

	public static Coroutine jiggle(this MonoBehaviour _mono)
	{
		return _mono.StartCoroutine(jiggleAnim(_mono));
	}

	public static Coroutine jiggle(this MonoBehaviour _mono, List<Transform> _jiggle_transforms, Vector2 _range)
	{
		return _mono.StartCoroutine(jiggleAnim(_mono, _jiggle_transforms, _range));
	}

	public static void jiggle(List<JiggleRunner> _jiggle_list)
	{
		_jiggle_list.ForEach(delegate(JiggleRunner _j)
		{
			_j.jiggle();
		});
	}

	public static void jiggleFuse(this MonoBehaviour _mono, Vector2 _jiggle_range, List<List<Transform>> _fuse_groups, float _fuse_length = 0.2f)
	{
		jiggleFuseAnim(_mono, _jiggle_range, _fuse_groups, _fuse_length).start(_mono);
	}

	public static void jiggleFuse(this MonoBehaviour _mono, List<List<JiggleRunner>> _fuse_groups, float _fuse_length = 0.2f)
	{
		jiggleFuseAnim(_mono, _fuse_groups, _fuse_length).start(_mono);
	}
}
