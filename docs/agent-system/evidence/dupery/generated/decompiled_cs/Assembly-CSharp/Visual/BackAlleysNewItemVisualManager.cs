using System;
using GRGLib.Coroutines;
using GRGLib.Extensions.Unity;
using GRGLib.Maybe;
using GRGLib.UI;
using GRGLocalisation;
using Localisation;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;

namespace Visual;

public class BackAlleysNewItemVisualManager : MenuBase, IAmLocalised
{
	[SerializeField]
	private BackAlleysItemVisualDataSO items_data;

	[Header("References")]
	[SerializeField]
	private BackAlleysPouchVisualManager pouch_manager;

	[SerializeField]
	private RectTransform temporary_slots_parent;

	[SerializeField]
	private Image item_icon;

	[SerializeField]
	private CurveText item_name;

	[SerializeField]
	private Button discard_button;

	[SerializeField]
	private CanvasGroup initial_group;

	private Maybe<Action<Maybe<Vector2Int>>> add_to_slot = new Maybe<Action<Maybe<Vector2Int>>>();

	private Maybe<Transform> previous_parent = new Maybe<Transform>();

	private CoroutineRunner init_group_runner;

	private AssetKey localisation_asset => LocalisationHelper.ui_asset;

	private string loc_key => "gain_item";

	protected override void Awake()
	{
		base.Awake();
		init_group_runner = new CoroutineRunner(this);
	}

	public void setUp(PlayerInput _player_input)
	{
		input = _player_input;
	}

	public void open(BackAlleysItem _item, bool _forced, Action<Maybe<Vector2Int>> _add_to_slot)
	{
		discard_button.interactable = !_forced;
		item_icon.sprite = items_data[_item.type];
		item_icon.SetNativeSize();
		item_name.setText(getGainText(_item));
		add_to_slot = _add_to_slot.maybe();
		openMenu();
	}

	public void onKeep()
	{
		if (!add_to_slot.is_some)
		{
			return;
		}
		Maybe<Vector2Int> firstFreeSlot = pouch_manager.getFirstFreeSlot();
		if (firstFreeSlot.is_some)
		{
			add_to_slot.value(firstFreeSlot);
			add_to_slot = new Maybe<Action<Maybe<Vector2Int>>>();
			closeMenu();
			return;
		}
		RectTransform slotsParent = pouch_manager.getSlotsParent();
		previous_parent = slotsParent.parent.maybe();
		slotsParent.SetParent(temporary_slots_parent);
		pouch_manager.setOnClickCallbacks(onSelectSlotReplace);
		initial_group.interactable = false;
		init_group_runner.run(initial_group.fade(0f, 0.35f, CoroutineExtensions.easeInOutFunc));
		if (GameHandler.instance.using_gamepad)
		{
			pouch_manager.selectFirstSlot();
		}
	}

	private void onSelectSlotReplace(BackAlleysSlotVisual _slot)
	{
		if (add_to_slot.is_some)
		{
			_slot.removeItem();
			if (previous_parent.is_some)
			{
				pouch_manager.getSlotsParent().SetParent(previous_parent.value);
				previous_parent = new Maybe<Transform>();
			}
			add_to_slot.value(_slot.slot_position.maybe());
			add_to_slot = new Maybe<Action<Maybe<Vector2Int>>>();
			pouch_manager.resetClickCallbacks();
			closeMenu();
		}
	}

	public void onDiscard()
	{
		add_to_slot = new Maybe<Action<Maybe<Vector2Int>>>();
		closeMenu();
	}

	protected override void onMenuClosed()
	{
		base.onMenuClosed();
		initial_group.putOn();
	}

	private string getGainText(BackAlleysItem _item)
	{
		if (GRGLocalisationHandler.needs_translation && GRGLocalisationHandler.instance.translateAndReplace(localisation_asset, loc_key, out var _result, _item.name))
		{
			return _result;
		}
		return englishGainText(_item.name);
	}

	private string englishGainText(string _data)
	{
		return "Gained " + _data + "!";
	}
}
