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

public class CasinoRegionWorldManager : WorldVisualManager
{
	[SerializeField]
	private CasinoChipsManager chips_manager;

	[SerializeField]
	private CasinoCardManager card_manager;

	[SerializeField]
	private CasinoLightsManager chips_lights;

	[SerializeField]
	private CasinoLightsManager suspect_lights;

	[Header("Tutorial References")]
	[SerializeField]
	private RectTransform cards_parent;

	[SerializeField]
	private RectTransform cost_multi_parent;

	private List<int> arrested_adresses = new List<int>();

	public override TutorialReferences getTutorialReferences()
	{
		return new TutorialReferences(cost_multi_parent, cards_parent, pen_manager, rubber_manager, pins_controller);
	}

	protected override void setUpRegion(CaseSnapshot _case_snapshot, List<CaseQuirkData> _active_quirks, Func<CaseSnapshot> _get_snap, PureLogicCalls _logic_calls, Action<CaseSnapshot> _renew_world, PlayerInput _player_input, CaseControllerSupportHandler _controller_handler, AbilityVisualManager _ab_manager)
	{
		if (!(_case_snapshot is CasinoCaseSnapshot casinoCaseSnapshot))
		{
			Debug.LogError("Snapshot is not a CasinoCaseSnapshot! Casino Region Visuals Manager can only accept CasinoCaseSnapshot!");
			return;
		}
		chips_manager.setUp();
		chips_manager.setChips(casinoCaseSnapshot.casino_payload.chips, casinoCaseSnapshot.casino_payload.chips_hidden, _animate: false);
		card_manager.setUp(casinoCaseSnapshot.casino_payload.left_card, casinoCaseSnapshot.casino_payload.right_card);
		chips_lights.setUp();
		suspect_lights.setUp();
		renewRegionWorld(_case_snapshot);
	}

	protected override void renewRegionWorld(CaseSnapshot _snap)
	{
		if (!(_snap is CasinoCaseSnapshot casinoCaseSnapshot))
		{
			Debug.LogError("Snapshot is not a CasinoCaseSnapshot! Casino Region Visuals Manager can only accept CasinoCaseSnapshot!");
			return;
		}
		chips_manager.setChips(casinoCaseSnapshot.casino_payload.chips, casinoCaseSnapshot.casino_payload.chips_hidden);
		card_manager.checkRenew(casinoCaseSnapshot.casino_payload.left_card, casinoCaseSnapshot.casino_payload.right_card);
		Maybe<Alignments> arrested = new Maybe<Alignments>();
		List<KeyValuePair<int, RoleData>> list = casinoCaseSnapshot.address_occupents.Where((KeyValuePair<int, RoleData> _r) => _r.Value.getIsArrested()).ToList();
		if (list.Count != arrested_adresses.Count)
		{
			arrested = list.Find((KeyValuePair<int, RoleData> _r) => !arrested_adresses.Contains(_r.Key)).Value.getTrueAlignment().maybe();
			arrested_adresses = list.Select((KeyValuePair<int, RoleData> _r) => _r.Key).ToList();
		}
		chips_lights.renew(casinoCaseSnapshot, arrested);
		suspect_lights.renew(casinoCaseSnapshot, arrested);
	}

	protected override void onRevealTruth()
	{
		base.onRevealTruth();
		chips_manager.revealTruth();
	}

	public void setUpCardsForSelection(Action<CasinoCardAbilityData> _on_selection)
	{
		card_manager.setUpCardsForSelection(_on_selection);
	}

	public void resetCardSelections()
	{
		card_manager.resetCardSelections();
	}
}
