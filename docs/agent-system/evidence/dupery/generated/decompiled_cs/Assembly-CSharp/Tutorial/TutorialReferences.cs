using System;
using UnityEngine;
using UnityEngine.UI;
using Visual;

namespace Tutorial;

[Serializable]
public class TutorialReferences
{
	public RectTransform suspect_list;

	public RectTransform ratio;

	public RectTransform board;

	public RectTransform magnifying_glass;

	public Image background_image;

	public RectTransform clock;

	public RectTransform newspaper;

	public RectTransform dock_lever;

	public RectTransform dock_finish;

	public RectTransform cost_multi_parent;

	public RectTransform cards_parent;

	public PenManager pen_manager;

	public RubberManager rubber_manager;

	public PinsController pins_controller;

	private TutorialReferences(RectTransform _sl, RectTransform _rat, RectTransform _board, RectTransform _magn, PenManager _pen, RubberManager _rubber, PinsController _pins)
	{
		suspect_list = _sl;
		ratio = _rat;
		board = _board;
		magnifying_glass = _magn;
		pen_manager = _pen;
		rubber_manager = _rubber;
		pins_controller = _pins;
	}

	public TutorialReferences(RectTransform _sl, RectTransform _rat, RectTransform _clock, RectTransform _board, RectTransform _magn, RectTransform _news, PenManager _pen, RubberManager _rubber, PinsController _pins)
		: this(_sl, _rat, _board, _magn, _pen, _rubber, _pins)
	{
		clock = _clock;
		newspaper = _news;
	}

	public TutorialReferences(RectTransform _sl, RectTransform _rat, RectTransform _board, RectTransform _magn, PenManager _pen, RubberManager _rubber, PinsController _pins, RectTransform _lever, RectTransform _finish)
		: this(_sl, _rat, _board, _magn, _pen, _rubber, _pins)
	{
		dock_lever = _lever;
		dock_finish = _finish;
	}

	public TutorialReferences(RectTransform _cost_multi_parent, RectTransform _cards_parent, PenManager _pen, RubberManager _rubber, PinsController _pins)
		: this(null, null, null, null, _pen, _rubber, _pins)
	{
		cost_multi_parent = _cost_multi_parent;
		cards_parent = _cards_parent;
	}
}
