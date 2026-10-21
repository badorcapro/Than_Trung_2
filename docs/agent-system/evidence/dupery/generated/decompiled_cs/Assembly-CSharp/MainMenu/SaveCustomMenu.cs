using System.Collections.Generic;
using System.IO;
using System.Linq;
using GRGLib.Save;
using GRGLib.Save.Json;
using GRGLocalisation;
using Localisation;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace MainMenu;

public class SaveCustomMenu : MenuBase, IAmLocalised
{
	public static string custom_leads_folder = "/CustomLeads/";

	public static string custom_lead_save_ext = ".lead";

	[Header("References")]
	[SerializeField]
	private TMP_InputField name_field;

	[SerializeField]
	private TMP_Text result_text;

	[SerializeField]
	private Button save_button;

	[SerializeField]
	private ConfirmationMenu override_menu;

	private List<string> exisiting_presets = new List<string>();

	public CustomLeadPreset to_save { get; private set; }

	public string save_name { get; private set; } = "";

	private AssetKey localisation_asset => LocalisationHelper.misc_asset;

	private string loc_override_confirmation_key => "CustomLeadMenu [override]";

	private string loc_saving_failed_key => "CustomLeadMenu [save_fail]";

	private string loc_invalid_file_name_key => "CustomLeadMenu [invalid_name]";

	public void setSaving(CustomLeadPreset _preset)
	{
		to_save = _preset;
	}

	protected override void onMenuOpening()
	{
		base.onMenuOpening();
		exisiting_presets = FileHandler.getFilesInDirectory(custom_leads_folder, custom_lead_save_ext, _return_full_path: false).ToList();
		name_field.SetTextWithoutNotify(to_save.prime_suspects.set_name);
		setName(to_save.prime_suspects.set_name);
	}

	public void setName(string _save_name)
	{
		save_name = _save_name;
		save_button.interactable = seemsValid(save_name);
		if (save_button.interactable)
		{
			result_text.text = "";
		}
		else
		{
			result_text.text = localisation_asset.checkTranslation(loc_invalid_file_name_key, englishInvalidFileName, _check_keywords: false);
		}
	}

	private string englishInvalidFileName()
	{
		return "Invalid file name.";
	}

	private bool seemsValid(string _name)
	{
		if (_name.Length < 2)
		{
			return false;
		}
		if (_name.Contains('/'))
		{
			return false;
		}
		if (_name.Contains('.'))
		{
			return false;
		}
		if (_name.Contains('\\'))
		{
			return false;
		}
		char[] invalid_chars = Path.GetInvalidFileNameChars();
		if (_name.Any((char _c) => invalid_chars.Contains(_c)))
		{
			return false;
		}
		return true;
	}

	public void trySave()
	{
		if (save_button.interactable)
		{
			if (exisiting_presets.Contains(save_name + custom_lead_save_ext))
			{
				openConfirmationMenu(override_menu, overrideConfirmationText(), forceSave, delegate
				{
				});
			}
			else
			{
				forceSave();
			}
		}
	}

	private string overrideConfirmationText()
	{
		return localisation_asset.checkTranslation(loc_override_confirmation_key, englishOverrideConfirmation, _check_keywords: false);
	}

	private string englishOverrideConfirmation()
	{
		return "Are you sure you wish to override this preset?";
	}

	private void forceSave()
	{
		if (to_save.SaveData(save_name + custom_lead_save_ext, custom_leads_folder))
		{
			closeMenu();
		}
		else
		{
			result_text.text = localisation_asset.checkTranslation(loc_saving_failed_key, englishFailedToSave, _check_keywords: false);
		}
	}

	private string englishFailedToSave()
	{
		return "Preset failed to save.";
	}
}
