using Audio;
using GRGLib.Extensions.Unity;
using GRGLib.Maybe;
using GRGLocalisation;
using Localisation;
using Save;
using Tutorial;
using UnityEngine;
using UnityEngine.UI;

namespace MainMenu;

public class MainMenu : MenuBase, IAmLocalised
{
	[SerializeField]
	private RegionsSO regions_data;

	[Header("References")]
	[SerializeField]
	private RectTransform title_rect;

	[SerializeField]
	private VerticalLayoutGroup buttons_vert_layout;

	[SerializeField]
	private Button continue_button;

	[SerializeField]
	private Button stats_button;

	[SerializeField]
	private ConfirmationMenu confirmation_menu;

	[SerializeField]
	private MultiConfirmationMenu multi_confirmation_menu;

	[SerializeField]
	private Button new_game_button;

	[SerializeField]
	private MapManager map;

	[Header("Special Localisation Settings")]
	[SerializeField]
	private Image community_button_image;

	[SerializeField]
	private Sprite discord_icon;

	[SerializeField]
	private Sprite qq_icon;

	protected override Selectable select_device_change
	{
		get
		{
			if (!continue_button.gameObject.activeSelf)
			{
				return new_game_button;
			}
			return continue_button;
		}
	}

	private AssetKey localisation_asset => LocalisationHelper.ui_asset;

	private string loc_conf_quit_key => "MainMenu [quit]";

	private string loc_conf_overwrite_key => "MainMenu [overwrite]";

	private string loc_conf_title_key => "MultiConfirm [title]";

	private string loc_conf_standard_key => "MultiConfirm [standard]";

	private string loc_conf_quirk_key => "MultiConfirm [quirk]";

	private string loc_conf_tuto_key => "MultiConfirm [tuto]";

	private void Start()
	{
		checkSaveReliantUI();
		AudioHandler.Atmo.stopAllAtmoAndStart(Atmo.RAIN);
		AudioHandler.Music.playMusic(Music.A_MT);
		community_button_image.sprite = ((GRGLocalisationHandler.instance.current_language == Languages.CHINESE_SIMPLIFIED) ? qq_icon : discord_icon);
		community_button_image.sizeToFit();
		if (input.isUsingGamepad())
		{
			select_device_change.Select();
		}
	}

	public void checkSaveReliantUI()
	{
		bool save_file_exists = SaveHandler.instance.doesValidGameSaveFileExist();
		checkButtonLayout(save_file_exists);
		stats_button.interactable = SaveHandler.instance.doesStatsSaveFileExist();
		map.saveFileChanged();
	}

	private void checkButtonLayout(bool _save_file_exists)
	{
		buttons_vert_layout.spacing = (_save_file_exists ? 65 : 100);
		continue_button.gameObject.SetActive(_save_file_exists);
		continue_button.interactable = _save_file_exists;
	}

	public void continueGame()
	{
		GameHandler.instance.continueGame();
	}

	public void startNewGame()
	{
		if (SaveHandler.instance.doesGameSaveFileExist())
		{
			openConfirmationMenu(confirmation_menu, localisation_asset.checkTranslation(loc_conf_overwrite_key, englishConfirmOverwrite), delegate
			{
				GameHandler.instance.abandonRun(_move_scene: false);
				SaveHandler.instance.deleteSave();
				should_refocus_on_confirmation_close = false;
				checkButtonLayout(_save_file_exists: false);
				confirmation_menu.closeMenu();
				startNewGame();
			}, delegate
			{
				should_refocus_on_confirmation_close = true;
				confirmation_menu.closeMenu();
			});
		}
		else if (!GameHandler.StatsData.tutorials_played.Contains(Tutorials.OFFICE_MAIN) && !GameHandler.MetaData.intro_cutscene_played)
		{
			GameHandler.instance.startNewGame(Regions.OFFICE, CaseType.CLOCK.maybe());
			GameHandler.instance.moveToSceneWhenPossible("IntroCutscene");
		}
		else
		{
			map.setUpAndOpen(this);
		}
	}

	public void checkQuitGame()
	{
		openConfirmationMenu(confirmation_menu, localisation_asset.checkTranslation(loc_conf_quit_key, englishConfirmQuit), base.quitGame, confirmation_menu.closeMenu);
	}

	public void openUrl(string _url)
	{
		_url.openUrl();
	}

	public void openCommunityLink()
	{
		if (GRGLocalisationHandler.instance.current_language == Languages.CHINESE_SIMPLIFIED)
		{
			"https://qm.qq.com/q/holtUCsdNK".openUrl();
		}
		else
		{
			"https://discord.gg/6gD6UJCMbt".openUrl();
		}
	}

	public void openCredits()
	{
		GameHandler.instance.playCreditsFromMainMenu();
	}

	private void startDemoRegion(Regions _region)
	{
		GameHandler.instance.moveToScene("LevelTransitionScene");
	}

	private void replayTutorial()
	{
		GameHandler.instance.startNewGame(Regions.DEMO, CaseType.CLOCK.maybe());
		GameHandler.State.setIsTutorialReplay();
		GameHandler.instance.moveToScene("GameScene");
	}

	private string englishConfirmQuit()
	{
		return "Are you sure you wish to quit?";
	}

	private string englishConfirmOverwrite()
	{
		return "Starting a new game will abandon your current run, are you sure you wish to proceed?";
	}

	private string englishConfirmTitle()
	{
		return "Select Difficulty";
	}

	private string englishConfirmStandard()
	{
		return "Standard";
	}

	private string englishConfirmQuirk(string _data)
	{
		return "Challenge " + _data;
	}

	private string englishConfirmTutorial()
	{
		return "Replay Tutorial";
	}
}
