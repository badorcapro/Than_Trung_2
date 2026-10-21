using System;
using System.Collections.Generic;
using GRGLib.Extensions.String;
using GRGLib.Serializable;
using GRGLib.UI;
using GRGLocalisation;
using Hover;
using Leads;
using Localisation;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class LeadFacade : MonoBehaviour, IAmLocalised
{
	[SerializeField]
	private CaseQuirksVisualDataSO quirks_data;

	[SerializeField]
	private StampVisualDataSO stamp_data;

	[Header("Text Refs")]
	[SerializeField]
	private TMP_Text progress_on_completion_text;

	[SerializeField]
	private TMP_Text grid_sequence_text;

	[SerializeField]
	private TMP_Text progression_type_text;

	[SerializeField]
	private TMP_Text cases_remaining_text;

	[SerializeField]
	private TMP_Text lead_title_text;

	[SerializeField]
	private TMP_Text region_name_text;

	[Header("Stamp Settings")]
	[SerializeField]
	private RectTransform stamp_parent;

	[SerializeField]
	private Image stamp_parent_image;

	[SerializeField]
	private AnimatedLayoutGroup preset_stamp_parents;

	[SerializeField]
	private LeadStampManager stamp_manager;

	[SerializeField]
	private AnimatedLayoutGroup clues_parent;

	[SerializeField]
	private LeadClueFacade lead_clue_prefab;

	[SerializeField]
	private int min_clue_boxes = 5;

	[Header("Prime Suspects")]
	[SerializeField]
	private List<PrimeSuspectVisual> prime_suspect_visuals;

	[Header("Image Refs")]
	[SerializeField]
	private HoveringImage quirk_hover;

	[SerializeField]
	private Image region_image;

	[SerializeField]
	private SerializableDictionary<CaseType, Sprite> possible_region_images;

	[SerializeField]
	private RoleVisualDataSO role_vis_data;

	public Lead current_lead { get; private set; }

	private AssetKey localisation_asset => LocalisationHelper.ui_asset;

	private string loc_prime_suspects_key => "LeadFacade [PS]";

	private string loc_title_key => "LeadFacade [T]";

	private string loc_cases_prog_key => "Cases Solved";

	private string loc_arrested_prog_key => "Evil Arrested";

	public void setCurrentLead(Lead _new_lead, string _region_name)
	{
		current_lead = _new_lead;
		region_name_text.text = _region_name;
		region_image.sprite = possible_region_images[_new_lead.case_type];
		progress_on_completion_text.text = localisation_asset.checkTranslation(loc_prime_suspects_key, englishPrimeSuspects, _check_keywords: false) + "\n" + _new_lead.prime_suspect_set.set_name;
		if (_new_lead is DocksLead docksLead)
		{
			progression_type_text.text = localisation_asset.checkTranslation(loc_arrested_prog_key, englishEvilArrested, _check_keywords: false);
			cases_remaining_text.text = $"{docksLead.evil_arrested} / {docksLead.needed_arrested}";
		}
		else
		{
			progression_type_text.text = localisation_asset.checkTranslation(loc_cases_prog_key, englishCasesSolved, _check_keywords: false);
			cases_remaining_text.text = $"{_new_lead.current_case} / {_new_lead.max_case}";
		}
		for (int i = 0; i < prime_suspect_visuals.Count; i++)
		{
			if (current_lead.prime_suspect_set.set_roles.Count > i)
			{
				prime_suspect_visuals[i].setUp(current_lead.prime_suspect_set.set_roles[i], role_vis_data);
			}
			else
			{
				prime_suspect_visuals[i].setUpEmpty(role_vis_data);
			}
		}
		lead_title_text.text = localisation_asset.checkTranslationWithData(loc_title_key, englishTitle, _new_lead.prime_suspect_set.lead_suffix);
		List<Vector2Int> gridSizes = _new_lead.getGridSizes();
		if (gridSizes.Count == 1)
		{
			grid_sequence_text.text = $"{gridSizes[0].x}x{gridSizes[0].y}";
		}
		else
		{
			string text = "";
			for (int j = 0; j < _new_lead.max_case; j++)
			{
				text += $"{gridSizes[j].x}x{gridSizes[j].y},";
			}
			text.removeFromEnd(1);
			grid_sequence_text.text = text;
		}
		setUpStamps(current_lead.stamps);
	}

	private string englishCasesSolved()
	{
		return "Cases Solved";
	}

	private string englishEvilArrested()
	{
		return "Evil Arrested";
	}

	private void setUpClues(List<Clue> _clues)
	{
		int num = Mathf.Max(_clues.Count, min_clue_boxes);
		float height = 90f * (8f / (float)num);
		for (int i = 0; i < num; i++)
		{
			LeadClueFacade leadClueFacade = UnityEngine.Object.Instantiate(lead_clue_prefab, clues_parent.transform);
			if (i < _clues.Count)
			{
				leadClueFacade.setUp(_clues[i].getName(), _clues[i].getDescription());
			}
			else
			{
				leadClueFacade.setUp("", "");
			}
			leadClueFacade.scaleUp(height);
		}
		clues_parent.checkUpdate();
	}

	private void setUpStamps(List<StampInfo> _stamps)
	{
		for (int i = 0; i < _stamps.Count; i++)
		{
			createStamp(_stamps[i]);
		}
	}

	private StampFacade createStamp(StampInfo _info)
	{
		StampFacade stampFacade = stamp_data[_info.stamp_reference, stamp_parent];
		stampFacade.transform.localPosition = _info.position;
		stampFacade.transform.localEulerAngles = new Vector3(0f, 0f, _info.rotation);
		if (_info.faded)
		{
			stampFacade.setFaded();
		}
		return stampFacade;
	}

	public void prepareForStamp(StampReference _stamp, Action _callback)
	{
		stamp_manager.startStamping(_stamp, stamp_data, delegate(StampInfo _s)
		{
			addStamp(_s);
			_callback();
		});
	}

	private void addStamp(StampInfo _stamp)
	{
		current_lead.applyStamp(_stamp);
		createStamp(_stamp);
	}

	private string englishPrimeSuspects()
	{
		return "Prime Suspects:";
	}

	private string englishTitle(string _data)
	{
		return "LEAD OF " + _data;
	}
}
