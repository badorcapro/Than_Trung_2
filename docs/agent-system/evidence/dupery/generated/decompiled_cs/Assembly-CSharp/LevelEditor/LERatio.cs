using System.Collections.Generic;
using GRGLocalisation;
using Localisation;
using TMPro;
using UnityEngine;
using Visual;

namespace LevelEditor;

public class LERatio : MonoBehaviour, IAmLocalised
{
	[Header("References")]
	[SerializeField]
	private TMP_Text ratio_text;

	[SerializeField]
	private LEErrorMarker error_marker;

	private AssetKey localisation_asset => LocalisationHelper.misc_asset;

	private string loc_error_class_key => "LE_Ratio [er_class]";

	public bool updateRatio(Dictionary<RoleClassifications, int> _ratio)
	{
		ratio_text.text = RatioVisualManager.getClassRatioString(_ratio);
		if (_ratio[RoleClassifications.INNOCENT] == 0)
		{
			setErrorWarning(localisation_asset.checkTranslationWithData(loc_error_class_key, englishClassMissingError, RoleClassifications.INNOCENT.toStringPlain()));
			return false;
		}
		if (_ratio[RoleClassifications.UNDERLING] == 0)
		{
			setErrorWarning(localisation_asset.checkTranslationWithData(loc_error_class_key, englishClassMissingError, RoleClassifications.UNDERLING.toStringPlain()));
			return false;
		}
		error_marker.closeMenu();
		return true;
	}

	private string englishClassMissingError(string _data)
	{
		return "Must have at least 1 " + _data + " on the board.";
	}

	private void setErrorWarning(string _error)
	{
		error_marker.openWithError(_error);
	}
}
