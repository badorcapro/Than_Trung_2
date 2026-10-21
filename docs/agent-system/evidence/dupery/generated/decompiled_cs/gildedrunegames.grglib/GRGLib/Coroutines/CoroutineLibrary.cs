using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Random;
using GRGLib.Extensions.Unity;
using GRGLib.Extensions.Vector;
using GRGLib.Maybe;
using GRGLib.Mono;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace GRGLib.Coroutines;

public static class CoroutineLibrary
{
	public static IEnumerator fade(this CanvasGroup _group, float _target, float _duration)
	{
		return _group.fade(_target, _duration, CoroutineExtensions.easeInOutFunc);
	}

	public static IEnumerator fade(this CanvasGroup _group, float _target, float _duration, Func<float, float> _ease_func)
	{
		return _group.fade(_target, _duration, _ease_func, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator fade(this CanvasGroup _group, float _target, float _duration, Func<float, float> _ease_func, Func<float> _delta_time)
	{
		float e = 0f;
		float start = _group.alpha;
		float diff = _target - start;
		while (e < _duration)
		{
			_group.alpha = start + diff * _ease_func(e / _duration);
			e += _delta_time();
			yield return null;
		}
		_group.alpha = _target;
	}

	public static IEnumerator fade(this List<CanvasGroup> _groups, float _target, float _duration, Func<float, float> _ease_func)
	{
		return _groups.fade(_target, _duration, _ease_func, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator fade(this List<CanvasGroup> _groups, float _target, float _duration, Func<float, float> _ease_func, Func<float> _delta_time)
	{
		float e = 0f;
		Dictionary<CanvasGroup, float> starts = new Dictionary<CanvasGroup, float>();
		Dictionary<CanvasGroup, float> diffs = new Dictionary<CanvasGroup, float>();
		_groups.ForEach(delegate(CanvasGroup _e)
		{
			starts[_e] = _e.alpha;
			diffs[_e] = _target - _e.alpha;
		});
		while (e < _duration)
		{
			_groups.ForEach(delegate(CanvasGroup _e)
			{
				_e.alpha = starts[_e] + diffs[_e] * _ease_func(e / _duration);
			});
			e += _delta_time();
			yield return null;
		}
		_groups.ForEach(delegate(CanvasGroup _e)
		{
			_e.alpha = _target;
		});
	}

	public static IEnumerator fadeRealTime(this CanvasGroup _group, float _target, float _duration, Func<float, float> _ease_func)
	{
		return _group.fade(_target, _duration, _ease_func, CoroutineExtensions.getUnscaledDeltaTime);
	}

	public static IEnumerator fadeRealTime(this List<CanvasGroup> _groups, float _target, float _duration, Func<float, float> _ease_func)
	{
		return _groups.fade(_target, _duration, _ease_func, CoroutineExtensions.getUnscaledDeltaTime);
	}

	public static IEnumerator fadeInOutContinuous(this CanvasGroup _group, float _in, float _out, float _in_duration, float _out_duration, Func<float, float> _ease_func)
	{
		return _group.fadeInOutContinuous(_in, _out, _in_duration, _out_duration, _ease_func, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator fadeInOutContinuous(this CanvasGroup _group, float _in, float _out, float _in_duration, float _out_duration, Func<float, float> _ease_func, Func<float> _delta_time)
	{
		while (true)
		{
			yield return _group.fade(_in, _in_duration, _ease_func, _delta_time);
			yield return _group.fade(_out, _out_duration, _ease_func, _delta_time);
		}
	}

	public static IEnumerator fade(this Image _img, float _alpha, float _duration, Func<float, float> _ease_func)
	{
		return _img.fade(_alpha, _duration, _ease_func, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator fade(this Image _img, float _alpha, float _duration, Func<float, float> _ease_func, Func<float> _delta_time)
	{
		return _img.fadeToColour(new Color(_img.color.r, _img.color.g, _img.color.b, _alpha), _duration, _ease_func, _delta_time);
	}

	public static IEnumerator fade(this List<Image> _imgs, float _alpha, float _duration, Func<float, float> _ease_func)
	{
		return _imgs.fade(_alpha, _duration, _ease_func, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator fade(this List<Image> _imgs, float _alpha, float _duration, Func<float, float> _ease_func, Func<float> _delta_time)
	{
		float e = 0f;
		Dictionary<Image, Color> starts = new Dictionary<Image, Color>();
		Dictionary<Image, Color> diffs = new Dictionary<Image, Color>();
		_imgs.ForEach(delegate(Image _e)
		{
			starts[_e] = _e.color;
			diffs[_e] = new Color(_e.color.r, _e.color.g, _e.color.b, _alpha) - _e.color;
		});
		while (e < _duration)
		{
			_imgs.ForEach(delegate(Image _e)
			{
				_e.color = starts[_e] + diffs[_e] * _ease_func(e / _duration);
			});
			e += _delta_time();
			yield return null;
		}
		_imgs.ForEach(delegate(Image _e)
		{
			_e.color = new Color(_e.color.r, _e.color.g, _e.color.b, _alpha);
		});
	}

	public static IEnumerator fadeInOutContinuous(this Image _image, float _in, float _out, float _in_duration, float _out_duration, Func<float, float> _ease_func)
	{
		return _image.fadeInOutContinuous(_in, _out, _in_duration, _out_duration, _ease_func, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator fadeInOutContinuous(this Image _image, float _in, float _out, float _in_duration, float _out_duration, Func<float, float> _ease_func, Func<float> _delta_time)
	{
		while (true)
		{
			yield return _image.fade(_in, _in_duration, _ease_func, _delta_time);
			yield return _image.fade(_out, _out_duration, _ease_func, _delta_time);
		}
	}

	public static IEnumerator fadeToColour(this Image _img, Color _target, float _duration, Func<float, float> _ease_func)
	{
		return _img.fadeToColour(_target, _duration, _ease_func, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator fadeToColour(this Image _img, Color _target, float _duration, Func<float, float> _ease_func, Func<float> _delta_time)
	{
		return fadeToColour(delegate(Color _v)
		{
			_img.color = _v;
		}, _img.color, _target, _duration, _ease_func, _delta_time);
	}

	public static IEnumerator fadeToColour(this List<Image> _imgs, Color _target, float _duration, Func<float, float> _ease)
	{
		return _imgs.fadeToColour(_target, _duration, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator fadeToColour(this List<Image> _imgs, Color _target, float _duration, Func<float, float> _ease, Func<float> _delta_time)
	{
		float e = 0f;
		Dictionary<Image, Color> starts = new Dictionary<Image, Color>();
		Dictionary<Image, Color> diffs = new Dictionary<Image, Color>();
		_imgs.ForEach(delegate(Image _e)
		{
			starts[_e] = _e.color;
			diffs[_e] = _target - _e.color;
		});
		while (e < _duration)
		{
			_imgs.ForEach(delegate(Image _e)
			{
				_e.color = starts[_e] + diffs[_e] * _ease(e / _duration);
			});
			e += _delta_time();
			yield return null;
		}
		_imgs.ForEach(delegate(Image _e)
		{
			_e.color = _target;
		});
	}

	public static IEnumerator fade(this SpriteRenderer _spr, float _alpha, float _duration, Func<float, float> _ease_func)
	{
		return _spr.fade(_alpha, _duration, _ease_func, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator fade(this SpriteRenderer _spr, float _alpha, float _duration, Func<float, float> _ease_func, Func<float> _delta_time)
	{
		return _spr.fadeToColour(new Color(_spr.color.r, _spr.color.g, _spr.color.b, _alpha), _duration, _ease_func, _delta_time);
	}

	public static IEnumerator fadeInOutContinuous(this SpriteRenderer _spr, float _in, float _out, float _in_duration, float _out_duration, Func<float, float> _ease_func)
	{
		return _spr.fadeInOutContinuous(_in, _out, _in_duration, _out_duration, _ease_func, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator fadeInOutContinuous(this SpriteRenderer _spr, float _in, float _out, float _in_duration, float _out_duration, Func<float, float> _ease_func, Func<float> _delta_time)
	{
		while (true)
		{
			yield return _spr.fade(_in, _in_duration, _ease_func, _delta_time);
			yield return _spr.fade(_out, _out_duration, _ease_func, _delta_time);
		}
	}

	public static IEnumerator fade(this List<SpriteRenderer> _sprs, float _alpha, float _duration, Func<float, float> _ease_func)
	{
		return _sprs.fade(_alpha, _duration, _ease_func, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator fade(this List<SpriteRenderer> _sprs, float _alpha, float _duration, Func<float, float> _ease_func, Func<float> _delta_time)
	{
		float e = 0f;
		Dictionary<SpriteRenderer, Color> starts = new Dictionary<SpriteRenderer, Color>();
		Dictionary<SpriteRenderer, Color> diffs = new Dictionary<SpriteRenderer, Color>();
		_sprs.ForEach(delegate(SpriteRenderer _e)
		{
			starts[_e] = _e.color;
			diffs[_e] = new Color(_e.color.r, _e.color.g, _e.color.b, _alpha) - _e.color;
		});
		while (e < _duration)
		{
			_sprs.ForEach(delegate(SpriteRenderer _e)
			{
				_e.color = starts[_e] + diffs[_e] * _ease_func(e / _duration);
			});
			e += _delta_time();
			yield return null;
		}
		_sprs.ForEach(delegate(SpriteRenderer _e)
		{
			_e.color = new Color(_e.color.r, _e.color.g, _e.color.b, _alpha);
		});
	}

	public static IEnumerator fadeToColour(this SpriteRenderer _spr, Color _target, float _duration, Func<float, float> _ease_func)
	{
		return _spr.fadeToColour(_target, _duration, _ease_func, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator fadeToColour(this SpriteRenderer _spr, Color _target, float _duration, Func<float, float> _ease_func, Func<float> _delta_time)
	{
		return fadeToColour(delegate(Color _v)
		{
			_spr.color = _v;
		}, _spr.color, _target, _duration, _ease_func, _delta_time);
	}

	public static IEnumerator fadeToColour(this List<SpriteRenderer> _sprs, Color _target, float _duration, Func<float, float> _ease)
	{
		return _sprs.fadeToColour(_target, _duration, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator fadeToColour(this List<SpriteRenderer> _sprs, Color _target, float _duration, Func<float, float> _ease, Func<float> _delta_time)
	{
		float e = 0f;
		Dictionary<SpriteRenderer, Color> starts = new Dictionary<SpriteRenderer, Color>();
		Dictionary<SpriteRenderer, Color> diffs = new Dictionary<SpriteRenderer, Color>();
		_sprs.ForEach(delegate(SpriteRenderer _e)
		{
			starts[_e] = _e.color;
			diffs[_e] = _target - _e.color;
		});
		while (e < _duration)
		{
			_sprs.ForEach(delegate(SpriteRenderer _e)
			{
				_e.color = starts[_e] + diffs[_e] * _ease(e / _duration);
			});
			e += _delta_time();
			yield return null;
		}
		_sprs.ForEach(delegate(SpriteRenderer _e)
		{
			_e.color = _target;
		});
	}

	public static IEnumerator fade(this SpriteAlphaGroup _group, float _target, float _duration)
	{
		return _group.fade(_target, _duration, CoroutineExtensions.easeInOutFunc);
	}

	public static IEnumerator fade(this SpriteAlphaGroup _group, float _target, float _duration, Func<float, float> _ease_func)
	{
		return _group.fade(_target, _duration, _ease_func, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator fade(this SpriteAlphaGroup _group, float _target, float _duration, Func<float, float> _ease_func, Func<float> _delta_time)
	{
		return fade(delegate(float _a)
		{
			_group.alpha = _a;
		}, _group.alpha, _target, _duration, _ease_func, _delta_time);
	}

	public static IEnumerator fadeInOutContinuous(this SpriteAlphaGroup _group, float _in, float _out, float _in_duration, float _out_duration, Func<float, float> _ease_func)
	{
		return _group.fadeInOutContinuous(_in, _out, _in_duration, _out_duration, _ease_func, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator fadeInOutContinuous(this SpriteAlphaGroup _group, float _in, float _out, float _in_duration, float _out_duration, Func<float, float> _ease_func, Func<float> _delta_time)
	{
		while (true)
		{
			yield return _group.fade(_in, _in_duration, _ease_func, _delta_time);
			yield return _group.fade(_out, _out_duration, _ease_func, _delta_time);
		}
	}

	public static IEnumerator fade(this TMP_Text _text, float _target, float _duration, Func<float, float> _ease_func)
	{
		return fade(delegate(float _a)
		{
			_text.alpha = _a;
		}, _text.alpha, _target, _duration, _ease_func, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator fade(this TMP_Text _text, float _target, float _duration, Func<float, float> _ease_func, Func<float> _delta_time)
	{
		return fade(delegate(float _a)
		{
			_text.alpha = _a;
		}, _text.alpha, _target, _duration, _ease_func, _delta_time);
	}

	public static IEnumerator fadeInOutContinuous(this TMP_Text _text, float _in, float _out, float _in_duration, float _out_duration, Func<float, float> _ease_func)
	{
		return _text.fadeInOutContinuous(_in, _out, _in_duration, _out_duration, _ease_func, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator fadeInOutContinuous(this TMP_Text _text, float _in, float _out, float _in_duration, float _out_duration, Func<float, float> _ease_func, Func<float> _delta_time)
	{
		while (true)
		{
			yield return _text.fade(_in, _in_duration, _ease_func, _delta_time);
			yield return _text.fade(_out, _out_duration, _ease_func, _delta_time);
		}
	}

	public static IEnumerator fade(this List<TMP_Text> _texts, float _alpha, float _duration, Func<float, float> _ease_func)
	{
		return _texts.fade(_alpha, _duration, _ease_func, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator fade(this List<TMP_Text> _texts, float _alpha, float _duration, Func<float, float> _ease_func, Func<float> _delta_time)
	{
		float e = 0f;
		Dictionary<TMP_Text, float> starts = new Dictionary<TMP_Text, float>();
		Dictionary<TMP_Text, float> diffs = new Dictionary<TMP_Text, float>();
		_texts.ForEach(delegate(TMP_Text _e)
		{
			starts[_e] = _e.alpha;
			diffs[_e] = _alpha - _e.alpha;
		});
		while (e < _duration)
		{
			_texts.ForEach(delegate(TMP_Text _e)
			{
				_e.alpha = starts[_e] + diffs[_e] * _ease_func(e / _duration);
			});
			e += _delta_time();
			yield return null;
		}
		_texts.ForEach(delegate(TMP_Text _e)
		{
			_e.color = new Color(_e.color.r, _e.color.g, _e.color.b, _alpha);
		});
	}

	public static IEnumerator fadeToColour(this TMP_Text _text, Color _target, float _duration, Func<float, float> _ease_func)
	{
		return fadeToColour(delegate(Color _c)
		{
			_text.color = _c;
		}, _text.color, _target, _duration, _ease_func, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator fadeToColour(this TMP_Text _text, Color _target, float _duration, Func<float, float> _ease_func, Func<float> _delta_time)
	{
		return fadeToColour(delegate(Color _c)
		{
			_text.color = _c;
		}, _text.color, _target, _duration, _ease_func, _delta_time);
	}

	public static IEnumerator fadeToColour(this List<TMP_Text> _texts, Color _target, float _duration, Func<float, float> _ease)
	{
		return _texts.fadeToColour(_target, _duration, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator fadeToColour(this List<TMP_Text> _texts, Color _target, float _duration, Func<float, float> _ease, Func<float> _delta_time)
	{
		float e = 0f;
		Dictionary<TMP_Text, Color> starts = new Dictionary<TMP_Text, Color>();
		Dictionary<TMP_Text, Color> diffs = new Dictionary<TMP_Text, Color>();
		_texts.ForEach(delegate(TMP_Text _e)
		{
			starts[_e] = _e.color;
			diffs[_e] = _target - _e.color;
		});
		while (e < _duration)
		{
			_texts.ForEach(delegate(TMP_Text _e)
			{
				_e.color = starts[_e] + diffs[_e] * _ease(e / _duration);
			});
			e += _delta_time();
			yield return null;
		}
		_texts.ForEach(delegate(TMP_Text _e)
		{
			_e.color = _target;
		});
	}

	public static IEnumerator fade(this Action<float> _set_alpha, float _start_alpha, float _target, float _duration, Func<float, float> _ease_func)
	{
		return _set_alpha.fade(_start_alpha, _target, _duration, _ease_func, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator fade(this Action<float> _set_alpha, float _start_alpha, float _target, float _duration, Func<float, float> _ease_func, Func<float> _delta_time)
	{
		float diff = _target - _start_alpha;
		float e = 0f;
		while (e < _duration)
		{
			_set_alpha(_start_alpha + diff * _ease_func(e / _duration));
			e += _delta_time();
			yield return null;
		}
		_set_alpha(_target);
	}

	public static IEnumerator fadeInOutContinuous(this Action<float> _set_alpha, float _start_alpha, float _in, float _out, float _in_duration, float _out_duration, Func<float, float> _ease_func)
	{
		return _set_alpha.fadeInOutContinuous(_start_alpha, _in, _out, _in_duration, _out_duration, _ease_func, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator fadeInOutContinuous(this Action<float> _set_alpha, float _start_alpha, float _in, float _out, float _in_duration, float _out_duration, Func<float, float> _ease_func, Func<float> _delta_time)
	{
		float start_alpha = _start_alpha;
		while (true)
		{
			yield return _set_alpha.fade(start_alpha, _in, _in_duration, _ease_func, _delta_time);
			yield return _set_alpha.fade(_in, _out, _out_duration, _ease_func, _delta_time);
			start_alpha = _out;
		}
	}

	public static IEnumerator fade(this Action<Color> _set_colour, Color _start_colour, float _alpha, float _duration, Func<float, float> _ease_func)
	{
		return _set_colour.fade(_start_colour, _alpha, _duration, _ease_func, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator fade(this Action<Color> _set_colour, Color _start_colour, float _alpha, float _duration, Func<float, float> _ease_func, Func<float> _delta_time)
	{
		return _set_colour.fadeToColour(_start_colour, new Color(_start_colour.r, _start_colour.g, _start_colour.b, _alpha), _duration, _ease_func, _delta_time);
	}

	public static IEnumerator fadeToColour(this Action<Color> _set_colour, Color _start_colour, Color _target, float _duration, Func<float, float> _ease_func)
	{
		return _set_colour.fadeToColour(_start_colour, _target, _duration, _ease_func, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator fadeToColour(this Action<Color> _set_colour, Color _start_colour, Color _target, float _duration, Func<float, float> _ease_func, Func<float> _delta_time)
	{
		Color diff = _target - _start_colour;
		float e = 0f;
		while (e < _duration)
		{
			_set_colour(_start_colour + diff * _ease_func(e / _duration));
			e += _delta_time();
			yield return null;
		}
		_set_colour(_target);
	}

	public static IEnumerator crossFade(this SpriteRenderer _in, SpriteRenderer _out, float _duration, Func<float, float> _ease)
	{
		return _in.crossFade(_out, _duration, 1f, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator crossFade(this SpriteRenderer _in, SpriteRenderer _out, float _duration, float _in_alpha, Func<float, float> _ease)
	{
		return _in.crossFade(_out, _duration, _in_alpha, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator crossFade(this SpriteRenderer _in, SpriteRenderer _out, float _duration, float _in_alpha, Func<float, float> _ease, Func<float> _delta_time)
	{
		return _in.crossFade(_out, _duration, _in.color.setAlpha(_in_alpha), _ease, _delta_time);
	}

	public static IEnumerator crossFade(this SpriteRenderer _in, SpriteRenderer _out, float _duration, Color _in_colour, Func<float, float> _ease)
	{
		return _in.crossFade(_out, _duration, _in_colour, _ease);
	}

	public static IEnumerator crossFade(this SpriteRenderer _in, SpriteRenderer _out, float _duration, Color _in_colour, Func<float, float> _ease, Func<float> _delta_time)
	{
		float e = 0f;
		Color start_in = _in.color;
		Color start_out = _out.color;
		Color diff_in = _in_colour - start_in;
		Color diff_out = _out.color.setAlpha(0f) - start_out;
		while (e < _duration)
		{
			_in.color = start_in + diff_in * _ease(e / _duration);
			_out.color = start_out + diff_out * _ease(e / _duration);
			e += _delta_time();
			yield return null;
		}
		_in.color = _in_colour;
		_out.color = start_out.setAlpha(0f);
	}

	public static IEnumerator crossFade(this Image _in, Image _out, float _duration, Func<float, float> _ease)
	{
		return _in.crossFade(_out, _duration, 1f, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator crossFade(this Image _in, Image _out, float _duration, float _in_alpha, Func<float, float> _ease)
	{
		return _in.crossFade(_out, _duration, _in_alpha, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator crossFade(this Image _in, Image _out, float _duration, float _in_alpha, Func<float, float> _ease, Func<float> _delta_time)
	{
		return _in.crossFade(_out, _duration, _in.color.setAlpha(_in_alpha), _ease, _delta_time);
	}

	public static IEnumerator crossFade(this Image _in, Image _out, float _duration, Color _in_colour, Func<float, float> _ease)
	{
		return _in.crossFade(_out, _duration, _in_colour, _ease);
	}

	public static IEnumerator crossFade(this Image _in, Image _out, float _duration, Color _in_colour, Func<float, float> _ease, Func<float> _delta_time)
	{
		float e = 0f;
		Color start_in = _in.color;
		Color start_out = _out.color;
		Color diff_in = _in_colour - start_in;
		Color diff_out = _out.color.setAlpha(0f) - start_out;
		while (e < _duration)
		{
			_in.color = start_in + diff_in * _ease(e / _duration);
			_out.color = start_out + diff_out * _ease(e / _duration);
			e += _delta_time();
			yield return null;
		}
		_in.color = _in_colour;
		_out.color = start_out.setAlpha(0f);
	}

	public static IEnumerator crossFade(this Action<float> _set_in, Action<float> _set_out, float _duration, Func<float, float> _ease)
	{
		return _set_in.crossFade(_set_out, _duration, 0f, 1f, 1f, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator crossFade(this Action<float> _set_in, Action<float> _set_out, float _duration, float _starting_in_alpha, float _starting_out_alpha, float _target_in_alpha, Func<float, float> _ease)
	{
		return _set_in.crossFade(_set_out, _duration, _starting_in_alpha, _starting_out_alpha, _target_in_alpha, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator crossFade(this Action<float> _set_in, Action<float> _set_out, float _duration, float _starting_in_alpha, float _starting_out_alpha, float _target_in_alpha, Func<float, float> _ease, Func<float> _delta_time)
	{
		float e = 0f;
		float diff_in = _target_in_alpha - _starting_in_alpha;
		float diff_out = 0f - _starting_out_alpha;
		while (e < _duration)
		{
			_set_in(_starting_in_alpha + diff_in * _ease(e / _duration));
			_set_out(_starting_out_alpha + diff_out * _ease(e / _duration));
			e += _delta_time();
			yield return null;
		}
		_set_in(_target_in_alpha);
		_set_out(0f);
	}

	public static IEnumerator rotateTransform(this Transform _trans, Quaternion _target, float _duration, Func<float, float> _ease)
	{
		return new List<Transform> { _trans }.rotateTransform(_target, _duration, _ease);
	}

	public static IEnumerator rotateTransform(this List<Transform> _trans, Quaternion _target, float _duration, Func<float, float> _ease)
	{
		return _trans.rotateTransform(_target, _duration, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator rotateTransform(this List<Transform> _trans, Quaternion _target, float _duration, Func<float, float> _ease, Func<float> _delta_time)
	{
		float _e2 = 0f;
		List<Quaternion> starting_rots = _trans.Select((Transform _e) => _e.localRotation).ToList();
		while (_e2 < _duration)
		{
			for (int i = 0; i < starting_rots.Count; i++)
			{
				_trans[i].localRotation = Quaternion.Lerp(starting_rots[i], _target, _ease(_e2 / _duration));
			}
			_e2 += _delta_time();
			yield return null;
		}
		_trans.ForEach(delegate(Transform _e)
		{
			_e.localRotation = _target;
		});
	}

	public static IEnumerator rotateTransform(this Transform _trans, float _degrees, float _duration, Func<float, float> _ease)
	{
		return _trans.rotateTransform(_degrees, _duration, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator rotateTransform(this Transform _trans, float _degrees, float _duration, Func<float, float> _ease, Func<float> _delta_time)
	{
		float e = 0f;
		float starting_rot = _trans.localRotation.eulerAngles.z;
		float diff = _degrees - starting_rot;
		while (e < _duration)
		{
			_trans.localRotation = Quaternion.Euler(0f, 0f, starting_rot + diff * _ease(e / _duration));
			e += _delta_time();
			yield return null;
		}
		_trans.localRotation = Quaternion.Euler(0f, 0f, _degrees);
	}

	public static IEnumerator rotateTransformGlobal(this Transform _trans, Quaternion _target, float _duration, Func<float, float> _ease)
	{
		return new List<Transform> { _trans }.rotateTransformGlobal(_target, _duration, _ease);
	}

	public static IEnumerator rotateTransformGlobal(this List<Transform> _trans, Quaternion _target, float _duration, Func<float, float> _ease)
	{
		return _trans.rotateTransformGlobal(_target, _duration, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator rotateTransformGlobal(this List<Transform> _trans, Quaternion _target, float _duration, Func<float, float> _ease, Func<float> _delta_time)
	{
		float _e2 = 0f;
		List<Quaternion> starting_rots = _trans.Select((Transform _e) => _e.rotation).ToList();
		while (_e2 < _duration)
		{
			for (int i = 0; i < starting_rots.Count; i++)
			{
				_trans[i].rotation = Quaternion.Lerp(starting_rots[i], _target, _ease(_e2 / _duration));
			}
			_e2 += _delta_time();
			yield return null;
		}
		_trans.ForEach(delegate(Transform _e)
		{
			_e.rotation = _target;
		});
	}

	public static IEnumerator rotateTransformGlobal(this Transform _trans, float _degrees, float _duration, Func<float, float> _ease)
	{
		return _trans.rotateTransformGlobal(_degrees, _duration, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator rotateTransformGlobal(this Transform _trans, float _degrees, float _duration, Func<float, float> _ease, Func<float> _delta_time)
	{
		float e = 0f;
		float starting_rot = _trans.rotation.eulerAngles.z;
		float diff = _degrees - starting_rot;
		while (e < _duration)
		{
			_trans.rotation = Quaternion.Euler(0f, 0f, starting_rot + diff * _ease(e / _duration));
			e += _delta_time();
			yield return null;
		}
		_trans.rotation = Quaternion.Euler(0f, 0f, _degrees);
	}

	public static IEnumerator rotateTransformDirection(this Transform _trans, float _degrees, float _duration, bool _clockwise, Func<float, float> _ease)
	{
		return _trans.rotateTransformDirection(_degrees, _duration, _clockwise, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator rotateTransformDirection(this Transform _trans, float _degrees, float _duration, bool _clockwise, Func<float, float> _ease, Func<float> _delta_time)
	{
		float e = 0f;
		float starting_rot = _trans.localRotation.eulerAngles.z;
		float diff;
		if (!_clockwise)
		{
			if (starting_rot > _degrees)
			{
				_degrees += 360f;
			}
			diff = _degrees - starting_rot;
		}
		else
		{
			if (starting_rot < _degrees)
			{
				starting_rot += 360f;
			}
			diff = _degrees - starting_rot;
		}
		while (e < _duration)
		{
			_trans.localRotation = Quaternion.Euler(0f, 0f, starting_rot + diff * _ease(e / _duration));
			e += _delta_time();
			yield return null;
		}
		_trans.localRotation = Quaternion.Euler(0f, 0f, _degrees);
	}

	public static IEnumerator rotateTransformDirectionGlobal(this Transform _trans, float _degrees, float _duration, bool _clockwise, Func<float, float> _ease)
	{
		return _trans.rotateTransformDirectionGlobal(_degrees, _duration, _clockwise, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator rotateTransformDirectionGlobal(this Transform _trans, float _degrees, float _duration, bool _clockwise, Func<float, float> _ease, Func<float> _delta_time)
	{
		float e = 0f;
		float starting_rot = _trans.rotation.eulerAngles.z;
		float diff;
		if (!_clockwise)
		{
			if (starting_rot > _degrees)
			{
				_degrees += 360f;
			}
			diff = _degrees - starting_rot;
		}
		else
		{
			if (starting_rot < _degrees)
			{
				starting_rot += 360f;
			}
			diff = _degrees - starting_rot;
		}
		while (e < _duration)
		{
			_trans.rotation = Quaternion.Euler(0f, 0f, starting_rot + diff * _ease(e / _duration));
			e += _delta_time();
			yield return null;
		}
		_trans.rotation = Quaternion.Euler(0f, 0f, _degrees);
	}

	public static IEnumerator rotateTransformSmart(this Transform _trans, float _target, float _duration, Func<float, float> _ease)
	{
		return _trans.rotateTransformSmart(_target, _duration, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator rotateTransformSmart(this Transform _trans, float _target, float _duration, Func<float, float> _ease, Func<float> _delta_time)
	{
		float starting_angle;
		for (starting_angle = _trans.localEulerAngles.z; starting_angle > 180f; starting_angle -= 360f)
		{
		}
		for (; starting_angle < -180f; starting_angle += 360f)
		{
		}
		float diff = _target - starting_angle;
		float e = 0f;
		while (e < _duration)
		{
			_trans.localRotation = Quaternion.Euler(0f, 0f, starting_angle + diff * _ease(e / _duration));
			e += _delta_time();
			yield return null;
		}
		_trans.localRotation = Quaternion.Euler(0f, 0f, _target);
	}

	public static IEnumerator rotateTransformSmartGlobal(this Transform _trans, float _target, float _duration, Func<float, float> _ease)
	{
		return _trans.rotateTransformSmartGlobal(_target, _duration, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator rotateTransformSmartGlobal(this Transform _trans, float _target, float _duration, Func<float, float> _ease, Func<float> _delta_time)
	{
		float starting_angle;
		for (starting_angle = _trans.localEulerAngles.z; starting_angle > 180f; starting_angle -= 360f)
		{
		}
		for (; starting_angle < -180f; starting_angle += 360f)
		{
		}
		float diff = _target - starting_angle;
		float e = 0f;
		while (e < _duration)
		{
			_trans.rotation = Quaternion.Euler(0f, 0f, starting_angle + diff * _ease(e / _duration));
			e += _delta_time();
			yield return null;
		}
		_trans.rotation = Quaternion.Euler(0f, 0f, _target);
	}

	public static IEnumerator rotateTransformToMovingTarget(this Transform _trans, Func<float> _degrees, float _duration, Func<float, float> _ease)
	{
		return _trans.rotateTransformToMovingTarget(_degrees, _duration, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator rotateTransformToMovingTarget(this Transform _trans, Func<float> _degrees, float _duration, Func<float, float> _ease, Func<float> _delta_time)
	{
		float e = 0f;
		float starting_rot = _trans.localRotation.eulerAngles.z;
		while (e < _duration)
		{
			float num = _degrees() - starting_rot;
			_trans.localRotation = Quaternion.Euler(0f, 0f, starting_rot + num * _ease(e / _duration));
			e += _delta_time();
			yield return null;
		}
		_trans.localRotation = Quaternion.Euler(0f, 0f, _degrees());
	}

	public static IEnumerator rotateTransformToMovingTargetGlobal(this Transform _trans, Func<float> _degrees, float _duration, Func<float, float> _ease)
	{
		return _trans.rotateTransformToMovingTargetGlobal(_degrees, _duration, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator rotateTransformToMovingTargetGlobal(this Transform _trans, Func<float> _degrees, float _duration, Func<float, float> _ease, Func<float> _delta_time)
	{
		float e = 0f;
		float starting_rot = _trans.rotation.eulerAngles.z;
		while (e < _duration)
		{
			float num = _degrees() - starting_rot;
			_trans.rotation = Quaternion.Euler(0f, 0f, starting_rot + num * _ease(e / _duration));
			e += _delta_time();
			yield return null;
		}
		_trans.rotation = Quaternion.Euler(0f, 0f, _degrees());
	}

	public static IEnumerator moveTransform(this Transform _trans, Vector3 _target, float _duration)
	{
		return _trans.moveTransform(_target, _duration, (float _a) => _a);
	}

	public static IEnumerator moveTransform(this Transform _trans, Vector3 _target, float _duration, Func<float, float> _ease_func)
	{
		return _trans.moveTransform(_target, _duration, _ease_func, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator moveTransform(this Transform _trans, Vector3 _target, float _duration, Func<float, float> _ease_func, Func<float> _delta_time)
	{
		float e = 0f;
		Vector3 start = _trans.localPosition;
		Vector3 diff = _target - start;
		while (e < _duration)
		{
			_trans.localPosition = start + diff * _ease_func(e / _duration);
			e += _delta_time();
			yield return null;
		}
		_trans.localPosition = _target;
	}

	public static IEnumerator moveTransform(this Transform _trans, Func<Vector3> _target, float _duration, Func<float, float> _ease_func)
	{
		return _trans.moveTransform(_target, _duration, _ease_func, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator moveTransform(this Transform _trans, Func<Vector3> _target, float _duration, Func<float, float> _ease_func, Func<float> _delta_time)
	{
		float e = 0f;
		Vector3 start = _trans.localPosition;
		Vector3 diff = _target() - start;
		while (e < _duration)
		{
			_trans.localPosition = start + diff * _ease_func(e / _duration);
			e += _delta_time();
			yield return null;
		}
		_trans.localPosition = _target();
	}

	public static IEnumerator moveTransformGlobal(this Transform _trans, Vector3 _target, float _duration, Func<float, float> _ease_func)
	{
		return _trans.moveTransformGlobal(_target, _duration, _ease_func, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator moveTransformGlobal(this Transform _trans, Vector3 _target, float _duration, Func<float, float> _ease_func, Func<float> _delta_time)
	{
		float e = 0f;
		Vector3 start = _trans.position;
		Vector3 diff = _target - start;
		while (e < _duration)
		{
			_trans.position = start + diff * _ease_func(e / _duration);
			e += _delta_time();
			yield return null;
		}
		_trans.position = _target;
	}

	public static IEnumerator moveTransforms(this List<Transform> _trans, Vector3 _target, float _duration, Func<float, float> _ease_func)
	{
		return _trans.moveTransforms(_target, _duration, _ease_func, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator moveTransforms(this List<Transform> _trans, Vector3 _target, float _duration, Func<float, float> _ease_func, Func<float> _delta_time)
	{
		float e = 0f;
		Dictionary<Transform, Vector3> starts = new Dictionary<Transform, Vector3>();
		Dictionary<Transform, Vector3> diffs = new Dictionary<Transform, Vector3>();
		_trans.ForEach(delegate(Transform _e)
		{
			starts[_e] = _e.localPosition;
			diffs[_e] = _target - _e.localPosition;
		});
		while (e < _duration)
		{
			_trans.ForEach(delegate(Transform _e)
			{
				_e.localPosition = starts[_e] + diffs[_e] * _ease_func(e / _duration);
			});
			e += _delta_time();
			yield return null;
		}
		_trans.ForEach(delegate(Transform _e)
		{
			_e.localPosition = _target;
		});
	}

	public static IEnumerator moveTransformAround(this Transform _trans, Vector2 _centre, float _distance, float _starting_theta, float _end_theta, float _duration, Func<float, float> _ease_func)
	{
		return _trans.moveTransformAround(_centre, _distance, _starting_theta, _end_theta, _duration, _ease_func, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator moveTransformAround(this Transform _trans, Vector2 _centre, float _distance, float _starting_theta, float _end_theta, float _duration, Func<float, float> _ease_func, Func<float> _delta_time)
	{
		float e_time = 0f;
		float diff = _end_theta - _starting_theta;
		while (e_time < _duration)
		{
			_trans.localPosition = _centre + new Vector2(_distance, _starting_theta + diff * _ease_func(e_time / _duration)).polarToCartesian();
			e_time += _delta_time();
			yield return null;
		}
		_trans.localPosition = _centre + new Vector2(_distance, _end_theta).polarToCartesian();
	}

	public static IEnumerator moveTransformToMovingTarget(this Transform _trans, Func<Vector3> _get_pos, float _duration, Func<float, float> _ease_func)
	{
		return _trans.moveTransformToMovingTarget(_get_pos, _duration, _ease_func, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator moveTransformToMovingTarget(this Transform _trans, Func<Vector3> _get_pos, float _duration, Func<float, float> _ease_func, Func<float> _delta_time)
	{
		float e = 0f;
		Vector3 start = _trans.localPosition;
		while (e < _duration)
		{
			Vector3 vector = _get_pos() - start;
			_trans.localPosition = start + vector * _ease_func(e / _duration);
			e += _delta_time();
			yield return null;
		}
		_trans.localPosition = _get_pos();
	}

	public static IEnumerator moveTransformToMovingTargetGlobal(this Transform _trans, Func<Vector3> _get_pos, float _duration, Func<float, float> _ease_func)
	{
		return _trans.moveTransformToMovingTargetGlobal(_get_pos, _duration, _ease_func, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator moveTransformToMovingTargetGlobal(this Transform _trans, Func<Vector3> _get_pos, float _duration, Func<float, float> _ease_func, Func<float> _delta_time)
	{
		float e = 0f;
		Vector3 start = _trans.position;
		while (e < _duration)
		{
			Vector3 vector = _get_pos() - start;
			_trans.position = start + vector * _ease_func(e / _duration);
			e += _delta_time();
			yield return null;
		}
		_trans.position = _get_pos();
	}

	public static IEnumerator moveTransformsRelative(this List<Transform> _trans, Vector3 _diff, float _duration, Func<float, float> _ease_func)
	{
		return _trans.moveTransformsRelative(_diff, _duration, _ease_func, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator moveTransformsRelative(this List<Transform> _trans, Vector3 _diff, float _duration, Func<float, float> _ease_func, Func<float> _delta_time)
	{
		float e = 0f;
		Dictionary<Transform, Vector3> starts = new Dictionary<Transform, Vector3>();
		_trans.ForEach(delegate(Transform _e)
		{
			starts[_e] = _e.localPosition;
		});
		while (e < _duration)
		{
			_trans.ForEach(delegate(Transform _e)
			{
				_e.localPosition = starts[_e] + _diff * _ease_func(e / _duration);
			});
			e += _delta_time();
			yield return null;
		}
		_trans.ForEach(delegate(Transform _e)
		{
			_e.localPosition = starts[_e] + _diff;
		});
	}

	public static IEnumerator moveTransformsRelativeGlobal(this List<Transform> _trans, Vector3 _diff, float _duration, Func<float, float> _ease_func)
	{
		return _trans.moveTransformsRelativeGlobal(_diff, _duration, _ease_func, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator moveTransformsRelativeGlobal(this List<Transform> _trans, Vector3 _diff, float _duration, Func<float, float> _ease_func, Func<float> _delta_time)
	{
		float e = 0f;
		Dictionary<Transform, Vector3> starts = new Dictionary<Transform, Vector3>();
		_trans.ForEach(delegate(Transform _e)
		{
			starts[_e] = _e.position;
		});
		while (e < _duration)
		{
			_trans.ForEach(delegate(Transform _e)
			{
				_e.position = starts[_e] + _diff * _ease_func(e / _duration);
			});
			e += _delta_time();
			yield return null;
		}
		_trans.ForEach(delegate(Transform _e)
		{
			_e.position = starts[_e] + _diff;
		});
	}

	public static IEnumerator moveTransformAtSpeed(this Transform _trans, Vector3 _target, float _speed)
	{
		return _trans.moveTransformAtSpeed(_target, _speed, (float _f) => _f, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator moveTransformAtSpeed(this Transform _trans, Vector3 _target, float _speed, Func<float, float> _ease)
	{
		return _trans.moveTransformAtSpeed(_target, _speed, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator moveTransformAtSpeed(this Transform _trans, Vector3 _target, float _speed, Func<float, float> _ease, Func<float> _delta_time)
	{
		return _trans.moveTransform(_target, (_target - _trans.localPosition).magnitude / _speed, _ease, _delta_time);
	}

	public static IEnumerator doubleMove(this Transform _trans, Vector3 _starting_target, Vector3 _end_target, float _duration, Func<float, float> _target_ease, Func<float, float> _ease)
	{
		return _trans.doubleMove(_starting_target, _end_target, _duration, _target_ease, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator doubleMove(this Transform _trans, Vector3 _starting_target, Vector3 _end_target, float _duration, Func<float, float> _target_ease, Func<float, float> _ease, Func<float> _delta_time)
	{
		Vector3 target_diff = _end_target - _starting_target;
		float e = 0f;
		Vector3 start = _trans.localPosition;
		while (e < _duration)
		{
			Vector3 vector = _starting_target + target_diff * _target_ease(e / _duration);
			Vector3 vector2 = vector - start;
			_trans.localPosition = start + vector2 * _ease(e / _duration);
			e += _delta_time();
			yield return null;
		}
		_trans.localPosition = _end_target;
	}

	public static IEnumerator moveTransformAxis(this Transform _trans, Vector3 _target, float _duration, Func<float, float> _x_ease, Func<float, float> _y_ease, Func<float, float> _z_ease)
	{
		return _trans.moveTransformAxis(_target, new Vector3(_duration, _duration, _duration), _x_ease, _y_ease, _z_ease);
	}

	public static IEnumerator moveTransformAxis(this Transform _trans, Vector3 _target, Vector3 _duration, Func<float, float> _ease)
	{
		return _trans.moveTransformAxis(_target, _duration, _ease, _ease, _ease);
	}

	public static IEnumerator moveTransformAxis(this Transform _trans, Vector3 _target, Vector3 _duration, Func<float, float> _x_ease, Func<float, float> _y_ease, Func<float, float> _z_ease)
	{
		return _trans.moveTransformAxis(_target, _duration, _x_ease, _y_ease, _z_ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator moveTransformAxis(this Transform _trans, Vector3 _target, Vector3 _duration, Func<float, float> _x_ease, Func<float, float> _y_ease, Func<float, float> _z_ease, Func<float> _delta_time)
	{
		Vector3 start = _trans.localPosition;
		Vector3 diff = _target - start;
		float e = 0f;
		float max_duration = Mathf.Max(_duration.x, _duration.y, _duration.z);
		while (e < max_duration)
		{
			e += _delta_time();
			Vector3 localPosition = start;
			localPosition.x += diff.x * _x_ease(Mathf.Min(e / _duration.x, 1f));
			localPosition.y += diff.y * _y_ease(Mathf.Min(e / _duration.y, 1f));
			localPosition.z += diff.z * _z_ease(Mathf.Min(e / _duration.z, 1f));
			_trans.localPosition = localPosition;
			yield return null;
		}
		_trans.localPosition = _target;
	}

	public static IEnumerator moveTransformAxis(this Transform _trans, Vector2 _target, float _duration, Func<float, float> _x_ease, Func<float, float> _y_ease)
	{
		return _trans.moveTransformAxis(_target, new Vector2(_duration, _duration), _x_ease, _y_ease);
	}

	public static IEnumerator moveTransformAxis(this Transform _trans, Vector2 _target, Vector2 _duration, Func<float, float> _ease)
	{
		return _trans.moveTransformAxis(_target, _duration, _ease, _ease);
	}

	public static IEnumerator moveTransformAxis(this Transform _trans, Vector2 _target, Vector2 _duration, Func<float, float> _x_ease, Func<float, float> _y_ease)
	{
		return _trans.moveTransformAxis(_target, _duration, _x_ease, _y_ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator moveTransformAxis(this Transform _trans, Vector2 _target, Vector2 _duration, Func<float, float> _x_ease, Func<float, float> _y_ease, Func<float> _delta_time)
	{
		Vector2 start = _trans.localPosition;
		Vector2 diff = _target - start;
		float e = 0f;
		float max_duration = Mathf.Max(_duration.x, _duration.y);
		while (e < max_duration)
		{
			e += _delta_time();
			Vector2 vector = start;
			vector.x += diff.x * _x_ease(Mathf.Min(e / _duration.x, 1f));
			vector.y += diff.y * _y_ease(Mathf.Min(e / _duration.y, 1f));
			_trans.localPosition = vector;
			yield return null;
		}
		_trans.localPosition = _target;
	}

	public static IEnumerator moveTransformAxisGlobal(this Transform _trans, Vector3 _target, float _duration, Func<float, float> _x_ease, Func<float, float> _y_ease, Func<float, float> _z_ease)
	{
		return _trans.moveTransformAxisGlobal(_target, new Vector3(_duration, _duration, _duration), _x_ease, _y_ease, _z_ease);
	}

	public static IEnumerator moveTransformAxisGlobal(this Transform _trans, Vector3 _target, Vector3 _duration, Func<float, float> _ease)
	{
		return _trans.moveTransformAxisGlobal(_target, _duration, _ease, _ease, _ease);
	}

	public static IEnumerator moveTransformAxisGlobal(this Transform _trans, Vector3 _target, Vector3 _duration, Func<float, float> _x_ease, Func<float, float> _y_ease, Func<float, float> _z_ease)
	{
		return _trans.moveTransformAxisGlobal(_target, _duration, _x_ease, _y_ease, _z_ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator moveTransformAxisGlobal(this Transform _trans, Vector3 _target, Vector3 _duration, Func<float, float> _x_ease, Func<float, float> _y_ease, Func<float, float> _z_ease, Func<float> _delta_time)
	{
		Vector3 start = _trans.position;
		Vector3 diff = _target - start;
		float e = 0f;
		float max_duration = Mathf.Max(_duration.x, _duration.y, _duration.z);
		while (e < max_duration)
		{
			e += _delta_time();
			Vector3 position = start;
			position.x += diff.x * _x_ease(Mathf.Min(e / _duration.x, 1f));
			position.y += diff.y * _y_ease(Mathf.Min(e / _duration.y, 1f));
			position.z += diff.z * _z_ease(Mathf.Min(e / _duration.z, 1f));
			_trans.position = position;
			yield return null;
		}
		_trans.position = _target;
	}

	public static IEnumerator moveTransformAxisGlobal(this Transform _trans, Vector2 _target, float _duration, Func<float, float> _x_ease, Func<float, float> _y_ease)
	{
		return _trans.moveTransformAxisGlobal(_target, new Vector2(_duration, _duration), _x_ease, _y_ease);
	}

	public static IEnumerator moveTransformAxisGlobal(this Transform _trans, Vector2 _target, Vector2 _duration, Func<float, float> _ease)
	{
		return _trans.moveTransformAxisGlobal(_target, _duration, _ease, _ease);
	}

	public static IEnumerator moveTransformAxisGlobal(this Transform _trans, Vector2 _target, Vector2 _duration, Func<float, float> _x_ease, Func<float, float> _y_ease)
	{
		return _trans.moveTransformAxisGlobal(_target, _duration, _x_ease, _y_ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator moveTransformAxisGlobal(this Transform _trans, Vector2 _target, Vector2 _duration, Func<float, float> _x_ease, Func<float, float> _y_ease, Func<float> _delta_time)
	{
		Vector2 start = _trans.position;
		Vector2 diff = _target - start;
		float e = 0f;
		float max_duration = Mathf.Max(_duration.x, _duration.y);
		while (e < max_duration)
		{
			e += _delta_time();
			Vector2 vector = start;
			vector.x += diff.x * _x_ease(Mathf.Min(e / _duration.x, 1f));
			vector.y += diff.y * _y_ease(Mathf.Min(e / _duration.y, 1f));
			_trans.position = vector;
			yield return null;
		}
		_trans.position = _target;
	}

	public static IEnumerator moveTransformAlongLineAtSpeed(this Transform _trans, List<Vector3> _targets, float _speed, Func<float, float> _ease_func)
	{
		return _trans.moveTransformAlongLineAtSpeed(_targets, _speed, _ease_func, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator moveTransformAlongLineAtSpeed(this Transform _trans, List<Vector3> _targets, float _speed, Func<float, float> _ease_func, Func<float> _delta_time)
	{
		if (_targets.Count < 2)
		{
			if (_targets.Count == 1)
			{
				yield return _trans.moveTransform(_targets[0], (_targets[0] - _trans.localPosition).magnitude / _speed, _ease_func, _delta_time);
			}
			else
			{
				Debug.LogError("Cannot move transform along line as list of target positions is empty!!!");
			}
			yield break;
		}
		List<(float, Vector3)> list = _targets.Aggregate((0f, _trans.localPosition).makeListFromItem(), (List<(float, Vector3 localPosition)> _a, Vector3 _p) => _a.add((_a[_a.Count - 1].Item1 + (_a[_a.Count - 1].localPosition - _p).magnitude, _p)));
		float item = list[list.Count - 1].Item1;
		yield return _trans.moveTransformAlongLine(list, item, item / _speed, _ease_func, _delta_time);
	}

	public static IEnumerator moveTransformAlongLine(this Transform _trans, List<Vector3> _targets, float _duration)
	{
		return _trans.moveTransformAlongLine(_targets, _duration, CoroutineExtensions.easeInOutFunc, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator moveTransformAlongLine(this Transform _trans, List<Vector3> _targets, float _duration, Func<float, float> _ease_func)
	{
		return _trans.moveTransformAlongLine(_targets, _duration, _ease_func, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator moveTransformAlongLine(this Transform _trans, List<Vector3> _targets, float _duration, Func<float, float> _ease_func, Func<float> _delta_time)
	{
		if (_targets.Count < 2)
		{
			if (_targets.Count == 1)
			{
				yield return _trans.moveTransform(_targets[0], _duration, _ease_func, _delta_time);
			}
			else
			{
				Debug.LogError("Cannot move transform along line as list of target positions is empty!!!");
			}
			yield break;
		}
		List<(float, Vector3)> list = _targets.Aggregate((0f, _trans.localPosition).makeListFromItem(), (List<(float, Vector3 localPosition)> _a, Vector3 _p) => _a.add((_a[_a.Count - 1].Item1 + (_a[_a.Count - 1].localPosition - _p).magnitude, _p)));
		float item = list[list.Count - 1].Item1;
		yield return _trans.moveTransformAlongLine(list, item, _duration, _ease_func, _delta_time);
	}

	private static IEnumerator moveTransformAlongLine(this Transform _trans, List<(float, Vector3)> _targets_with_dist, float _total_distance, float _duration, Func<float, float> _ease_func, Func<float> _delta_time)
	{
		float e = 0f;
		int current_line_point = 1;
		while (e < _duration)
		{
			float num;
			for (num = _ease_func(e / _duration) * _total_distance; _targets_with_dist[current_line_point].Item1 <= num && current_line_point + 1 < _targets_with_dist.Count; current_line_point++)
			{
			}
			Vector3 item = _targets_with_dist[current_line_point - 1].Item2;
			Vector3 vector = _targets_with_dist[current_line_point].Item2 - item;
			float num2 = (num - _targets_with_dist[current_line_point - 1].Item1) / (_targets_with_dist[current_line_point].Item1 - _targets_with_dist[current_line_point - 1].Item1);
			_trans.localPosition = item + vector * num2;
			e += _delta_time();
			yield return null;
		}
		_trans.localPosition = _targets_with_dist[_targets_with_dist.Count - 1].Item2;
	}

	public static IEnumerator scaleTransform(this Transform _trans, float _target, float _duration, Func<float, float> _ease_func)
	{
		return _trans.scaleTransform(Vector3.one * _target, _duration, _ease_func);
	}

	public static IEnumerator scaleTransform(this Transform _trans, float _target, float _duration, Func<float, float> _ease_func, Func<float> _delta_time)
	{
		return _trans.scaleTransform(Vector3.one * _target, _duration, _ease_func, _delta_time);
	}

	public static IEnumerator scaleTransform(this Transform _trans, Vector3 _target, float _duration, Func<float, float> _ease_func)
	{
		return _trans.scaleTransform(_target, _duration, _ease_func, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator scaleTransform(this Transform _trans, Vector3 _target, float _duration, Func<float, float> _ease_func, Func<float> _delta_time)
	{
		float e = 0f;
		Vector3 start = _trans.localScale;
		Vector3 diff = _target - start;
		while (e < _duration)
		{
			_trans.localScale = start + diff * _ease_func(e / _duration);
			e += _delta_time();
			yield return null;
		}
		_trans.localScale = _target;
	}

	public static IEnumerator scaleTransformToMovingTarget(this Transform _trans, Func<float> _get_scale, float _duration, Func<float, float> _ease_func)
	{
		return _trans.scaleTransformToMovingTarget(_get_scale, _duration, _ease_func, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator scaleTransformToMovingTarget(this Transform _trans, Func<float> _get_scale, float _duration, Func<float, float> _ease_func, Func<float> _delta_time)
	{
		return _trans.scaleTransformToMovingTarget(delegate
		{
			float num = _get_scale();
			return new Vector3(num, num, num);
		}, _duration, _ease_func, _delta_time);
	}

	public static IEnumerator scaleTransformToMovingTarget(this Transform _trans, Func<Vector3> _get_scale, float _duration, Func<float, float> _ease_func)
	{
		return _trans.scaleTransformToMovingTarget(_get_scale, _duration, _ease_func, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator scaleTransformToMovingTarget(this Transform _trans, Func<Vector3> _get_scale, float _duration, Func<float, float> _ease_func, Func<float> _delta_time)
	{
		float e = 0f;
		Vector3 start = _trans.localScale;
		while (e < _duration)
		{
			Vector3 vector = _get_scale() - start;
			_trans.localScale = start + vector * _ease_func(e / _duration);
			e += _delta_time();
			yield return null;
		}
		_trans.localScale = _get_scale();
	}

	public static IEnumerator shake(this Transform _transform, float _duration, float _power)
	{
		return _transform.shake(_duration, _power, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator shake(this Transform _transform, float _duration, float _power, Func<float> _delta_time)
	{
		Vector3 start_pos = _transform.localPosition;
		float e_time = 0f;
		while (e_time < _duration)
		{
			_transform.localPosition = start_pos.addVector2(UnityEngine.Random.insideUnitCircle * _power);
			e_time += _delta_time();
			yield return null;
		}
		_transform.localPosition = start_pos;
	}

	public static IEnumerator shakeMultiple(this List<Transform> _trans, float _duration, float _power)
	{
		return _trans.shakeMultiple(_duration, _power, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator shakeMultiple(this List<Transform> _trans, float _duration, float _power, Func<float> _delta_time)
	{
		List<Vector3> start_pos = new List<Vector3>();
		for (int i = 0; i < _trans.Count; i++)
		{
			start_pos.Add(_trans[i].localPosition);
		}
		float e_time = 0f;
		while (e_time < _duration)
		{
			for (int j = 0; j < _trans.Count; j++)
			{
				_trans[j].localPosition = start_pos[j].addVector2(UnityEngine.Random.insideUnitCircle * _power);
			}
			e_time += _delta_time();
			yield return null;
		}
		for (int k = 0; k < _trans.Count; k++)
		{
			_trans[k].localPosition = start_pos[k];
		}
	}

	public static IEnumerator slowShake(this Transform _transform, float _duration, float _power, float _frame_duration)
	{
		Vector3 start_pos = _transform.localPosition;
		float e_time = 0f;
		while (e_time < _duration)
		{
			_transform.localPosition = start_pos.addVector2(UnityEngine.Random.insideUnitCircle * _power);
			e_time += _frame_duration;
			yield return _frame_duration.wait();
		}
		_transform.transform.localPosition = start_pos;
	}

	public static IEnumerator lerpShake(this Transform _transform, float _duration, float _power, float _lerp_duration, Func<float, float> _ease, Func<float> _delta_time)
	{
		Vector3 start_pos = _transform.localPosition;
		float e_time = 0f;
		for (float duration = _duration - _lerp_duration; e_time < duration; e_time += _lerp_duration)
		{
			Vector3 target = start_pos.addVector2(UnityEngine.Random.insideUnitCircle * _power);
			yield return _transform.moveTransform(target, _lerp_duration, _ease, _delta_time);
		}
		yield return _transform.moveTransform(start_pos, _lerp_duration, _ease, _delta_time);
	}

	public static IEnumerator shake(this Transform _transform, float _duration, float _starting_power, float _end_power, Func<float, float> _power_growth_ease)
	{
		return _transform.shake(_duration, _starting_power, _end_power, _duration, 0f, _power_growth_ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator shake(this Transform _transform, float _duration, float _starting_power, float _end_power, Func<float, float> _power_growth_ease, Func<float> _delta_time)
	{
		return _transform.shake(_duration, _starting_power, _end_power, _duration, 0f, _power_growth_ease, _delta_time);
	}

	public static IEnumerator shake(this Transform _transform, float _shake_duration, float _starting_power, float _end_power, float _power_growth_duration, float _power_growth_delay, Func<float, float> _power_growth_ease)
	{
		return _transform.shake(_shake_duration, _starting_power, _end_power, _power_growth_duration, _power_growth_delay, _power_growth_ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator shake(this Transform _transform, float _shake_duration, float _starting_power, float _end_power, float _power_growth_duration, float _power_growth_delay, Func<float, float> _power_growth_ease, Func<float> _delta_time)
	{
		Vector3 start_pos = _transform.localPosition;
		float e_time = 0f;
		float power = _starting_power;
		float power_diff = _end_power - _starting_power;
		float power_time = _power_growth_duration + _power_growth_delay;
		while (e_time < _shake_duration)
		{
			if (e_time >= _power_growth_delay && e_time <= power_time)
			{
				power = _starting_power + power_diff * _power_growth_ease((e_time - _power_growth_delay) / _power_growth_duration);
			}
			else if (e_time > power_time)
			{
				power = _end_power;
			}
			_transform.localPosition = start_pos.addVector2(UnityEngine.Random.insideUnitCircle * power);
			e_time += _delta_time();
			yield return null;
		}
		_transform.localPosition = start_pos;
	}

	public static IEnumerator shakyMovement(this Transform _transform, Vector3 _target, float _duration, float _shake_power, Func<float, float> _ease)
	{
		return _transform.shakyMovement(_target, _duration, _shake_power, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator shakyMovement(this Transform _transform, Vector3 _target, float _duration, float _shake_power, Func<float, float> _ease, Func<float> _delta_time)
	{
		Vector3 start_pos = _transform.localPosition;
		Vector3 diff = _target - start_pos;
		float e_time = 0f;
		while (e_time < _duration)
		{
			Vector3 v = start_pos + diff * _ease(e_time / _duration);
			_transform.localPosition = v.addVector2(UnityEngine.Random.insideUnitCircle * _shake_power);
			e_time += _delta_time();
			yield return null;
		}
		_transform.transform.localPosition = _target;
	}

	public static IEnumerator rotationShake(this Transform _transform, float _duration, float _power)
	{
		return _transform.rotationShake(RandomExtensions.freshRandom(), _duration, _power, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator rotationShake(this Transform _transform, System.Random _random, float _duration, float _power)
	{
		return _transform.rotationShake(_random, _duration, _power, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator rotationShake(this Transform _transform, System.Random _random, float _duration, float _power, Func<float> _delta_time)
	{
		Vector3 start_angle = _transform.localEulerAngles;
		float e_time = 0f;
		while (e_time < _duration)
		{
			_transform.localEulerAngles = new Vector3(start_angle.x, start_angle.y, start_angle.z + _random.nextFloat(0f - _power, _power));
			e_time += _delta_time();
			yield return null;
		}
		_transform.localEulerAngles = start_angle;
	}

	public static IEnumerator rotationShake(this Transform _transform, float _duration, float _starting_power, float _end_power, Func<float, float> _power_growth_ease)
	{
		return _transform.rotationShake(RandomExtensions.freshRandom(), _duration, _starting_power, _end_power, _duration, 0f, _power_growth_ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator rotationShake(this Transform _transform, System.Random _random, float _duration, float _starting_power, float _end_power, Func<float, float> _power_growth_ease)
	{
		return _transform.rotationShake(_random, _duration, _starting_power, _end_power, _duration, 0f, _power_growth_ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator rotationShake(this Transform _transform, System.Random _random, float _duration, float _starting_power, float _end_power, Func<float, float> _power_growth_ease, Func<float> _delta_time)
	{
		return _transform.rotationShake(_random, _duration, _starting_power, _end_power, _duration, 0f, _power_growth_ease, _delta_time);
	}

	public static IEnumerator rotationShake(this Transform _transform, float _shake_duration, float _starting_power, float _end_power, float _power_growth_duration, float _power_growth_delay, Func<float, float> _power_growth_ease)
	{
		return _transform.rotationShake(RandomExtensions.freshRandom(), _shake_duration, _starting_power, _end_power, _power_growth_duration, _power_growth_delay, _power_growth_ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator rotationShake(this Transform _transform, System.Random _random, float _shake_duration, float _starting_power, float _end_power, float _power_growth_duration, float _power_growth_delay, Func<float, float> _power_growth_ease)
	{
		return _transform.rotationShake(_random, _shake_duration, _starting_power, _end_power, _power_growth_duration, _power_growth_delay, _power_growth_ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator rotationShake(this Transform _transform, System.Random _random, float _shake_duration, float _starting_power, float _end_power, float _power_growth_duration, float _power_growth_delay, Func<float, float> _power_growth_ease, Func<float> _delta_time)
	{
		Vector3 start_angle = _transform.localEulerAngles;
		float e_time = 0f;
		float power = _starting_power;
		float power_diff = _end_power - _starting_power;
		float power_time = _power_growth_duration + _power_growth_delay;
		while (e_time < _shake_duration)
		{
			if (e_time >= _power_growth_delay && e_time <= power_time)
			{
				power = _starting_power + power_diff * _power_growth_ease((e_time - _power_growth_delay) / _power_growth_duration);
			}
			else if (e_time > power_time)
			{
				power = _end_power;
			}
			_transform.localEulerAngles = new Vector3(start_angle.x, start_angle.y, start_angle.z + _random.nextFloat(0f - power, power));
			e_time += _delta_time();
			yield return null;
		}
		_transform.localEulerAngles = start_angle;
	}

	public static IEnumerator jiggle(this Transform _transform, System.Random _rng)
	{
		return _transform.jiggle(_rng, (5f, 8f));
	}

	public static IEnumerator jiggle(this Transform _transform, System.Random _rng, (float, float) _rotation_range, float _scale = 1.08f, float _duration = 0.75f)
	{
		return _transform.jiggle(_rng, _rotation_range, _scale, _duration, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator jiggle(this Transform _transform, System.Random _rng, (float, float) _rotation_range, float _scale, float _duration, Func<float> _delta_time)
	{
		float rotation_offset = _rng.nextFloat(_rotation_range.Item1, _rotation_range.Item2);
		bool num = _rng.Next(0, 2) == 0;
		_transform.localScale = new Vector3(_scale, _scale, 1f);
		_transform.localRotation = Quaternion.Euler(0f, 0f, rotation_offset);
		if (num)
		{
			rotation_offset *= -1f;
		}
		float scale_diff = 1f - _scale;
		yield return doActionForTime(delegate(float _f)
		{
			float num2 = _scale + scale_diff * _f;
			_transform.localScale = new Vector3(num2, num2, 1f);
			_transform.localEulerAngles = new Vector3(0f, 0f, rotation_offset * (1f - _f));
		}, _duration, CoroutineExtensions.easeOutElasticFunc, _delta_time);
		_transform.localScale = new Vector3(1f, 1f, 1f);
		_transform.localEulerAngles = new Vector3(0f, 0f, 0f);
	}

	public static IEnumerator anchoredMove(this RectTransform _trans, Vector3 _target, float _duration)
	{
		return _trans.anchoredMove(_target, _duration, (float _f) => _f);
	}

	public static IEnumerator anchoredMove(this RectTransform _trans, Vector3 _target, float _duration, Func<float, float> _ease_func)
	{
		return _trans.anchoredMove(_target, _duration, _ease_func, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator anchoredMove(this RectTransform _trans, Vector3 _target, float _duration, Func<float, float> _ease_func, Func<float> _delta_time)
	{
		float e = 0f;
		Vector3 start = _trans.anchoredPosition;
		Vector3 diff = _target - start;
		while (e < _duration)
		{
			_trans.anchoredPosition = start + diff * _ease_func(e / _duration);
			e += _delta_time();
			yield return null;
		}
		_trans.anchoredPosition = _target;
	}

	public static IEnumerator anchoredScale(this RectTransform _trans, Vector2 _min_target, Vector2 _max_target, float _duration)
	{
		return _trans.anchoredScale(_min_target, _max_target, _duration, (float f) => f);
	}

	public static IEnumerator anchoredScale(this RectTransform _trans, Vector2 _min_target, Vector2 _max_target, float _duration, Func<float, float> _ease_func)
	{
		return _trans.anchoredScale(_min_target, _max_target, _duration, _ease_func, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator anchoredScale(this RectTransform _trans, Vector2 _min_target, Vector2 _max_target, float _duration, Func<float, float> _ease_func, Func<float> _delta_time)
	{
		float e = 0f;
		Vector2 start_min = _trans.anchorMin;
		Vector2 diff_min = _min_target - start_min;
		Vector2 start_max = _trans.anchorMax;
		Vector2 diff_max = _max_target - start_max;
		while (e < _duration)
		{
			_trans.anchorMin = start_min + diff_min * _ease_func(e / _duration);
			_trans.anchorMax = start_max + diff_max * _ease_func(e / _duration);
			e += _delta_time();
			yield return null;
		}
		_trans.anchorMin = _min_target;
		_trans.anchorMax = _max_target;
	}

	public static IEnumerator anchoredMaxScale(this RectTransform _trans, Vector2 _max_target, float _duration)
	{
		return _trans.anchoredMaxScale(_max_target, _duration, (float f) => f);
	}

	public static IEnumerator anchoredMaxScale(this RectTransform _trans, Vector2 _max_target, float _duration, Func<float, float> _ease_func)
	{
		return _trans.anchoredMaxScale(_max_target, _duration, _ease_func, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator anchoredMaxScale(this RectTransform _trans, Vector2 _max_target, float _duration, Func<float, float> _ease_func, Func<float> _delta_time)
	{
		float e = 0f;
		Vector2 start_max = _trans.anchorMax;
		Vector2 diff_max = _max_target - start_max;
		while (e < _duration)
		{
			_trans.anchorMax = start_max + diff_max * _ease_func(e / _duration);
			e += _delta_time();
			yield return null;
		}
		_trans.anchorMax = _max_target;
	}

	public static IEnumerator anchoredMinScale(this RectTransform _trans, Vector2 _min_target, float _duration)
	{
		return _trans.anchoredMinScale(_min_target, _duration, (float f) => f);
	}

	public static IEnumerator anchoredMinScale(this RectTransform _trans, Vector2 _min_target, float _duration, Func<float, float> _ease_func)
	{
		return _trans.anchoredMinScale(_min_target, _duration, _ease_func, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator anchoredMinScale(this RectTransform _trans, Vector2 _min_target, float _duration, Func<float, float> _ease_func, Func<float> _delta_time)
	{
		float e = 0f;
		Vector2 start = _trans.anchorMin;
		Vector2 diff = _min_target - start;
		while (e < _duration)
		{
			_trans.anchorMin = start + diff * _ease_func(e / _duration);
			e += _delta_time();
			yield return null;
		}
		_trans.anchorMin = _min_target;
	}

	public static IEnumerator expandSizeDelta(this RectTransform _trans, Vector2 _target, float _duration, Func<float, float> _ease)
	{
		return _trans.expandSizeDelta(_target, _duration, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator expandSizeDelta(this RectTransform _trans, Vector2 _target, float _duration, Func<float, float> _ease, Func<float> _delta_time)
	{
		float e = 0f;
		Vector2 start_size = _trans.sizeDelta;
		Vector2 diff = _target - start_size;
		while (e < _duration)
		{
			e += _delta_time();
			_trans.sizeDelta = start_size + diff * _ease(e / _duration);
			yield return null;
		}
		_trans.sizeDelta = _target;
	}

	public static IEnumerator countDown1PerSecond(this TMP_Text _text, int _start_number, int _end_number)
	{
		return _text.countDown1PerSecond(_start_number, _end_number, (float f) => f, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator countDown1PerSecond(this TMP_Text _text, int _start_number, int _end_number, Func<float, float> _ease)
	{
		return _text.countDown1PerSecond(_start_number, _end_number, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator countDown1PerSecond(this TMP_Text _text, int _start_number, int _end_number, Func<float, float> _ease, Func<float> _delta_time)
	{
		return _text.countDown("", "", _start_number, _end_number, Mathf.Abs(_end_number - _start_number), _ease, _delta_time);
	}

	public static IEnumerator countDown1PerSecond(this TMP_Text _text, string _before, string _after, int _start_number, int _end_number)
	{
		return _text.countDown1PerSecond(_before, _after, _start_number, _end_number, (float f) => f, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator countDown1PerSecond(this TMP_Text _text, string _before, string _after, int _start_number, int _end_number, Func<float, float> _ease)
	{
		return _text.countDown1PerSecond(_before, _after, _start_number, _end_number, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator countDown1PerSecond(this TMP_Text _text, string _before, string _after, int _start_number, int _end_number, Func<float, float> _ease, Func<float> _delta_time)
	{
		return _text.countDown(_before, _after, _start_number, _end_number, Mathf.Abs(_end_number - _start_number), _ease, _delta_time);
	}

	public static IEnumerator countDown(this TMP_Text _text, int _start_number, int _end_number, float _duration, Func<float, float> _ease)
	{
		return _text.countDown(_start_number, _end_number, _duration, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator countDown(this TMP_Text _text, int _start_number, int _end_number, float _duration, Func<float, float> _ease, Func<float> _delta_time)
	{
		return _text.countDown("", "", _start_number, _end_number, _duration, _ease, _delta_time);
	}

	public static IEnumerator countDown(this TMP_Text _text, string _before, string _after, int _start_number, int _end_number, float _duration, Func<float, float> _ease)
	{
		return _text.countDown(_before, _after, _start_number, _end_number, _duration, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator countDown(this TMP_Text _text, string _before, string _after, int _start_number, int _end_number, float _duration, Func<float, float> _ease, Func<float> _delta_time)
	{
		float e = 0f;
		float diff = _end_number - _start_number;
		Func<float, int> round = ((_end_number <= _start_number) ? new Func<float, int>(Mathf.CeilToInt) : new Func<float, int>(Mathf.FloorToInt));
		while (e < _duration)
		{
			e += _delta_time();
			_text.text = _before + (_start_number + round(diff * _ease(e / _duration))) + _after;
			yield return null;
		}
		_text.text = _before + _end_number + _after;
	}

	public static IEnumerator countDown(this TMP_Text _text, float _start_number, float _target, float _duration)
	{
		return _text.countDown("", "", _start_number, _target, _duration, "0", (float _f) => _f, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator countDown(this TMP_Text _text, float _start_number, float _target, float _duration, Func<float, float> _ease)
	{
		return _text.countDown("", "", _start_number, _target, _duration, "0", _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator countDown(this TMP_Text _text, float _start_number, float _target, float _duration, string _format, Func<float, float> _ease)
	{
		return _text.countDown("", "", _start_number, _target, _duration, _format, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator countDown(this TMP_Text _text, float _start_number, float _target, float _duration, string _format, Func<float, float> _ease, Func<float> _delta)
	{
		return _text.countDown("", "", _start_number, _target, _duration, _format, _ease, _delta);
	}

	public static IEnumerator countDown(this TMP_Text _text, string _before, string _after, float _start_number, float _target, float _duration)
	{
		return _text.countDown(_before, _after, _start_number, _target, _duration, "0.0", (float _f) => _f, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator countDown(this TMP_Text _text, string _before, string _after, float _start_number, float _target, float _duration, Func<float, float> _ease)
	{
		return _text.countDown(_before, _after, _start_number, _target, _duration, "0", _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator countDown(this TMP_Text _text, string _before, string _after, float _start_number, float _target, float _duration, string _format, Func<float, float> _ease)
	{
		return _text.countDown(_before, _after, _start_number, _target, _duration, _format, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator countDown(this TMP_Text _text, string _before, string _after, float _start_number, float _target, float _duration, string _format, Func<float, float> _ease, Func<float> _delta_time)
	{
		float e = 0f;
		float diff = _target - _start_number;
		while (e < _duration)
		{
			e += _delta_time();
			_text.text = _before + (_start_number + diff * _ease(e / _duration)).ToString(_format) + _after;
			yield return null;
		}
		_text.text = _before + _target.ToString(_format) + _after;
	}

	public static IEnumerator countdownReplace(this TMP_Text _text, string _string, string _to_replace, int _start, int _target, float _duration, Func<float, float> _ease)
	{
		return _text.countdownReplace(_string, _to_replace, _start, _target, _duration, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator countdownReplace(this TMP_Text _text, string _string, string _to_replace, int _start, int _target, float _duration, Func<float, float> _ease, Func<float> _delta_time)
	{
		return _text.countdownReplace(_string, _to_replace, _start, _target, _duration, (int _i) => _i.ToString(), _ease, _delta_time);
	}

	public static IEnumerator countdownReplace(this TMP_Text _text, string _string, string _to_replace, int _start, int _target, float _duration, Func<int, string> _to_string, Func<float, float> _ease)
	{
		return _text.countdownReplace(_string, _to_replace, _start, _target, _duration, _to_string, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator countdownReplace(this TMP_Text _text, string _string, string _to_replace, int _start, int _target, float _duration, Func<int, string> _to_string, Func<float, float> _ease, Func<float> _delta_time)
	{
		float e = 0f;
		float diff = _target - _start;
		Func<float, int> round = ((_target <= _start) ? new Func<float, int>(Mathf.CeilToInt) : new Func<float, int>(Mathf.FloorToInt));
		while (e < _duration)
		{
			e += _delta_time();
			int arg = _start + round(diff * _ease(e / _duration));
			_text.text = _string.Replace(_to_replace, _to_string(arg));
			yield return null;
		}
		_text.text = _string.Replace(_to_replace, _to_string(_target));
	}

	public static IEnumerator countdownReplace(this TMP_Text _text, string _string, string _to_replace, float _start, float _target, float _duration, Func<float, float> _ease)
	{
		return _text.countdownReplace(_string, _to_replace, _start, _target, _duration, "0.0", _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator countdownReplace(this TMP_Text _text, string _string, string _to_replace, float _start, float _target, float _duration, string _format, Func<float, float> _ease)
	{
		return _text.countdownReplace(_string, _to_replace, _start, _target, _duration, _format, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator countdownReplace(this TMP_Text _text, string _string, string _to_replace, float _start, float _target, float _duration, string _format, Func<float, float> _ease, Func<float> _delta_time)
	{
		return _text.countdownReplace(_string, _to_replace, _start, _target, _duration, (float _i) => _i.ToString(_format), _ease, _delta_time);
	}

	public static IEnumerator countdownReplace(this TMP_Text _text, string _string, string _to_replace, float _start, float _target, float _duration, Func<float, string> _to_string, Func<float, float> _ease)
	{
		return _text.countdownReplace(_string, _to_replace, _start, _target, _duration, _to_string, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator countdownReplace(this TMP_Text _text, string _string, string _to_replace, float _start, float _target, float _duration, Func<float, string> _to_string, Func<float, float> _ease, Func<float> _delta_time)
	{
		float e = 0f;
		float diff = _target - _start;
		while (e < _duration)
		{
			e += _delta_time();
			float arg = _start + diff * _ease(e / _duration);
			_text.text = _string.Replace(_to_replace, _to_string(arg));
			yield return null;
		}
		_text.text = _string.Replace(_to_replace, _to_string(_target));
	}

	public static IEnumerator scaleSection(this TMP_Text _text, string _before, string _scaling, string _after, float _starting_size_percent, float _target_percentage, float _duration, Func<float, float> _ease)
	{
		return _text.scaleSection(_before, _scaling, _after, _starting_size_percent, _target_percentage, _duration, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator scaleSection(this TMP_Text _text, string _before, string _scaling, string _after, float _starting_size_percent, float _target_percentage, float _duration, Func<float, float> _ease, Func<float> _delta_time)
	{
		float e = 0f;
		float diff = _target_percentage - _starting_size_percent;
		while (e < _duration)
		{
			e += _delta_time();
			float f = _starting_size_percent + diff * _ease(e / _duration);
			_text.text = _before + $"<size={Mathf.RoundToInt(f)}%>" + _scaling + "</size>" + _after;
			yield return null;
		}
		_text.text = _before + $"<size={Mathf.RoundToInt(_target_percentage)}%>" + _scaling + "</size>" + _after;
	}

	public static IEnumerator bobSection(this TMP_Text _text, string _before, string _scaling, string _after, float _starting_size_percent, float _bob_percentage, float _duration_in, float _duration_out, Func<float, float> _ease)
	{
		return _text.bobSection(_before, _scaling, _after, _starting_size_percent, _bob_percentage, _duration_in, _duration_out, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator bobSection(this TMP_Text _text, string _before, string _scaling, string _after, float _starting_size_percent, float _bob_percentage, float _duration_in, float _duration_out, Func<float, float> _ease, Func<float> _delta_time)
	{
		yield return _text.scaleSection(_before, _scaling, _after, _starting_size_percent, _bob_percentage, _duration_in, _ease, _delta_time);
		yield return _text.scaleSection(_before, _scaling, _after, _bob_percentage, _starting_size_percent, _duration_out, _ease, _delta_time);
		_text.text = _before + _scaling + _after;
	}

	public static IEnumerator fadeMaterialColour(this SpriteRenderer _renderer, string _property_name, Color _target, float _duration)
	{
		return _renderer.fadeMaterialColour(_property_name, _target, _duration, CoroutineExtensions.easeInOutFunc);
	}

	public static IEnumerator fadeMaterialColour(this SpriteRenderer _renderer, string _property_name, Color _target, float _duration, Func<float, float> _ease)
	{
		return _renderer.fadeMaterialColour(_property_name, _target, _duration, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator fadeMaterialColour(this SpriteRenderer _renderer, string _property_name, Color _target, float _duration, Func<float, float> _ease, Func<float> _delta_time)
	{
		return _renderer.material.fadeMaterialColour(_property_name, _target, _duration, _ease, _delta_time);
	}

	public static IEnumerator fadeMaterialColour(this Material _mat, string _property_name, Color _target, float _duration)
	{
		return _mat.fadeMaterialColour(_property_name, _target, _duration, CoroutineExtensions.easeInOutFunc, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator fadeMaterialColour(this Material _mat, string _property_name, Color _target, float _duration, Func<float, float> _ease)
	{
		return _mat.fadeMaterialColour(_property_name, _target, _duration, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator fadeMaterialColour(this Material _mat, string _property_name, Color _target, float _duration, Func<float, float> _ease, Func<float> _delta_time)
	{
		float e = 0f;
		Color starting_colour = _mat.GetColor(_property_name);
		Color diff = _target - starting_colour;
		while (e < _duration)
		{
			e += _delta_time();
			_mat.SetColor(_property_name, starting_colour + diff * _ease(e / _duration));
			yield return null;
		}
		_mat.SetColor(_property_name, _target);
	}

	public static IEnumerator lerpMaterialProperty(this SpriteRenderer _renderer, string _property_name, float _target, float _duration)
	{
		return _renderer.lerpMaterialProperty(_property_name, _target, _duration, CoroutineExtensions.easeInOutFunc);
	}

	public static IEnumerator lerpMaterialProperty(this SpriteRenderer _renderer, string _property_name, float _target, float _duration, Func<float, float> _ease)
	{
		return _renderer.lerpMaterialProperty(_property_name, _target, _duration, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator lerpMaterialProperty(this SpriteRenderer _renderer, string _property_name, float _target, float _duration, Func<float, float> _ease, Func<float> _delta_time)
	{
		return _renderer.material.lerpMaterialProperty(_property_name, _target, _duration, _ease, _delta_time);
	}

	public static IEnumerator lerpMaterialProperty(this Material _mat, string _property_name, float _target, float _duration)
	{
		return _mat.lerpMaterialProperty(_property_name, _target, _duration, CoroutineExtensions.easeInOutFunc, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator lerpMaterialProperty(this Material _mat, string _property_name, float _target, float _duration, Func<float, float> _ease)
	{
		return _mat.lerpMaterialProperty(_property_name, _target, _duration, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator lerpMaterialProperty(this Material _mat, string _property_name, float _target, float _duration, Func<float, float> _ease, Func<float> _delta_time)
	{
		float e = 0f;
		float starting_value = _mat.GetFloat(_property_name);
		float diff = _target - starting_value;
		while (e < _duration)
		{
			e += _delta_time();
			_mat.SetFloat(_property_name, starting_value + diff * _ease(e / _duration));
			yield return null;
		}
		_mat.SetFloat(_property_name, _target);
	}

	public static IEnumerator lerpMaterialProperty(this SpriteRenderer _renderer, string _property_name, Vector2 _target, float _duration, Func<float, float> _ease)
	{
		return _renderer.lerpMaterialProperty(_property_name, _target, _duration, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator lerpMaterialProperty(this SpriteRenderer _renderer, string _property_name, Vector2 _target, float _duration, Func<float, float> _ease, Func<float> _delta_time)
	{
		return _renderer.material.lerpMaterialProperty(_property_name, _target, _duration, _ease, _delta_time);
	}

	public static IEnumerator lerpMaterialProperty(this SpriteRenderer _renderer, string _property_name, Vector3 _target, float _duration, Func<float, float> _ease)
	{
		return _renderer.lerpMaterialProperty(_property_name, _target, _duration, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator lerpMaterialProperty(this SpriteRenderer _renderer, string _property_name, Vector3 _target, float _duration, Func<float, float> _ease, Func<float> _delta_time)
	{
		return _renderer.material.lerpMaterialProperty(_property_name, _target, _duration, _ease, _delta_time);
	}

	public static IEnumerator lerpMaterialProperty(this SpriteRenderer _renderer, string _property_name, Vector4 _target, float _duration, Func<float, float> _ease)
	{
		return _renderer.lerpMaterialProperty(_property_name, _target, _duration, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator lerpMaterialProperty(this SpriteRenderer _renderer, string _property_name, Vector4 _target, float _duration, Func<float, float> _ease, Func<float> _delta_time)
	{
		return _renderer.material.lerpMaterialProperty(_property_name, _target, _duration, _ease, _delta_time);
	}

	public static IEnumerator lerpMaterialProperty(this Material _mat, string _property_name, Vector2 _target, float _duration, Func<float, float> _ease)
	{
		return _mat.lerpMaterialProperty(_property_name, _target, _duration, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator lerpMaterialProperty(this Material _mat, string _property_name, Vector2 _target, float _duration, Func<float, float> _ease, Func<float> _delta_time)
	{
		return _mat.lerpMaterialProperty(_property_name, new Vector4(_target.x, _target.y, 0f, 0f), _duration, _ease, _delta_time);
	}

	public static IEnumerator lerpMaterialProperty(this Material _mat, string _property_name, Vector3 _target, float _duration, Func<float, float> _ease)
	{
		return _mat.lerpMaterialProperty(_property_name, _target, _duration, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator lerpMaterialProperty(this Material _mat, string _property_name, Vector3 _target, float _duration, Func<float, float> _ease, Func<float> _delta_time)
	{
		return _mat.lerpMaterialProperty(_property_name, new Vector4(_target.x, _target.y, _target.z, 0f), _duration, _ease, _delta_time);
	}

	public static IEnumerator lerpMaterialProperty(this Material _mat, string _property_name, Vector4 _target, float _duration, Func<float, float> _ease)
	{
		return _mat.lerpMaterialProperty(_property_name, _target, _duration, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator lerpMaterialProperty(this Material _mat, string _property_name, Vector4 _target, float _duration, Func<float, float> _ease, Func<float> _delta_time)
	{
		float e = 0f;
		Vector4 starting_value = _mat.GetVector(_property_name);
		Vector4 diff = _target - starting_value;
		while (e < _duration)
		{
			e += _delta_time();
			_mat.SetVector(_property_name, starting_value + diff * _ease(e / _duration));
			yield return null;
		}
		_mat.SetVector(_property_name, _target);
	}

	public static IEnumerator wait(this float _duration)
	{
		yield return new WaitForSeconds(_duration);
	}

	public static IEnumerator wait(this float _duration, Action _callback)
	{
		yield return new WaitForSeconds(_duration);
		_callback();
	}

	public static IEnumerator wait(this int _duration)
	{
		yield return new WaitForSeconds(_duration);
	}

	public static IEnumerator wait(this int _duration, Action _callback)
	{
		yield return new WaitForSeconds(_duration);
		_callback();
	}

	public static IEnumerator waitReal(this float _duration)
	{
		yield return new WaitForSecondsRealtime(_duration);
	}

	public static IEnumerator waitReal(this float _duration, Action _callback)
	{
		yield return _duration.waitReal();
		_callback();
	}

	public static IEnumerator waitReal(this int _duration)
	{
		yield return new WaitForSecondsRealtime(_duration);
	}

	public static IEnumerator waitReal(this int _duration, Action _callback)
	{
		yield return _duration.waitReal();
		_callback();
	}

	public static IEnumerator waitEndOfFrame()
	{
		yield return new WaitForEndOfFrame();
	}

	public static IEnumerator fill(this Image _image, float _target, float _duration)
	{
		return _image.fill(_target, _duration, (float _f) => _f, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator fill(this Image _image, float _target, float _duration, Func<float, float> _ease_func)
	{
		return _image.fill(_target, _duration, _ease_func, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator fill(this Image _image, float _target, float _duration, Func<float, float> _ease_func, Func<float> _delta_time)
	{
		float start = _image.fillAmount;
		float diff = _target - start;
		float e = 0f;
		while (e < _duration)
		{
			e += _delta_time();
			_image.fillAmount = start + diff * _ease_func(e / _duration);
			yield return null;
		}
		_image.fillAmount = _target;
	}

	public static IEnumerator fill(this List<Image> _images, float _target, float _duration)
	{
		return _images.fill(_target, _duration, (float _f) => _f, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator fill(this List<Image> _images, float _target, float _duration, Func<float, float> _ease_func)
	{
		return _images.fill(_target, _duration, _ease_func, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator fill(this List<Image> _images, float _target, float _duration, Func<float, float> _ease_func, Func<float> _delta_time)
	{
		List<float> start = _images.Select((Image _i) => _i.fillAmount).toListSafe();
		List<float> diff = start.Select((float _s) => _target - _s).toListSafe();
		float e = 0f;
		while (e < _duration)
		{
			e += _delta_time();
			float num = _ease_func(e / _duration);
			for (int i = 0; i < _images.Count; i++)
			{
				_images[i].fillAmount = start[i] + diff[i] * num;
			}
			yield return null;
		}
		foreach (Image _image in _images)
		{
			_image.fillAmount = _target;
		}
	}

	public static IEnumerator countdownFill(this Image _image, TMP_Text _text, float _target, float _text_target, float _text_start, float _duration)
	{
		return _image.countdownFill(_text, _target, _text_target, _text_start, _duration, "0", (float _f) => _f, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator countdownFill(this Image _image, TMP_Text _text, float _target, float _text_target, float _text_start, float _duration, string _text_format)
	{
		return _image.countdownFill(_text, _target, _text_target, _text_start, _duration, _text_format, (float _f) => _f, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator countdownFill(this Image _image, TMP_Text _text, float _target, float _text_target, float _text_start, float _duration, string _text_format, Func<float, float> _ease_func)
	{
		return _image.countdownFill(_text, _target, _text_target, _text_start, _duration, _text_format, _ease_func, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator countdownFill(this Image _image, TMP_Text _text, float _target, float _text_target, float _text_start, float _duration, string _text_format, Func<float, float> _ease_func, Func<float> _delta_time)
	{
		float img_start = _image.fillAmount;
		float img_diff = _target - img_start;
		float text_diff = _text_target - _text_start;
		float e = 0f;
		while (e < _duration)
		{
			e += _delta_time();
			_image.fillAmount = img_start + img_diff * _ease_func(e / _duration);
			_text.text = (_text_start + text_diff * _ease_func(e / _duration)).ToString(_text_format);
			yield return null;
		}
		_image.fillAmount = _target;
		_text.text = _text_target.ToString(_text_format);
	}

	public static IEnumerator lerpConstantsRateOverTimeEmissions(this ParticleSystem _particle_system, float _target_min, float _target_max, float _duration)
	{
		return _particle_system.lerpConstantsRateOverTimeEmissions(_target_min, _target_max, _duration, CoroutineExtensions.easeInOutFunc, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator lerpConstantsRateOverTimeEmissions(this ParticleSystem _particle_system, float _target_min, float _target_max, float _duration, Func<float, float> _ease)
	{
		return _particle_system.lerpConstantsRateOverTimeEmissions(_target_min, _target_max, _duration, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator lerpConstantsRateOverTimeEmissions(this ParticleSystem _particle_system, float _target_min, float _target_max, float _duration, Func<float, float> _ease, Func<float> _delta_time)
	{
		ParticleSystem.EmissionModule emissions = _particle_system.emission;
		ParticleSystem.MinMaxCurve rot = emissions.rateOverTime;
		Vector2 start = new Vector2(rot.constantMin, rot.constantMax);
		Vector2 diff = new Vector2(_target_min - start.x, _target_max - start.y);
		yield return doActionForTime(delegate(float _f)
		{
			rot.constantMin = start.x + diff.x * _f;
			rot.constantMax = start.y + diff.y * _f;
			emissions.rateOverTime = rot;
		}, _duration, _ease, _delta_time);
		rot.constantMin = _target_min;
		rot.constantMax = _target_max;
		emissions.rateOverTime = rot;
	}

	public static IEnumerator lerpConstantRateOverTimeEmissions(this ParticleSystem _particle_system, float _target, float _duration)
	{
		return _particle_system.lerpConstantRateOverTimeEmissions(_target, _duration, CoroutineExtensions.easeInOutFunc, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator lerpConstantRateOverTimeEmissions(this ParticleSystem _particle_system, float _target, float _duration, Func<float, float> _ease)
	{
		return _particle_system.lerpConstantRateOverTimeEmissions(_target, _duration, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator lerpConstantRateOverTimeEmissions(this ParticleSystem _particle_system, float _target, float _duration, Func<float, float> _ease, Func<float> _delta_time)
	{
		ParticleSystem.EmissionModule emissions = _particle_system.emission;
		ParticleSystem.MinMaxCurve rot = emissions.rateOverTime;
		float start = rot.constant;
		float diff = _target - start;
		yield return doActionForTime(delegate(float _f)
		{
			rot.constant = start + diff * _f;
			emissions.rateOverTime = rot;
		}, _duration, _ease, _delta_time);
		rot.constant = _target;
		emissions.rateOverTime = rot;
	}

	public static IEnumerator fadeConstantColour(this ParticleSystem _particle_system, float _alpha, float _duration)
	{
		return _particle_system.fadeConstantColour(_alpha, _duration, CoroutineExtensions.easeInOutFunc, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator fadeConstantColour(this ParticleSystem _particle_system, float _alpha, float _duration, Func<float, float> _ease)
	{
		return _particle_system.fadeConstantColour(_alpha, _duration, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator fadeConstantColour(this ParticleSystem _particle_system, float _alpha, float _duration, Func<float, float> _ease, Func<float> _delta_time)
	{
		ParticleSystem.MainModule main = _particle_system.main;
		ParticleSystem.MinMaxGradient colour = main.startColor;
		float start = colour.color.a;
		float diff = _alpha - start;
		yield return doActionForTime(delegate(float _f)
		{
			colour.color = colour.color.setAlpha(start + diff * _f);
			main.startColor = colour;
		}, _duration, _ease, _delta_time);
		colour.color = colour.color.setAlpha(_alpha);
		main.startColor = colour;
	}

	public static IEnumerator lerpConstantColour(this ParticleSystem _particle_system, Color _colour, float _duration)
	{
		return _particle_system.lerpConstantColour(_colour, _duration, CoroutineExtensions.easeInOutFunc, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator lerpConstantColour(this ParticleSystem _particle_system, Color _colour, float _duration, Func<float, float> _ease)
	{
		return _particle_system.lerpConstantColour(_colour, _duration, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator lerpConstantColour(this ParticleSystem _particle_system, Color _colour, float _duration, Func<float, float> _ease, Func<float> _delta_time)
	{
		ParticleSystem.MainModule main = _particle_system.main;
		ParticleSystem.MinMaxGradient colour = main.startColor;
		Color start_colour = colour.color;
		Color diff = _colour - start_colour;
		yield return doActionForTime(delegate(float _f)
		{
			colour.color = start_colour + diff * _f;
			main.startColor = colour;
		}, _duration, _ease, _delta_time);
		colour.color = _colour;
		main.startColor = colour;
	}

	public static IEnumerator fadeColourOverLifetimeGradientAlpha(this ParticleSystem _particle_system, List<int> _key_indexes, float _alpha, float _duration)
	{
		return _particle_system.fadeColourOverLifetimeGradientAlpha(_key_indexes, _alpha, _duration, CoroutineExtensions.easeInOutFunc, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator fadeColourOverLifetimeGradientAlpha(this ParticleSystem _particle_system, List<int> _key_indexes, float _alpha, float _duration, Func<float, float> _ease)
	{
		return _particle_system.fadeColourOverLifetimeGradientAlpha(_key_indexes, _alpha, _duration, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator fadeColourOverLifetimeGradientAlpha(this ParticleSystem _particle_system, List<int> _key_indexes, float _alpha, float _duration, Func<float, float> _ease, Func<float> _delta_time)
	{
		ParticleSystem.ColorOverLifetimeModule main = _particle_system.colorOverLifetime;
		Gradient gradient = main.color.gradient;
		GradientAlphaKey[] alpha_keys = gradient.alphaKeys;
		Dictionary<int, (float, float)> useful_alphas = new Dictionary<int, (float, float)>();
		_key_indexes.ForEach(delegate(int _i)
		{
			useful_alphas[_i] = (alpha_keys[_i].alpha, _alpha - alpha_keys[_i].alpha);
		});
		yield return doActionForTime(delegate(float _f)
		{
			_key_indexes.ForEach(delegate(int _ki)
			{
				alpha_keys[_ki].alpha = useful_alphas[_ki].Item1 + useful_alphas[_ki].Item2 * _f;
			});
			gradient.alphaKeys = alpha_keys;
			main.color = gradient;
		}, _duration, _ease, _delta_time);
		_key_indexes.ForEach(delegate(int _ki)
		{
			alpha_keys[_ki].alpha = _alpha;
		});
		gradient.alphaKeys = alpha_keys;
		main.color = gradient;
	}

	public static IEnumerator lerpConstantSpeed(this ParticleSystem _particle_system, float _speed, float _duration)
	{
		return _particle_system.lerpConstantSpeed(_speed, _duration, CoroutineExtensions.easeInOutFunc, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator lerpConstantSpeed(this ParticleSystem _particle_system, float _speed, float _duration, Func<float, float> _ease)
	{
		return _particle_system.lerpConstantSpeed(_speed, _duration, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator lerpConstantSpeed(this ParticleSystem _particle_system, float _speed, float _duration, Func<float, float> _ease, Func<float> _delta_time)
	{
		ParticleSystem.MainModule main = _particle_system.main;
		ParticleSystem.MinMaxCurve speed = main.startSpeed;
		float start_speed = speed.constant;
		float diff = _speed - start_speed;
		yield return doActionForTime(delegate(float _f)
		{
			speed.constant = start_speed + diff * _f;
			main.startSpeed = speed;
		}, _duration, _ease, _delta_time);
		speed.constant = _speed;
		main.startSpeed = speed;
	}

	public static IEnumerator lerpConstantsSpeed(this ParticleSystem _particle_system, float _target_min, float _target_max, float _duration)
	{
		return _particle_system.lerpConstantsSpeed(_target_min, _target_max, _duration, CoroutineExtensions.easeInOutFunc, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator lerpConstantsSpeed(this ParticleSystem _particle_system, float _target_min, float _target_max, float _duration, Func<float, float> _ease)
	{
		return _particle_system.lerpConstantsSpeed(_target_min, _target_max, _duration, _ease, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator lerpConstantsSpeed(this ParticleSystem _particle_system, float _target_min, float _target_max, float _duration, Func<float, float> _ease, Func<float> _delta_time)
	{
		ParticleSystem.MainModule main = _particle_system.main;
		ParticleSystem.MinMaxCurve speed = main.startSpeed;
		Vector2 start = new Vector2(speed.constantMin, speed.constantMax);
		Vector2 diff = new Vector2(_target_min - start.x, _target_max - start.y);
		yield return doActionForTime(delegate(float _f)
		{
			speed.constantMin = start.x + diff.x * _f;
			speed.constantMax = start.y + diff.y * _f;
			main.startSpeed = speed;
		}, _duration, _ease, _delta_time);
		speed.constantMin = _target_min;
		speed.constantMax = _target_max;
		main.startSpeed = speed;
	}

	public static IEnumerator zoom(this Camera _camera, float _target, float _duration, Func<float, float> _ease_func)
	{
		return _camera.zoom(_target, _duration, _ease_func, CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator zoom(this Camera _camera, float _target, float _duration, Func<float, float> _ease_func, Func<float> _delta_time)
	{
		float e = 0f;
		float start = _camera.orthographicSize;
		float diff = _target - start;
		while (e < _duration)
		{
			_camera.orthographicSize = start + diff * _ease_func(e / _duration);
			e += _delta_time();
			yield return null;
		}
		_camera.orthographicSize = _target;
	}

	public static IEnumerator doActionForTime(this Action _action, float _time)
	{
		return _action.doActionForTime(_time, (Func<float>)CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator doActionForTime(this Action _action, float _time, Func<float> _delta_time)
	{
		float e = 0f;
		while (e < _time)
		{
			_action();
			e += _delta_time();
			yield return null;
		}
	}

	public static IEnumerator doActionForTime(this Action _action, float _time, Action _callback)
	{
		return _action.doActionForTime(_time, (Func<float>)CoroutineExtensions.getDeltaTime).addCallback(_callback);
	}

	public static IEnumerator doActionForTime(this Action _action, float _time, Func<float> _delta_time, Action _callback)
	{
		return _action.doActionForTime(_time, _delta_time).addCallback(_callback);
	}

	public static IEnumerator doActionForTime(this Action<float> _action, float _time)
	{
		return _action.doActionForTime(_time, (float f) => f);
	}

	public static IEnumerator doActionForTime(this Action<float> _action, float _time, Func<float, float> _ease_func)
	{
		return _action.doActionForTime(_time, _ease_func, (Func<float>)CoroutineExtensions.getDeltaTime);
	}

	public static IEnumerator doActionForTime(this Action<float> _action, float _time, Func<float, float> _ease_func, Func<float> _delta_time)
	{
		float e = 0f;
		while (e < _time)
		{
			_action(_ease_func(e / _time));
			e += _delta_time();
			yield return null;
		}
	}

	public static IEnumerator doActionForTime(this Action<float> _action, float _time, Action _callback)
	{
		return _action.doActionForTime(_time).addCallback(_callback);
	}

	public static IEnumerator doActionForTime(this Action<float> _action, float _time, Func<float, float> _ease_func, Action _callback)
	{
		return _action.doActionForTime(_time, _ease_func).addCallback(_callback);
	}

	public static IEnumerator doActionForTime(this Action<float> _action, float _time, Func<float, float> _ease_func, Func<float> _delta_time, Action _callback)
	{
		return _action.doActionForTime(_time, _ease_func, _delta_time).addCallback(_callback);
	}

	public static IEnumerator all<T>(this List<IEnumerator> _list, T _mono) where T : MonoBehaviour
	{
		return all(_mono, _list.ToArray());
	}

	public static IEnumerator all<T>(T _mono, params IEnumerator[] _coroutines) where T : MonoBehaviour
	{
		bool[] complete_list = new bool[_coroutines.Length];
		for (int i = 0; i < _coroutines.Length; i++)
		{
			int t = i;
			_mono.StartCoroutine(_coroutines[i].addCallback(delegate
			{
				complete_list[t] = true;
			}));
		}
		while (!complete_list.Aggregate(seed: true, (bool _a, bool _b) => _a = _b && _a))
		{
			yield return null;
		}
	}

	public static IEnumerator any<T>(this List<IEnumerator> _list, T _mono) where T : MonoBehaviour
	{
		return any(_mono, _list.ToArray());
	}

	public static IEnumerator any<T>(T _mono, params IEnumerator[] _coroutines) where T : MonoBehaviour
	{
		bool[] complete_list = new bool[_coroutines.Length];
		int i;
		for (i = 0; i < _coroutines.Length; i++)
		{
			_mono.StartCoroutine(_coroutines[i].addCallback(delegate
			{
				complete_list[i] = true;
			}));
		}
		while (complete_list.Where((bool _e) => _e).ToList().Count < 1)
		{
			yield return null;
		}
	}

	public static IEnumerator chain(this List<IEnumerator> _list)
	{
		return chain(_list.ToArray());
	}

	public static IEnumerator chain(params IEnumerator[] _coroutines)
	{
		for (int i = 0; i < _coroutines.Length; i++)
		{
			yield return _coroutines[i];
		}
	}

	public static IEnumerator sequence<T>(this List<IEnumerator> _list, float _delay, T _mono, bool _wait_for_completion = false) where T : MonoBehaviour
	{
		return sequence(_delay, _mono, _wait_for_completion, _list.ToArray());
	}

	public static IEnumerator sequence<T>(float _delay, T _mono, bool _wait_for_completion, params IEnumerator[] _coroutines) where T : MonoBehaviour
	{
		for (int i = 0; i < _coroutines.Length; i++)
		{
			if (_wait_for_completion)
			{
				yield return _mono.StartCoroutine(_coroutines[i]);
			}
			else
			{
				_mono.StartCoroutine(_coroutines[i]);
			}
			yield return _delay.wait();
		}
	}

	public static IEnumerator sequenceRealTime<T>(this List<IEnumerator> _list, float _delay, T _mono, bool _wait_for_completion = false) where T : MonoBehaviour
	{
		return sequenceRealTime(_delay, _mono, _wait_for_completion, _list.ToArray());
	}

	public static IEnumerator sequenceRealTime<T>(float _delay, T _mono, bool _wait_for_completion, params IEnumerator[] _coroutines) where T : MonoBehaviour
	{
		for (int i = 0; i < _coroutines.Length; i++)
		{
			if (_wait_for_completion)
			{
				yield return _mono.StartCoroutine(_coroutines[i]);
			}
			else
			{
				_mono.StartCoroutine(_coroutines[i]);
			}
			yield return _delay.waitReal();
		}
	}

	public static IEnumerator loop(this Func<IEnumerator> _coroutine, int _iterations)
	{
		if (_iterations < 0)
		{
			throw new ArgumentException("Loop iterations cannot be less than 0.");
		}
		bool infinte = _iterations == 0;
		int loops_left = _iterations;
		while (infinte || loops_left > 1)
		{
			if (!infinte)
			{
				loops_left--;
			}
			yield return _coroutine();
		}
	}

	public static IEnumerator addCallback(this IEnumerator _coroutine, Action _callback)
	{
		yield return _coroutine;
		_callback();
	}

	public static Coroutine start<T>(this IEnumerator _coroutine, T _mono) where T : MonoBehaviour
	{
		return _mono.StartCoroutine(_coroutine);
	}

	public static void stop<T>(this Coroutine _coroutine, T _mono) where T : MonoBehaviour
	{
		_mono.StopCoroutine(_coroutine);
	}

	public static Maybe<Coroutine> start(this Maybe<Coroutine> _maybe, IEnumerator _enumerator, MonoBehaviour _mono)
	{
		_maybe = _enumerator.addCallback(delegate
		{
			_maybe = new Maybe<Coroutine>();
		}).start(_mono).maybe();
		return _maybe;
	}

	public static Maybe<Coroutine> stopCoroutineIfSome(this Maybe<Coroutine> _coroutine, MonoBehaviour _mono)
	{
		_coroutine.doActionIfSome(delegate(Coroutine _c)
		{
			_mono.StopCoroutine(_c);
			_coroutine = new Maybe<Coroutine>();
		});
		return _coroutine;
	}
}
