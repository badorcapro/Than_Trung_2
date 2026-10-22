using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using GRGLib.Save;
using GRGLib.Save.Json;
using GRGLib.UI;
using GRGLocalisation;
using Localisation;
using TMPro;
using UnityEngine;

namespace MainMenu;

public class LoadCustomMenu : MenuBase, IAmLocalised
{
	[Header("References")]
	[SerializeField]
	private TMP_InputField filter;

	[SerializeField]
	private RectTransform custom_lead_parents;

	[SerializeField]
	private AnimatedLayoutGroup layout_group;

	[SerializeField]
	private TMP_Text error_texts;

	[Header("Prefabs")]
	[SerializeField]
	private LoadCustomElement element_prefab;

	private List<string> all_files = new List<string>();

	private List<LoadCustomElement> all_elements = new List<LoadCustomElement>();

	private Action<CustomLeadPreset> on_select;

	public static string custom_leads_folder => SaveCustomMenu.custom_leads_folder;

	public static string custom_lead_save_ext => SaveCustomMenu.custom_lead_save_ext;

	private AssetKey localisation_asset => LocalisationHelper.misc_asset;

	private string loc_error_key => "CustomLeadLoad [error]";

	public void setUp(Action<CustomLeadPreset> _on_select)
	{
		on_select = _on_select;
		all_files = FileHandler.getFilesInDirectory(custom_leads_folder, custom_lead_save_ext).ToList();
		all_elements.destroyAll();
		filter.SetTextWithoutNotify("");
		for (int i = 0; i < all_files.Count; i++)
		{
			string[] array = all_files[i].Split('/');
			LoadCustomElement loadCustomElement = UnityEngine.Object.Instantiate(element_prefab, custom_lead_parents);
			loadCustomElement.setUp(i, array[^1].Substring(0, array[^1].Length - 5), "", onSelection);
			all_elements.Add(loadCustomElement);
		}
		layout_group.forceUpdateSequential(all_elements.Count, 0.05f);
		custom_lead_parents.sizeDelta = new Vector2(custom_lead_parents.sizeDelta.x, (float)all_elements.Count * ((element_prefab.transform as RectTransform).sizeDelta.y + 10f));
	}

	public void onSearch(string _input)
	{
		all_elements.ForEach(delegate(LoadCustomElement _el)
		{
			_el.checkAgainstSearch(_input);
		});
		layout_group.checkUpdate();
	}

	private void onSelection(int _id)
	{
		Maybe<CustomLeadPreset> maybe = JsonSaveHandler.LoadDataFromSetFolder<CustomLeadPreset>(all_files[_id]);
		if (maybe.is_some)
		{
			on_select(maybe.value);
			closeMenu();
		}
		else
		{
			error_texts.text = localisation_asset.checkTranslation(loc_error_key, englishError, _check_keywords: false);
		}
	}

	private string englishError()
	{
		return "Failed to load preset...";
	}
}
