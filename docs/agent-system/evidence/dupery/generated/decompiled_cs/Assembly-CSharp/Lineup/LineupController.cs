using System;
using System.Collections;
using System.Collections.Generic;
using Audio;
using GRGLib.Coroutines;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Random;
using GRGLib.Extensions.String;
using GRGLocalisation;
using Localisation;
using Save;
using TMPro;
using UnityEngine;

namespace Lineup;

public class LineupController : MonoBehaviour, IAmLocalised
{
	[Header("References")]
	[SerializeField]
	private TMP_Text clipboard_text;

	[SerializeField]
	private TMP_Text top_text;

	[SerializeField]
	private DialogueBox top_box;

	[SerializeField]
	private RectTransform suspect_parent_transform;

	[SerializeField]
	private RectTransform suspect_parent_wobble_transform;

	[SerializeField]
	private RectTransform clipboard_transform;

	[SerializeField]
	private RectTransform clipboard_wobble_transform;

	[SerializeField]
	private RectTransform blame_transform;

	[SerializeField]
	private RectTransform gun_transform;

	[SerializeField]
	private RectTransform hard_cut_transform;

	[SerializeField]
	private LineupArrow left_arrow;

	[SerializeField]
	private LineupArrow right_arrow;

	[Header("Prefabs")]
	[SerializeField]
	private LineupSuspect suspect_prefab;

	[Header("Settings")]
	[SerializeField]
	private float distance_between_suspects = 1500f;

	[SerializeField]
	[Range(3f, 10f)]
	private int number_suspects = 8;

	[SerializeField]
	[Range(0f, 5f)]
	private int all_wrong_suspects = 2;

	[SerializeField]
	[Range(0f, 5f)]
	private int partially_true_suspects = 2;

	private System.Random random;

	private List<LineupSuspect> suspects = new List<LineupSuspect>();

	private LineupSuspectInfo mastermind_info;

	private int current_selected_suspect;

	private int correct_mastermind;

	private bool has_blamed;

	private CoroutineRunner move_to_runner;

	private string loc_clipboard_key => "Lineup [clip]";

	private string loc_title_key => "Lineup [title]";

	private string loc_convict_key => "Lineup [blame]";

	private AssetKey localisation_asset => LocalisationHelper.lineup_asset;

	private void Awake()
	{
		move_to_runner = new CoroutineRunner(this);
		random = RandomExtensions.freshRandom();
	}

	private void Start()
	{
		List<LineupClue> lineup_clues = GameHandler.State.lineup_clues;
		mastermind_info = new LineupSuspectInfo(random, lineup_clues, LineupSuspectInfo.ClueConformType.CONFORM_ALL);
		clipboard_text.text = localisation_asset.checkTranslation(loc_clipboard_key, englishCliboard).bold().sizeRelative(125);
		foreach (LineupClue item in lineup_clues)
		{
			TMP_Text tMP_Text = clipboard_text;
			tMP_Text.text = tMP_Text.text + "\n\n" + item.clue_text;
		}
		correct_mastermind = random.Next(0, number_suspects);
		List<int> completely_wrong = new List<int>().addUntil(0, number_suspects, _inclusive_end: false).remove(correct_mastermind).getRandomElementsFromList(random, Mathf.Min(all_wrong_suspects, number_suspects - 1));
		List<int> randomElementsFromList = new List<int>().addUntil(0, number_suspects, _inclusive_end: false).removeAll((int _i) => _i == correct_mastermind || completely_wrong.Contains(_i)).getRandomElementsFromList(random, Mathf.Min(partially_true_suspects, number_suspects - 1 - all_wrong_suspects));
		int num = random.Next(0, 990);
		for (int i = 0; i < number_suspects; i++)
		{
			if (i == correct_mastermind)
			{
				createAndConfigureSuspect(mastermind_info, num + i);
				continue;
			}
			LineupSuspectInfo.ClueConformType conform = (completely_wrong.Contains(i) ? LineupSuspectInfo.ClueConformType.CONFORM_NONE : (randomElementsFromList.Contains(i) ? LineupSuspectInfo.ClueConformType.CONFORM_SOME : LineupSuspectInfo.ClueConformType.RANDOM_NOT_ALL));
			createAndConfigureSuspect(new LineupSuspectInfo(random, lineup_clues, conform), num + i);
		}
		suspects.ForEach(delegate(LineupSuspect _e)
		{
			_e.setFadeColour(1f);
		});
		move_to_runner.runIfNot(moveToSuspectIntro());
		AudioHandler.Music.playMusic(Music.F, new List<(string, float)>(), 0f, 1f);
	}

	private void createAndConfigureSuspect(LineupSuspectInfo _clue, int _suspect_number)
	{
		LineupSuspect lineupSuspect = UnityEngine.Object.Instantiate(suspect_prefab, suspect_parent_transform);
		lineupSuspect.transform.localPosition = new Vector3(distance_between_suspects * (float)suspects.Count, lineupSuspect.transform.localPosition.y);
		lineupSuspect.createSuspect(_clue, _suspect_number);
		suspects.Add(lineupSuspect);
	}

	public void nextSuspect(bool _right)
	{
		if (!move_to_runner.is_running && !has_blamed)
		{
			int old = current_selected_suspect;
			current_selected_suspect += (_right ? 1 : (-1));
			if (current_selected_suspect < 0)
			{
				current_selected_suspect = 0;
			}
			if (current_selected_suspect > 7)
			{
				current_selected_suspect = 7;
			}
			left_arrow.gameObject.SetActive(current_selected_suspect != 0);
			right_arrow.gameObject.SetActive(current_selected_suspect != 7);
			move_to_runner.runIfNot(moveToSuspect(current_selected_suspect, old));
			AudioHandler.Sfx.playSfx(Sfx.LINEUP_MOVE);
		}
	}

	private IEnumerator jiggleClipboard(bool _right)
	{
		clipboard_transform.rotateTransformSmart(_right ? (-5) : 5, 0.2f, CoroutineExtensions.easeInOutFunc).start(this);
		yield return clipboard_transform.anchoredMove(new Vector3(-377.7195f + (float)(_right ? 100 : (-100)), clipboard_transform.anchoredPosition.y), 0.2f, CoroutineExtensions.easeInOutFunc);
		clipboard_transform.rotateTransformSmart(0f, 0.2f, CoroutineExtensions.easeInOutFunc).start(this);
		yield return clipboard_transform.anchoredMove(new Vector3(-377.7195f, clipboard_transform.anchoredPosition.y), 0.2f, CoroutineExtensions.easeInOutFunc);
		clipboard_transform.rotateTransformSmart(_right ? (-5) : 5, 0.2f, CoroutineExtensions.easeInOutFunc).start(this);
		yield return clipboard_transform.anchoredMove(new Vector3(-377.7195f + (float)(_right ? 100 : (-100)), clipboard_transform.anchoredPosition.y), 0.2f, CoroutineExtensions.easeInOutFunc);
		clipboard_transform.rotateTransformSmart(0f, 0.2f, CoroutineExtensions.easeInOutFunc).start(this);
		yield return clipboard_transform.anchoredMove(new Vector3(-377.7195f, clipboard_transform.anchoredPosition.y), 0.2f, CoroutineExtensions.easeInOutFunc);
	}

	private IEnumerator moveToSuspect(int _index, int _old)
	{
		suspect_parent_transform.anchoredMove(new Vector3((float)_index * (0f - distance_between_suspects), 0f, 0f), 1f, CoroutineExtensions.easeInOutFunc).start(this);
		moveShadow(suspects[_index], new Vector2(100f, -20f)).start(this);
		moveShadow(suspects[_old], new Vector2(0f, 0f)).start(this);
		fadeCharacter(suspects[_index], _to_black: false).start(this);
		fadeCharacter(suspects[_old], _to_black: true).start(this);
		jiggleClipboard(_index > _old).start(this);
		yield return suspect_parent_wobble_transform.anchoredMove(new Vector3(0f, 20f, 0f), 0.25f, CoroutineExtensions.easeInOutFunc);
		yield return suspect_parent_wobble_transform.anchoredMove(new Vector3(0f, 0f, 0f), 0.25f, CoroutineExtensions.easeInOutFunc);
		yield return suspect_parent_wobble_transform.anchoredMove(new Vector3(0f, 20f, 0f), 0.25f, CoroutineExtensions.easeInOutFunc);
		yield return suspect_parent_wobble_transform.anchoredMove(new Vector3(0f, 0f, 0f), 0.25f, CoroutineExtensions.easeInOutFunc);
	}

	private IEnumerator moveToSuspectIntro()
	{
		top_text.text = "";
		clipboard_wobble_transform.anchoredMove(new Vector3(-1354.73f, 0f, 0f), 1f, CoroutineExtensions.easeInOutFunc).start(this);
		clipboard_transform.anchoredMove(new Vector3(-377.7195f, -1400.5f, 0f), 1.2f, CoroutineExtensions.easeInOutFunc).start(this);
		top_box.writeDialogue(localisation_asset.checkTranslation(loc_title_key, englishTitle).animateLink(TextAnimationType.LINEUP_TITLE_WIGGLE));
		while (top_box.is_writing)
		{
			yield return null;
		}
		yield return 1f.wait();
		jiggleClipboard(_right: false).start(this);
		suspect_parent_transform.anchoredMove(new Vector3(0f, 0f, 0f), 2f, CoroutineExtensions.easeOutFunc).start(this);
		moveShadow(suspects[0], new Vector2(100f, -20f)).start(this);
		fadeCharacter(suspects[0], _to_black: false).start(this);
		yield return suspect_parent_wobble_transform.anchoredMove(new Vector3(0f, 20f, 0f), 0.5f, CoroutineExtensions.easeInOutFunc);
		yield return suspect_parent_wobble_transform.anchoredMove(new Vector3(0f, 0f, 0f), 0.5f, CoroutineExtensions.easeInOutFunc);
		yield return suspect_parent_wobble_transform.anchoredMove(new Vector3(0f, 20f, 0f), 0.5f, CoroutineExtensions.easeInOutFunc);
		yield return suspect_parent_wobble_transform.anchoredMove(new Vector3(0f, 0f, 0f), 0.5f, CoroutineExtensions.easeInOutFunc);
		right_arrow.gameObject.SetActive(value: true);
		blame_transform.anchoredMove(new Vector3(1007f, -16f, 0f), 1f, CoroutineExtensions.easeInOutFunc).start(this);
		yield return 0.15f.wait();
	}

	private IEnumerator moveShadow(LineupSuspect _sus, Vector2 _new_loc)
	{
		yield return _sus.shadow.GetComponent<RectTransform>().anchoredMove(new Vector2(_new_loc.x, _new_loc.y), 1f);
	}

	private IEnumerator fadeCharacter(LineupSuspect _sus, bool _to_black)
	{
		float e_time = 0f;
		float duration = 1f;
		while (e_time <= duration)
		{
			_sus.setFadeColour(Mathf.Lerp((!_to_black) ? 1 : 0, _to_black ? 1 : 0, e_time / duration));
			e_time += Time.deltaTime;
			yield return null;
		}
	}

	public void onBlame()
	{
		has_blamed = true;
		blame_transform.gameObject.SetActive(value: false);
		bool first_success = false;
		if (current_selected_suspect == correct_mastermind)
		{
			first_success = GameHandler.MetaData.getProgressionUnserialized().getOrCreate(Regions.SYNDICATE, () => new RegionProgressionSaveData(1, 0)).runs_succeeded < 1;
			GameHandler.instance.finishRunSuccess();
		}
		else
		{
			GameHandler.instance.runLost();
		}
		gunMove(first_success).start(this);
	}

	private IEnumerator gunMove(bool _first_success)
	{
		yield return gun_transform.anchoredMove(new Vector3(1395f, -612f), 2f, CoroutineExtensions.easeInOutBackFunc);
		yield return 0.5f.wait();
		AudioHandler.Sfx.playSfx(Sfx.GUNSHOT);
		yield return 0.1f.wait();
		AudioHandler.Music.stopMusic(_allow_fadeout: false);
		AudioHandler.Atmo.stopAllAtmo();
		hard_cut_transform.gameObject.SetActive(value: true);
		GameHandler.instance.moveToScene(_first_success ? "CreditsScene" : "SummaryScene");
	}

	public string getConvictString()
	{
		return localisation_asset.checkTranslation(loc_convict_key, englishConvict);
	}

	private string englishTitle()
	{
		return "Find the Syndicate Leader";
	}

	private string englishCliboard()
	{
		return "MASTERMIND CLUES:";
	}

	private string englishConvict()
	{
		return "Convict Suspect";
	}
}
