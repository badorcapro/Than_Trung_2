using System;
using Audio;
using GRGLib.Extensions.Random;
using GRGLib.Menus;
using GRGLib.Serializable;
using Nodes;
using TMPro;
using UnityEngine;
using UnityEngine.UI;
using Visual;

namespace TransitionScene;

public class TransitionSceneHandler : MonoBehaviour
{
	[Serializable]
	public struct TransitionRegionSettings
	{
		public TransitionSceneDecor decor;

		public StoryNodeGraph story_graph;

		public Music music;
	}

	[SerializeField]
	private RegionsSO region_settings;

	[Header("References")]
	[SerializeField]
	private RectTransform decor_parent;

	[SerializeField]
	private TextBox text_box;

	[SerializeField]
	private Button continue_button;

	[SerializeField]
	private MenuController choice_button_menu;

	[SerializeField]
	private Button left_button;

	[SerializeField]
	private TMP_Text left_button_text;

	[SerializeField]
	private TMP_Text right_button_text;

	[Header("Prefabs")]
	[SerializeField]
	private SerializableDictionary<Regions, TransitionRegionSettings> region_decors;

	[Header("Settings")]
	[SerializeField]
	private StoryNodeGraph template_graph;

	private TransitionSceneDecor decor;

	private StoryNodeGraph story_graph;

	private StoryGraphNavigator graph_navigator;

	private System.Random random;

	private bool moving_on;

	private bool story_end;

	private void Start()
	{
		random = RandomExtensions.freshRandom();
		TransitionRegionSettings transitionRegionSettings = (region_decors.ContainsKey(GameHandler.State.current_region) ? region_decors[GameHandler.State.current_region] : region_decors[Regions.OFFICE]);
		decor = UnityEngine.Object.Instantiate(transitionRegionSettings.decor, decor_parent);
		decor.setUp();
		story_graph = transitionRegionSettings.story_graph;
		GameHandler.instance.saveGame();
		graph_navigator = new StoryGraphNavigator(this, random, text_box, decor, onGraphEnd);
		story_graph.fetchStartNode().progress(graph_navigator);
		continue_button.Select();
		AudioHandler.Atmo.stopAllAtmoAndStart(Atmo.RAIN_WINDOW);
		AudioHandler.Music.playMusic(transitionRegionSettings.music);
	}

	public void onClickButton(int _option)
	{
		if (!story_end)
		{
			graph_navigator.onClick();
		}
	}

	private void onGraphEnd()
	{
		story_end = true;
		tryMoveOn();
	}

	private void tryMoveOn()
	{
		if (story_end && !moving_on)
		{
			moving_on = true;
			GameHandler.instance.moveToSceneWhenPossible("LeadSelectionScene");
		}
	}
}
