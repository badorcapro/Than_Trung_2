using System;
using System.Collections.Generic;
using GRGLib.Extensions.String;
using GRGLocalisation;
using Localisation;
using Nodes.Logic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class TimeExlusiveRoleDisplay : MonoBehaviour, IAmLocalised
{
	[Header("Settings")]
	[SerializeField]
	private int day;

	[SerializeField]
	private int month;

	[SerializeField]
	private int hour;

	[SerializeField]
	private RoleSetsGraph temporary_set;

	[SerializeField]
	private Color set_name_colour;

	[Header("References")]
	[SerializeField]
	private List<TMP_Text> role_name_text;

	[SerializeField]
	private List<Image> role_icons;

	[SerializeField]
	private TMP_Text name_text;

	[SerializeField]
	private TMP_Text timer_text;

	[SerializeField]
	private RoleVisualDataSO role_visuals;

	private string base_next_text = "";

	private AssetKey localisation_asset => LocalisationHelper.ui_asset;

	private string loc_new_roles_key => "DemoTemp [new_roles]";

	private string loc_next_key => "DemoTemp [next_set]";

	private void Start()
	{
		name_text.text = localisation_asset.checkTranslationWithData(loc_new_roles_key, englishNewElusiveRoles, temporary_set.getSetName().sandwichWithColour(set_name_colour));
		base_next_text = localisation_asset.checkTranslation(loc_next_key, englishNextSet);
	}

	private void setRole(Roles _role, int _index)
	{
		role_icons[_index].sprite = role_visuals[_role];
		role_icons[_index].color = role_visuals[_role.getClassificationFromRoleType()].class_colour;
		role_name_text[_index].text = _role.toString();
	}

	private void Update()
	{
		TimeSpan timeSpan = new DateTime(DateTime.UtcNow.Year, month, day, hour - 1, 0, 0) - DateTime.UtcNow;
		timer_text.text = base_next_text.Replace(LocalisationHelper.text_marker_1, timeSpan.Days.ToString()).Replace(LocalisationHelper.text_marker_2, timeSpan.Hours.ToString()).Replace(LocalisationHelper.text_marker_3, timeSpan.Minutes.ToString())
			.Replace(LocalisationHelper.text_marker_4, timeSpan.Seconds.ToString());
	}

	private string englishNewElusiveRoles(string _data)
	{
		return "New Time Exclusive Roles: " + _data;
	}

	private string englishNextSet()
	{
		return "Next Set In: " + LocalisationHelper.text_marker_1 + "d " + LocalisationHelper.text_marker_2 + "h " + LocalisationHelper.text_marker_3 + "m " + LocalisationHelper.text_marker_4 + "s";
	}
}
