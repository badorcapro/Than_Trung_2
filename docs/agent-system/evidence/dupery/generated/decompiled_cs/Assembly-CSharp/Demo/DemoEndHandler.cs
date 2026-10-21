using GRGLocalisation;
using Localisation;
using UnityEngine;
using UnityEngine.UI;
using Visual;

namespace Demo;

public class DemoEndHandler : MonoBehaviour, IAmLocalised
{
	[Header("References")]
	[SerializeField]
	private CanvasGroup demo_menu_canvas;

	[SerializeField]
	private TextBox demo_text;

	[SerializeField]
	private Selectable initial_select;

	[Header("Special Localisation Settings")]
	[SerializeField]
	private Image community_button_image;

	[SerializeField]
	private Sprite discord_icon;

	[SerializeField]
	private Sprite qq_icon;

	[SerializeField]
	private GameObject qq_qr_code;

	private AssetKey localisation_asset => LocalisationHelper.ui_asset;

	private string loc_demoend_key => "DemoEnd [base]";

	private string loc_newMode_key => "DemoEnd [new]";

	private string loc_quirkI_key => "Quirk Challenge I";

	private string loc_quirkII_key => "Quirk Challenge II";

	private string loc_quirkIII_key => "Quirk Challenge III";

	private string loc_allBeat_key => "DemoEnd [allBeat]";

	public void backToMainMenu()
	{
		GameHandler.instance.moveToScene("MainMenuScene");
	}

	public void openUrl(string _url)
	{
		_url.openUrl();
	}

	public void openCommunityLink()
	{
		if (GRGLocalisationHandler.instance.current_language == Languages.CHINESE_SIMPLIFIED)
		{
			"https://qm.qq.com/q/holtUCsdNK".openUrl();
		}
		else
		{
			"https://discord.gg/6gD6UJCMbt".openUrl();
		}
	}
}
