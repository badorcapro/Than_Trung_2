using System;
using System.Collections.Generic;
using GRGLib.Coroutines;
using GRGLib.Extensions.Unity;
using GRGLib.Maybe;
using GRGLib.Menus;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;
using Visual;

namespace ControllerSupport;

public class CaseControllerSupportHandler : AdvancedInputHandler
{
	[Header("References")]
	[SerializeField]
	private CaseHandler case_handler;

	[SerializeField]
	private AbilityVisualManager ability_manager;

	[SerializeField]
	private List<BasicMenuController> scene_menus;

	private CanvasGroup support_group;

	private Image role_selectioner;

	private PinsController pins_controller;

	private PenManager pen_manager;

	private RubberManager rubber_manager;

	private StringManager string_manager;

	private ColourWheel colour_wheel;

	private CoroutineRunner group_fade_runner;

	private CoroutineRunner selectioner_fade_runner;

	private CoroutineRunner selectioner_move_runner;

	private CoroutineRunner wait_for_deselection;

	private EmptySlot backup_selection;

	private Maybe<Action<EmptySlot>> select_backup_asap = new Maybe<Action<EmptySlot>>();

	private Vector2Int last_string_controller_pos;

	public Maybe<EmptySlot> selected_slot { get; private set; } = new Maybe<EmptySlot>();

	public Maybe<SuspectVisual> selected_suspect { get; private set; } = new Maybe<SuspectVisual>();

	public bool something_selected
	{
		get
		{
			if (!selected_slot.is_some)
			{
				return selected_suspect.is_some;
			}
			return true;
		}
	}

	public bool wants_selection
	{
		get
		{
			if (!something_selected)
			{
				return !scene_menus.Exists((BasicMenuController _m) => _m.is_open);
			}
			return false;
		}
	}

	protected override void Awake()
	{
		base.Awake();
		group_fade_runner = new CoroutineRunner(this);
		selectioner_fade_runner = new CoroutineRunner(this);
		selectioner_move_runner = new CoroutineRunner(this);
		wait_for_deselection = new CoroutineRunner(this);
	}

	public void setReferences(CanvasGroup _group, Image _selectioner, PinsController _pins, PenManager _pen, RubberManager _rubber, StringManager _string, ColourWheel _wheel)
	{
		support_group = _group;
		role_selectioner = _selectioner;
		pins_controller = _pins;
		pen_manager = _pen;
		rubber_manager = _rubber;
		string_manager = _string;
		colour_wheel = _wheel;
	}

	public Selectable getBackupSelectable()
	{
		return backup_selection.getSelectable();
	}

	public void scaleSelectioner(float _scale)
	{
		role_selectioner.transform.localScale = new Vector3(_scale, _scale, 1f);
	}

	public void checkSelection()
	{
		if (GameHandler.instance.using_gamepad)
		{
			group_fade_runner.run(support_group.fade(1f, 0.5f, CoroutineExtensions.easeInOutFunc));
			if (wants_selection)
			{
				backup_selection.forceSelect();
			}
		}
	}

	public void setUpBackupSelection(EmptySlot _slot)
	{
		backup_selection = _slot;
		if (case_handler.in_tutorial)
		{
			select_backup_asap = new Maybe<Action<EmptySlot>>();
			group_fade_runner.stop();
			support_group.alpha = 0f;
			case_handler.forceTutorialSelect();
		}
		else if (select_backup_asap.is_some)
		{
			select_backup_asap.value(backup_selection);
			select_backup_asap = new Maybe<Action<EmptySlot>>();
		}
	}

	private void trySelectBackup(Action<EmptySlot> _select_func)
	{
		if (backup_selection == null)
		{
			select_backup_asap = _select_func.maybe();
		}
		else
		{
			_select_func(backup_selection);
		}
	}

	public override bool trySelectSomething()
	{
		if (case_handler.in_tutorial)
		{
			return false;
		}
		if (base.trySelectSomething())
		{
			return true;
		}
		if (backup_selection != null)
		{
			backup_selection.forceSelect();
			return true;
		}
		return false;
	}

	protected override void onChangeToGamepad(PlayerInput _input)
	{
		base.onChangeToGamepad(_input);
		if (group_fade_runner == null || support_group == null)
		{
			return;
		}
		if (!case_handler.in_tutorial)
		{
			group_fade_runner.run(support_group.fade(1f, 0.5f, CoroutineExtensions.easeInOutFunc));
			if (wants_selection)
			{
				trySelectBackup(delegate(EmptySlot _b)
				{
					_b.forceSelect();
				});
			}
		}
		else
		{
			group_fade_runner.run(support_group.fade(0f, 0.5f, CoroutineExtensions.easeInOutFunc));
			if (wants_selection)
			{
				case_handler.forceTutorialSelect();
			}
		}
	}

	protected override void onChangeToKBM(PlayerInput _input)
	{
		base.onChangeToKBM(_input);
		if (group_fade_runner != null)
		{
			group_fade_runner.run(support_group.fade(0f, 0.5f, CoroutineExtensions.easeInOutFunc));
		}
	}

	public void onSlotSelect(EmptySlot _slot)
	{
		selected_slot = _slot.maybe();
		selectioner_move_runner.run(role_selectioner.transform.moveTransformGlobal(_slot.transform.position, 0.15f, CoroutineExtensions.easeInOutFunc));
		if (selectioner_fade_runner.is_running || role_selectioner.color.a != 1f)
		{
			selectioner_fade_runner.run(role_selectioner.fade(1f, 0.15f, CoroutineExtensions.easeInOutFunc));
		}
	}

	public void onSlotDeselect(EmptySlot _slot)
	{
		if (selected_slot.is_some && selected_slot.value == _slot)
		{
			selected_slot = new Maybe<EmptySlot>();
			selectioner_fade_runner.run(role_selectioner.fade(0f, 0.15f, CoroutineExtensions.easeInOutFunc));
		}
	}

	public void onSelectSuspect(SuspectVisual _suspect)
	{
		selected_suspect = _suspect.maybe();
		wait_for_deselection.stop();
		if (role_selectioner.color.a > 0f)
		{
			selectioner_fade_runner.run(role_selectioner.fade(0f, 0.15f, CoroutineExtensions.easeInOutFunc));
		}
	}

	public void onDeselectSuspect(SuspectVisual _suspect)
	{
		if (selected_suspect.is_some && selected_suspect.value == _suspect)
		{
			selected_suspect = new Maybe<SuspectVisual>();
		}
	}

	protected override void onSouthButton(InputAction.CallbackContext _context)
	{
		if (_context.performed || _context.canceled)
		{
			if (selected_slot.is_some)
			{
				selected_slot.value.onControllerSouth(_context.performed && !_context.canceled);
			}
			if (selected_suspect.is_some)
			{
				selected_suspect.value.openCodexOfRole();
			}
			checkSceneActions(ControllerActions.SOUTH, _context);
		}
	}

	protected override void onEastButton(InputAction.CallbackContext _context)
	{
		if (_context.canceled)
		{
			if (pen_manager.tool_selected)
			{
				pen_manager.deselectPen();
			}
			else if (rubber_manager.tool_selected)
			{
				rubber_manager.deselectPen();
			}
			else if (ability_manager.using_ability)
			{
				ability_manager.cancelSelection();
			}
			else
			{
				checkSceneActions(ControllerActions.EAST, _context);
			}
		}
	}

	protected override void onWestButton(InputAction.CallbackContext _context)
	{
		if (selected_slot.is_some)
		{
			selected_slot.value.onControllerWest(_context.performed && !_context.canceled);
		}
		else if (selected_suspect.is_some && _context.canceled)
		{
			pen_manager.toggleSuspectCross(selected_suspect.value, ControllerSuspectLineTypes.CROSS_OUT);
		}
		checkSceneActions(ControllerActions.WEST, _context);
	}

	protected override void onNorthButton(InputAction.CallbackContext _context)
	{
		checkSceneActions(ControllerActions.NORTH, _context);
		if (_context.canceled)
		{
			if (selected_slot.is_some)
			{
				pins_controller.togglePinAtPosition(selected_slot.value.grid_pos);
			}
			else if (selected_suspect.is_some)
			{
				pen_manager.toggleSuspectCross(selected_suspect.value, ControllerSuspectLineTypes.CHECKMARK);
			}
		}
	}

	protected override void onWestShoulder(InputAction.CallbackContext _context)
	{
		checkSceneActions(ControllerActions.SHOULDER_WEST, _context);
		if (_context.canceled && selected_slot.is_some)
		{
			pins_controller.tryChangeColour(selected_slot.value.grid_pos, -1);
		}
	}

	protected override void onEastShoulder(InputAction.CallbackContext _context)
	{
		checkSceneActions(ControllerActions.SHOULDER_EAST, _context);
		if (_context.canceled && selected_slot.is_some)
		{
			pins_controller.tryChangeColour(selected_slot.value.grid_pos, 1);
		}
	}

	protected override void onWestTrigger(InputAction.CallbackContext _context)
	{
		checkSceneActions(ControllerActions.TRIGGER_WEST, _context);
	}

	protected override void onEastTrigger(InputAction.CallbackContext _context)
	{
		checkSceneActions(ControllerActions.TRIGGER_EAST, _context);
		if (_context.performed)
		{
			if (selected_slot.is_some)
			{
				Maybe<DragPin> pinAtBoardPos = pins_controller.getPinAtBoardPos(selected_slot.value.grid_pos);
				if (pinAtBoardPos.is_some)
				{
					string_manager.startControllerStringFromPin(pinAtBoardPos.value, pinAtBoardPos.value.getColourIndex(), getStringControllerPosition);
				}
			}
		}
		else
		{
			if (!string_manager.tool_selected || !_context.canceled)
			{
				return;
			}
			if (!selected_slot.is_some)
			{
				string_manager.stopControllerString(new Maybe<DragPin>());
				return;
			}
			Maybe<DragPin> pinAtBoardPos2 = pins_controller.getPinAtBoardPos(selected_slot.value.grid_pos);
			if (!pinAtBoardPos2.is_some)
			{
				pins_controller.addPinAtBoardPosition(selected_slot.value.grid_pos, string_manager.getCurrentStringColour());
				pinAtBoardPos2 = pins_controller.getPinAtBoardPos(selected_slot.value.grid_pos);
			}
			string_manager.stopControllerString(pinAtBoardPos2);
		}
	}

	protected Vector2 getStringControllerPosition()
	{
		if (selected_slot.is_some)
		{
			last_string_controller_pos = selected_slot.value.grid_pos;
			return new Vector2(3840f, 2160f).getPositionToUI(pins_controller.getEstimatedPinScreenPosition(selected_slot.value.grid_pos));
		}
		return new Vector2(3840f, 2160f).getPositionToUI(pins_controller.getEstimatedPinScreenPosition(last_string_controller_pos));
	}

	protected override void onRightJoystick(InputAction.CallbackContext _context)
	{
		if (!selected_slot.is_some)
		{
			return;
		}
		if (string_manager.tool_selected)
		{
			controllerColourWheel(_context, string_manager.getPossibleColours(), pins_controller.getEstimatedPinWorldPosition(selected_slot.value.grid_pos), string_manager.changeColour);
		}
		else if (pins_controller.hasPinAtPosition(selected_slot.value.grid_pos))
		{
			controllerColourWheel(_context, pins_controller.getPossibleColours(), pins_controller.getPinWorldPosition(selected_slot.value.grid_pos), delegate(Color _c)
			{
				pins_controller.tryChangeColour(selected_slot.value.grid_pos, _c);
			});
		}
		checkSceneActions(ControllerActions.RIGHT_JOYSTICK, _context);
	}

	protected void controllerColourWheel(InputAction.CallbackContext _context, List<Color> _colours, Vector2 _position, Action<Color> _callback)
	{
		Vector2 joy_pos = _context.ReadValue<Vector2>();
		bool flag = colour_wheel.checkController(joy_pos);
		if (flag && colour_wheel.is_closed)
		{
			colour_wheel.setColoursAndOpen(_colours, _position, _callback);
		}
		else if (!flag)
		{
			colour_wheel.closeMenu();
		}
	}

	protected override void onSelectButton(InputAction.CallbackContext _context)
	{
		if (_context.canceled)
		{
			if (selected_slot.is_some)
			{
				selected_slot.value.onControllerLeftStart();
			}
			checkSceneActions(ControllerActions.SELECT, _context);
		}
	}

	protected override void onEscape(InputAction.CallbackContext _context)
	{
		if (_context.canceled)
		{
			if (ability_manager.using_ability)
			{
				ability_manager.cancelSelection();
			}
			else
			{
				pause_menu.onStartButton(delegate
				{
				});
			}
		}
	}
}
