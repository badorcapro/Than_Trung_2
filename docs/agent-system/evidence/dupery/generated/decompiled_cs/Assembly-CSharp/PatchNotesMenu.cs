using System.Collections;
using GRGLib.Coroutines;
using GRGLib.Extensions;
using Save;
using UnityEngine;
using UnityEngine.UI;

public class PatchNotesMenu : MenuBase
{
	[Header("References")]
	[SerializeField]
	private RectTransform menu_base;

	[SerializeField]
	private Selectable select_on_close;

	protected override void Awake()
	{
		if (SaveHandler.instance.meta_save_version.equalToAny(SaveHandler.SaveDataVersions.NEWEST, SaveHandler.SaveDataVersions.INVALID))
		{
			Object.Destroy(base.gameObject);
		}
		else
		{
			base.Awake();
		}
	}

	public void openSteamAnnoucmentsURL()
	{
		SteamHandler.openUrlInSteamOverlay("https://store.steampowered.com/news/app/3845070/view/582779932700049676");
	}

	protected override IEnumerator openingMenuAnimation()
	{
		menu_group.alpha = 1f;
		yield return menu_base.scaleTransform(1f, 0.35f, CoroutineExtensions.easeInOutFunc);
	}

	protected override IEnumerator closingMenuAnimation()
	{
		yield return menu_base.scaleTransform(0f, 0.35f, CoroutineExtensions.easeInOutFunc);
		menu_group.alpha = 0f;
	}

	protected override void onMenuClosed()
	{
		base.onMenuClosed();
		if (GameHandler.instance.using_gamepad)
		{
			select_on_close.Select();
		}
	}
}
