using System.Collections;
using GRGLib.Coroutines;
using GRGLib.Extensions.Unity;
using GRGLib.Menus;
using GRGLocalisation;
using Localisation;
using TMPro;
using UnityEngine;
using UnityEngine.InputSystem;

namespace Visual;

public class NavigationVisualHelper : HoverMenu, IAmLocalised
{
	[Header("Reference")]
	[SerializeField]
	private TMP_Text text;

	[Header("Settings")]
	[SerializeField]
	private Vector2 box_diff;

	private CoroutineRunner movement_runner;

	private CoroutineRunner follow_mouse_runner;

	private string key = "nav_helper [fuel_cost]";

	public Vector2 mouse_pos => new Vector2(3840f, 2160f).getPositionToUI(Pointer.current.position.ReadValue());

	private AssetKey localisation_asset => LocalisationHelper.ui_asset;

	private void Start()
	{
		movement_runner = new CoroutineRunner(this);
		follow_mouse_runner = new CoroutineRunner(this);
	}

	public void checkDestination(EmptySlot _open, Vector2 _box_pos, int _fuel_cost)
	{
		tryOpen(_open);
		if (GRGLocalisationHandler.needs_translation && GRGLocalisationHandler.instance.translateAndReplace(localisation_asset, key, out var _result, $"<b>{_fuel_cost}</b>"))
		{
			text.text = _result;
		}
		else
		{
			text.text = englishText($"<b>{_fuel_cost}</b>");
		}
		if (GameHandler.instance.using_gamepad)
		{
			movement_runner.run(base.transform.moveTransform(_box_pos + box_diff, 0.25f, CoroutineExtensions.easeInOutFunc));
		}
		if (!follow_mouse_runner.is_running)
		{
			follow_mouse_runner.run(followMouse());
		}
	}

	private string englishText(string _data)
	{
		return "Move boat here.\nEstimated Fuel cost: " + _data;
	}

	protected override void onMenuClosed()
	{
		base.onMenuClosed();
		follow_mouse_runner.stop();
	}

	private IEnumerator followMouse()
	{
		while (true)
		{
			if (!GameHandler.instance.using_gamepad)
			{
				movement_runner.stop();
				base.transform.localPosition = mouse_pos;
			}
			yield return null;
		}
	}
}
