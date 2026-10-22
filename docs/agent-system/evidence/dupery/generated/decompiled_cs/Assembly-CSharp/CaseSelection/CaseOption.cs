using System;
using System.Collections.Generic;
using System.Linq;
using Audio;
using GRGLib.Coroutines;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Random;
using GRGLib.Extensions.String;
using GRGLib.UI;
using GRGLocalisation;
using Localisation;
using Quirks;
using TMPro;
using UnityEngine;
using UnityEngine.UI;
using Visual;

namespace CaseSelection;

public class CaseOption : MonoBehaviour, IAmLocalised
{
	[SerializeField]
	private RoleVisualDataSO role_visual_data;

	[SerializeField]
	private CaseQuirksVisualDataSO quirks_visual_data;

	[Header("References")]
	[SerializeField]
	private CaseQuirkExplanation quirk_explain;

	[SerializeField]
	private RectTransform option_jiggle_parent;

	[SerializeField]
	private CanvasGroup group;

	[SerializeField]
	private Image role_icon;

	[SerializeField]
	private Image quirk_icon;

	[SerializeField]
	private TMP_Text case_title;

	[SerializeField]
	private TMP_Text case_difficulty;

	[SerializeField]
	private TMP_Text case_reputation;

	[SerializeField]
	private TMP_Text case_description;

	[SerializeField]
	private AdvancedButton button;

	[Header("Settings")]
	[SerializeField]
	private Color red_text_colour;

	[SerializeField]
	private Color orange_text_colour;

	[SerializeField]
	private Color green_text_colour;

	private CaseBuildData case_data;

	private Action<CaseBuildData> on_selected;

	private CoroutineRunner jiggler_runner;

	private AssetKey localisation_asset => LocalisationHelper.ui_asset;

	private string loc_onSolve_key => "CaseOption [on_solve]";

	private string loc_rep_gain_key => "CaseOption [rep_gain]";

	private string loc_chips_gain_key => "CaseOption [chips_gain]";

	private string loc_progress_arrest_key => "CaseOption [prog_arr]";

	private string loc_case_key => "CaseOption [case]";

	private string loc_final_case_key => "CaseOption [final]";

	private string loc_traitor_key => "CaseOption [traitor]";

	private string loc_address_count_key => "CaseOption [occupents]";

	private string loc_ratio_count_key => "CaseOption [ratio]";

	private string loc_ratio_empty_key => "CaseOption [ratio_0]";

	private string loc_quirk_add_key => "CaseOption [key_add]";

	private string loc_suspected_key => "CaseOption [suspect]";

	private string loc_in_play_key => "CaseOption [in_play]";

	private string loc_boat_fuel_key => "CaseOption [boat_fuel]";

	private string loc_money_gain_key => "CaseOption [money_gain]";

	public CanvasGroup getGroup()
	{
		return group;
	}

	private void Awake()
	{
		jiggler_runner = new CoroutineRunner(this);
	}

	public void jiggle()
	{
		jiggler_runner.run(option_jiggle_parent.jiggle());
	}

	public void setUpCase(int _case_number, CaseBuildData _case_data, Action<CaseBuildData> _on_selected)
	{
		case_data = _case_data;
		on_selected = _on_selected;
		case_title.text = ((_case_number == 0) ? checkTranslation(loc_final_case_key, "Final Case!") : checkTranslation(loc_case_key, (string _c) => "Case #" + _c, _case_number.ToString()));
		string text = "";
		string text2 = "";
		if (_case_data.case_reward is ClockCaseReward clockCaseReward)
		{
			text = ((_case_number == 0) ? "" : (" <size=94%>(" + $"+{clockCaseReward.region_progress}%".sandwichWithColour(red_text_colour) + ")</size>"));
			text2 = ((_case_number == 0) ? "" : (getOnSolve() + " " + checkTranslation(loc_rep_gain_key, getPlusReputationEnglish, clockCaseReward.reputation_gain.ToString()).sandwichWithColour(green_text_colour)));
		}
		else if (_case_data.case_reward is DocksCaseReward docksCaseReward)
		{
			text = ((_case_number == 0) ? "" : (" <size=94%>(" + checkTranslation(loc_progress_arrest_key, progressPerArrestEnglish, docksCaseReward.region_progress_per_arrest.ToString()).sandwichWithColour(red_text_colour) + ")</size>"));
			text2 = getOnSolve() + " " + checkTranslation(loc_rep_gain_key, getPlusReputationEnglish, docksCaseReward.reputation_gain.ToString()).sandwichWithColour(green_text_colour);
		}
		else if (_case_data.case_reward is CasinoCaseReward casinoCaseReward)
		{
			text2 = getOnSolve() + " " + checkTranslation(loc_chips_gain_key, getPlusChipsEnglish, casinoCaseReward.chips_gained.ToString()).sandwichWithColour(orange_text_colour);
		}
		else if (_case_data.case_reward is BackAlleysCaseReward backAlleysCaseReward)
		{
			text = ((_case_number == 0) ? "" : (" <size=94%>(" + $"+{backAlleysCaseReward.region_progress}%".sandwichWithColour(red_text_colour) + ")</size>"));
			text2 = getOnSolve() + " " + checkTranslation(loc_money_gain_key, getPlusMoneyEnglish, backAlleysCaseReward.money_gained.ToString()).sandwichWithColour(orange_text_colour);
		}
		case_difficulty.text = getDifficultyText(_case_data.difficulty_01) + text;
		case_reputation.text = text2;
		setUpCaseDescription(_case_data);
	}

	public AdvancedButton getSelectable()
	{
		return button;
	}

	public void setUpSelectables(Selectable _left, Selectable _right)
	{
		Navigation navigation = button.navigation;
		navigation.selectOnLeft = _left;
		navigation.selectOnRight = _right;
		button.navigation = navigation;
	}

	public void updateBuiltCase(Func<Case, Case> _update_case)
	{
		case_data.updateBuiltCase(_update_case);
	}

	private void setUpCaseDescription(CaseBuildData _case_data)
	{
		if (_case_data.quirk_added.is_some)
		{
			quirk_icon.sprite = quirks_visual_data[_case_data.quirk_added.value];
		}
		else
		{
			quirk_icon.gameObject.SetActive(value: false);
		}
		if (_case_data.case_description.Length > 10)
		{
			case_description.text = _case_data.case_description;
			role_icon.sprite = role_visual_data[_case_data.icon];
			role_icon.SetNativeSize();
			role_icon.color = role_visual_data[_case_data.icon.getClassificationFromRoleType()].class_colour;
			return;
		}
		case_description.text = "";
		CaseSnapshot caseSnapshot = _case_data.buildCase().pregameSnap();
		System.Random rnd = RandomExtensions.freshRandom();
		if (caseSnapshot.classification_ratio[RoleClassifications.TRAITOR] > 0)
		{
			TMP_Text tMP_Text = case_description;
			tMP_Text.text = tMP_Text.text + checkTranslation(loc_traitor_key, getTraitorTextEnglish, RoleClassifications.TRAITOR.toString()) + "\n";
		}
		else
		{
			RoleClassifications randomElementFromList = new List<RoleClassifications>().addAll().getRandomElementFromList(rnd);
			if (randomElementFromList == RoleClassifications.TRAITOR)
			{
				TMP_Text tMP_Text2 = case_description;
				tMP_Text2.text = tMP_Text2.text + checkTranslation(loc_address_count_key, getAddressCountTextEnglish, $"<b>{caseSnapshot.address_occupents.Values.Count}</b>") + "\n";
			}
			else
			{
				int num = caseSnapshot.classification_ratio[randomElementFromList];
				TMP_Text tMP_Text3 = case_description;
				tMP_Text3.text = tMP_Text3.text + ((num == 0) ? checkTranslation(loc_ratio_empty_key, getNoRatioTextEnglish, randomElementFromList.toString()) : checkTranslation(loc_ratio_count_key, getRatioTextEnglish, num.ToString(), randomElementFromList.toString())) + "\n";
			}
		}
		if (_case_data.quirk_added.is_some)
		{
			CaseQuirkData caseQuirkData = _case_data.quirk_added.value.createQuirk();
			TMP_Text tMP_Text4 = case_description;
			tMP_Text4.text = tMP_Text4.text + checkTranslation(loc_quirk_add_key, getAddQuirkTextEnglish, caseQuirkData.name.bold().colour(quirks_visual_data.text_colour)) + "\n";
		}
		RoleData roleData;
		if (_case_data.difficulty_01 < 0.5f)
		{
			RoleData randomElementFromList2 = caseSnapshot.address_occupents.Values.Where((RoleData _e) => !_e.role.isTraitor()).ToList().getRandomElementFromList(rnd);
			TMP_Text tMP_Text5 = case_description;
			tMP_Text5.text = tMP_Text5.text + checkTranslation(loc_in_play_key, getInPlayTextEnglish, GameHandler.Text.getRoleNameColoured(randomElementFromList2)) + "\n";
			roleData = randomElementFromList2;
		}
		else
		{
			RoleData randomElement = caseSnapshot.true_suspect_list.getRandomElement(rnd);
			TMP_Text tMP_Text6 = case_description;
			tMP_Text6.text = tMP_Text6.text + checkTranslation(loc_suspected_key, getSuspectedTextEnglish, GameHandler.Text.getRoleNameColoured(randomElement)) + "\n";
			roleData = randomElement;
		}
		case_description.text += regionDescriptionText(_case_data, caseSnapshot);
		role_icon.sprite = role_visual_data[roleData.role];
		role_icon.SetNativeSize();
		role_icon.color = role_visual_data[roleData.role.getClassificationFromRoleType()].class_colour;
		_case_data.icon = roleData.role;
		_case_data.case_description = case_description.text;
	}

	private string regionDescriptionText(CaseBuildData _case_data, CaseSnapshot _pregame_snap)
	{
		if (_pregame_snap is DocksCaseSnapshot docksCaseSnapshot)
		{
			return checkTranslation(loc_boat_fuel_key, getBoatFuelTextEnglish, docksCaseSnapshot.docks_payload.boat.fuel.ToString().bold()) + "\n";
		}
		return "";
	}

	private string getTraitorTextEnglish(string _name)
	{
		return "- At least <b>1</b> " + _name + " in town.";
	}

	private string getAddressCountTextEnglish(string _data)
	{
		return "- " + _data + " addresses in town.";
	}

	private string getNoRatioTextEnglish(string _data)
	{
		return "- <b>No " + _data + "</b> in town.";
	}

	private string getRatioTextEnglish(string _data, string _data_2)
	{
		return "- <b>" + _data + "</b> " + _data_2 + " in town.";
	}

	private string getAddQuirkTextEnglish(string _data)
	{
		return "- Adds " + _data + ".";
	}

	private string getSuspectedTextEnglish(string _data)
	{
		return "- " + _data + " suspected.";
	}

	private string getInPlayTextEnglish(string _data)
	{
		return "- " + _data + " spotted in-play.";
	}

	private string getBoatFuelTextEnglish(string _data)
	{
		return "- Boat Fuel: " + _data;
	}

	private string getOnSolve()
	{
		return checkTranslation(loc_onSolve_key, getOnSolveEnglish());
	}

	private string getOnSolveEnglish()
	{
		return "On Solve:";
	}

	private string getPlusReputationEnglish(string _data)
	{
		return "+" + _data + " Reputation";
	}

	private string getPlusChipsEnglish(string _data)
	{
		return "+" + _data + " Chips";
	}

	private string getPlusMoneyEnglish(string _data)
	{
		return "+" + _data + " Credits";
	}

	private string progressPerArrestEnglish(string _data)
	{
		return "+" + _data + "%/Arrest";
	}

	private string getDifficultyText(float _diff_01)
	{
		if (_diff_01 > 0.75f)
		{
			return checkTranslation("Very Hard").sandwichWithColour(red_text_colour);
		}
		if (_diff_01 > 0.5f)
		{
			return checkTranslation("Hard").sandwichWithColour(red_text_colour);
		}
		if (_diff_01 > 0.25f)
		{
			return checkTranslation("Normal").sandwichWithColour(orange_text_colour);
		}
		return checkTranslation("Easy").sandwichWithColour(green_text_colour);
	}

	public void onClick()
	{
		on_selected(case_data);
		AudioHandler.Sfx.playSfx(Sfx.PAPER_BUTTON, 0.5f);
	}

	public void onHover()
	{
		AudioHandler.Sfx.playSfx(Sfx.PAPER_SHORT);
		if (case_data.quirk_added.is_some)
		{
			CaseQuirkData caseQuirkData = case_data.quirk_added.value.createQuirk();
			quirk_explain.explainText(this, caseQuirkData.name.bold().sandwichWithColour(quirks_visual_data.text_colour) + "\n" + caseQuirkData.description);
		}
	}

	public void onUnhover()
	{
		quirk_explain.tryClose(this);
	}

	private string checkTranslation(string _key_and_english)
	{
		return checkTranslation(_key_and_english, _key_and_english);
	}

	private string checkTranslation(string _key, string _english)
	{
		if (GRGLocalisationHandler.needs_translation)
		{
			string _result = "";
			if (GRGLocalisationHandler.instance.translate(localisation_asset, _key, out _result))
			{
				return _result;
			}
		}
		return _english;
	}

	private string checkTranslation(string _key, Func<string, string> _english, string _input)
	{
		if (GRGLocalisationHandler.needs_translation)
		{
			string _result = "";
			if (GRGLocalisationHandler.instance.translateAndReplace(localisation_asset, _key, out _result, _input))
			{
				return _result;
			}
		}
		return _english(_input);
	}

	private string checkTranslation(string _key, Func<string, string, string> _english, string _input_1, string _input_2)
	{
		if (GRGLocalisationHandler.needs_translation)
		{
			string _result = "";
			if (GRGLocalisationHandler.instance.translateAndReplace(localisation_asset, _key, out _result, _input_1, _input_2))
			{
				return _result;
			}
		}
		return _english(_input_1, _input_2);
	}
}
