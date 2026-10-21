using System.Collections;
using GRGLib.Coroutines;
using GRGLib.Extensions.String;
using GRGLib.Extensions.Unity;
using GRGLib.Generic;
using GRGLib.Maybe;
using GRGLib.TextAnimation;
using TMPro;
using UnityEngine;

namespace Hover;

public class TextLinkHover : BaseHover
{
	private CoroutineRunner text_bob_runner;

	private Maybe<(TMP_Text, int)> locked_on = new Maybe<(TMP_Text, int)>();

	private TextAnimationManager text_animator;

	private TMP_LinkInfo link_info;

	public override bool is_locked => locked_on.is_some;

	protected override void Awake()
	{
		base.Awake();
		text_bob_runner = new CoroutineRunner(this);
	}

	public void setUp(TMP_LinkInfo _link_info, Camera _camera, Vector2 _canvas_size)
	{
		link_info = _link_info;
		KeywordInfo keywordFromLink = _link_info.GetLinkID().getKeywordFromLink();
		text.text = keywordFromLink.toStringNoLinkTitle().sizeRelative(115).bold() + "\n" + keywordFromLink.description;
		base.rect_trans.anchoredPosition = getHoverPosition(_link_info, _camera, _canvas_size);
		fade_runner.run(group.fade(1f, 0.3f, CoroutineExtensions.easeInOutFunc));
		text_bob_runner.run(bobHoveredText(_link_info));
	}

	private Vector2 getHoverPosition(TMP_LinkInfo _link, Camera _camera, Vector2 _canvas_size)
	{
		Vector2 vector = _link.textComponent.textInfo.characterInfo[_link.linkTextfirstCharacterIndex].bottomLeft;
		Vector2 result = _canvas_size.getPositionToUI(_camera.WorldToScreenPoint(_link.textComponent.rectTransform.position)) + vector - new Vector2(0f, 25f);
		if (result.x + base.rect_trans.sizeDelta.x > _canvas_size.x / 2f)
		{
			result.x = _canvas_size.x / 2f - base.rect_trans.sizeDelta.x - 5f;
		}
		if (result.y - base.rect_trans.sizeDelta.y < (0f - _canvas_size.y) / 2f)
		{
			result.y = base.rect_trans.sizeDelta.y - _canvas_size.y / 2f + 5f;
		}
		return result;
	}

	protected override void onDestroySelf()
	{
		text_bob_runner.stop();
		resetText();
	}

	public void lockSelf((TMP_Text, int) _text)
	{
		locked_on = _text.maybe();
		displayLock();
	}

	public void unlockSelf()
	{
		locked_on = new Maybe<(TMP_Text, int)>();
		displayLock();
	}

	public bool lockedOnto((TMP_Text, int) _text)
	{
		if (is_locked && locked_on.value.Item1 == _text.Item1)
		{
			return locked_on.value.Item2 == _text.Item2;
		}
		return false;
	}

	private IEnumerator bobHoveredText(TMP_LinkInfo _link_info)
	{
		if (_link_info.linkTextLength > 3)
		{
			text_animator = new HoveringTextAnimationManager(_link_info.textComponent, 0.2f, 0.1f, 1f, _link_info.linkTextfirstCharacterIndex, _link_info.linkTextfirstCharacterIndex + _link_info.linkTextLength);
		}
		else
		{
			text_animator = new BobTextAnimationManager(_link_info.textComponent, new MinMaxFloat(0.2f, 0.3f), 1f, _link_info.linkTextfirstCharacterIndex, _link_info.linkTextfirstCharacterIndex + _link_info.linkTextLength);
		}
		while (true)
		{
			_link_info.textComponent.updateGeometry(text_animator);
			yield return null;
		}
	}

	private void resetText()
	{
		if (text_animator != null)
		{
			text_bob_runner.run(resetTextVerticesPos(0.15f));
		}
	}

	private IEnumerator resetTextVerticesPos(float _duration)
	{
		TextAnimationManager animator = new ResetTextAnimationManager(text_animator, _duration);
		float e = 0f;
		while (e < _duration)
		{
			e += Time.deltaTime;
			link_info.textComponent.updateGeometry(animator);
			yield return null;
		}
	}
}
