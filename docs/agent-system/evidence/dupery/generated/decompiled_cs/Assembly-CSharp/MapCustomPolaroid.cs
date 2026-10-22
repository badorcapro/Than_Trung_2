using GRGLocalisation;
using Localisation;
using MainMenu;
using UnityEngine;
using UnityEngine.UI;

public class MapCustomPolaroid : MapPolaroid, IAmLocalised
{
	[SerializeField]
	private MenuBase map_menu;

	[SerializeField]
	private CustomLeadMenu custom_leads_menu;

	[SerializeField]
	private AlternativeModesMenu alternate_modes_menu;

	[SerializeField]
	private Image custom_image;

	private string custom_localised => localisation_asset.checkTranslation("CUSTOM", () => "CUSTOM", _check_keywords: false);

	private AssetKey localisation_asset => LocalisationHelper.ui_asset;

	public void setUp(bool _discovered)
	{
		setDiscovered(_discovered);
		if (!_discovered)
		{
			title.text = "???";
			custom_image.color = new Color(0.5f, 0.5f, 0.5f, 0.1f);
		}
		else
		{
			title.text = custom_localised;
			custom_image.color = Color.white;
		}
	}

	public void onHover()
	{
		if (base.discovered)
		{
			openExtension();
		}
	}

	public void onUnhover()
	{
		closeExtension();
	}

	public void onCustomLeads()
	{
		map_menu.openNewMenu(custom_leads_menu);
	}

	public void onAlternateModes()
	{
		map_menu.openNewMenu(alternate_modes_menu);
	}

	public void onCustomCases()
	{
	}

	public void onCaseCreator()
	{
	}

	protected override void onA()
	{
		onCustomLeads();
	}

	protected override void onX()
	{
		onAlternateModes();
	}

	protected override void onY()
	{
		onCaseCreator();
	}
}
