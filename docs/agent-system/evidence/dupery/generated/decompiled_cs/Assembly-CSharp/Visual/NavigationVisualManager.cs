using System;
using ControllerSupport;
using GRGLib.Coroutines;
using GRGLib.Extensions.Unity;
using GRGLib.Maybe;
using UnityEngine;

namespace Visual;

public class NavigationVisualManager : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private CanvasGroup navigation_board;

	[SerializeField]
	private RectTransform board_boat_marker;

	[SerializeField]
	private NavigationVisualHelper navigation_helper;

	[SerializeField]
	private CanvasGroup board_group;

	[SerializeField]
	private BoardVisualManager board_manager;

	[SerializeField]
	private LeverHandle handle;

	[SerializeField]
	private BoatMarkerVisualManager boat_marker;

	[SerializeField]
	private Vector2 board_boat_offset = new Vector2(200f, 100f);

	private Action<Vector2Int> move_boat;

	private CoroutineRunner group_runner;

	private CoroutineRunner mini_boat_runner;

	private bool navigating;

	private Vector2Int boat_position;

	private Func<Vector2Int, Vector2Int, int> estimate_cost;

	private CaseControllerSupportHandler controller_support_handler;

	public RectTransform getLeverTransformForTutorial()
	{
		return handle.transform as RectTransform;
	}

	public void setUp(DocksBoat _boat, Action<Vector2Int> _move_boat, CaseControllerSupportHandler _controller_support, AbilityVisualManager _ab_manager)
	{
		controller_support_handler = _controller_support;
		board_group.putOn();
		base.transform.SetParent(board_manager.transform);
		move_boat = _move_boat;
		handle.setUp(_ab_manager);
		navigating = false;
		boat_position = _boat.position;
		estimate_cost = _boat.estimateFuelCostToPosition;
		boat_marker.setUp(board_manager.getTruePosition, _boat.position, board_boat_offset);
		group_runner = new CoroutineRunner(this);
		mini_boat_runner = new CoroutineRunner(this);
	}

	public void renew(DocksBoat _boat)
	{
		boat_position = _boat.position;
		boat_marker.moveBoat(_boat.position);
	}

	public void switchStates(bool _state)
	{
		if (_state == navigating)
		{
			return;
		}
		navigating = _state;
		if (navigating)
		{
			board_manager.overrideEmptySlotCallback(hover, unhover, click);
			Maybe<EmptySlot> maybe = board_manager.findAlreadyHoveringSlot();
			if (GameHandler.instance.using_gamepad && controller_support_handler.selected_slot.is_some)
			{
				hover(controller_support_handler.selected_slot.value, controller_support_handler.selected_slot.value.grid_pos);
			}
			else if (maybe.is_some)
			{
				hover(maybe.value, maybe.value.grid_pos);
			}
			swapGroups(navigation_board, board_group);
			group_runner.run(navigation_board.fade(1f, 0.35f, CoroutineExtensions.easeInOutFunc));
			boat_marker.startActiveAnimation();
		}
		else
		{
			board_manager.resetEmptySlotCallbackOverride();
			swapGroups(board_group, navigation_board);
			navigation_helper.forceCloseAndReset();
			group_runner.run(navigation_board.fade(0f, 0.35f, CoroutineExtensions.easeInOutFunc));
			boat_marker.startIdleAnimation();
		}
	}

	private void swapGroups(CanvasGroup _group_in, CanvasGroup _group_out)
	{
		_group_out.interactable = false;
		_group_out.blocksRaycasts = false;
		_group_in.interactable = true;
		_group_in.blocksRaycasts = true;
	}

	private void hover(EmptySlot _slot, Vector2Int _position)
	{
		if (!(_position == boat_position))
		{
			navigation_helper.checkDestination(_slot, board_manager.getTruePosition(_position), estimate_cost(boat_position, _position));
		}
	}

	private void unhover(EmptySlot _slot, Vector2Int _position)
	{
		navigation_helper.tryClose(_slot);
	}

	private void click(EmptySlot _slot, Vector2Int _position)
	{
		move_boat(_position);
		handle.putHandleOff();
	}
}
