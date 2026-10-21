using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Coroutines;
using GRGLib.Maybe;
using TMPro;
using UnityEngine;

namespace GRGLib.TextAnimation;

public static class TextAnimationHelper
{
	public enum PresetTextAnimationCurves
	{
		NONE,
		SLOW,
		NORMAL,
		FAST,
		SLOW_EXAGERATED,
		NORMAL_EXAGERATED,
		FAST_EXAGERATED
	}

	public static IEnumerator animateText(this TMP_Text _text_base, params TextAnimationManager[] _managers)
	{
		return _text_base.animateText(_managers.ToList());
	}

	public static IEnumerator animateText(this TMP_Text _text_base, List<TextAnimationManager> _managers)
	{
		while (true)
		{
			_text_base.updateGeometry(_managers);
			yield return null;
		}
	}

	public static IEnumerator animateText(this TMP_Text _text_base, Func<string, TMP_Text, Maybe<TextAnimationManager>> _text_animation_manager_getter)
	{
		_text_base.ForceMeshUpdate();
		List<TextAnimationManager> animation_managers = _text_base.getTextAnimationManagers(_text_animation_manager_getter);
		string previous_text = _text_base.text;
		while (true)
		{
			_text_base.updateGeometry(animation_managers);
			yield return null;
			if (previous_text != _text_base.text)
			{
				previous_text = _text_base.text;
				if (!animation_managers.checkAnimationManagers(_text_base, _text_animation_manager_getter))
				{
					animation_managers = _text_base.getTextAnimationManagers(_text_animation_manager_getter);
				}
			}
		}
	}

	public static void updateGeometry(this TMP_Text _text_base, params TextAnimationManager[] _animation_managers)
	{
		_text_base.updateGeometry(_animation_managers.ToList());
	}

	public static void updateGeometry(this TMP_Text _text_base, List<TextAnimationManager> _animation_managers)
	{
		_text_base.renderMode = TextRenderFlags.DontRender;
		TMP_TextInfo textInfo = _text_base.textInfo;
		foreach (TextAnimationManager _animation_manager in _animation_managers)
		{
			int num = _animation_manager.end_index;
			if (num == -1)
			{
				num = textInfo.characterCount;
			}
			for (int i = _animation_manager.start_index; i < num; i++)
			{
				TMP_CharacterInfo tMP_CharacterInfo = textInfo.characterInfo[i];
				if (tMP_CharacterInfo.isVisible)
				{
					Vector3[] vertices = textInfo.meshInfo[tMP_CharacterInfo.materialReferenceIndex].vertices;
					for (int j = 0; j < 4; j++)
					{
						Vector3 vert_origin = vertices[tMP_CharacterInfo.vertexIndex + j];
						vertices[tMP_CharacterInfo.vertexIndex + j] = _animation_manager.VertexOffset(vert_origin, textInfo.meshInfo[tMP_CharacterInfo.materialReferenceIndex], i, tMP_CharacterInfo.vertexIndex + j);
					}
				}
			}
			_animation_manager.onUpdate();
		}
		for (int k = 0; k < textInfo.meshInfo.Length; k++)
		{
			TMP_MeshInfo tMP_MeshInfo = textInfo.meshInfo[k];
			tMP_MeshInfo.mesh.vertices = tMP_MeshInfo.vertices;
			_text_base.UpdateGeometry(tMP_MeshInfo.mesh, k);
		}
		_text_base.updateTextMesh(0);
		_text_base.ForceMeshUpdate();
		_text_base.renderMode = TextRenderFlags.Render;
	}

	public static void wobbleText(this TMP_Text _text, System.Random _rng, float _speed, float _strength, int _start_index = 0, int _end_index = -1)
	{
		_text.animateText(new WobbleTextAnimationManager(_text, _rng, _speed, _strength, _no_offset: false, _start_index, _end_index)).start(_text);
	}

	public static void animateText(this TMP_Text _text, AnimationCurve _curve, float _animation_speed = 1f, float _curve_output_multi = 1f, int _loop_after = 2, int _start_index = 0, int _end_index = -1)
	{
		_text.animateText(new CurveTextAnimationManager(_text, _curve, _animation_speed, _curve_output_multi, _loop_after, _start_index, _end_index)).start(_text);
	}

	public static void shakeTextVertices(this TMP_Text _text, float _power, int _start_index = 0, int _end_index = -1)
	{
		_text.animateText(new ShakeTextAnimationManager(_text, _power, _shake_vertices_seperatly: true, _start_index, _end_index)).start(_text);
	}

	public static void shakeTextCharacters(this TMP_Text _text, float _power, int _start_index = 0, int _end_index = -1)
	{
		_text.animateText(new ShakeTextAnimationManager(_text, _power, _shake_vertices_seperatly: false, _start_index, _end_index)).start(_text);
	}

	public static void bakeAlways(this TMP_Text _text, Func<string, TMP_Text, Maybe<TextAnimationManager>> _text_animation_manager_getter)
	{
		_text.StopAllCoroutines();
		_text.StartCoroutine(_text.animateText(_text_animation_manager_getter));
	}

	public static void bake(this TMP_Text _text)
	{
		_text.bake("A_", tryGetPresetAnimationManagers);
	}

	public static void bake(this TMP_Text _text, string _animation_link_identifier, Func<string, TMP_Text, Maybe<TextAnimationManager>> _text_animation_manager_getter, bool _always_animate = false)
	{
		_text.StopAllCoroutines();
		if (_always_animate || _text.getContainsLinkSegment(_animation_link_identifier))
		{
			_text.StartCoroutine(_text.animateText(_text_animation_manager_getter));
		}
		else
		{
			_text.renderMode = TextRenderFlags.Render;
		}
	}

	public static void unbake(this TMP_Text _text)
	{
		_text.StopAllCoroutines();
		_text.renderMode = TextRenderFlags.Render;
	}

	public static void bakeString(this TMP_Text _text, params string[] _content)
	{
		_text.bakeString(_content.ToList().Aggregate("", (string _a, string _b) => _a += _b));
	}

	public static void bakeString(this TMP_Text _text, string _content)
	{
		_text.bakeString(_content, "A_", tryGetPresetAnimationManagers);
	}

	public static void bakeString(this TMP_Text _text, string _content, string _animation_link_identifier, Func<string, TMP_Text, Maybe<TextAnimationManager>> _text_animation_manager_getter)
	{
		_text.text = _content.Replace("\\n", "\n").Replace("\\\"", "\"");
		_text.StopAllCoroutines();
		if (_text.getContainsLinkSegment(_animation_link_identifier))
		{
			_text.StartCoroutine(_text.animateText(_text_animation_manager_getter));
		}
		else
		{
			_text.renderMode = TextRenderFlags.Render;
		}
	}

	private static List<TextAnimationManager> getTextAnimationManagers(this TMP_Text _text, Func<string, TMP_Text, Maybe<TextAnimationManager>> _text_animation_manager_getter)
	{
		List<TextAnimationManager> list = new List<TextAnimationManager>();
		for (int i = 0; i < _text.textInfo.linkCount; i++)
		{
			Maybe<TextAnimationManager> maybe = _text_animation_manager_getter(_text.textInfo.linkInfo[i].GetLinkID(), _text);
			if (maybe.is_some)
			{
				TextAnimationManager value = maybe.value;
				value.start_index = _text.textInfo.linkInfo[i].linkTextfirstCharacterIndex;
				value.end_index = _text.textInfo.linkInfo[i].linkTextLength + value.start_index;
				list.Add(value);
			}
		}
		return list;
	}

	private static bool checkAnimationManagers(this List<TextAnimationManager> _current, TMP_Text _text, Func<string, TMP_Text, Maybe<TextAnimationManager>> _text_animation_manager_getter)
	{
		int num = 0;
		for (int i = 0; i < _text.textInfo.linkCount; i++)
		{
			Maybe<TextAnimationManager> maybe = _text_animation_manager_getter(_text.textInfo.linkInfo[i].GetLinkID(), _text);
			if (maybe.is_some)
			{
				TextAnimationManager value = maybe.value;
				if (_current.Count <= num || value.GetType() != _current[num].GetType())
				{
					return false;
				}
				_current[num].start_index = _text.textInfo.linkInfo[i].linkTextfirstCharacterIndex;
				_current[num].end_index = _text.textInfo.linkInfo[i].linkTextLength + _current[num].start_index;
				num++;
			}
		}
		return num == _current.Count;
	}

	public static Maybe<AnimationCurve> tryGetPresetAnimationCurve(string _link)
	{
		try
		{
			return getPresetAnimationCurve(_link).maybe();
		}
		catch
		{
			return new Maybe<AnimationCurve>();
		}
	}

	public static string toLinkText(this PresetTextAnimationCurves _curve_type)
	{
		return _curve_type switch
		{
			PresetTextAnimationCurves.NONE => "", 
			PresetTextAnimationCurves.SLOW => "A_W0", 
			PresetTextAnimationCurves.NORMAL => "A_W1", 
			PresetTextAnimationCurves.FAST => "A_W2", 
			PresetTextAnimationCurves.SLOW_EXAGERATED => "A_W3", 
			PresetTextAnimationCurves.NORMAL_EXAGERATED => "A_W4", 
			PresetTextAnimationCurves.FAST_EXAGERATED => "A_W5", 
			_ => throw new ArgumentException($"No link text set up for curve type {_curve_type}"), 
		};
	}

	private static AnimationCurve getPresetAnimationCurve(string _link)
	{
		if (_link.Contains(PresetTextAnimationCurves.SLOW.toLinkText()))
		{
			return createLoopingAnimationCurve(0.6f);
		}
		if (_link.Contains(PresetTextAnimationCurves.NORMAL.toLinkText()))
		{
			return createLoopingAnimationCurve(0.3f);
		}
		if (_link.Contains(PresetTextAnimationCurves.FAST.toLinkText()))
		{
			return createLoopingAnimationCurve(0.15f);
		}
		if (_link.Contains(PresetTextAnimationCurves.SLOW_EXAGERATED.toLinkText()))
		{
			return createLoopingAnimationCurve(0.6f, 7.5f);
		}
		if (_link.Contains(PresetTextAnimationCurves.NORMAL_EXAGERATED.toLinkText()))
		{
			return createLoopingAnimationCurve(0.3f, 7.5f);
		}
		if (_link.Contains(PresetTextAnimationCurves.FAST_EXAGERATED.toLinkText()))
		{
			return createLoopingAnimationCurve(0.15f, 7.5f);
		}
		throw new ArgumentException("No animation curve found in link " + _link);
	}

	public static AnimationCurve createLoopingAnimationCurve(float _x_per_step, float _y_max = 3f)
	{
		return new AnimationCurve(new Keyframe(0f, 0f), new Keyframe(_x_per_step, _y_max), new Keyframe(2f * _x_per_step, 0f), new Keyframe(3f * _x_per_step, _y_max), new Keyframe(4f * _x_per_step, 0f))
		{
			preWrapMode = WrapMode.Loop,
			postWrapMode = WrapMode.Loop
		};
	}

	public static Maybe<TextAnimationManager> tryGetPresetAnimationManagers(string _link, TMP_Text _text)
	{
		Maybe<AnimationCurve> maybe = tryGetPresetAnimationCurve(_link);
		if (maybe.is_some)
		{
			return ((TextAnimationManager)new CurveTextAnimationManager(_text, maybe.value)).maybe();
		}
		return new Maybe<TextAnimationManager>();
	}

	public static bool getContainsLinkSegment(this TMP_Text _text, string _link_segment)
	{
		_text.ForceMeshUpdate();
		for (int i = 0; i < _text.textInfo.linkCount; i++)
		{
			if (_text.textInfo.linkInfo[i].GetLinkID().Contains(_link_segment))
			{
				return true;
			}
		}
		return false;
	}

	private static void updateTextMesh(this TMP_Text _text, int _index)
	{
		_text.mesh.vertices = _text.textInfo.meshInfo[_index].vertices;
		_text.mesh.triangles = _text.textInfo.meshInfo[_index].triangles;
		_text.mesh.uv = _text.textInfo.meshInfo[_index].uvs0;
		_text.mesh.uv2 = _text.textInfo.meshInfo[_index].uvs2;
		_text.mesh.colors32 = _text.textInfo.meshInfo[_index].colors32;
	}
}
