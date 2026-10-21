using System.Collections.Generic;
using Audio;
using GRGLib.Coroutines;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Unity;
using GRGLib.Serializable;
using GRGLocalisation;
using Localisation;
using Save;
using TMPro;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;

namespace LevelEditor;

public class LESetUpMenu : MenuBase, IAmLocalised
{
	[SerializeField]
	private RegionsSO region_data;

	[Header("References")]
	[SerializeField]
	private PlayerInput player_input;

	[SerializeField]
	private TMP_Text board_size_text;

	[SerializeField]
	private TMP_Dropdown case_dropdown;

	[SerializeField]
	private Slider x_slider;

	[SerializeField]
	private TMP_Text x_slider_text;

	[SerializeField]
	private Slider y_slider;

	[SerializeField]
	private TMP_Text y_slider_text;

	[Header("Prefabs")]
	[SerializeField]
	private SerializableDictionary<CaseType, LevelEditorManager> editor_prefabs;

	[SerializeField]
	private CanvasGroup editor_group;

	private CaseType case_type;

	private Vector2Int board_size;

	private AssetKey localisation_asset => LocalisationHelper.ui_asset;

	private string loc_board_size_key => "LE_setup [size]";

	private void Start()
	{
		if (GameHandler.instance.level_editor_case.is_some)
		{
			Case value = GameHandler.instance.level_editor_case.value;
			Object.Instantiate(editor_prefabs[value.case_type], editor_group.transform).setUpFromCase(value, player_input);
			editor_group.putOn();
			Object.Destroy(base.gameObject);
		}
		else
		{
			setUp();
			AudioHandler.Atmo.playAtmo(Atmo.RAIN);
			AudioHandler.Music.playMusic(Music.E);
		}
	}

	public void setUp()
	{
		Dictionary<Regions, RegionProgressionSaveData> progressionUnserialized = SaveHandler.instance.meta_data.getProgressionUnserialized();
		List<string> list = region_data[Regions.OFFICE].region_name.makeListFromItem();
		if (progressionUnserialized.ContainsKey(Regions.CASINO) && progressionUnserialized[Regions.CASINO].tier > 0)
		{
			list.Add(region_data[Regions.CASINO].region_name);
		}
		if (progressionUnserialized.ContainsKey(Regions.DOCKS) && progressionUnserialized[Regions.DOCKS].tier > 0)
		{
			list.Add(region_data[Regions.DOCKS].region_name);
		}
		case_dropdown.ClearOptions();
		case_dropdown.AddOptions(list);
		onBSX(4f);
		onBSY(4f);
	}

	public void backButton()
	{
		GameHandler.instance.moveToScene("MainMenuScene");
	}

	public void startButton()
	{
		LevelEditorManager levelEditorManager = Object.Instantiate(editor_prefabs[case_type], editor_group.transform);
		levelEditorManager.setUp(case_type, board_size, player_input);
		editor_group.interactable = true;
		editor_group.blocksRaycasts = true;
		editor_group.fade(1f, 0.4f, CoroutineExtensions.easeInOutFunc).start(levelEditorManager);
		closeMenu();
	}

	public void onCaseType(int _option)
	{
		case_type = _option switch
		{
			0 => CaseType.CLOCK, 
			1 => CaseType.CASINO, 
			2 => CaseType.DOCKS, 
			_ => CaseType.CLOCK, 
		};
	}

	public void onBSX(float _x)
	{
		board_size.x = Mathf.RoundToInt(_x);
		x_slider_text.text = board_size.x.ToString();
		updateBoardSizeText();
	}

	public void onBSY(float _y)
	{
		board_size.y = Mathf.RoundToInt(_y);
		y_slider_text.text = board_size.y.ToString();
		updateBoardSizeText();
	}

	private void updateBoardSizeText()
	{
		board_size_text.text = localisation_asset.checkTranslationWithData(loc_board_size_key, englishBoardSize, $"{board_size.x}x{board_size.y}");
	}

	private string englishBoardSize(string _data)
	{
		return "Board Size: (" + _data + ")";
	}
}
