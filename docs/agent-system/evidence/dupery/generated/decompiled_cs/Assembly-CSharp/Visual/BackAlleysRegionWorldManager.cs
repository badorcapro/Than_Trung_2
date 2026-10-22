using System;
using System.Collections.Generic;
using System.Linq;
using ControllerSupport;
using GRGLib.Maybe;
using Quirks;
using Tutorial;
using UnityEngine;
using UnityEngine.InputSystem;

namespace Visual;

public class BackAlleysRegionWorldManager : WorldVisualManager
{
	[SerializeField]
	private BackAlleysHealthVisualManager health_manager;

	[SerializeField]
	private BackAlleysPouchVisualManager pouch_manager;

	[SerializeField]
	private BackAlleysNewItemVisualManager new_item_menu;

	public override TutorialReferences getTutorialReferences()
	{
		return new TutorialReferences(suspect_list.transform as RectTransform, ratio_manager.transform as RectTransform, null, board_manager.transform as RectTransform, suspect_list.explanation_trans, null, pen_manager, rubber_manager, pins_controller);
	}

	protected override void setUpRegion(CaseSnapshot _case_snapshot, List<CaseQuirkData> _active_quirks, Func<CaseSnapshot> _get_snap, PureLogicCalls _logic_calls, Action<CaseSnapshot> _renew_world, PlayerInput _player_input, CaseControllerSupportHandler _controller_handler, AbilityVisualManager _ab_manager)
	{
		pouch_manager.setUp(delegate(Vector2Int _p, IHaveAbility _a)
		{
			board_manager.getAbilityManager().attemptAbility(_a, delegate(List<int> _ras)
			{
				_renew_world(_logic_calls.do_item_ability(_p, ((IEnumerable<int>)_ras).Select((Func<int, AbilityData>)((int _a) => new AddressAbilityData(_a))).ToList()));
			}, delegate(List<AbilityData> _ad)
			{
				_renew_world(_logic_calls.do_item_ability(_p, _ad));
			}, delegate
			{
			});
		}, delegate(Vector2Int _p1, Vector2Int _p2)
		{
			_renew_world(_logic_calls.exchange_items(_p1, _p2));
		}, base.transform as RectTransform, board_manager);
		new_item_menu.setUp(_player_input);
		_controller_handler.addActionCallback(ControllerActions.SOUTH, "alleys_pouch", pouch_manager.onControllerSouth);
		_controller_handler.addDeviceChangeCallback("alleys_pouch", pouch_manager.onDeviceChange);
		renewRegionWorld(_case_snapshot);
	}

	public override void setUpCaseReferences(Case _case)
	{
		if (!(_case is BackAlleysCase backAlleysCase))
		{
			Debug.LogError("Case is not a back alleys case!");
		}
		else
		{
			backAlleysCase.setUpAddNewItemCall(addNewItem);
		}
	}

	protected override void renewRegionWorld(CaseSnapshot _snap)
	{
		if (!(_snap is BackAlleysCaseSnapshot backAlleysCaseSnapshot))
		{
			Debug.LogError("Snapshot is not a BackAlleysCaseSnapshot! Back Alleys Region Visuals Manager can only accept BackAlleysCaseSnapshot!");
			return;
		}
		health_manager.renew(backAlleysCaseSnapshot.back_alleys_payload.current_health, backAlleysCaseSnapshot.back_alleys_payload.max_health);
		pouch_manager.renew(backAlleysCaseSnapshot);
	}

	private void addNewItem(BackAlleysItem _item, bool _forced, Func<Maybe<Vector2Int>, BackAlleysCaseSnapshot> _add_to_slot)
	{
		new_item_menu.open(_item, _forced, delegate(Maybe<Vector2Int> _p)
		{
			renewRegionWorld(_add_to_slot(_p));
		});
	}
}
