using System.Collections;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Coroutines;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Unity;
using GRGLib.Input;
using GRGLib.Maybe;
using Save;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.InputSystem;

namespace Visual;

public class PinsController : DragInput
{
	[Header("References")]
	[SerializeField]
	private RectTransform drag_pin_parent;

	[SerializeField]
	private RectTransform board_pins_parent;

	[SerializeField]
	private RubberManager rubber_manager;

	[SerializeField]
	private PenManager pen_manager;

	[SerializeField]
	private StringManager string_manager;

	[SerializeField]
	private BoardVisualManager board_manager;

	[SerializeField]
	private ColourWheel colour_wheel;

	[Header("Prefabs")]
	[SerializeField]
	private DragPin drag_pin_prefab;

	[Header("Settings")]
	[SerializeField]
	private Vector2 pin_starting_position;

	[SerializeField]
	private Vector2 pin_drag_offset = new Vector2(0f, 20f);

	[SerializeField]
	private Vector3 pin_offset = new Vector3(-0.25f, 0.35f, 0f);

	[SerializeField]
	private List<Color> pin_colours;

	private Canvas canvas;

	public Maybe<DragPin> dragging = new Maybe<DragPin>();

	private CoroutineRunner drag_runner;

	private CoroutineRunner jiggle_runner;

	private List<DragPin> pins_on_board = new List<DragPin>();

	private Dictionary<Vector2Int, DragPin> pins_on_set_board = new Dictionary<Vector2Int, DragPin>();

	private Dictionary<int, int> remapped_indeces = new Dictionary<int, int>();

	private int pin_index = 1;

	protected void Start()
	{
		drag_runner = new CoroutineRunner(this);
		jiggle_runner = new CoroutineRunner(this);
	}

	public void setUpReferences(Canvas _canvas)
	{
		canvas = _canvas;
	}

	public void setUpFromSave()
	{
		if (!GameHandler.State.case_notes.is_some)
		{
			return;
		}
		PinsSave pins_data = GameHandler.State.case_notes.value.pins_data;
		if (pins_data.is_empty)
		{
			return;
		}
		List<PinSaveData> list = new List<PinSaveData>();
		foreach (PinSaveData pins_datum in pins_data.pins_data)
		{
			DragPin dragPin = Object.Instantiate(drag_pin_prefab, board_pins_parent);
			dragPin.setup(this, pen_manager, rubber_manager, canvas, pin_colours, colour_wheel, pin_index, onPinDestroy, string_manager);
			if (dragPin.setFromSave(pins_datum, (Vector2Int _bp) => board_manager.getPinPositionOfSlot(_bp, pin_offset), out var _board_pos))
			{
				pins_on_set_board[_board_pos] = dragPin;
			}
			pins_on_board.Add(dragPin);
			remapped_indeces[pins_datum.m_pin_index] = pin_index;
			pin_index++;
			list.Add(dragPin.getSaveData());
		}
		GameHandler.State.case_notes.value.pins_data = new PinsSave(list.copy());
	}

	public Dictionary<int, int> getRemappedIndeces()
	{
		return remapped_indeces;
	}

	public void resetRemappedIndeces()
	{
		remapped_indeces = null;
	}

	public void jiggle(RectTransform _trans)
	{
		if (!dragging.is_some && !drag_runner.is_running)
		{
			jiggle_runner.run(_trans.jiggle((2f, 4f)));
		}
	}

	protected override void onDragStart(PointerEventData.InputButton _input)
	{
		if (_input == PointerEventData.InputButton.Left && !rubber_manager.tool_selected && !pen_manager.tool_selected)
		{
			if (dragging.is_some)
			{
				Debug.LogError("Trying to drag pin when a pin is already being dragged?");
				return;
			}
			capPins();
			DragPin dragPin = Object.Instantiate(drag_pin_prefab, drag_pin_parent);
			dragPin.setup(this, pen_manager, rubber_manager, canvas, pin_colours, colour_wheel, pin_index, onPinDestroy, string_manager);
			pin_index++;
			dragPin.rect_trans.localPosition = pin_starting_position;
			dragPin.rect_trans.localScale = new Vector3(0f, 0f, 1f);
			dragPin.scaleUpPin(1.1f);
			dragging = dragPin.maybe();
			drag_runner.run(this.dragPin(dragPin));
		}
	}

	private void capPins()
	{
		if (pins_on_board.Count >= 100)
		{
			DragPin obj = pins_on_board[0];
			pins_on_board.RemoveAt(0);
			obj.destroySelf();
		}
	}

	protected override void onDragEnd(PointerEventData _event_data)
	{
		if (_event_data.button == PointerEventData.InputButton.Left)
		{
			drag_runner.stop();
			if (dragging.is_some)
			{
				dragging.value.positionPin(getPositionForPin());
				pins_on_board.Add(dragging.value);
				dragging = new Maybe<DragPin>();
			}
		}
	}

	private IEnumerator dragPin(DragPin _pin)
	{
		yield return _pin.transform.moveTransformToMovingTarget(() => getPositionForPin(), 0.15f, CoroutineExtensions.easeInOutFunc);
		while (true)
		{
			_pin.transform.localPosition = getPositionForPin() + pin_drag_offset;
			yield return null;
		}
	}

	private Vector2 getPositionForPin()
	{
		return canvas.getPositionToUI(Pointer.current.position.ReadValue());
	}

	public void togglePinAtPosition(Vector2Int _position)
	{
		if (pins_on_set_board.ContainsKey(_position))
		{
			DragPin dragPin = pins_on_set_board[_position];
			pins_on_board.Remove(dragPin);
			dragPin.destroySelf();
			pins_on_set_board.Remove(_position);
			GameHandler.State.getCaseNotes().pins_data.removePin(dragPin.pin_index);
			GameHandler.instance.saveGame();
		}
		else
		{
			DragPin dragPin2 = makePin();
			dragPin2.setBoardPosition(_position);
			dragPin2.rect_trans.localPosition = pin_starting_position;
			dragPin2.rect_trans.localScale = new Vector3(0f, 0f, 1f);
			dragPin2.scaleUpPin();
			dragPin2.setPlaced();
			dragPin2.rect_trans.moveTransformGlobal(board_manager.getPinPositionOfSlot(_position, pin_offset), 0.25f, CoroutineExtensions.easeInOutFunc).start(this);
			pins_on_set_board[_position] = dragPin2;
			GameHandler.State.getCaseNotes().pins_data.addPin(dragPin2.getSaveData());
			GameHandler.instance.saveGame();
		}
	}

	private DragPin makePin()
	{
		DragPin dragPin = Object.Instantiate(drag_pin_prefab, drag_pin_parent);
		dragPin.setup(this, pen_manager, rubber_manager, canvas, pin_colours, colour_wheel, pin_index, onPinDestroy, string_manager);
		pin_index++;
		pins_on_board.Add(dragPin);
		return dragPin;
	}

	public Maybe<DragPin> getPinAtBoardPos(Vector2Int _position)
	{
		if (!pins_on_set_board.ContainsKey(_position))
		{
			return new Maybe<DragPin>();
		}
		return pins_on_set_board[_position].maybe();
	}

	public void tryChangeColour(Vector2Int _position, Color _colour)
	{
		if (pins_on_set_board.ContainsKey(_position))
		{
			DragPin dragPin = pins_on_set_board[_position];
			if (!(dragPin == null))
			{
				dragPin.changeColour(_colour);
				GameHandler.State.getCaseNotes().pins_data.resetPin(dragPin.pin_index, dragPin.getSaveData());
			}
		}
	}

	public void tryChangeColour(Vector2Int _position, int _direction)
	{
		if (pins_on_set_board.ContainsKey(_position))
		{
			DragPin dragPin = pins_on_set_board[_position];
			if (!(dragPin == null))
			{
				dragPin.changeColour(_direction);
				GameHandler.State.getCaseNotes().pins_data.resetPin(dragPin.pin_index, dragPin.getSaveData());
				GameHandler.instance.saveGame();
			}
		}
	}

	public void clearAll()
	{
		foreach (DragPin item in pins_on_board)
		{
			if (item != null)
			{
				Object.Destroy(item.gameObject);
			}
		}
		pins_on_board.Clear();
		if (GameHandler.State.case_notes.is_some)
		{
			GameHandler.State.getCaseNotes().pins_data = new PinsSave(new List<PinSaveData>());
			GameHandler.instance.saveGame();
		}
	}

	public void addPinsOnBoard(List<Vector2Int> _board_positions)
	{
		_board_positions.ForEach(delegate(Vector2Int _p)
		{
			togglePinAtPosition(_p);
		});
	}

	public DragPin addPinAtPosition(Vector2 _position, Color _colour)
	{
		DragPin dragPin = makePin();
		dragPin.rect_trans.localScale = new Vector3(0f, 0f, 1f);
		dragPin.rect_trans.localPosition = _position;
		dragPin.scaleUpPin();
		dragPin.changeColour(_colour, _save: false);
		dragPin.setPlaced();
		GameHandler.State.getCaseNotes().pins_data.addPin(dragPin.getSaveData());
		GameHandler.instance.saveGame();
		return dragPin;
	}

	public DragPin addPinAtBoardPosition(Vector2Int _position, Color _colour)
	{
		DragPin dragPin = makePin();
		dragPin.setBoardPosition(_position);
		dragPin.rect_trans.position = board_manager.getPinPositionOfSlot(_position, pin_offset);
		dragPin.rect_trans.localScale = new Vector3(0f, 0f, 1f);
		dragPin.scaleUpPin();
		dragPin.changeColour(_colour, _save: false);
		dragPin.setPlaced();
		pins_on_set_board[_position] = dragPin;
		GameHandler.State.getCaseNotes().pins_data.addPin(dragPin.getSaveData());
		GameHandler.instance.saveGame();
		return dragPin;
	}

	public bool hasAnyPin()
	{
		return pins_on_board.Count > 0;
	}

	public List<DragPin> getAllPins()
	{
		return pins_on_board;
	}

	public Maybe<DragPin> getClosestPinWithinDist(Vector2 _pos, float _dist)
	{
		return getClosestPinWithinDist(_pos, _dist, new Maybe<DragPin>());
	}

	public Maybe<DragPin> getClosestPinWithinDist(Vector2 _pos, float _dist, Maybe<DragPin> _start_pin)
	{
		Maybe<DragPin> result = new Maybe<DragPin>();
		float num = _dist;
		foreach (DragPin item in pins_on_board)
		{
			if (!_start_pin.is_some || _start_pin.value.canAttachString(item))
			{
				float magnitude = ((Vector2)item.transform.localPosition - _pos).magnitude;
				if (magnitude < num)
				{
					num = magnitude;
					result = item.maybe();
				}
			}
		}
		return result;
	}

	public bool hasPinAtPosition(Vector2Int _board_pos)
	{
		return pins_on_set_board.ContainsKey(_board_pos);
	}

	public Vector2 getPinWorldPosition(Vector2Int _board_pos)
	{
		return pins_on_set_board[_board_pos].transform.position;
	}

	public Vector2 getEstimatedPinWorldPosition(Vector2Int _board_pos)
	{
		return board_manager.getPinPositionOfSlot(_board_pos, pin_offset);
	}

	public Vector2 getEstimatedPinScreenPosition(Vector2Int _board_pos)
	{
		return Camera.main.WorldToScreenPoint(getEstimatedPinWorldPosition(_board_pos));
	}

	public List<Color> getPossibleColours()
	{
		return pin_colours;
	}

	public void tryChangeColourLeft(InputAction.CallbackContext _context)
	{
		if ((!dragging.is_some && pins_on_board.Count == 0) || !_context.performed)
		{
			return;
		}
		if (dragging.is_some)
		{
			dragging.value.changeColourLeft();
			return;
		}
		pins_on_board.Any((DragPin _e) => _e.changeColourLeft());
	}

	public void tryChangeColourRight(InputAction.CallbackContext _context)
	{
		if ((!dragging.is_some && pins_on_board.Count == 0) || !_context.performed)
		{
			return;
		}
		if (dragging.is_some)
		{
			dragging.value.changeColourRight();
			return;
		}
		pins_on_board.Any((DragPin _e) => _e.changeColourRight());
	}

	private void onPinDestroy(DragPin _pin)
	{
		pins_on_board.Remove(_pin);
		Maybe<Vector2Int> boardPosition = _pin.getBoardPosition();
		if (boardPosition.is_some)
		{
			pins_on_set_board.Remove(boardPosition.value);
		}
	}
}
