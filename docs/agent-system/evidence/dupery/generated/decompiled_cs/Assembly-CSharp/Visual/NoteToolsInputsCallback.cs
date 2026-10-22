using GRGLib.Extensions.Unity;
using GRGLib.Maybe;
using UnityEngine;
using UnityEngine.InputSystem;

namespace Visual;

public class NoteToolsInputsCallback : MonoBehaviour
{
	[SerializeField]
	private Canvas canvas;

	[SerializeField]
	private CaseEndVisualManager end_menu;

	private PinsController pins_controller;

	private PenManager pen_manager;

	private StringManager string_manager;

	private RubberManager rubber_manager;

	private bool set_up;

	public void setUpToolReferences(PinsController _pins, PenManager _pen, StringManager _string, RubberManager _rubber)
	{
		pins_controller = _pins;
		pen_manager = _pen;
		string_manager = _string;
		rubber_manager = _rubber;
		set_up = true;
	}

	public void onColourChangeRight(InputAction.CallbackContext _context)
	{
		if (set_up && !end_menu.is_open_and_visible)
		{
			pins_controller.tryChangeColourRight(_context);
			pen_manager.changePenColourRight(_context);
			string_manager.changePenColourRight(_context);
		}
	}

	public void onColourChangeLeft(InputAction.CallbackContext _context)
	{
		if (set_up && !end_menu.is_open_and_visible)
		{
			pins_controller.tryChangeColourLeft(_context);
			pen_manager.changePenColourLeft(_context);
			string_manager.changePenColourLeft(_context);
		}
	}

	public void onScrollWheel(InputAction.CallbackContext _context)
	{
		if (set_up && !end_menu.is_open_and_visible)
		{
			rubber_manager.onMouseScroll(_context);
		}
	}

	public void togglePen(InputAction.CallbackContext _context)
	{
		if (!_context.canceled && _context.performed && !end_menu.is_open_and_visible && !pins_controller.dragging.is_some)
		{
			if (pen_manager.tool_selected)
			{
				pen_manager.deselectPen();
				return;
			}
			closeTools(rubber_manager, string_manager);
			pen_manager.selectPen();
		}
	}

	public void toggleRubber(InputAction.CallbackContext _context)
	{
		if (!_context.canceled && _context.performed && !end_menu.is_open_and_visible && !pins_controller.dragging.is_some)
		{
			if (rubber_manager.tool_selected)
			{
				rubber_manager.deselectPen();
				return;
			}
			closeTools(pen_manager, string_manager);
			rubber_manager.selectPen();
		}
	}

	public void placePin(InputAction.CallbackContext _context)
	{
		if (!_context.canceled && _context.performed && !end_menu.is_open_and_visible && !pins_controller.dragging.is_some)
		{
			Vector2 positionToUI = canvas.getPositionToUI(Pointer.current.position.ReadValue());
			Maybe<DragPin> closestPinWithinDist = pins_controller.getClosestPinWithinDist(positionToUI, 45f);
			if (closestPinWithinDist.is_some)
			{
				closestPinWithinDist.value.destroySelf();
			}
			else
			{
				pins_controller.addPinAtPosition(positionToUI, pins_controller.getPossibleColours()[0]);
			}
		}
	}

	private void closeTools(params NotesToolManager[] tools)
	{
		foreach (NotesToolManager notesToolManager in tools)
		{
			if (notesToolManager.tool_selected)
			{
				notesToolManager.deselectPen();
			}
		}
	}
}
