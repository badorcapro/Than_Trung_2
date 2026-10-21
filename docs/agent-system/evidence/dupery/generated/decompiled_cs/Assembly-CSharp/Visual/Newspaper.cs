using System.Collections.Generic;
using GRGLocalisation;
using Localisation;
using TMPro;
using UnityEngine;

namespace Visual;

public class Newspaper : MonoBehaviour, IAmLocalised
{
	[Header("References")]
	[SerializeField]
	private RectTransform reputation_marker;

	[SerializeField]
	private TMP_Text headline_text;

	[SerializeField]
	private TMP_Text reputation_change_text;

	[SerializeField]
	private GameObject hidden_overlay;

	[Header("Settings")]
	[SerializeField]
	private List<float> marker_positions;

	private string gain_english => "The famous detective gains reputation!";

	private string lose_english => "The famous detective loses reputation!";

	private string loc_gain_key => "Reputation [gain]";

	private string loc_loss_key => "Reputation [loss]";

	private AssetKey localisation_asset => LocalisationHelper.ui_asset;

	public void setUp(int _reputation, string _headline, bool _gain)
	{
		_reputation = Mathf.Clamp(_reputation, 0, 6);
		if (_reputation < 0)
		{
			_reputation = 0;
		}
		reputation_marker.localPosition = new Vector3(marker_positions[_reputation], reputation_marker.localPosition.y);
		headline_text.text = _headline;
		reputation_change_text.text = getReputationChangeText(_gain);
	}

	public void hide()
	{
		reputation_marker.gameObject.SetActive(value: false);
		hidden_overlay.gameObject.SetActive(value: true);
	}

	private string getReputationChangeText(bool _gain)
	{
		if (GRGLocalisationHandler.needs_translation && GRGLocalisationHandler.instance.translate(localisation_asset, _gain ? loc_gain_key : loc_loss_key, out var _result))
		{
			return _result;
		}
		if (!_gain)
		{
			return lose_english;
		}
		return gain_english;
	}
}
