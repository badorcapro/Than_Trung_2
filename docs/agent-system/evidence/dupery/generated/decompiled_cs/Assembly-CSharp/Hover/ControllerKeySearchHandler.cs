using System.Collections;
using System.Collections.Generic;
using GRGLib.Coroutines;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Unity;
using TMPro;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;

namespace Hover;

public class ControllerKeySearchHandler : MenuBase
{
	[Header("References")]
	[SerializeField]
	private Image selector;

	[SerializeField]
	private Image background;

	[SerializeField]
	private Camera scene_camera;

	[Header("Settings")]
	[SerializeField]
	private Vector2 canvas_size = new Vector2(3840f, 2160f);

	public ControllerPageKeywords selected_keyword;

	private List<ControllerPageKeywords> existing_keywords = new List<ControllerPageKeywords>();

	private MultiCoroutineRunner selector_runner;

	private CoroutineRunner background_opening_runner;

	private bool has_moved;

	protected override void Awake()
	{
		selector_runner = new MultiCoroutineRunner(this);
		background_opening_runner = new CoroutineRunner(this);
		base.Awake();
	}

	public void setUpPageKeywordsLinks(List<TMP_Text> _texts)
	{
		List<List<ControllerPageKeywords>> list = new List<List<ControllerPageKeywords>>();
		existing_keywords.Clear();
		for (int i = 0; i < _texts.Count; i++)
		{
			List<ControllerPageKeywords> textKeywords = getTextKeywords(_texts[i], (existing_keywords.Count == 0) ? null : existing_keywords[existing_keywords.Count - 1]);
			list.Add(textKeywords);
			existing_keywords.addRange(textKeywords);
		}
		setUpAdditionalNavigation(list);
		selectKeyword(existing_keywords[0]);
	}

	private List<ControllerPageKeywords> getTextKeywords(TMP_Text _text, ControllerPageKeywords _previous)
	{
		List<ControllerPageKeywords> list = new List<ControllerPageKeywords>();
		TMP_LinkInfo[] linkInfo = _text.textInfo.linkInfo;
		for (int i = 0; i < linkInfo.Length; i++)
		{
			TMP_LinkInfo link_info = linkInfo[i];
			if (link_info.GetLinkID().isLinkHoverable())
			{
				(Vector2, Vector2) linkTextLimits = getLinkTextLimits(link_info.textComponent.textInfo, link_info.linkTextfirstCharacterIndex, link_info.linkTextLength);
				Vector2 position = canvas_size.getPositionToUI(scene_camera.WorldToScreenPoint(link_info.textComponent.rectTransform.position)) + linkTextLimits.Item1;
				Vector2 size = linkTextLimits.Item2 - linkTextLimits.Item1 + new Vector2(30f, 30f);
				ControllerPageKeywords controllerPageKeywords = new ControllerPageKeywords(_text, link_info, position, size);
				if (_previous != null)
				{
					controllerPageKeywords.addLeft(_previous);
					_previous.addRight(controllerPageKeywords);
				}
				_previous = controllerPageKeywords;
				list.Add(controllerPageKeywords);
			}
		}
		return list;
	}

	private (Vector2, Vector2) getLinkTextLimits(TMP_TextInfo _textInfo, int _starting_index, int _length)
	{
		Vector2 item = _textInfo.characterInfo[_starting_index].bottomLeft;
		Vector2 item2 = _textInfo.characterInfo[_starting_index + _length - 1].topRight;
		for (int i = _starting_index; i < _starting_index + _length; i++)
		{
			Vector3 bottomLeft = _textInfo.characterInfo[i].bottomLeft;
			Vector3 topRight = _textInfo.characterInfo[i].topRight;
			if (item.y > bottomLeft.y)
			{
				item.y = bottomLeft.y;
			}
			if (item2.y < topRight.y)
			{
				item2.y = topRight.y;
			}
		}
		return (item, item2);
	}

	private void setUpAdditionalNavigation(List<List<ControllerPageKeywords>> _keywords_by_text)
	{
		List<ControllerPageKeywords> list = new List<ControllerPageKeywords>();
		List<ControllerPageKeywords> current_line = new List<ControllerPageKeywords>();
		for (int i = 0; i < _keywords_by_text.Count; i++)
		{
			float num = -100000f;
			for (int j = 0; j < _keywords_by_text[i].Count; j++)
			{
				ControllerPageKeywords controllerPageKeywords = _keywords_by_text[i][j];
				float y = controllerPageKeywords.position.y;
				if (num == -1000000f || Mathf.Abs(y - num) > controllerPageKeywords.link_info.textComponent.fontSize / 2f)
				{
					if (current_line.Count > 0)
					{
						list.ForEach(delegate(ControllerPageKeywords _k)
						{
							_k.addDown(getClosestWord(_k, current_line));
						});
					}
					list = current_line.copy();
					current_line = new List<ControllerPageKeywords>();
					num = y;
				}
				current_line.Add(controllerPageKeywords);
				if (list.Count > 0)
				{
					controllerPageKeywords.addUp(getClosestWord(controllerPageKeywords, list));
				}
			}
		}
		if (current_line.Count > 0)
		{
			list.ForEach(delegate(ControllerPageKeywords _k)
			{
				_k.addDown(getClosestWord(_k, current_line));
			});
		}
	}

	private ControllerPageKeywords getClosestWord(ControllerPageKeywords _keyword, List<ControllerPageKeywords> _to_check)
	{
		ControllerPageKeywords result = null;
		float num = -1f;
		foreach (ControllerPageKeywords item in _to_check)
		{
			float magnitude = (_keyword.position - item.position).magnitude;
			if (num == -1f || magnitude < num)
			{
				num = magnitude;
				result = item;
			}
		}
		return result;
	}

	private void selectKeyword(ControllerPageKeywords _keyword)
	{
		selected_keyword = _keyword;
		GameHandler.Links.selectKeyword(_keyword);
		Vector2 vector = _keyword.position + _keyword.size / 2f - new Vector2(15f, 15f);
		selector_runner.run(selector.rectTransform.moveTransform(vector, 0.25f, CoroutineExtensions.easeInOutFunc).addCallback(delegate
		{
			background.material.SetVector("_Position", selector.rectTransform.localPosition);
		}), selector.rectTransform.expandSizeDelta(_keyword.size, 0.25f, CoroutineExtensions.easeInOutFunc).addCallback(delegate
		{
			background.material.SetVector("_Size", selector.rectTransform.sizeDelta);
		}), updateMaterial());
	}

	private IEnumerator updateMaterial()
	{
		while (true)
		{
			background.material.SetVector("_Position", selector.rectTransform.localPosition);
			background.material.SetVector("_Size", selector.rectTransform.sizeDelta);
			yield return null;
		}
	}

	protected override void onMenuOpening()
	{
		base.onMenuOpening();
		background_opening_runner.run(background.material.lerpMaterialProperty("_Alpha", 0.27f, 0.25f, CoroutineExtensions.easeInOutFunc));
	}

	protected override void onMenuClosing()
	{
		base.onMenuClosing();
		GameHandler.Links.unselectAll();
		background_opening_runner.run(background.material.lerpMaterialProperty("_Alpha", 0f, 0.25f, CoroutineExtensions.easeInOutFunc));
	}

	public override void onDeviceChange(PlayerInput _input)
	{
		if (base.is_open && !_input.isUsingGamepad())
		{
			closeMenu();
		}
	}

	public void move(InputAction.CallbackContext _context)
	{
		if (!base.is_open)
		{
			return;
		}
		if (has_moved)
		{
			if (_context.canceled)
			{
				has_moved = false;
			}
		}
		else
		{
			if (!_context.performed)
			{
				return;
			}
			Vector2 vector = _context.ReadValue<Vector2>();
			Vector2 vector2 = new Vector2(Mathf.Abs(vector.x), Mathf.Abs(vector.y));
			if (vector2.x > vector2.y)
			{
				if (!(vector2.x < 0.5f))
				{
					if (vector.x > 0f)
					{
						goRight();
					}
					else
					{
						goLeft();
					}
					has_moved = true;
				}
			}
			else if (!(vector2.y < 0.5f))
			{
				if (vector.y > 0f)
				{
					goUp();
				}
				else
				{
					goDown();
				}
				has_moved = true;
			}
		}
	}

	public void goRight()
	{
		if (selected_keyword.right_keyword != null)
		{
			GameHandler.Links.unselectAll();
			selectKeyword(selected_keyword.right_keyword);
		}
	}

	public void goDown()
	{
		if (selected_keyword.down_keyword != null)
		{
			GameHandler.Links.unselectAll();
			selectKeyword(selected_keyword.down_keyword);
		}
	}

	public void goLeft()
	{
		if (selected_keyword.left_keyword != null)
		{
			GameHandler.Links.unselectAll();
			selectKeyword(selected_keyword.left_keyword);
		}
	}

	public void goUp()
	{
		if (selected_keyword.up_keyword != null)
		{
			GameHandler.Links.unselectAll();
			selectKeyword(selected_keyword.up_keyword);
		}
	}
}
