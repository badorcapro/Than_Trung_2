using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.String;
using GRGLib.Maybe;
using TMPro;
using UnityEngine;

namespace GRGLib.TextAnimation;

public static class DialogueTextWriter
{
	public static string AbnormalTimeLink = "T{";

	public static string WaitingTimeLink = "T_Wait{";

	public static IEnumerator writeDialogueToText(TMP_Text _body_text, float _write_speed = 0.08f, bool _bake_text = true, bool _fade = true, float _fade_strength = 0.9f)
	{
		return writeDialogueToText(_body_text, TextAnimationHelper.tryGetPresetAnimationManagers, _write_speed, _bake_text, _fade, _fade_strength);
	}

	public static IEnumerator writeDialogueToText(TMP_Text _body_text, Func<string, TMP_Text, Maybe<TextAnimationManager>> _preset_animation_manager_getter, float _write_speed = 0.08f, bool _bake_text = true, bool _fade = true, float _fade_strength = 0.9f)
	{
		return writeDialogueToText(_body_text, new List<(int, Action)>(), _preset_animation_manager_getter, _write_speed, _bake_text, _fade, _fade_strength);
	}

	public static IEnumerator writeDialogueToText(TMP_Text _body_text, List<(int, Action)> _events, float _write_speed = 0.08f, bool _bake_text = true, bool _fade = true, float _fade_strength = 0.9f)
	{
		return writeDialogueToText(_body_text, _events, TextAnimationHelper.tryGetPresetAnimationManagers, _write_speed, _bake_text, _fade, _fade_strength);
	}

	public static IEnumerator writeDialogueToText(TMP_Text _body_text, List<(int, Action)> _events, Func<string, TMP_Text, Maybe<TextAnimationManager>> _preset_animation_manager_getter, float _write_speed = 0.08f, bool _bake_text = true, bool _fade = true, float _fade_strength = 0.9f)
	{
		if (!_fade)
		{
			yield return writeDialogueToTextNoFade(_body_text, _events, _preset_animation_manager_getter, _write_speed);
			yield break;
		}
		_body_text.maxVisibleCharacters = 0;
		int visible_characters = -1;
		if (_bake_text)
		{
			_body_text.bakeAlways(_preset_animation_manager_getter);
		}
		AnimationCurve current_progression_curve = _body_text.bakeCurveFromString(_write_speed);
		float text_scroll_e_time = 0f;
		float text_scroll_duration = current_progression_curve.keys.OrderByDescending((Keyframe _a) => _a.time).ToList()[0].time;
		yield return null;
		Dictionary<int, Color32[]> mat_verteces = new Dictionary<int, Color32[]>();
		Dictionary<int, float> fade_tracker = new Dictionary<int, float>();
		while (text_scroll_e_time < text_scroll_duration)
		{
			visible_characters = Mathf.FloorToInt((float)_body_text.textInfo.characterCount * current_progression_curve.Evaluate(text_scroll_e_time));
			fade_tracker[visible_characters] = 0f;
			if (_events.Count > 0)
			{
				_events.Where(((int, Action) _e) => _e.Item1 <= visible_characters).toListSafe().ForEach(delegate((int, Action) _ev)
				{
					_ev.Item2();
					_events.remove(_ev);
				});
			}
			text_scroll_e_time += Time.deltaTime;
			updateCharFade(fade_tracker, mat_verteces, _body_text, visible_characters, _fade_strength);
			yield return null;
		}
		visible_characters = _body_text.textInfo.characterCount - 1;
		while (fade_tracker.Where((KeyValuePair<int, float> _c) => _c.Value < 1f).ToList().Count > 0)
		{
			updateCharFade(fade_tracker, mat_verteces, _body_text, visible_characters, _fade_strength);
			yield return null;
		}
	}

	public static IEnumerator writeDialogueToTextNoFade(TMP_Text _body_text, float _write_speed = 0.08f, bool _bake_text = true)
	{
		return writeDialogueToTextNoFade(_body_text, new List<(int, Action)>(), TextAnimationHelper.tryGetPresetAnimationManagers, _write_speed, _bake_text);
	}

	public static IEnumerator writeDialogueToTextNoFade(TMP_Text _body_text, List<(int, Action)> _event, float _write_speed = 0.08f, bool _bake_text = true)
	{
		return writeDialogueToTextNoFade(_body_text, _event, TextAnimationHelper.tryGetPresetAnimationManagers, _write_speed, _bake_text);
	}

	public static IEnumerator writeDialogueToTextNoFade(TMP_Text _body_text, List<(int, Action)> _events, Func<string, TMP_Text, Maybe<TextAnimationManager>> _preset_animation_manager_getter, float _write_speed = 0.08f, bool _bake_text = true)
	{
		_body_text.maxVisibleCharacters = 0;
		int visible_characters = -1;
		if (_bake_text)
		{
			_body_text.bakeAlways(_preset_animation_manager_getter);
		}
		AnimationCurve current_progression_curve = _body_text.bakeCurveFromString(_write_speed);
		float text_scroll_e_time = 0f;
		float text_scroll_duration = current_progression_curve.keys.OrderByDescending((Keyframe _a) => _a.time).ToList()[0].time;
		yield return null;
		new Dictionary<int, Color32[]>();
		while (text_scroll_e_time < text_scroll_duration)
		{
			int num = visible_characters;
			visible_characters = Mathf.FloorToInt((float)_body_text.textInfo.characterCount * current_progression_curve.Evaluate(text_scroll_e_time));
			if (visible_characters != num)
			{
				if (_events.Count > 0)
				{
					_events.Where(((int, Action) _e) => _e.Item1 <= visible_characters).toListSafe().ForEach(delegate((int, Action) _ev)
					{
						_ev.Item2();
						_events.remove(_ev);
					});
				}
				_body_text.renderMode = TextRenderFlags.DontRender;
				_body_text.maxVisibleCharacters = visible_characters;
				_body_text.ForceMeshUpdate();
			}
			text_scroll_e_time += Time.deltaTime;
			yield return null;
		}
		_body_text.renderMode = TextRenderFlags.DontRender;
		_body_text.maxVisibleCharacters = _body_text.textInfo.characterCount;
		_body_text.ForceMeshUpdate();
	}

	private static void updateCharFade(Dictionary<int, float> fade_tracker, Dictionary<int, Color32[]> mat_verteces, TMP_Text _body_text, int visible_characters, float fade_strength)
	{
		if (fade_tracker.Count <= 0)
		{
			return;
		}
		_body_text.renderMode = TextRenderFlags.DontRender;
		_body_text.maxVisibleCharacters = visible_characters + 1;
		_body_text.ForceMeshUpdate();
		List<int> to_remove = new List<int>();
		fade_tracker.Keys.ToList().ForEach(delegate(int _c)
		{
			if (fade_tracker[_c] >= 1f)
			{
				fade_tracker[_c] = 1f;
				to_remove.add(_c);
			}
			if (_body_text.textInfo.characterInfo.Length > _c && _body_text.textInfo.characterInfo[_c].isVisible)
			{
				int materialReferenceIndex = _body_text.textInfo.characterInfo[_c].materialReferenceIndex;
				if (!mat_verteces.ContainsKey(materialReferenceIndex))
				{
					mat_verteces[materialReferenceIndex] = _body_text.textInfo.meshInfo[materialReferenceIndex].colors32;
				}
				int vertexIndex = _body_text.textInfo.characterInfo[_c].vertexIndex;
				byte a = (byte)Mathf.Clamp(255f * fade_tracker[_c], 0f, 255f);
				mat_verteces[materialReferenceIndex][vertexIndex].a = a;
				mat_verteces[materialReferenceIndex][vertexIndex + 1].a = a;
				mat_verteces[materialReferenceIndex][vertexIndex + 2].a = a;
				mat_verteces[materialReferenceIndex][vertexIndex + 3].a = a;
				fade_tracker[_c] += fade_strength * Time.deltaTime;
			}
			else
			{
				to_remove.add(_c);
			}
		});
		to_remove.ForEach(delegate(int _key)
		{
			fade_tracker.Remove(_key);
		});
		_body_text.UpdateVertexData(TMP_VertexDataUpdateFlags.Colors32);
	}

	public static AnimationCurve bakeCurveFromString(this TMP_Text _text, float _base_character_speed)
	{
		List<Keyframe> list = new List<Keyframe>
		{
			new Keyframe(0f, 0f)
		};
		float num = 1f;
		float num2 = 0f;
		_text.ForceMeshUpdate();
		int characterCount = _text.textInfo.characterCount;
		List<int> characterIndexesMatchingLink = _text.getCharacterIndexesMatchingLink("T{");
		List<int> characterIndexesMatchingLink2 = _text.getCharacterIndexesMatchingLink("T_Wait{");
		for (int i = 0; i < characterCount; i++)
		{
			float num3 = _base_character_speed;
			if (characterIndexesMatchingLink2.Contains(i))
			{
				string s = _text.getListOfLinksEffectingCharacter(i).First((string _l) => _l.Contains("T_Wait{")).removeUntilSubstring("T_Wait{")
					.untilSubstring("}");
				num3 += float.Parse(s);
			}
			else if (characterIndexesMatchingLink.Contains(i))
			{
				string s2 = _text.getListOfLinksEffectingCharacter(i).First((string _l) => _l.Contains("T{")).removeUntilSubstring("T{")
					.untilSubstring("}");
				num3 = _base_character_speed * float.Parse(s2);
			}
			num2 += num3;
			list.add(new Keyframe(num2, num / (float)characterCount));
			num += 1f;
		}
		return new AnimationCurve(list.ToArray());
	}

	public static List<int> getCharacterIndexesMatchingLink(this TMP_Text _text, string _link)
	{
		List<int> list = new List<int>();
		for (int i = 0; i < _text.textInfo.linkCount; i++)
		{
			if (_text.textInfo.linkInfo[i].GetLinkID().Contains(_link))
			{
				int linkTextfirstCharacterIndex = _text.textInfo.linkInfo[i].linkTextfirstCharacterIndex;
				for (int j = 0; j < _text.textInfo.linkInfo[i].linkTextLength; j++)
				{
					list.Add(linkTextfirstCharacterIndex + j);
				}
			}
		}
		return list;
	}

	public static List<string> getListOfLinksEffectingCharacter(this TMP_Text _text, int _character_index)
	{
		if (_text.textInfo.linkCount == 0)
		{
			return new List<string>();
		}
		List<string> list = new List<string>();
		for (int i = 0; i < _text.textInfo.linkCount; i++)
		{
			TMP_LinkInfo tMP_LinkInfo = _text.textInfo.linkInfo[i];
			if (_character_index >= tMP_LinkInfo.linkTextfirstCharacterIndex && _character_index < tMP_LinkInfo.linkTextfirstCharacterIndex + tMP_LinkInfo.linkTextLength)
			{
				list.add(tMP_LinkInfo.GetLinkID());
			}
		}
		return list;
	}

	public static string createAbnormalTimeLink(float _time, bool _with_link = true)
	{
		if (!_with_link)
		{
			return AbnormalTimeLink + _time + "}";
		}
		return $"<link={'"'}{createAbnormalTimeLink(_time, _with_link: false)}{'"'}>";
	}

	public static string createWaitingTimeLink(float _time, bool _with_link = true)
	{
		if (!_with_link)
		{
			return WaitingTimeLink + _time + "}";
		}
		return $"<link={'"'}{createAbnormalTimeLink(_time, _with_link: false)}{'"'}>";
	}
}
