using System;
using System.Collections;
using System.Collections.Generic;
using GRGLib.Coroutines;
using GRGLib.Extensions.String;
using GRGLib.Maybe;
using GRGLocalisation;
using Localisation;
using TMPro;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;

namespace Visual;

public class CaseEndVisualManager : MenuBase, IAmLocalised
{
	[Header("Case End References")]
	[SerializeField]
	private CaseHandler case_handler;

	[SerializeField]
	private CanvasGroup button_group;

	[SerializeField]
	private TMP_Text case_end_title_text;

	[SerializeField]
	private TMP_Text case_end_text;

	[SerializeField]
	private TMP_Text continue_button_text;

	[SerializeField]
	private Button continue_button;

	[SerializeField]
	private Button exit_button;

	[Header("Settings")]
	[SerializeField]
	private Material english_loss_mat;

	[SerializeField]
	private Material other_loss_mat;

	[Header("Animation Settings")]
	[SerializeField]
	private RectTransform back_1;

	[SerializeField]
	private RectTransform back_2;

	[SerializeField]
	private Vector2 back_1_start;

	[SerializeField]
	private Vector2 back_2_scale_start = new Vector2(-1.1f, 1.1f);

	[SerializeField]
	private float backs_anim_duration;

	[Header("Callbacks")]
	[SerializeField]
	private UnityEvent post_solve;

	private RectTransform board_trans;

	private List<Button> reopen_buttons;

	private CoroutineRunner hide_runner;

	private CoroutineRunner buttons_fade;

	private MultiCoroutineRunner menuing_extra_runner;

	private MultiCoroutineRunner scene_movement_runner;

	private bool unique_level;

	private bool hidden;

	private bool solved;

	private bool tutorial;

	private const string loc_case_solve = "case_solve [name]";

	private const string loc_case_solve_time = "case_solve [time]";

	private const string loc_case_solve_boat = "case_solve [boat]";

	private const string loc_case_solve_boat_none = "case_solve [boat_none]";

	private const string loc_case_solve_boat_all = "case_solve [boat_all]";

	private const string loc_case_solve_chips = "case_solve [chips]";

	private const string loc_case_fail = "case_fail";

	private const string loc_case_lost_no_fuel = "case_fail [no_fuel]";

	private const string loc_continue = "continue";

	private const string loc_try_again = "try_again";

	private const string loc_back_to_editor = "back_to_editor";

	private const string loc_exit = "exit";

	private const string loc_one_more = "One More";

	private const string loc_replace = "{1}";

	private const string loc_replace_2 = "{2}";

	public bool is_open_and_visible
	{
		get
		{
			if (base.is_open)
			{
				return !hidden;
			}
			return false;
		}
	}

	protected override void Awake()
	{
		base.Awake();
		hide_runner = new CoroutineRunner(this);
		buttons_fade = new CoroutineRunner(this);
		menuing_extra_runner = new MultiCoroutineRunner(this);
		scene_movement_runner = new MultiCoroutineRunner(this);
	}

	public void setUp(RectTransform _board_visuals, List<Button> _reopen_buttons)
	{
		board_trans = _board_visuals;
		reopen_buttons = _reopen_buttons;
		reopen_buttons.ForEach(delegate(Button _b)
		{
			_b.onClick.AddListener(fadeIn);
		});
	}

	public void onCaseEnd(bool _tutorial, bool _solved, CaseSnapshot _last_snap)
	{
		unique_level = GameHandler.instance.level_editor_case.is_some;
		tutorial = _tutorial;
		solved = _solved;
		case_end_title_text.text = (_solved ? (getText("case_solve [name]") ?? "") : (getText("case_fail") ?? ""));
		case_end_text.text = getExtraCommentFromPayload(_last_snap, _solved, _tutorial);
		continue_button_text.text = getContinueButtonText(_tutorial, _solved);
		if (!_solved && !unique_level && !case_handler.is_quick_case)
		{
			continue_button.gameObject.SetActive(value: false);
		}
		openMenu();
		exit_button.gameObject.SetActive(case_handler.is_quick_case);
		if (!_solved)
		{
			case_end_title_text.color = Color.black;
			case_end_title_text.fontStyle = FontStyles.Bold;
			if (GRGLocalisationHandler.instance.current_language == Languages.ENGLISH)
			{
				case_end_title_text.fontMaterial = english_loss_mat;
			}
			else
			{
				case_end_title_text.fontMaterial = other_loss_mat;
			}
			case_end_title_text.ForceMeshUpdate();
		}
	}

	private string getContinueButtonText(bool _tutorial, bool _solved)
	{
		if (unique_level)
		{
			return getText("back_to_editor");
		}
		if (case_handler.is_quick_case)
		{
			return getText("One More");
		}
		if (_solved)
		{
			return getText("continue");
		}
		if (_tutorial)
		{
			return getText("try_again");
		}
		return getText("exit");
	}

	private string getExtraCommentFromPayload(CaseSnapshot _last_snap, bool _solved, bool _tutorial)
	{
		if (_solved && _last_snap.payload is ClockCaseActionPayload clockCaseActionPayload)
		{
			return getText("case_solve [time]").Replace("{1}", clockCaseActionPayload.hour_passed.ToString());
		}
		if (_last_snap is DocksCaseSnapshot docksCaseSnapshot)
		{
			if (_solved)
			{
				if (docksCaseSnapshot.docks_payload.correct_arrests == 0)
				{
					return getText("case_solve [boat_none]");
				}
				int count = docksCaseSnapshot.board.getAllNotArrestedOrDeadEvil().Count;
				if (count > 0)
				{
					return getText("case_solve [boat]").Replace("{1}", docksCaseSnapshot.docks_payload.correct_arrests.ToString()).Replace("{2}", count.ToString()).sizeRelative(65);
				}
				return getText("case_solve [boat_all]");
			}
			if (docksCaseSnapshot.docks_payload.boat.fuel == 0)
			{
				return getText("case_fail [no_fuel]");
			}
		}
		if (_solved && _last_snap.payload is CasinoCaseActionPayload casinoCaseActionPayload)
		{
			return getText("case_solve [chips]").Replace("{1}", casinoCaseActionPayload.chips.ToString());
		}
		return "";
	}

	protected override IEnumerator openingMenuAnimation()
	{
		menuing_extra_runner.run(back_1.moveTransform(Vector3.zero, backs_anim_duration, CoroutineExtensions.easeOutBackFunc), back_2.scaleTransform(new Vector2(-1f, 1f), backs_anim_duration, CoroutineExtensions.easeInOutFunc));
		scene_movement_runner.run(board_trans.moveTransform(new Vector3(-550f, 0f, 0f), backs_anim_duration, CoroutineExtensions.easeInOutFunc), board_trans.scaleTransform(0.95f, backs_anim_duration, CoroutineExtensions.easeInOutFunc));
		buttons_fade.run(button_group.fade(1f, 0.25f, CoroutineExtensions.easeInOutFunc));
		return base.openingMenuAnimation();
	}

	protected override IEnumerator closingMenuAnimation()
	{
		menuing_extra_runner.run(back_1.moveTransform(back_1_start, backs_anim_duration, CoroutineExtensions.easeInBackFunc), back_2.scaleTransform(back_2_scale_start, backs_anim_duration, CoroutineExtensions.easeInOutFunc));
		scene_movement_runner.run(board_trans.moveTransform(new Vector3(0f, 0f, 0f), backs_anim_duration, CoroutineExtensions.easeInOutFunc), board_trans.scaleTransform(1f, backs_anim_duration, CoroutineExtensions.easeInOutFunc));
		buttons_fade.run(button_group.fade(0f, 0.25f, CoroutineExtensions.easeInOutFunc));
		yield return 0.25f.wait();
		yield return base.closingMenuAnimation();
	}

	public void hide()
	{
		if (hidden)
		{
			fadeIn();
			return;
		}
		hidden = true;
		hide_runner.run(closingMenuAnimation().addCallback(delegate
		{
			menu_group.blocksRaycasts = false;
		}));
		reopen_buttons.ForEach(delegate(Button _button)
		{
			_button.gameObject.SetActive(value: true);
		});
	}

	public void fadeIn()
	{
		continue_button.gameObject.SetActive(value: true);
		hide_runner.run(openingMenuAnimation());
		reopen_buttons.ForEach(delegate(Button _button)
		{
			_button.gameObject.SetActive(value: false);
		});
		menu_group.blocksRaycasts = true;
		hidden = false;
	}

	protected override void onMenuClosing()
	{
		base.onMenuClosing();
		hide_runner.stop();
	}

	protected override void onMenuOpening()
	{
		base.onMenuOpening();
		hide_runner.stop();
	}

	protected override void onMenuOpen()
	{
		base.onMenuOpen();
		Maybe<ClueObtainedMenu> maybe = case_handler.checkForSyndicateClue(solved);
		if (maybe.is_some)
		{
			openNewMenu(maybe.value);
		}
	}

	public void onContinue()
	{
		if (hidden)
		{
			fadeIn();
		}
		else if (unique_level)
		{
			post_solve.Invoke();
		}
		else if (case_handler.is_quick_case)
		{
			GameHandler.instance.setQuickCase(case_handler.case_type.fromType());
			GameHandler.instance.moveToScene("GameScene");
		}
		else if (!solved)
		{
			if (tutorial)
			{
				GameHandler.instance.moveToScene("GameScene");
			}
			else
			{
				onFailExit();
			}
		}
		else
		{
			post_solve.Invoke();
		}
	}

	public void onFailExit()
	{
		if (hidden)
		{
			fadeIn();
		}
		else
		{
			GameHandler.instance.runLostExit();
		}
	}

	public void onQuickCaseExit()
	{
		GameHandler.instance.moveToScene("MainMenuScene");
	}

	private string getText(string _key)
	{
		if (GRGLocalisationHandler.needs_translation)
		{
			string _result = "";
			if (GRGLocalisationHandler.instance.translate(LocalisationHelper.ui_asset, _key, out _result))
			{
				return _result;
			}
		}
		return getEnglishVersion(_key);
	}

	private string getEnglishVersion(string _key)
	{
		return _key switch
		{
			"case_solve [name]" => "Case Solved!", 
			"case_solve [time]" => "In {1} hours.", 
			"case_solve [boat]" => "You arrested {1} evil. But you let {2} evil escape!", 
			"case_solve [boat_none]" => "You failed to arrest any evil role!", 
			"case_solve [boat_all]" => "You arrested all evil roles!", 
			"case_fail [no_fuel]" => "You run out of fuel!", 
			"case_solve [chips]" => "With {1} chips remaining!", 
			"case_fail" => "You're Fired!", 
			"continue" => "Continue", 
			"back_to_editor" => "Back to Editor", 
			"try_again" => "Try Again", 
			"exit" => "Exit", 
			"One More" => "One More", 
			_ => throw new ArgumentException("No english version set up for key " + _key), 
		};
	}
}
