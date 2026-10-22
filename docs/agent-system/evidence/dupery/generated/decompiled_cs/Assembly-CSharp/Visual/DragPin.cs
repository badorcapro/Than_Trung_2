using System;
using System.Collections;
using System.Collections.Generic;
using Audio;
using GRGLib.Coroutines;
using GRGLib.Extensions.Unity;
using GRGLib.Extensions.Vector;
using GRGLib.Input;
using GRGLib.Maybe;
using Save;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.InputSystem;
using UnityEngine.UI;

namespace Visual;

public class DragPin : DragInput
{
	[Header("References")]
	[SerializeField]
	private Image pin_image;

	[Header("Settings")]
	[SerializeField]
	private Vector2 pin_drag_offset = new Vector2(0f, 20f);

	[Header("Pin Symbols")]
	[SerializeField]
	private List<Image> pin_symbols;

	private List<Color> pin_colours;

	private CoroutineRunner colour_swap_runner;

	private CoroutineRunner colour_check_runner;

	private CoroutineRunner drag_scale_runner;

	private CoroutineRunner drag_runner;

	private CoroutineRunner check_strings_runner;

	private CoroutineRunner scale_runner;

	private MultiCoroutineRunner position_runner;

	private bool placed;

	private int colour_index;

	private bool destroying;

	private PinsController controller;

	private PenManager pen_manager;

	private RubberManager rubber_manager;

	private StringManager string_manager;

	private bool mid_drag;

	private Canvas canvas;

	private bool in_range;

	private ColourWheel colour_wheel;

	private Action<DragPin> on_destroy;

	private Maybe<Vector2Int> board_position = new Maybe<Vector2Int>();

	public bool previous_was_drag;

	private bool has_colour_wheel_open;

	public List<ConnectionStringBase> attached_strings = new List<ConnectionStringBase>();

	public RectTransform rect_trans => base.transform as RectTransform;

	public int pin_index { get; private set; }

	public void setup(PinsController _controller, PenManager _pen, RubberManager _rubber, Canvas _canvas, List<Color> _colours, ColourWheel _colour_wheel, int _pin_index, Action<DragPin> _destroy_callback, StringManager _string_manager)
	{
		pin_colours = _colours;
		colour_wheel = _colour_wheel;
		controller = _controller;
		pen_manager = _pen;
		rubber_manager = _rubber;
		drag_scale_runner = new CoroutineRunner(this);
		drag_runner = new CoroutineRunner(this);
		colour_swap_runner = new CoroutineRunner(this);
		colour_check_runner = new CoroutineRunner(this);
		scale_runner = new CoroutineRunner(this);
		check_strings_runner = new CoroutineRunner(this);
		position_runner = new MultiCoroutineRunner(this);
		colour_check_runner.run(checkColourChange());
		canvas = _canvas;
		pin_index = _pin_index;
		on_destroy = _destroy_callback;
		string_manager = _string_manager;
		updateSymbol(colour_index);
	}

	public void setBoardPosition(Vector2Int _pos)
	{
		board_position = _pos.maybe();
	}

	public Maybe<Vector2Int> getBoardPosition()
	{
		return board_position;
	}

	public void setPlaced()
	{
		placed = true;
	}

	public void positionPin(Vector2 _position)
	{
		position_runner.run(rect_trans.moveTransform(_position, 0.4f, CoroutineExtensions.easeInBackFunc).addCallback(delegate
		{
			check_strings_runner.stop();
		}), rect_trans.scaleTransform(1f, 0.4f, CoroutineExtensions.easeInBackFunc), 0.3f.wait(delegate
		{
			AudioHandler.Sfx.playSfx(Sfx.PIN_DROP, 0.5f);
		}));
		placed = true;
		GameHandler.State.getCaseNotes().pins_data.resetPin(pin_index, getSaveData());
	}

	public void scaleUpPin(float _scale = 1f)
	{
		scale_runner.run(base.transform.scaleTransform(_scale, 0.15f, CoroutineExtensions.easeInOutFunc));
	}

	private IEnumerator dragPin(DragPin _pin)
	{
		if (attached_strings.Count > 0)
		{
			check_strings_runner.run(checkAttachedStringsContinous());
		}
		yield return _pin.transform.moveTransformToMovingTarget(() => getPositionForPin(), 0.15f, CoroutineExtensions.easeInOutFunc);
		while (true)
		{
			_pin.transform.localPosition = getPositionForPin() + pin_drag_offset;
			yield return null;
		}
	}

	private IEnumerator checkAttachedStringsContinous()
	{
		bool first = true;
		while (true)
		{
			checkAttachedStrings(first);
			yield return null;
		}
	}

	private Vector2 getPositionForPin()
	{
		return canvas.getPositionToUI(Pointer.current.position.ReadValue());
	}

	private void checkAttachedStrings(bool _resim)
	{
		foreach (ConnectionStringBase attached_string in attached_strings)
		{
			attached_string.recalculateString();
			if (_resim)
			{
				attached_string.refreshSimulation();
			}
		}
	}

	public void onClickDown(PointerEventData _event)
	{
		if (_event.button == PointerEventData.InputButton.Middle && !destroying)
		{
			colour_wheel.setColoursAndOpen(pin_colours, base.transform.position, changeColour, _limit_y: false, _is_pin: true);
			colour_wheel.startMousePosCheck();
			has_colour_wheel_open = true;
		}
	}

	public void onClick(PointerEventData _event)
	{
		if (destroying)
		{
			return;
		}
		switch (_event.button)
		{
		case PointerEventData.InputButton.Left:
			if (!string_manager.tool_selected)
			{
				if (previous_was_drag)
				{
					previous_was_drag = false;
				}
				else
				{
					onLeftClick();
				}
			}
			break;
		case PointerEventData.InputButton.Right:
			if (placed)
			{
				onRightClick();
			}
			break;
		case PointerEventData.InputButton.Middle:
			colour_wheel.stopMousePosCheckAndClose();
			has_colour_wheel_open = false;
			break;
		}
	}

	private IEnumerator checkColourChange()
	{
		while (true)
		{
			Vector2 vector = Mouse.current.scroll.ReadValue();
			if (vector.y != 0f && in_range && !pen_manager.tool_selected)
			{
				changeColour((vector.y > 0f) ? 1 : (-1));
			}
			yield return null;
		}
	}

	public void onLeftClick()
	{
		string_manager.startStringFromPin(this, colour_index);
	}

	public void onRightClick()
	{
		if (!pen_manager.tool_selected && !rubber_manager.tool_selected && !string_manager.tool_selected)
		{
			destroySelf();
			if (has_colour_wheel_open && colour_wheel.is_open)
			{
				colour_wheel.closeMenu();
			}
		}
	}

	public void destroySelf()
	{
		destroying = true;
		GameHandler.State.getCaseNotes().pins_data.removePin(pin_index);
		StopAllCoroutines();
		rect_trans.scaleTransform(0f, 0.45f, CoroutineExtensions.easeInBackFunc).addCallback(delegate
		{
			UnityEngine.Object.Destroy(base.gameObject);
		}).start(this);
		foreach (ConnectionStringBase attached_string in attached_strings)
		{
			attached_string.destroyString(this);
		}
		on_destroy(this);
	}

	public void changeColour(Color _colour)
	{
		changeColour(_colour, _save: true);
	}

	public void changeColour(Color _colour, bool _save)
	{
		colour_index = pin_colours.FindIndex(0, (Color _c) => _c == _colour);
		colour_swap_runner.run(pin_image.fadeToColour(pin_colours[colour_index], 0.15f, CoroutineExtensions.easeInOutFunc));
		updateSymbol(colour_index);
		if (_save)
		{
			GameHandler.State.getCaseNotes().pins_data.resetPin(pin_index, getSaveData());
		}
	}

	public void changeColour(int _direction)
	{
		colour_index += _direction;
		if (_direction < 0)
		{
			colour_index += pin_colours.Count;
		}
		colour_index %= pin_colours.Count;
		colour_swap_runner.run(pin_image.fadeToColour(pin_colours[colour_index], 0.15f, CoroutineExtensions.easeInOutFunc));
		updateSymbol(colour_index);
		GameHandler.State.getCaseNotes().pins_data.resetPin(pin_index, getSaveData());
	}

	private void updateSymbol(int _symbol_index)
	{
		pin_symbols.ForEach(delegate(Image _e)
		{
			_e.gameObject.SetActive(value: false);
		});
		if (SettingsHandler.show_pin_symbols)
		{
			pin_symbols[_symbol_index].gameObject.SetActive(value: true);
			pin_symbols[_symbol_index].color = pin_colours[_symbol_index];
		}
	}

	public void pollPinSymbol()
	{
		updateSymbol(colour_index);
	}

	public bool changeColourLeft()
	{
		if (in_range && !pen_manager.tool_selected)
		{
			changeColour(-1);
			return true;
		}
		return false;
	}

	public bool changeColourRight()
	{
		if (in_range && !pen_manager.tool_selected)
		{
			changeColour(1);
			return true;
		}
		return false;
	}

	protected override void onDragStart(PointerEventData.InputButton _input)
	{
		if (_input == PointerEventData.InputButton.Left && !controller.dragging.is_some && !pen_manager.tool_selected && !rubber_manager.tool_selected && !string_manager.tool_selected)
		{
			mid_drag = true;
			previous_was_drag = true;
			position_runner.stop();
			drag_scale_runner.run(rect_trans.scaleTransform(1.1f, 0.15f, CoroutineExtensions.easeInOutFunc));
			drag_runner.run(dragPin(this));
		}
	}

	protected override void onDragEnd(PointerEventData _event)
	{
		if (_event.button == PointerEventData.InputButton.Left)
		{
			drag_runner.stop();
			drag_scale_runner.stop();
			if (mid_drag)
			{
				positionPin(getPositionForPin());
				mid_drag = false;
			}
		}
	}

	public override void OnPointerEnter(PointerEventData eventData)
	{
		base.OnPointerEnter(eventData);
		in_range = true;
	}

	public override void OnPointerExit(PointerEventData eventData)
	{
		base.OnPointerExit(eventData);
		in_range = false;
	}

	public PinSaveData getSaveData()
	{
		if (board_position.is_some)
		{
			return new PinSaveData(board_position.value, colour_index, pin_index);
		}
		return new PinSaveData(base.transform.localPosition, colour_index, pin_index);
	}

	public bool setFromSave(PinSaveData _pin_save, Func<Vector2Int, Vector2> _to_position, out Vector2Int _board_pos)
	{
		colour_index = _pin_save.pin_colour;
		pin_image.color = pin_colours[colour_index];
		updateSymbol(colour_index);
		placed = true;
		if (_pin_save.position_as_board_pos)
		{
			board_position = _pin_save.position.toVector2Int().maybe();
			base.transform.position = _to_position(board_position.value);
			_board_pos = board_position.value;
			return true;
		}
		base.transform.localPosition = _pin_save.position;
		_board_pos = new Vector2Int(0, 0);
		return false;
	}

	public int getColourIndex()
	{
		return colour_index;
	}

	public bool canAttachString(DragPin _other)
	{
		if (_other == this)
		{
			return false;
		}
		return !attached_strings.Exists((ConnectionStringBase _c) => _c.isSame(_other));
	}

	public void addString(ConnectionStringBase _string)
	{
		attached_strings.Add(_string);
	}

	public void deatach(ConnectionStringBase _string)
	{
		attached_strings.Remove(_string);
	}
}
