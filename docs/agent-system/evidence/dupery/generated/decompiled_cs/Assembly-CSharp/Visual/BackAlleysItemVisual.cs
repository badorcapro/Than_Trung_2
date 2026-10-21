using System;
using System.Collections;
using GRGLib.Coroutines;
using GRGLib.Extensions.Unity;
using TMPro;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;

namespace Visual;

public class BackAlleysItemVisual : MonoBehaviour
{
	public static Vector2 canvas_size = new Vector2(3840f, 2160f);

	[Header("References")]
	[SerializeField]
	private CanvasGroup group;

	[SerializeField]
	private Image item_icon;

	[SerializeField]
	private TMP_Text item_usages;

	private int usages_remaining;

	private CoroutineRunner drag_runner;

	public BackAlleysItemType type { get; private set; }

	public BackAlleysItem item_data { get; private set; }

	public string item_name { get; private set; }

	public BackAlleysItemColour colour { get; private set; }

	public string item_description { get; private set; }

	public bool wait_controller_release { get; private set; }

	public void setUp(BackAlleysItem _item, Sprite _item_icon)
	{
		drag_runner = new CoroutineRunner(this);
		item_data = _item;
		item_icon.sprite = _item_icon;
		type = _item.type;
		item_name = _item.name;
		item_description = _item.description;
		usages_remaining = _item.uses_remaining;
		colour = _item.colour;
		updateItemUsages();
	}

	public void renew(BackAlleysItem _item)
	{
		item_data = _item;
		if (usages_remaining != _item.uses_remaining)
		{
			usages_remaining = _item.uses_remaining;
			updateItemUsages();
		}
	}

	private void updateItemUsages()
	{
		if (usages_remaining >= 0)
		{
			item_usages.gameObject.SetActive(value: true);
			item_usages.text = $"x{usages_remaining}";
		}
		else
		{
			item_usages.gameObject.SetActive(value: false);
		}
	}

	public void destroySelf()
	{
		item_icon.fade(0f, 0.5f, CoroutineExtensions.easeInOutFunc).start(this);
		base.transform.scaleTransform(0f, 0.5f, CoroutineExtensions.easeInOutBackFunc).addCallback(delegate
		{
			UnityEngine.Object.Destroy(base.gameObject);
		}).start(this);
	}

	public void dragItem(Action _on_stop)
	{
		if (GameHandler.instance.using_gamepad)
		{
			waitForControllerSouthRelease(_on_stop).start(this);
			return;
		}
		drag_runner.run(followMouse());
		checkButtonRelease(_on_stop).start(this);
	}

	public void controllerDragItemToSlot(BackAlleysSlotVisual _slot)
	{
		base.transform.SetParent(_slot.transform);
		drag_runner.run(base.transform.moveTransform(Vector2.zero, 0.35f, CoroutineExtensions.easeInOutFunc));
	}

	private IEnumerator followMouse()
	{
		yield return base.transform.moveTransformToMovingTarget(() => getMousePosition(), 0.35f, CoroutineExtensions.easeInOutFunc);
		while (true)
		{
			base.transform.localPosition = getMousePosition();
			yield return null;
		}
	}

	private IEnumerator checkButtonRelease(Action _on_stop)
	{
		while (!Mouse.current.leftButton.wasReleasedThisFrame)
		{
			yield return null;
		}
		drag_runner.stop();
		_on_stop();
	}

	private IEnumerator waitForControllerSouthRelease(Action _on_stop)
	{
		wait_controller_release = true;
		while (wait_controller_release)
		{
			yield return null;
		}
		_on_stop();
	}

	public void controllerReleased()
	{
		wait_controller_release = false;
	}

	private Vector2 getMousePosition()
	{
		return canvas_size.getPositionToUI(Pointer.current.position.ReadValue());
	}

	public void setInteractableState(bool _interactable)
	{
		group.interactable = _interactable;
		group.blocksRaycasts = _interactable;
	}
}
