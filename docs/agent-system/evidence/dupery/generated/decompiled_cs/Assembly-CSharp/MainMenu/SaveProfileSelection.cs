using GRGLocalisation;
using Localisation;
using Save;
using TMPro;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;

namespace MainMenu;

public class SaveProfileSelection : MonoBehaviour, IAmLocalised
{
	[Header("References")]
	[SerializeField]
	private MainMenu main_menu;

	[SerializeField]
	private PlayerInput input;

	[SerializeField]
	private TMP_InputField name_input_text;

	[SerializeField]
	private Button left_button;

	[SerializeField]
	private Button right_button;

	private int profile_number = 1;

	private AssetKey localisation_asset => LocalisationHelper.ui_asset;

	private string loc_save_key => "MM [save]";

	private void Start()
	{
		profile_number = SaveHandler.instance.save_file_number + 1;
		onProfileChange();
	}

	public void changeProfile(bool _direction)
	{
		SettingsHandler.save_number += (_direction ? 1 : (-1));
		profile_number = Mathf.Clamp(SaveHandler.instance.save_file_number + 1, 1, SaveHandler.max_save_files);
		if (input.getInputType() != 0)
		{
			if (profile_number == 1)
			{
				right_button.Select();
			}
			else if (profile_number == SaveHandler.max_save_files)
			{
				left_button.Select();
			}
		}
		onProfileChange();
		main_menu.checkSaveReliantUI();
	}

	private void onProfileChange()
	{
		checkName();
		left_button.interactable = profile_number > 1;
		right_button.interactable = profile_number < SaveHandler.max_save_files;
	}

	public void onNameChange(string _name)
	{
		GameHandler.MetaData.file_name = _name.Trim();
	}

	public void onEndEdit(string _name)
	{
		onNameChange(_name);
		SaveHandler.instance.saveMetaData();
		checkName();
	}

	public void checkName()
	{
		if (GameHandler.MetaData.file_name.Length > 0)
		{
			name_input_text.SetTextWithoutNotify(GameHandler.MetaData.file_name);
		}
		else
		{
			name_input_text.SetTextWithoutNotify(localisation_asset.checkTranslationWithData(loc_save_key, englishSave, profile_number));
		}
	}

	private string englishSave(string _d1)
	{
		return "Save " + _d1;
	}
}
