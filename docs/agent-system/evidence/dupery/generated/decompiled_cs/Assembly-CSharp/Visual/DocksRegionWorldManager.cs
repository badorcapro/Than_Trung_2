using System;
using System.Collections.Generic;
using System.Linq;
using Audio;
using CaseSelection;
using ControllerSupport;
using GRGLib.Coroutines;
using GRGLib.Menus;
using GRGLocalisation;
using Localisation;
using Quirks;
using TMPro;
using Tutorial;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;

namespace Visual;

public class DocksRegionWorldManager : WorldVisualManager, IAmLocalised
{
	[SerializeField]
	private CaseSelectionReputationManager reputation_manager;

	[SerializeField]
	private NavigationVisualManager navigation_manager;

	[SerializeField]
	private FuelVisualManager fuel_manager;

	[SerializeField]
	private ConfirmationMenu traitor_confirmation;

	[SerializeField]
	private TMP_Text cant_end_text;

	[SerializeField]
	private BasicMenuController finish_menu;

	[SerializeField]
	private Button finish_case_button;

	[SerializeField]
	private TMP_Text finish_case_text;

	[SerializeField]
	private Image finish_case_background;

	[SerializeField]
	private MenuBase confirmation_menu;

	[Header("Settings")]
	[SerializeField]
	private Sprite on_back;

	[SerializeField]
	private Sprite off_back;

	public Action player_end_case;

	private bool has_traitor;

	private bool has_arrested_role;

	private CoroutineRunner end_text_runner;

	private string english_end_case => "Finish Case";

	private AssetKey localisation_asset => LocalisationHelper.ui_asset;

	private string loc_rd_key => "DockUI [rd]";

	public override TutorialReferences getTutorialReferences()
	{
		return new TutorialReferences(suspect_list.transform as RectTransform, ratio_manager.transform as RectTransform, board_manager.transform as RectTransform, suspect_list.explanation_trans, pen_manager, rubber_manager, pins_controller, navigation_manager.getLeverTransformForTutorial(), finish_menu.transform as RectTransform);
	}

	protected override void setUpRegion(CaseSnapshot _case_snapshot, List<CaseQuirkData> _active_quirks, Func<CaseSnapshot> _get_snap, PureLogicCalls _logic_calls, Action<CaseSnapshot> _renew_world, PlayerInput _player_input, CaseControllerSupportHandler _controller_handler, AbilityVisualManager _ab_manager)
	{
		if (!(_case_snapshot is DocksCaseSnapshot docksCaseSnapshot))
		{
			Debug.LogError("Snapshot is not a DocksCaseSnapshot! Docks Region Visuals Manager can only accept DocksCaseSnapshot!");
			return;
		}
		confirmation_menu.setPlayerInput(_player_input);
		end_text_runner = new CoroutineRunner(this);
		player_end_case = delegate
		{
			_renew_world(_logic_calls.finish_case());
		};
		navigation_manager.setUp(docksCaseSnapshot.docks_payload.boat, delegate(Vector2Int _p)
		{
			_renew_world(_logic_calls.move_boat_interaction(_p));
		}, _controller_handler, _ab_manager);
		fuel_manager.setUp(docksCaseSnapshot.docks_payload.boat.visual_fuel, docksCaseSnapshot.docks_payload.boat.visual_max_fuel);
		reputation_manager.setUp();
		renewRegionWorld(_case_snapshot);
		has_traitor = _case_snapshot.classification_ratio[RoleClassifications.TRAITOR] > 0;
		has_arrested_role = _case_snapshot.address_occupents.Values.Any((RoleData _r) => (_r.getTrueAlignment() == Alignments.EVIL && _r.getIsArrested()) || _r.getIsDead());
		AudioHandler.Atmo.playAtmo(Atmo.WAVES);
		AudioHandler.Atmo.playAtmo(Atmo.DOCKS);
	}

	protected override void renewRegionWorld(CaseSnapshot _snap)
	{
		if (!(_snap is DocksCaseSnapshot docksCaseSnapshot))
		{
			Debug.LogError("Snapshot is not a DocksCaseSnapshot! Docks Region Visuals Manager can only accept DocksCaseSnapshot!");
			return;
		}
		DocksBoat boat = docksCaseSnapshot.docks_payload.boat;
		reputation_manager.changeReputation(docksCaseSnapshot.docks_payload.reputation);
		navigation_manager.renew(boat);
		fuel_manager.renew(boat.visual_fuel, boat.position.cardinalDistance(docksCaseSnapshot.board.getLocationsInPlay()[LocationTypes.DOCKS].getBoardPosition()), boat.fuel_hidden);
		if (boat.position == docksCaseSnapshot.board.getLocationsInPlay()[LocationTypes.DOCKS].getBoardPosition())
		{
			setFinishCaseButton(_on: true);
		}
		else
		{
			setFinishCaseButton(_on: false);
		}
		has_arrested_role = has_arrested_role || _snap.address_occupents.Values.Any((RoleData _r) => (_r.getTrueAlignment() == Alignments.EVIL && _r.getIsArrested()) || _r.getIsDead());
	}

	public void finishCase()
	{
		if (!finish_menu.is_open || !finish_case_button.interactable)
		{
			return;
		}
		if (!has_arrested_role)
		{
			end_text_runner.run(cant_end_text.fade(1f, 0.15f, CoroutineExtensions.easeInOutFunc).addCallback(delegate
			{
				end_text_runner.run(1.5f.wait(delegate
				{
					end_text_runner.run(cant_end_text.fade(0f, 0.65f, CoroutineExtensions.easeInOutFunc));
				}));
			}));
		}
		else if (has_traitor)
		{
			traitor_confirmation.setUpAndOpen(endCase, traitor_confirmation.closeMenu);
		}
		else
		{
			endCase();
		}
	}

	private void endCase()
	{
		player_end_case();
		Debug.Log("Case ended!");
	}

	private void setFinishCaseButton(bool _on)
	{
		if (_on)
		{
			AudioHandler.Atmo.playAtmo(Atmo.DOCKS);
			finish_case_button.interactable = true;
			finish_case_text.text = localisation_asset.checkTranslation(english_end_case, () => english_end_case, _check_keywords: false);
			finish_case_background.sprite = on_back;
		}
		else
		{
			AudioHandler.Atmo.stopAtmoIfPlaying(Atmo.DOCKS);
			finish_case_text.text = localisation_asset.checkTranslation(loc_rd_key, englishRequireDocks, _check_keywords: false);
			finish_case_background.sprite = off_back;
			finish_case_button.interactable = false;
		}
	}

	private string englishRequireDocks()
	{
		return "Must be at the Docks to finish the case.";
	}
}
