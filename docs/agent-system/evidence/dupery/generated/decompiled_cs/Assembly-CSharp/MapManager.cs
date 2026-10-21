using System.Collections.Generic;
using Codex;
using GRGLib.Coroutines;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using GRGLocalisation;
using Save;
using TMPro;
using UnityEngine;
using UnityEngine.InputSystem;

public class MapManager : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private MenuBase menu;

	[SerializeField]
	private PlayerInput input;

	[SerializeField]
	private CanvasGroup extensions_background;

	[SerializeField]
	private List<MapRegionPolaroid> region_polaroids;

	[SerializeField]
	private MapSyndicatePolaroid syndicate_polaroid;

	[SerializeField]
	private MapCustomPolaroid custom_polaroid;

	[SerializeField]
	private CodexMenu codex;

	[SerializeField]
	private TMP_Dropdown difficulty_dropdown;

	[SerializeField]
	private LocalisedStaticDropDown loc_diff;

	private bool set_up;

	private CoroutineRunner extensions_back_runner;

	private void Awake()
	{
		extensions_back_runner = new CoroutineRunner(this);
	}

	private void Start()
	{
	}

	public void saveFileChanged()
	{
		set_up = false;
	}

	public void setUpAndOpen(MenuBase _menu)
	{
		setUpMapPolaroids();
		_menu.openNewMenu(menu);
	}

	public void setUpMapPolaroids()
	{
		if (set_up)
		{
			return;
		}
		Dictionary<Regions, RegionProgressionSaveData> progressionUnserialized = SaveHandler.instance.meta_data.getProgressionUnserialized();
		foreach (MapRegionPolaroid region_polaroid in region_polaroids)
		{
			if (progressionUnserialized.ContainsKey(region_polaroid.polaroid_region))
			{
				region_polaroid.setUpPolaroid(progressionUnserialized[region_polaroid.polaroid_region], startRegion, checkRegion, quickCase, replayTutorial, setRegionTier);
			}
			else
			{
				region_polaroid.setUpPolaroidUndiscovered();
			}
			region_polaroid.onControlsChanged(input);
		}
		syndicate_polaroid.setUp(startRegion);
		syndicate_polaroid.onControlsChanged(input);
		custom_polaroid.setUp(progressionUnserialized.getOrDefault(Regions.OFFICE, new RegionProgressionSaveData(0, 0)).tier >= 2);
		custom_polaroid.onControlsChanged(input);
		difficulty_dropdown.SetValueWithoutNotify((int)(GameHandler.MetaData.difficulty + 1));
		set_up = true;
	}

	private void startRegion(Regions _region)
	{
		RegionProgressionSaveData regionProgressionSaveData = SaveHandler.instance.meta_data.region_progression[_region];
		bool flag = _region != Regions.SYNDICATE && !GameHandler.StatsData.playedTutorial(_region.getTutorialType().toTutorial());
		Debug.Log(string.Format("Starting region {0}! (Tier {1}{2})", _region, regionProgressionSaveData.using_tier, flag ? ", tutorial" : ""));
		GameHandler.instance.startNewGame(_region, flag ? _region.getTutorialType().maybe() : new Maybe<CaseType>());
		if (flag)
		{
			GameHandler.instance.moveToScene("GameScene");
		}
		else
		{
			GameHandler.instance.moveToScene("LevelTransitionScene");
		}
	}

	private void checkRegion(Regions _region)
	{
		codex.openRegionPage(_region);
		menu.openNewMenu(codex);
	}

	private void quickCase(Regions _region)
	{
		GameHandler.State.setIgnoreSave();
		GameHandler.instance.setQuickCase(_region);
		GameHandler.instance.moveToScene("GameScene");
	}

	private void replayTutorial(Regions _region)
	{
		GameHandler.instance.startNewGame(_region, _region.fromRegion().maybe());
		GameHandler.State.setIsTutorialReplay();
		GameHandler.instance.moveToScene("GameScene");
	}

	private (int, bool) setRegionTier(Regions _region, int _tier)
	{
		GameHandler.MetaData.setTierOfRegion(_region, _tier);
		return (GameHandler.MetaData.getTierOfRegion(_region), GameHandler.MetaData.isRegionUsingCustomTier(_region));
	}

	public void onExtensionsOpen(MapPolaroid _polaroid)
	{
		extensions_background.transform.SetAsLastSibling();
		_polaroid.transform.SetAsLastSibling();
		extensions_back_runner.run(extensions_background.fade(1f, 0.45f));
	}

	public void onExtensionsClose(MapPolaroid _polaroid)
	{
		extensions_back_runner.run(extensions_background.fade(0f, 0.25f));
	}

	public void onDifficultyChange(int _option)
	{
		GameHandler.MetaData.difficulty = (GameMetaData.Difficulty)(_option - 1);
	}

	public void onControlsChanged(PlayerInput _input)
	{
		region_polaroids.ForEach(delegate(MapRegionPolaroid _p)
		{
			_p.onControlsChanged(_input);
		});
		syndicate_polaroid.onControlsChanged(input);
		custom_polaroid.onControlsChanged(input);
		menu.onControlsChange(_input.currentControlScheme);
	}

	public void onControllerSouth(InputAction.CallbackContext _context)
	{
		if (menu.is_open && !menu.is_unfocused && set_up)
		{
			region_polaroids.ForEach(delegate(MapRegionPolaroid _p)
			{
				_p.onControllerSouth(_context);
			});
			syndicate_polaroid.onControllerSouth(_context);
			custom_polaroid.onControllerSouth(_context);
		}
	}

	public void onControllerWest(InputAction.CallbackContext _context)
	{
		if (menu.is_open && !menu.is_unfocused && set_up)
		{
			region_polaroids.ForEach(delegate(MapRegionPolaroid _p)
			{
				_p.onControllerWest(_context);
			});
			syndicate_polaroid.onControllerWest(_context);
			custom_polaroid.onControllerWest(_context);
		}
	}

	public void onControllerNorth(InputAction.CallbackContext _context)
	{
		if (menu.is_open && !menu.is_unfocused && set_up)
		{
			region_polaroids.ForEach(delegate(MapRegionPolaroid _p)
			{
				_p.onControllerNorth(_context);
			});
			syndicate_polaroid.onControllerNorth(_context);
			custom_polaroid.onControllerNorth(_context);
		}
	}

	public void onControllerEast(InputAction.CallbackContext _context)
	{
		if (menu.is_open && !menu.is_unfocused && set_up && _context.canceled)
		{
			menu.Cancel();
		}
	}

	public void onControllerSelect(InputAction.CallbackContext _context)
	{
		if (menu.is_open && !menu.is_unfocused && set_up)
		{
			region_polaroids.ForEach(delegate(MapRegionPolaroid _p)
			{
				_p.onControllerSelect(_context);
			});
			syndicate_polaroid.onControllerSelect(_context);
			custom_polaroid.onControllerSelect(_context);
		}
	}
}
