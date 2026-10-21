using System.Collections;
using GRGLib.Coroutines;
using GRGLib.Extensions.Unity;
using GRGLib.Menus;
using TMPro;
using UnityEngine;
using UnityEngine.InputSystem;

namespace Visual;

public class ItemVisualHelper : HoverMenu
{
	[Header("Reference")]
	[SerializeField]
	private TMP_Text text;

	private CoroutineRunner movement_runner;

	private CoroutineRunner follow_mouse_runner;

	public Vector2 mouse_pos => new Vector2(3840f, 2160f).getPositionToUI(Pointer.current.position.ReadValue());

	private void Start()
	{
		movement_runner = new CoroutineRunner(this);
		follow_mouse_runner = new CoroutineRunner(this);
	}

	public void checkDestination(IAmItemVisualised _slot, Vector2 _box_pos)
	{
		if (_slot.is_full)
		{
			tryOpen(_slot.mono);
			text.text = "<size=125%><b>" + _slot.title + "</b></size>\n" + _slot.colour_name + "<size=30%>\n </size>\n" + _slot.description;
			if (GameHandler.instance.using_gamepad)
			{
				movement_runner.run(base.transform.moveTransformGlobal(_box_pos, 0.25f, CoroutineExtensions.easeInOutFunc));
			}
			if (!follow_mouse_runner.is_running)
			{
				follow_mouse_runner.run(followMouse());
			}
		}
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
