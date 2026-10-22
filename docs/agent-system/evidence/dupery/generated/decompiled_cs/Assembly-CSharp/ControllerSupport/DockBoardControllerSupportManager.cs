using System.Collections.Generic;
using System.Linq;
using GRGLib.UI;
using UnityEngine;
using UnityEngine.InputSystem;
using Visual;

namespace ControllerSupport;

public class DockBoardControllerSupportManager : BoardControllerSupportManager
{
	[Header("Dock References")]
	[SerializeField]
	private LeverHandle lever;

	[SerializeField]
	private AdvancedButton lever_button;

	[SerializeField]
	private AdvancedButton finish_button;

	[SerializeField]
	private GameObject lever_controller_selector;

	public override void setControllerSupportReferences(CaseControllerSupportHandler _controller_support_handler)
	{
		base.setControllerSupportReferences(_controller_support_handler);
		_controller_support_handler.addActionCallback(ControllerActions.K_SPACE, "docks_lever", lever.onSpaceButton);
		_controller_support_handler.addActionCallback(ControllerActions.SOUTH, "docks_lever", lever.onSouthButton);
		_controller_support_handler.addActionCallback(ControllerActions.TRIGGER_WEST, "docks_lever", lever.onShoulder);
		_controller_support_handler.addDeviceChangeCallback("lever_controller_image", delegate(PlayerInput _p)
		{
			lever_controller_selector.SetActive(_p.isUsingGamepad());
		});
		lever_controller_selector.SetActive(GameHandler.instance.using_gamepad);
	}

	public override void setUp(BoardVisualManager _board_manager)
	{
		_board_manager.empty_slots.Where((KeyValuePair<Vector2Int, EmptySlot> _s) => _s.Key.x == 0).ToList().ForEach(delegate(KeyValuePair<Vector2Int, EmptySlot> _s)
		{
			_s.Value.setUpLeftNavigation(lever_button);
		});
		lever_button.addRightSelectable(_board_manager.empty_slots[new Vector2Int(0, 0)].getSelectable());
		finish_button.addRightSelectable(_board_manager.empty_slots[new Vector2Int(0, 0)].getSelectable());
	}
}
