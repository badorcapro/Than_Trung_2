using System;
using UnityEngine;

namespace GRGLib.Coroutines;

public static class CoroutineExtensions
{
	private static float easeInSine(this float _x)
	{
		return (float)(1.0 - Math.Cos((double)_x * Math.PI / 2.0));
	}

	private static float easeOutSine(this float _x)
	{
		return (float)(1.0 - Math.Sin((double)_x * Math.PI / 2.0));
	}

	private static float easeInOutSine(this float _x)
	{
		return (float)(Math.Cos(Math.PI * (double)_x) / 2.0) * -1f;
	}

	public static float easeInElastic(this float _x)
	{
		float num = MathF.PI * 2f / 3f;
		if (_x != 0f)
		{
			if (_x != 1f)
			{
				return (0f - Mathf.Pow(2f, 10f * _x - 10f)) * Mathf.Sin((_x * 10f - 10.75f) * num);
			}
			return 1f;
		}
		return 0f;
	}

	public static float easeOutElastic(this float _x)
	{
		float num = MathF.PI * 2f / 3f;
		if (_x != 0f)
		{
			if (_x != 1f)
			{
				return Mathf.Pow(2f, -10f * _x) * Mathf.Sin((_x * 10f - 0.75f) * num) + 1f;
			}
			return 1f;
		}
		return 0f;
	}

	public static float easeInBack(this float _x, float _c1 = 1.70158f)
	{
		return (_c1 + 1f) * _x * _x * _x - _c1 * _x * _x;
	}

	public static float easeOutBack(this float _x, float _c1 = 1.70158f)
	{
		float num = _c1 + 1f;
		return 1f + num * Mathf.Pow(_x - 1f, 3f) + _c1 * Mathf.Pow(_x - 1f, 2f);
	}

	public static float easeInOutBack(this float _x, float _c2 = 2.5949094f)
	{
		if (!(_x < 0.5f))
		{
			return (Mathf.Pow(2f * _x - 2f, 2f) * ((_c2 + 1f) * (_x * 2f - 2f) + _c2) + 2f) / 2f;
		}
		return Mathf.Pow(2f * _x, 2f) * ((_c2 + 1f) * 2f * _x - _c2) / 2f;
	}

	public static float easeInOutBack(this float _x, float _c1, float _c2)
	{
		if (!(_x < 0.5f))
		{
			return (Mathf.Pow(2f * _x - 2f, 2f) * ((_c2 + 1f) * (_x * 2f - 2f) + _c2) + 2f) / 2f;
		}
		return Mathf.Pow(2f * _x, 2f) * ((_c1 + 1f) * 2f * _x - _c1) / 2f;
	}

	public static float easeInBounce(this float _x)
	{
		return 1f - (1f - _x).easeOutBounce();
	}

	public static float easeOutBounce(this float _x)
	{
		float num = 7.5625f;
		float num2 = 2.75f;
		if (_x < 1f / num2)
		{
			return num * _x * _x;
		}
		if (_x < 2f / num2)
		{
			return num * (_x -= 1.5f / num2) * _x + 0.75f;
		}
		if (_x < 2.5f / num2)
		{
			return num * (_x -= 2.25f / num2) * _x + 0.9375f;
		}
		return num * (_x -= 2.625f / num2) * _x + 63f / 64f;
	}

	public static float easeInOutBounce(this float _x)
	{
		if (!(_x < 0.5f))
		{
			return (1f + (2f * _x - 1f).easeOutBounce()) / 2f;
		}
		return (1f - (1f - 2f * _x).easeOutBounce()) / 2f;
	}

	public static float inverseEaseInOutSine(this float _x)
	{
		return 0.5f - (float)(Math.Acos((_x - 0.5f) * 2f) / Math.PI);
	}

	public static float inverseEaseInSine(this float _x)
	{
		return 2f * (float)(Math.Acos(1f - _x) / Math.PI);
	}

	public static float inverseEaseOutSine(this float _x)
	{
		return 1f + 2f * (float)(Math.Asin(_x) / Math.PI);
	}

	public static float easeInOutFunc(float _f)
	{
		return _f.easeInOutSine() + 0.5f;
	}

	public static float easeInFunc(float _f)
	{
		return _f.easeInSine();
	}

	public static float easeOutFunc(float _f)
	{
		return 1f - _f.easeOutSine();
	}

	public static float easeOutElasticFunc(float _f)
	{
		return _f.easeOutElastic();
	}

	public static float easeInElasticFunc(float _f)
	{
		return _f.easeInElastic();
	}

	public static float easeOutBackFunc(float _f)
	{
		return _f.easeOutBack();
	}

	public static float easeInBackFunc(float _f)
	{
		return _f.easeInBack();
	}

	public static float easeInOutBackFunc(float _f)
	{
		return _f.easeInOutBack();
	}

	public static float easeInBounceFunc(float _f)
	{
		return _f.easeInBounce();
	}

	public static float easeOutBounceFunc(float _f)
	{
		return _f.easeOutBounce();
	}

	public static float easeInOutBounceFunc(float _f)
	{
		return _f.easeInOutBounce();
	}

	public static float noEaseFunc(float _f)
	{
		return _f;
	}

	public static Func<float, float> getCustomEaseInBackFunc(float _power = 1.70158f)
	{
		return (float _f) => _f.easeInBack(_power);
	}

	public static Func<float, float> getCustomEaseOutBackFunc(float _power = 1.70158f)
	{
		return (float _f) => _f.easeOutBack(_power);
	}

	public static Func<float, float> getCustomEaseInOutBackFunc(float _power = 2.5949094f)
	{
		return (float _f) => _f.easeInOutBack(_power);
	}

	public static Func<float, float> getCustomEaseInOutBackFunc(float _power_in, float _power_out)
	{
		return (float _f) => _f.easeInOutBack(_power_in, _power_out);
	}

	public static Func<float, float> getCustomEaseInOutBounceFunc(int _bounces = 3, float _dampen = 0f)
	{
		Func<float, float> out_func = getCustomEaseOutBounceFunc(_bounces, _dampen);
		return (float _x) => (!(_x < 0.5f)) ? ((1f + out_func(2f * _x - 1f)) / 2f) : ((1f - out_func(1f - 2f * _x)) / 2f);
	}

	public static Func<float, float> getCustomEaseInBounceFunc(int _bounces = 3, float _dampen = 0f)
	{
		Func<float, float> out_func = getCustomEaseOutBounceFunc(_bounces, _dampen);
		return (float _x) => 1f - out_func(1f - _x);
	}

	public static Func<float, float> getCustomEaseOutBounceFunc(int _bounces = 3, float _dampen = 0f)
	{
		if (_dampen == 0f)
		{
			return getCustomEaseOutBounceFunc(calculateImportantValuesForCustomBounceFunc(_bounces));
		}
		(float[], float[], float, float) values = calculateImportantValuesForCustomBounceFunc(_bounces);
		Func<float, float> normal_func = getCustomEaseOutBounceFunc(values);
		return delegate(float _x)
		{
			float num = normal_func(_x);
			return (_x < values.Item1[0] / values.Item4) ? num : (num + (1f - num) * _dampen);
		};
	}

	private static (float[], float[], float, float) calculateImportantValuesForCustomBounceFunc(int _bounces, float _ratio = 2f)
	{
		float num = 1f;
		float num2 = 1f;
		float[] array = new float[_bounces + 1];
		float[] array2 = new float[_bounces + 1];
		array[0] = num;
		array2[0] = 1f;
		for (int i = 1; i < _bounces + 1; i++)
		{
			num += num2;
			num2 /= _ratio;
			array[i] = num;
			array2[i] = num2;
		}
		float item = num * num;
		return (array, array2, item, num);
	}

	private static Func<float, float> getCustomEaseOutBounceFunc((float[], float[], float, float) _values)
	{
		return delegate(float _x)
		{
			for (int i = 0; i < _values.Item1.Length; i++)
			{
				float num = _values.Item1[i] / _values.Item4;
				if (_x <= num)
				{
					float num2 = (_values.Item1[i] - _values.Item2[i]) / _values.Item4;
					float num3 = _x - num2;
					float num4 = num - num2;
					float num5 = 1f - num4 * num4 * _values.Item3;
					return _values.Item3 * num3 * num3 + num5;
				}
			}
			Debug.LogError($"Custom Ease Out Bounce Func failed, returning _x ({_x})");
			return _x;
		};
	}

	public static Func<float, float> getCustomEaseInOutBounceFunc(int _bounces, float _dampen, float _ratio)
	{
		Func<float, float> out_func = getCustomEaseOutBounceFunc(_bounces, _dampen, _ratio);
		return (float _x) => (!(_x < 0.5f)) ? ((1f + out_func(2f * _x - 1f)) / 2f) : ((1f - out_func(1f - 2f * _x)) / 2f);
	}

	public static Func<float, float> getCustomEaseInBounceFunc(int _bounces, float _dampen, float _ratio)
	{
		Func<float, float> out_func = getCustomEaseOutBounceFunc(_bounces, _dampen, _ratio);
		return (float _x) => 1f - out_func(1f - _x);
	}

	public static Func<float, float> getCustomEaseOutBounceFunc(int _bounces, float _dampen, float _ratio)
	{
		if (_ratio == 2f)
		{
			return getCustomEaseOutBounceFunc(_bounces, _dampen);
		}
		if (_dampen == 0f)
		{
			return getCustomEaseOutBounceCustomRatioFunc(calculateImportantValuesForCustomBounceFunc(_bounces, _ratio));
		}
		(float[], float[], float, float) values = calculateImportantValuesForCustomBounceFunc(_bounces, _ratio);
		Func<float, float> normal_func = getCustomEaseOutBounceCustomRatioFunc(values);
		return delegate(float _x)
		{
			float num = normal_func(_x);
			return (_x < values.Item1[0] / values.Item4) ? num : (num + (1f - num) * _dampen);
		};
	}

	private static Func<float, float> getCustomEaseOutBounceCustomRatioFunc((float[], float[], float, float) _values)
	{
		return delegate(float _x)
		{
			for (int i = 0; i < _values.Item1.Length; i++)
			{
				float num = _values.Item1[i] / _values.Item4;
				if (_x <= num)
				{
					float num2 = (_values.Item1[i] - _values.Item2[i]) / _values.Item4;
					float num3 = num - num2;
					float num4 = 1f - num3 * num3 * _values.Item3;
					float num5;
					if (i == 0)
					{
						num5 = _x;
					}
					else
					{
						float num6 = _values.Item1[i - 1] / _values.Item4;
						float num7 = 2f * _values.Item3 * num2;
						float num8 = _values.Item3 * num2 * num2 + num4 - 1f;
						float num9 = 0f - (0f - num7 + Mathf.Sqrt(num7 * num7 - 4f * _values.Item3 * num8)) / (2f * _values.Item3);
						num5 = (_x - num6) / (num - num6) * (num - num9) + num9;
					}
					float num10 = num5 - num2;
					return _values.Item3 * num10 * num10 + num4;
				}
			}
			Debug.LogError($"Custom Ease Out Bounce Func failed, returning _x ({_x})");
			return _x;
		};
	}

	public static float getDeltaTime()
	{
		return Time.deltaTime;
	}

	public static float getUnscaledDeltaTime()
	{
		return Time.unscaledDeltaTime;
	}
}
