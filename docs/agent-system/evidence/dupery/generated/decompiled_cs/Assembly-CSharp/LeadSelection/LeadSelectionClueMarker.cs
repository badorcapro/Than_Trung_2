using GRGLocalisation;
using Lineup;
using Localisation;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace LeadSelection;

public class LeadSelectionClueMarker : MonoBehaviour, IAmLocalised
{
	[Header("References")]
	[SerializeField]
	private Image image;

	[SerializeField]
	private Button button;

	[SerializeField]
	private MenuBase clue_menu;

	[SerializeField]
	private TMP_Text clue_nb_text;

	[SerializeField]
	private TMP_Text clue_text;

	private LineupClue clue;

	private AssetKey localisation_asset => LocalisationHelper.misc_asset;

	private string loc_clue_key => "CLUE #";

	public void setUp(LineupClue _clue, int _nb, Sprite _clue_sprite)
	{
		image.sprite = _clue_sprite;
		image.SetNativeSize();
		clue = _clue;
		clue_nb_text.text = localisation_asset.checkTranslationWithData(loc_clue_key, englishClue, _nb);
		clue_text.text = _clue.clue_text;
	}

	public void onHover(bool _on)
	{
		if (_on)
		{
			clue_menu.openMenu();
		}
		else
		{
			clue_menu.closeMenu();
		}
	}

	private string englishClue(string _d1)
	{
		return "CLUE #" + _d1;
	}
}
