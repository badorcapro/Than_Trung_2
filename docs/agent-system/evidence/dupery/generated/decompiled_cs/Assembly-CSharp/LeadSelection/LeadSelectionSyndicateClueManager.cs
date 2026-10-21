using System.Collections.Generic;
using GRGLib.Extensions.Random;
using Lineup;
using UnityEngine;
using UnityEngine.UI;

namespace LeadSelection;

public class LeadSelectionSyndicateClueManager : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private RectTransform clue_marker_parent;

	[Header("Prefabs")]
	[SerializeField]
	private LeadSelectionClueMarker clue_marker_prefab;

	[SerializeField]
	private Image empty_marker_prefab;

	[Header("Settings")]
	[SerializeField]
	private List<Sprite> clue_icons;

	public void Start()
	{
		if (GameHandler.State.current_region != Regions.SYNDICATE)
		{
			return;
		}
		List<LineupClue> lineup_clues = GameHandler.State.lineup_clues;
		int num = RandomExtensions.freshRandom().Next(0, 3);
		for (int i = 0; i < 3; i++)
		{
			if (lineup_clues.Count > i)
			{
				Object.Instantiate(clue_marker_prefab, clue_marker_parent).setUp(lineup_clues[i], i + 1, clue_icons[(num + i) % clue_icons.Count]);
				continue;
			}
			Image image = Object.Instantiate(empty_marker_prefab, clue_marker_parent);
			image.sprite = clue_icons[(num + i) % clue_icons.Count];
			image.SetNativeSize();
		}
	}
}
