using System;
using System.Collections;
using System.Collections.Generic;
using Audio;
using Codex;
using GRGLib.Coroutines;
using GRGLib.Menus;
using GRGLocalisation;
using Localisation;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;

public class PauseMenu : MenuBase, IAmLocalised
{
	[Header("Animation Settings")]
	[SerializeField]
	private CanvasGroup button_group;

	[SerializeField]
	private RectTransform back_1;

	[SerializeField]
	private RectTransform back_2;

	[SerializeField]
	private RectTransform back_bug_report;

	[SerializeField]
	private Vector2 back_1_start;

	[SerializeField]
	private Vector2 back_bug_start;

	[SerializeField]
	private float back_2_scale_start;

	[SerializeField]
	private float backs_anim_duration;

	[Header("Optional Settings")]
	[SerializeField]
	private bool save_on_open;

	[Header("Other References")]
	[SerializeField]
	private GameObject abandandon_button;

	[SerializeField]
	private ConfirmationMenu confirmation_menu;

	[Header("Optional References")]
	[SerializeField]
	private Selectable select_on_close;

	[SerializeField]
	private List<MenuController> veto_opening;

	[SerializeField]
	private BugReporter bug_reporter_menu;

	[SerializeField]
	private CaseHandler case_handler;

	private MultiCoroutineRunner menuing_extra_runner;

	private CoroutineRunner buttons_fade;

	private AssetKey localisation_asset => LocalisationHelper.ui_asset;

	private string loc_abandon_key => "Pause [abandon]";

	private string loc_main_menu_exit_key => "Pause [exit_mm]";

	private string loc_quit_key => "Pause [quit]";

	protected override void Awake()
	{
		base.Awake();
		menuing_extra_runner = new MultiCoroutineRunner(this);
		buttons_fade = new CoroutineRunner(this);
		if (bug_reporter_menu != null)
		{
			bug_reporter_menu.setPlayerInput(input);
		}
		if (confirmation_menu != null)
		{
			confirmation_menu.setPlayerInput(input);
		}
	}

	protected override IEnumerator openingMenuAnimation()
	{
		menuing_extra_runner.run(back_1.moveTransform(Vector3.zero, backs_anim_duration, CoroutineExtensions.easeOutBackFunc), back_2.scaleTransform(1f, backs_anim_duration, CoroutineExtensions.easeInOutFunc), back_bug_report.moveTransform(new Vector3(1000f, -100f, 0f), backs_anim_duration, CoroutineExtensions.easeOutBackFunc));
		buttons_fade.run(button_group.fade(1f, 0.25f, CoroutineExtensions.easeInOutFunc));
		return base.openingMenuAnimation();
	}

	protected override IEnumerator closingMenuAnimation()
	{
		menuing_extra_runner.run(back_1.moveTransform(back_1_start, backs_anim_duration, CoroutineExtensions.easeInBackFunc), back_2.scaleTransform(back_2_scale_start, backs_anim_duration, CoroutineExtensions.easeInOutFunc), back_bug_report.moveTransform(back_bug_start, backs_anim_duration, CoroutineExtensions.easeInBackFunc));
		yield return 0.25f.wait();
		yield return base.closingMenuAnimation();
	}

	protected override void onMenuOpening()
	{
		base.onMenuOpening();
		GameHandler.State.run_stats.stopTimer();
		AudioHandler.instance.setGlobalParameter(GlobalParams.GAME_PAUSE, 1f);
		if (save_on_open)
		{
			GameHandler.instance.saveGame();
		}
		if (bug_reporter_menu != null)
		{
			bug_reporter_menu.setInputDevice();
		}
		abandandon_button.SetActive(GameHandler.State.current_lead.is_some || GameHandler.instance.current_scene == "LeadSelectionScene");
	}

	protected override void onMenuClosing()
	{
		base.onMenuClosing();
		AudioHandler.instance.setGlobalParameter(GlobalParams.GAME_PAUSE, 0f);
	}

	protected override void onMenuClosed()
	{
		base.onMenuClosed();
		GameHandler.State.run_stats.startTimer();
		if (select_on_close != null)
		{
			select_on_close.Select();
		}
	}

	protected override void unfocusMenu()
	{
		base.unfocusMenu();
		buttons_fade.run(button_group.fade(0f, 0.25f, CoroutineExtensions.easeInOutFunc));
	}

	protected override void refocusMenu()
	{
		base.refocusMenu();
		buttons_fade.run(button_group.fade(1f, 0.25f, CoroutineExtensions.easeInOutFunc));
	}

	public void onEscape(InputAction.CallbackContext _context)
	{
		if (_context.canceled)
		{
			onStartButton(delegate
			{
			});
		}
	}

	public void onStartButton(Action _callback)
	{
		if (base.is_open)
		{
			if (confirmation_menu.is_open)
			{
				confirmation_menu.closeMenu();
			}
			else
			{
				closeMenu();
			}
		}
		else if (!TransitionHandler.instance.is_transitioning && !veto_opening.Exists((MenuController _m) => _m.is_open || _m.current_state == MenuState.OPENING))
		{
			openMenu(_callback);
		}
	}

	public void checkAbandonRun()
	{
		openConfirmationMenu(confirmation_menu, localisation_asset.checkTranslation(loc_abandon_key, englishAbandon), abandonGame, confirmation_menu.closeMenu);
	}

	public void backToMainMenu()
	{
		openConfirmationMenu(confirmation_menu, localisation_asset.checkTranslation(loc_main_menu_exit_key, englishExitMain), leaveGame, confirmation_menu.closeMenu);
	}

	public void checkQuitGame()
	{
		openConfirmationMenu(confirmation_menu, localisation_asset.checkTranslation(loc_quit_key, englishQuit), quitToDesktop, confirmation_menu.closeMenu);
	}

	private string englishAbandon()
	{
		return "Are you sure you wish to abandon this run?";
	}

	private string englishExitMain()
	{
		return "Are you sure you wish to exit to the main menu?";
	}

	private string englishQuit()
	{
		return "Are you sure you wish to quit?";
	}

	public void openCodex(CodexMenu _codex)
	{
		openNewMenu(_codex);
		if (case_handler != null && case_handler.is_quick_case)
		{
			_codex.openRegionPage(case_handler.case_type.fromType());
			return;
		}
		Regions leadRegion = GameHandler.State.getLeadRegion();
		switch (leadRegion)
		{
		case Regions.SYNDICATE:
			_codex.openRegionPage(GameHandler.State.estimateSyndicateRegion());
			break;
		default:
			_codex.openRegionPage(leadRegion);
			break;
		case Regions.NONE:
			_codex.openRoleMenuPage(_open_codex: false);
			break;
		}
	}

	private void abandonGame()
	{
		GameHandler.instance.abandonRun();
		AudioHandler.instance.setGlobalParameter(GlobalParams.GAME_PAUSE, 0f);
	}

	private void leaveGame()
	{
		GameHandler.instance.saveGame(_save_stats: true);
		GameHandler.instance.moveToScene("MainMenuScene");
		AudioHandler.instance.setGlobalParameter(GlobalParams.GAME_PAUSE, 0f);
	}

	private void quitToDesktop()
	{
		GameHandler.instance.saveGame(_save_stats: true);
		quitGame();
	}
}
