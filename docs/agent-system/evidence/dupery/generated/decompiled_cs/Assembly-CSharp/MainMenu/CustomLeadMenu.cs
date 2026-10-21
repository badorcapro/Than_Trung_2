using System;
using System.Collections.Generic;
using System.Linq;
using Codex;
using GRGLib.Extensions;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Random;
using GRGLib.Generic;
using GRGLocalisation;
using Leads;
using Localisation;
using Nodes.Logic;
using Save;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace MainMenu;

public class CustomLeadMenu : MenuBase, IAmLocalised
{
	protected enum StampsDropdownOptions
	{
		DEFAULT_EXPAND,
		DEFAULT_UNREST,
		DEFAULT,
		NONE
	}

	[SerializeField]
	private RegionsSO regions_data;

	[SerializeField]
	private RoleVisualDataSO roles_data;

	[Header("References")]
	[SerializeField]
	private TMP_Dropdown region_dropdown;

	[SerializeField]
	private TMP_Text lead_length_setting_text;

	[SerializeField]
	private Slider lead_length_slider;

	[SerializeField]
	private TMP_InputField lead_length_input_field;

	[SerializeField]
	private Slider board_size_slider;

	[SerializeField]
	private TMP_Text board_size_text;

	[SerializeField]
	private Slider difficulty_slider_min;

	[SerializeField]
	private Slider difficulty_slider_max;

	[SerializeField]
	private TMP_Text difficulty_text;

	[SerializeField]
	private TMP_Dropdown prime_suspects_dropdown;

	[SerializeField]
	private List<PrimeSuspectVisual> prime_suspects;

	[SerializeField]
	private TMP_Text available_roles_text;

	[SerializeField]
	private TMP_Text available_quirks_text;

	[SerializeField]
	private TMP_Text starting_quirks_text;

	[SerializeField]
	private TMP_Dropdown stamps_dropdown;

	[SerializeField]
	private GameObject force_end_traitor_section;

	[SerializeField]
	private Slider forced_end_traitor_cases_slider;

	[SerializeField]
	private TMP_InputField forced_end_traitor_cases_input_field;

	[SerializeField]
	private SaveCustomMenu save_menu;

	[SerializeField]
	private LoadCustomMenu load_menu;

	[SerializeField]
	private CodexMenu codex_menu;

	[Header("Settings")]
	[SerializeField]
	private int max_lead_length = 15;

	[SerializeField]
	private int max_needed_arrests = 30;

	private Lead creating_lead;

	private LeadProgressionManager creating_progression_manager;

	private List<Regions> available_regions;

	private List<StampsDropdownOptions> stamp_options;

	private List<RoleSetInfoStruct> available_sets = new List<RoleSetInfoStruct>();

	private List<Roles> all_available_roles = new List<Roles>();

	private List<CaseQuirks> all_available_quirks = new List<CaseQuirks>();

	private string leadLengthLocalised => localisation_asset.checkTranslation(loc_lead_length_key, englishLeadLength, _check_keywords: false);

	private string neededArrestsLocalised => localisation_asset.checkTranslation(loc_needed_arrests_key, englishNeededArrests, _check_keywords: false);

	private string customLocalised => localisation_asset.checkTranslation(loc_custom_key, englishCustom, _check_keywords: false);

	private string allLocalised => localisation_asset.checkTranslation(loc_all_key, englishAll, _check_keywords: false);

	private string defaultLocalised => localisation_asset.checkTranslation(loc_default_key, englishDefault, _check_keywords: false);

	private string defaultExpandLocalised => localisation_asset.checkTranslation(loc_defaultExpand_key, englishDefaultExpand, _check_keywords: false);

	private string defaultPublicUnrestLocalised => localisation_asset.checkTranslation(loc_defaultPublicUnrest_key, englishDefaultPublicUnrest, _check_keywords: false);

	private string noneLocalised => localisation_asset.checkTranslation(loc_none_key, englishNone, _check_keywords: false);

	private AssetKey localisation_asset => LocalisationHelper.misc_asset;

	private string loc_lead_length_key => "CLM [length]";

	private string loc_needed_arrests_key => "CLM [na]";

	private string loc_custom_key => "Custom";

	private string loc_all_key => "All";

	private string loc_default_key => "Default";

	private string loc_defaultExpand_key => "Default [exp]";

	private string loc_defaultPublicUnrest_key => "Default [unr]";

	private string loc_none_key => "None";

	private string loc_difficulty => "custom_mode [diff]";

	private void Start()
	{
		save_menu.setPlayerInput(input);
		load_menu.setPlayerInput(input);
	}

	protected override void onMenuOpening()
	{
		base.onMenuOpening();
		setUpDefault();
	}

	public void setUpDefault()
	{
		Dictionary<Regions, RegionProgressionSaveData> progressionUnserialized = SaveHandler.instance.meta_data.getProgressionUnserialized();
		available_regions = new List<Regions> { Regions.OFFICE };
		if (progressionUnserialized.ContainsKey(Regions.CASINO) && progressionUnserialized[Regions.CASINO].tier > 0)
		{
			available_regions.Add(Regions.CASINO);
		}
		if (progressionUnserialized.ContainsKey(Regions.DOCKS) && progressionUnserialized[Regions.DOCKS].tier > 0)
		{
			available_regions.Add(Regions.DOCKS);
		}
		region_dropdown.ClearOptions();
		region_dropdown.AddOptions(available_regions.Select((Regions _r) => regions_data[_r].region_name).ToList());
		setUpRegion(available_regions[0], progressionUnserialized[Regions.OFFICE], _set_unchanging: true);
	}

	private void setUpRegion(Regions _region, RegionProgressionSaveData _progression, bool _set_unchanging = false)
	{
		RegionDataSO regionDataSO = regions_data[_region];
		checkLeadLength(_region);
		all_available_roles = regionDataSO.getAvailableRoles(_progression.tier);
		all_available_quirks = regionDataSO.getAvailableQuirks(_progression.tier);
		Vector2Int grid_size = new Vector2Int(Mathf.RoundToInt(board_size_slider.value), Mathf.RoundToInt(board_size_slider.value));
		MinMaxFloat diff = new MinMaxFloat(difficulty_slider_min.value / 100f, difficulty_slider_max.value / 100f);
		int num = Mathf.RoundToInt(lead_length_slider.value);
		RandomExtensions.freshRandom();
		available_sets = (from _s in regionDataSO.getTierSets(_progression.tier)
			select new RoleSetInfoStruct(_s)).ToList();
		creating_lead = _region switch
		{
			Regions.OFFICE => new OfficeLead(all_available_roles.copy(), grid_size, diff, num, available_sets[0]), 
			Regions.CASINO => new CasinoLead(all_available_roles.copy(), grid_size, diff, num, available_sets[0], 250), 
			Regions.DOCKS => new DocksLead(all_available_roles.copy(), grid_size, diff, num, available_sets[0]), 
			_ => throw new ArgumentException($"Not sure how to create custom lead of region {_region}!"), 
		};
		creating_progression_manager = _region switch
		{
			Regions.OFFICE => new OfficeLeadProgressionManager(regions_data, _progression.using_tier), 
			Regions.CASINO => new CasinoLeadProgressionManager(regions_data, _progression.using_tier), 
			Regions.DOCKS => new DocksLeadProgressionManager(regions_data, _progression.using_tier), 
			_ => throw new ArgumentException($"Not sure how to create custom lead of region {_region}!"), 
		};
		prime_suspects_dropdown.ClearOptions();
		prime_suspects_dropdown.AddOptions(available_sets.Select((RoleSetInfoStruct _p) => _p.set_name).ToList());
		prime_suspects_dropdown.SetValueWithoutNotify(0);
		for (int i = 0; i < prime_suspects.Count && i < creating_lead.prime_suspect_set.set_roles.Count; i++)
		{
			prime_suspects[i].setUp(creating_lead.prime_suspect_set.set_roles[i], roles_data);
		}
		available_roles_text.text = allLocalised;
		available_quirks_text.text = allLocalised;
		starting_quirks_text.text = noneLocalised;
		force_end_traitor_section.SetActive(_region != Regions.DOCKS);
		stamps_dropdown.ClearOptions();
		stamp_options = new List<StampsDropdownOptions>().addAll();
		if (_region.equalToAny(Regions.CASINO, Regions.DOCKS))
		{
			stamp_options.Remove(StampsDropdownOptions.DEFAULT_UNREST);
		}
		if (grid_size.x == 5)
		{
			stamp_options.Remove(StampsDropdownOptions.DEFAULT_EXPAND);
		}
		setStampDropdownText();
		stamps_dropdown.SetValueWithoutNotify(0);
		onStampChange(0);
		if (_set_unchanging)
		{
			lead_length_input_field.SetTextWithoutNotify(num.ToString());
			board_size_text.text = $"{grid_size.x}x{grid_size.y}";
			difficulty_text.text = difficultyLocalised(diff);
		}
	}

	private void checkLeadLength(Regions _region)
	{
		if (_region == Regions.DOCKS)
		{
			if (lead_length_slider.maxValue != (float)max_needed_arrests)
			{
				lead_length_slider.maxValue = max_needed_arrests;
				lead_length_slider.SetValueWithoutNotify(lead_length_slider.value * 2f);
				lead_length_input_field.SetTextWithoutNotify(Mathf.RoundToInt(lead_length_slider.value).ToString());
				lead_length_setting_text.text = neededArrestsLocalised;
			}
		}
		else if (lead_length_slider.maxValue != (float)max_lead_length)
		{
			lead_length_slider.SetValueWithoutNotify(Mathf.CeilToInt(lead_length_slider.value / 2f));
			lead_length_slider.maxValue = max_lead_length;
			lead_length_input_field.SetTextWithoutNotify(Mathf.RoundToInt(lead_length_slider.value).ToString());
			lead_length_setting_text.text = leadLengthLocalised;
		}
	}

	public void playLead()
	{
		if (!TransitionHandler.instance.is_transitioning)
		{
			GameHandler.instance.startCustomLead(creating_lead, creating_progression_manager);
		}
	}

	public void savePreset()
	{
		save_menu.setSaving(new CustomLeadPreset(creating_lead, creating_progression_manager));
		openNewMenu(save_menu);
	}

	public void loadPreset()
	{
		openNewMenu(load_menu);
		load_menu.setUp(loadPreset);
	}

	private void loadPreset(CustomLeadPreset _preset)
	{
		if (!available_regions.Contains(_preset.region))
		{
			available_regions.Add(_preset.region);
			region_dropdown.ClearOptions();
			region_dropdown.AddOptions(available_regions.Select((Regions _r) => regions_data[_r].region_name).ToList());
		}
		int valueWithoutNotify = available_regions.IndexOf(_preset.region);
		region_dropdown.SetValueWithoutNotify(valueWithoutNotify);
		RegionProgressionSaveData orDefault = SaveHandler.instance.meta_data.getProgressionUnserialized().getOrDefault(_preset.region, new RegionProgressionSaveData(1, 0));
		setUpRegion(_preset.region, orDefault);
		int num = available_sets.FindIndex((RoleSetInfoStruct _s) => _s.hasSameRolesAs(_preset.prime_suspects));
		if (num >= 0)
		{
			prime_suspects_dropdown.SetValueWithoutNotify(num);
			onPrimeSuspectChange(num);
		}
		else
		{
			prime_suspects_dropdown.SetValueWithoutNotify(prime_suspects_dropdown.options.Count - 1);
			setPrimeSuspects(_preset.prime_suspects);
		}
		creating_lead.setLeadLength(_preset.lead_length);
		creating_lead.setDifficulty(_preset.difficulty);
		creating_lead.setBoardSize(_preset.board_size);
		creating_lead.setAvailableRoles(_preset.available_roles);
		creating_lead.setStartingClues(_preset.starting_quirks);
		creating_lead.setForcedEndTraitorCases(_preset.traitor_cases);
		creating_progression_manager.loadCustomSettings(_preset.override_settings);
		if (_preset.available_quirks.Count > 0)
		{
			creating_progression_manager.setAvailableQuirks(_preset.available_quirks);
			available_quirks_text.text = customLocalised;
		}
		else
		{
			available_quirks_text.text = allLocalised;
		}
		lead_length_input_field.SetTextWithoutNotify(creating_lead.max_case.ToString());
		lead_length_slider.SetValueWithoutNotify(creating_lead.max_case);
		difficulty_slider_min.SetValueWithoutNotify(creating_lead.lead_difficulty.min * 100f);
		difficulty_slider_max.SetValueWithoutNotify(creating_lead.lead_difficulty.max * 100f);
		difficulty_text.text = difficultyLocalised(creating_lead.lead_difficulty);
		board_size_slider.SetValueWithoutNotify(creating_lead.current_board_size.x);
		board_size_text.text = $"{creating_lead.current_board_size.x}x{creating_lead.current_board_size.y}";
		if (creating_lead.lead_roles.Count >= all_available_roles.Count)
		{
			available_roles_text.text = allLocalised;
		}
		else
		{
			available_roles_text.text = customLocalised;
		}
		if (num >= 0)
		{
			prime_suspects_dropdown.SetValueWithoutNotify(num);
		}
		else
		{
			prime_suspects_dropdown.SetValueWithoutNotify(prime_suspects_dropdown.options.Count - 1);
		}
		starting_quirks_text.text = ((_preset.starting_quirks.Count > 0) ? customLocalised : noneLocalised);
		forced_end_traitor_cases_slider.SetValueWithoutNotify(_preset.traitor_cases);
		forced_end_traitor_cases_input_field.SetTextWithoutNotify(_preset.traitor_cases.ToString());
		if (creating_progression_manager.custom_settings.is_some)
		{
			if (creating_progression_manager.custom_settings.value.remove_stamps)
			{
				int valueWithoutNotify2 = stamp_options.IndexOf(StampsDropdownOptions.NONE);
				stamps_dropdown.SetValueWithoutNotify(valueWithoutNotify2);
			}
			else if (creating_progression_manager.custom_settings.value.override_event.Values.Contains(LeadEventType.INCREASE_BOARD_SIZE))
			{
				int valueWithoutNotify3 = stamp_options.IndexOf(StampsDropdownOptions.DEFAULT_EXPAND);
				stamps_dropdown.SetValueWithoutNotify(valueWithoutNotify3);
			}
			else if (creating_progression_manager.custom_settings.value.override_event.Values.Contains(LeadEventType.PUBLIC_UNREST))
			{
				int valueWithoutNotify4 = stamp_options.IndexOf(StampsDropdownOptions.DEFAULT_UNREST);
				stamps_dropdown.SetValueWithoutNotify(valueWithoutNotify4);
			}
			else
			{
				stamps_dropdown.AddOptions(new List<string> { customLocalised });
				stamps_dropdown.SetValueWithoutNotify(stamps_dropdown.options.Count - 1);
			}
		}
	}

	public void onRegionChange(int _value)
	{
		setUpRegion(available_regions[_value], SaveHandler.instance.meta_data.getProgressionUnserialized().getOrDefault(available_regions[_value], new RegionProgressionSaveData(1, 0)));
	}

	public void onLeadLengthSlider(float _value)
	{
		int num = Mathf.RoundToInt(_value);
		lead_length_input_field.SetTextWithoutNotify(num.ToString());
		if (creating_lead is DocksLead docksLead)
		{
			docksLead.setNeededEvilArrested(num);
		}
		creating_lead.setLeadLength(num);
		onStampChange(stamps_dropdown.value);
	}

	public void onLeadLengthInput(string _value)
	{
		int num;
		try
		{
			num = ((!(_value == "")) ? int.Parse(_value) : 0);
			if (num < 2)
			{
				num = 2;
			}
			if (creating_lead.case_type == CaseType.DOCKS && num < 4)
			{
				num = 4;
			}
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to parse lead length from input {_value}\nError: {arg}");
			num = Mathf.RoundToInt(lead_length_slider.value);
		}
		lead_length_slider.SetValueWithoutNotify(num);
		if (creating_lead is DocksLead docksLead)
		{
			docksLead.setNeededEvilArrested(num);
		}
		creating_lead.setLeadLength(num);
		onStampChange(stamps_dropdown.value);
	}

	public void onBoardSizeChange(float _value)
	{
		int num = Mathf.RoundToInt(_value);
		board_size_text.text = $"{num}x{num}";
		creating_lead.setBoardSize(new Vector2Int(num, num));
		if (num == 5)
		{
			StampsDropdownOptions num2 = stamp_options[stamps_dropdown.value];
			stamp_options.Remove(StampsDropdownOptions.DEFAULT_EXPAND);
			setStampDropdownText();
			if (num2 == StampsDropdownOptions.DEFAULT_EXPAND)
			{
				stamps_dropdown.SetValueWithoutNotify(0);
				onStampChange(0);
			}
		}
		else if (!stamp_options.Contains(StampsDropdownOptions.DEFAULT_EXPAND))
		{
			stamp_options = StampsDropdownOptions.DEFAULT_EXPAND.makeListFromItem().addRange(stamp_options);
			setStampDropdownText();
			stamps_dropdown.SetValueWithoutNotify(stamps_dropdown.value + 1);
		}
	}

	public void onDifficultyMinChange(float _value)
	{
		onDifficultyChange(new MinMaxFloat(_value / 100f, difficulty_slider_max.value / 100f), _value / 100f);
	}

	public void onDifficultyMaxChange(float _value)
	{
		onDifficultyChange(new MinMaxFloat(difficulty_slider_min.value / 100f, _value / 100f), _value / 100f);
	}

	private void onDifficultyChange(MinMaxFloat _new_diff, float _newer)
	{
		if (_new_diff.max < _new_diff.min)
		{
			_new_diff = new MinMaxFloat(_newer, _newer);
			difficulty_slider_min.SetValueWithoutNotify(Mathf.RoundToInt(_newer * 100f));
			difficulty_slider_max.SetValueWithoutNotify(Mathf.RoundToInt(_newer * 100f));
		}
		difficulty_text.text = difficultyLocalised(_new_diff);
		creating_lead.setDifficulty(_new_diff);
	}

	public void onPrimeSuspectChange(int _value)
	{
		if (_value == available_sets.Count)
		{
			prime_suspects.ForEach(delegate(PrimeSuspectVisual _p)
			{
				_p.setUpEmpty(roles_data);
			});
			creating_lead.setPrimeSuspect(new RoleSetInfoStruct(customLocalised, customLocalised, new List<Roles>(), RoleSetsGraph.SetsType.NONE));
		}
		else
		{
			setPrimeSuspects(available_sets[_value]);
		}
	}

	private void setPrimeSuspects(RoleSetInfoStruct _set)
	{
		for (int i = 0; i < prime_suspects.Count; i++)
		{
			if (_set.set_roles.Count > i)
			{
				prime_suspects[i].setUp(_set.set_roles[i], roles_data);
			}
			else
			{
				prime_suspects[i].setUpEmpty(roles_data);
			}
		}
		creating_lead.setPrimeSuspect(_set);
	}

	public void onStampChange(int _value)
	{
		creating_progression_manager.clearOverrideEvents();
		switch (stamp_options[_value])
		{
		case StampsDropdownOptions.DEFAULT_EXPAND:
		{
			int at2 = ((creating_lead.case_type == CaseType.DOCKS) ? Mathf.Min(Mathf.FloorToInt((float)creating_lead.max_case / 4f), 3) : Mathf.Min(Mathf.FloorToInt((float)creating_lead.max_case / 2f), 3));
			creating_progression_manager.addOverrideEvent(at2, LeadEventType.INCREASE_BOARD_SIZE);
			creating_progression_manager.addEventVetoe(LeadEventType.INCREASE_BOARD_SIZE, LeadEventType.PUBLIC_UNREST);
			break;
		}
		case StampsDropdownOptions.DEFAULT_UNREST:
		{
			int at = Mathf.CeilToInt((float)creating_lead.max_case / 2f);
			creating_progression_manager.addOverrideEvent(at, LeadEventType.PUBLIC_UNREST);
			creating_progression_manager.addEventVetoe(LeadEventType.INCREASE_BOARD_SIZE, LeadEventType.PUBLIC_UNREST);
			break;
		}
		case StampsDropdownOptions.DEFAULT:
			creating_progression_manager.addEventVetoe(LeadEventType.INCREASE_BOARD_SIZE, LeadEventType.PUBLIC_UNREST);
			break;
		case StampsDropdownOptions.NONE:
			creating_progression_manager.setNoStamps();
			break;
		default:
			Debug.LogError($"No setting set up for stamps dropdown option {stamp_options[_value]}!");
			break;
		}
	}

	private void setStampDropdownText()
	{
		stamps_dropdown.ClearOptions();
		stamps_dropdown.AddOptions(stamp_options.Select(getStampDropdownText).ToList());
	}

	private string getStampDropdownText(StampsDropdownOptions _option)
	{
		return _option switch
		{
			StampsDropdownOptions.DEFAULT => defaultLocalised, 
			StampsDropdownOptions.DEFAULT_EXPAND => defaultExpandLocalised, 
			StampsDropdownOptions.DEFAULT_UNREST => defaultPublicUnrestLocalised, 
			StampsDropdownOptions.NONE => noneLocalised, 
			_ => "", 
		};
	}

	public void onTraitorCasesChange(float _value)
	{
		creating_lead.setForcedEndTraitorCases(Mathf.RoundToInt(_value));
		forced_end_traitor_cases_input_field.SetTextWithoutNotify(Mathf.RoundToInt(_value).ToString());
	}

	public void onTraitorCasesChange(string _input)
	{
		int num;
		try
		{
			num = ((!(_input == "")) ? int.Parse(_input) : 0);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to parse final traitor cases {_input}\nError: {arg}");
			num = 1;
		}
		creating_lead.setForcedEndTraitorCases(num);
		forced_end_traitor_cases_slider.SetValueWithoutNotify(num);
	}

	public void chooseAvailableRoles()
	{
		openNewMenu(codex_menu);
		codex_menu.openRegionPageWithToggle(creating_lead.case_type.fromType(), RoleClassifications.INNOCENT, creating_lead.lead_roles, creating_lead.prime_suspect_set.set_roles, RegionDataSO.min_required, delegate(List<Roles> _selected)
		{
			creating_lead.setAvailableRoles(_selected);
			available_roles_text.text = ((_selected.Count == all_available_roles.Count) ? allLocalised : customLocalised);
		}, _open_codex: false);
	}

	public void chooseAvailableQuirks()
	{
		openNewMenu(codex_menu);
		codex_menu.openQuirksPageWithToggle(creating_lead.case_type.fromType(), creating_progression_manager.getAvailableQuirks(), new List<CaseQuirks>(), new MinMaxInt(3, 999), delegate(List<CaseQuirks> _selected)
		{
			if (_selected.Count == all_available_quirks.Count)
			{
				creating_progression_manager.resetAvailableQuirks();
				available_quirks_text.text = allLocalised;
			}
			else
			{
				creating_progression_manager.setAvailableQuirks(_selected);
				available_quirks_text.text = customLocalised;
			}
		}, _open_codex: false);
	}

	public void chooseStartingQuirks()
	{
		openNewMenu(codex_menu);
		codex_menu.openQuirksPageWithToggle(creating_lead.case_type.fromType(), creating_lead.clues_as_quirks, new List<CaseQuirks>(), new MinMaxInt(0, 8), delegate(List<CaseQuirks> _selected)
		{
			starting_quirks_text.text = ((_selected.Count == 0) ? noneLocalised : customLocalised);
			creating_lead.setStartingClues(_selected);
		}, _open_codex: false);
	}

	private string englishLeadLength()
	{
		return "Lead Length:";
	}

	private string englishNeededArrests()
	{
		return "Arrests Needed:";
	}

	private string englishCustom()
	{
		return "Custom";
	}

	private string englishAll()
	{
		return "All";
	}

	private string englishDefault()
	{
		return "Default";
	}

	private string englishDefaultExpand()
	{
		return "Default (Expand Jurisdiction)";
	}

	private string englishDefaultPublicUnrest()
	{
		return "Default (Public Unrest)";
	}

	private string englishNone()
	{
		return "None";
	}

	private string difficultyLocalised(MinMaxFloat _diff)
	{
		return localisation_asset.checkTranslationWithData(loc_difficulty, englishDifficulty, Mathf.RoundToInt(_diff.min * 100f).ToString(), Mathf.RoundToInt(_diff.max * 100f).ToString());
	}

	private string englishDifficulty(string _d1, string _d2)
	{
		return _d1 + " to " + _d2;
	}
}
