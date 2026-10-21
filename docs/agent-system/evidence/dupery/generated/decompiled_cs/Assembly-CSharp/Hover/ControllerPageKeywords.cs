using TMPro;
using UnityEngine;

namespace Hover;

public class ControllerPageKeywords
{
	public TMP_Text text;

	public TMP_LinkInfo link_info;

	public Vector2 position;

	public Vector2 size;

	public ControllerPageKeywords up_keyword;

	public ControllerPageKeywords right_keyword;

	public ControllerPageKeywords down_keyword;

	public ControllerPageKeywords left_keyword;

	public ControllerPageKeywords(TMP_Text _text, TMP_LinkInfo _link_info, Vector2 _position, Vector2 _size)
	{
		text = _text;
		link_info = _link_info;
		position = _position;
		size = _size;
	}

	public ControllerPageKeywords addUp(ControllerPageKeywords _keyword)
	{
		up_keyword = _keyword;
		return this;
	}

	public ControllerPageKeywords addRight(ControllerPageKeywords _keyword)
	{
		right_keyword = _keyword;
		return this;
	}

	public ControllerPageKeywords addDown(ControllerPageKeywords _keyword)
	{
		down_keyword = _keyword;
		return this;
	}

	public ControllerPageKeywords addLeft(ControllerPageKeywords _keyword)
	{
		left_keyword = _keyword;
		return this;
	}
}
