using System.Collections.Generic;
using GRGLib.Serializable;
using GRGLocalisation;
using Localisation;
using UnityEngine;
using UnityEngine.UI;

namespace Lineup;

public class LineupSuspect : MonoBehaviour, IAmLocalised
{
	public enum SuspectElements
	{
		FEMALE_BODY_1 = 0,
		FEMALE_BODY_2 = 1,
		FEMALE_BODY_3 = 3,
		FEMALE_SCAR_1 = 10,
		FEMALE_SCAR_2 = 11,
		FEMALE_SCAR_3 = 12,
		FEMALE_SCAR_4 = 13,
		FEMALE_HAIR_1 = 20,
		FEMALE_HAIR_2 = 21,
		FEMALE_HAIR_3 = 22,
		FEMALE_HAIR_4 = 23,
		FEMALE_HAIR_5 = 24,
		FEMALE_HAIR_6 = 25,
		FEMALE_HAT_1 = 30,
		FEMALE_HAT_2 = 31,
		FEMALE_HAT_3 = 32,
		FEMALE_EAR_1 = 50,
		FEMALE_FACE_1 = 60,
		FEMALE_FACE_2 = 61,
		FEMALE_FACE_3 = 62,
		FEMALE_FACE_4 = 63,
		FEMALE_FACE_5 = 64,
		FEMALE_GLASSES_1 = 70,
		FEMALE_GLASSES_2 = 71,
		MALE_BODY_1 = 100,
		MALE_BODY_2 = 101,
		MALE_BODY_3 = 103,
		MALE_SCAR_1 = 110,
		MALE_SCAR_2 = 111,
		MALE_SCAR_3 = 112,
		MALE_SCAR_4 = 113,
		MALE_HAIR_1 = 120,
		MALE_HAIR_2 = 121,
		MALE_HAIR_3 = 122,
		MALE_HAIR_4 = 123,
		MALE_HAIR_5 = 124,
		MALE_HAIR_6 = 125,
		MALE_HAT_1 = 130,
		MALE_HAT_2 = 131,
		MALE_HAT_3 = 132,
		MALE_FACE_HAIR_1 = 140,
		MALE_FACE_HAIR_2 = 141,
		MALE_FACE_HAIR_3 = 142,
		MALE_FACE_HAIR_4 = 143,
		MALE_EAR_1 = 150,
		MALE_FACE_1 = 160,
		MALE_FACE_2 = 161,
		MALE_FACE_3 = 162,
		MALE_FACE_4 = 163,
		MALE_FACE_5 = 164,
		MALE_GLASSES_1 = 170,
		MALE_GLASSES_2 = 171
	}

	[Header("References")]
	[SerializeField]
	private RectTransform male_head;

	[SerializeField]
	private RectTransform female_head;

	[SerializeField]
	private SerializableDictionary<SuspectElements, RectTransform> body_elements = new SerializableDictionary<SuspectElements, RectTransform>();

	[SerializeField]
	private SerializableDictionary<SuspectElements, LineupSuspectInfobox> info_boxes = new SerializableDictionary<SuspectElements, LineupSuspectInfobox>();

	private bool is_male;

	private List<SuspectElements> selected_elements;

	private LineupSuspectInfobox current_info_box;

	private List<Image> images = new List<Image>();

	public GameObject shadow { get; private set; }

	private string loc_male_key => "Suspect [male]";

	private string loc_female_key => "Suspect [female]";

	private AssetKey localisation_asset => LocalisationHelper.lineup_asset;

	public void createSuspect(LineupSuspectInfo _clues, int _suspect_number)
	{
		resetSuspect();
		is_male = _clues.male;
		selected_elements = _clues.suspect_elements;
		SuspectElements key = selected_elements.Find((SuspectElements _b) => info_boxes.ContainsKey(_b));
		if (!info_boxes.ContainsKey(key))
		{
			Debug.LogError("Could not find info box with given elements!");
		}
		else
		{
			current_info_box = info_boxes[key];
		}
		buildSuspect(SuspectClueHelper.createName(_clues), _suspect_number, _clues.age.ToString(), SuspectClueHelper.getHeightString(_clues.height_index), getGenderString(is_male));
		base.transform.localPosition = new Vector3(base.transform.localPosition.x, base.transform.localPosition.y + (float)_clues.height_index * 3.5f - 20f);
		base.transform.localScale = new Vector3(0.97f + (float)_clues.height_index * 0.003f, 0.97f + (float)_clues.height_index * 0.003f);
		shadow = Object.Instantiate(base.gameObject, base.transform);
		shadow.transform.SetSiblingIndex(0);
		shadow.GetComponent<LineupSuspect>().setFadeColour(1f);
		(shadow.transform as RectTransform).anchoredPosition = new Vector2(0f, 0f);
	}

	private void resetSuspect()
	{
		male_head.gameObject.SetActive(value: false);
		female_head.gameObject.SetActive(value: false);
		foreach (RectTransform value in body_elements.Values)
		{
			value.gameObject.SetActive(value: false);
		}
	}

	private void Awake()
	{
		List<RectTransform> list = new List<RectTransform> { male_head, female_head };
		foreach (RectTransform value in body_elements.Values)
		{
			list.Add(value);
		}
		foreach (RectTransform item in list)
		{
			images.Add(item.GetComponent<Image>());
		}
	}

	public void setFadeColour(float _01)
	{
		Color val = Color.Lerp(Color.white, Color.black, _01);
		images.ForEach(delegate(Image _e)
		{
			_e.color = val;
		});
	}

	private void buildSuspect(string _name, int _suspect_number, string _age, string _height, string _gender)
	{
		if (is_male)
		{
			male_head.gameObject.SetActive(value: true);
		}
		else
		{
			female_head.gameObject.SetActive(value: true);
		}
		selected_elements.ForEach(delegate(SuspectElements _e)
		{
			body_elements[_e].gameObject.SetActive(value: true);
		});
		current_info_box.updateText(_name, _suspect_number, _age, _height, _gender);
	}

	private string getGenderString(bool _male)
	{
		if (!_male)
		{
			return localisation_asset.checkTranslation(loc_female_key, englishFemale);
		}
		return localisation_asset.checkTranslation(loc_male_key, englishMale);
	}

	private string englishMale()
	{
		return "MALE";
	}

	private string englishFemale()
	{
		return "FEMALE";
	}
}
