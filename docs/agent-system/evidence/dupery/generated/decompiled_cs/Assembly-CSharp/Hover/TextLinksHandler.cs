using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using TMPro;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;

namespace Hover;

public class TextLinksHandler : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private Camera scene_camera;

	[SerializeField]
	private Canvas canvas;

	[Header("Prefabs")]
	[SerializeField]
	private TextLinkHover link_hover_prefab;

	[SerializeField]
	private ImageHover image_hover_prefab;

	private HashSet<TMP_Text> need_checking = new HashSet<TMP_Text>();

	private Maybe<(TMP_Text, int)> current_hover = new Maybe<(TMP_Text, int)>();

	private List<BaseHover> hoverers = new List<BaseHover>();

	private Maybe<BaseHover> locked_hover = new Maybe<BaseHover>();

	private bool needs_cleanup;

	private void Start()
	{
		GameHandler.instance.setLinksHandlerReference(this);
	}

	private void LateUpdate()
	{
		if (GameHandler.instance.using_gamepad)
		{
			return;
		}
		if (needs_cleanup)
		{
			need_checking.Remove(null);
			needs_cleanup = false;
		}
		if (current_hover.is_some && checkForLink(current_hover.value.Item1, current_hover.value.Item2))
		{
			return;
		}
		foreach (TMP_Text item in need_checking)
		{
			if (checkForLink(item))
			{
				return;
			}
		}
		clearTextHovers();
	}

	private bool checkForLink(TMP_Text _text, int _selected_link = -1)
	{
		if (checkForMouseOverText(_text, out var _result, _selected_link))
		{
			current_hover = (_text, _result.Item2).maybe();
			if (_result.Item1.is_some && _result.Item1.value.GetLinkID().isLinkHoverable())
			{
				setUpNewHoverer(_result.Item1.value);
			}
			else if (_result.Item2 == -1)
			{
				clearHoverers();
			}
			return true;
		}
		return false;
	}

	private bool checkForMouseOverText(TMP_Text _text, out (Maybe<TMP_LinkInfo>, int) _result, int _selected_link = -2)
	{
		if (_text == null)
		{
			_result = (new Maybe<TMP_LinkInfo>(), -1);
			needs_cleanup = true;
			return false;
		}
		int num = TMP_TextUtilities.FindIntersectingLink(_text, Input.mousePosition, scene_camera);
		if (num == -1)
		{
			_result = (new Maybe<TMP_LinkInfo>(), -1);
			return false;
		}
		if (_selected_link == num)
		{
			_result = (new Maybe<TMP_LinkInfo>(), _selected_link);
			return true;
		}
		_result = (_text.textInfo.linkInfo[num].maybe(), num);
		return true;
	}

	public void startChecks(TMP_Text _text)
	{
		need_checking.Add(_text);
	}

	public void stopChecks(TMP_Text _text)
	{
		need_checking.Remove(_text);
		if (current_hover.is_some && current_hover.value.Item1 == _text)
		{
			current_hover = new Maybe<(TMP_Text, int)>();
			clearHoverers();
		}
	}

	private void clearTextHovers()
	{
		List<TextLinkHover> closed = new List<TextLinkHover>();
		hoverers.ForEach(delegate(BaseHover _h)
		{
			if (_h is TextLinkHover textLinkHover && (!locked_hover.is_some || locked_hover.value != _h))
			{
				textLinkHover.destroySelf();
				closed.Add(textLinkHover);
			}
		});
		hoverers.RemoveAll((BaseHover _h) => closed.Contains(_h));
	}

	private void clearHoverers()
	{
		hoverers.ForEach(delegate(BaseHover _h)
		{
			_h.destroySelf();
		});
		hoverers.Clear();
		if (locked_hover.is_some)
		{
			hoverers.Add(locked_hover.value);
		}
	}

	public void onLock(InputAction.CallbackContext _context)
	{
		if (_context.canceled)
		{
			unlockCurrent();
		}
		else if (_context.started)
		{
			lockCurrent();
		}
	}

	private void lockCurrent()
	{
		if (hoverers.Count != 0 && current_hover.is_some)
		{
			locked_hover = hoverers[hoverers.Count - 1].maybe();
			if (locked_hover.value is TextLinkHover textLinkHover)
			{
				textLinkHover.lockSelf(current_hover.value);
			}
			else if (locked_hover.value is ImageHover imageHover)
			{
				imageHover.lockSelf();
			}
		}
	}

	private void unlockCurrent()
	{
		if (locked_hover.is_some)
		{
			if (!current_hover.is_some || !(locked_hover.value is TextLinkHover textLinkHover) || !textLinkHover.lockedOnto(current_hover.value))
			{
				hoverers.Remove(locked_hover.value);
				locked_hover.value.destroySelf(_force: true);
			}
			if (locked_hover.value is TextLinkHover textLinkHover2)
			{
				textLinkHover2.unlockSelf();
			}
			else if (locked_hover.value is ImageHover imageHover)
			{
				imageHover.unlockSelf();
			}
			locked_hover = new Maybe<BaseHover>();
		}
	}

	private void setUpNewHoverer(TMP_LinkInfo _link)
	{
		clearHoverers();
		TextLinkHover textLinkHover = Object.Instantiate(link_hover_prefab, base.transform);
		textLinkHover.setUp(_link, scene_camera, (canvas.transform as RectTransform).sizeDelta);
		hoverers.Add(textLinkHover);
	}

	public void createImageHover(Image _image, string _title, string _description)
	{
		clearHoverers();
		ImageHover imageHover = Object.Instantiate(image_hover_prefab, base.transform);
		imageHover.setUp(_image, _title, _description, scene_camera, (canvas.transform as RectTransform).sizeDelta);
		hoverers.Add(imageHover);
	}

	public void deleteImageHover(Image _image)
	{
		List<BaseHover> to_close = hoverers.Where((BaseHover _h) => _h is ImageHover imageHover && imageHover.hovering_image.is_some && imageHover.hovering_image.value == _image).ToList();
		hoverers.RemoveAll((BaseHover _h) => to_close.Contains(_h));
		to_close.ForEach(delegate(BaseHover _h)
		{
			_h.destroySelf(_force: true);
		});
	}

	public void selectKeyword(ControllerPageKeywords _keyword)
	{
		setUpNewHoverer(_keyword.link_info);
	}

	public void unselectAll()
	{
		clearHoverers();
	}
}
