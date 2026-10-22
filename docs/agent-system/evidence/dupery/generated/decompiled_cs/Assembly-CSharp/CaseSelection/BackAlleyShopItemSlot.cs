using System;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using UnityEngine;
using Visual;

namespace CaseSelection;

public class BackAlleyShopItemSlot : MonoBehaviour, IAmItemVisualised
{
	[SerializeField]
	private BackAlleysItemVisualDataSO items_data;

	[Header("References")]
	[SerializeField]
	private RectTransform item_parent;

	[Header("Prefabs")]
	[SerializeField]
	private BackAlleyShopItem item_prefab;

	private Maybe<BackAlleyShopItem> item = new Maybe<BackAlleyShopItem>();

	private Func<BackAlleysItemType, int, bool> try_buy_item;

	private ItemVisualHelper visualiser;

	public MonoBehaviour mono => this;

	public bool is_full => item.is_some;

	public string title
	{
		get
		{
			if (!is_full)
			{
				return "";
			}
			return item.value.title;
		}
	}

	public string colour_name
	{
		get
		{
			if (!is_full)
			{
				return "";
			}
			return item.value.colour.toString();
		}
	}

	public string description
	{
		get
		{
			if (!is_full)
			{
				return "";
			}
			return item.value.description;
		}
	}

	public void setItem(BackAlleysItemType _item, Func<BackAlleysItemType, int, bool> _try_buy, ItemVisualHelper _visualiser)
	{
		visualiser = _visualiser;
		try_buy_item = _try_buy;
		BackAlleyShopItem backAlleyShopItem = UnityEngine.Object.Instantiate(item_prefab, item_parent);
		backAlleyShopItem.transform.localPosition = new Vector3(0f, 0f, 0f);
		backAlleyShopItem.setUp(_item, items_data[_item], RandomExtensions.freshRandom());
		item = backAlleyShopItem.maybe();
	}

	public void tryBuyItem()
	{
		if (item.is_some && try_buy_item(item.value.item_type, item.value.price))
		{
			item.value.onBuy();
			item = new Maybe<BackAlleyShopItem>();
		}
	}

	public void onHover()
	{
		visualiser.checkDestination(this, base.transform.position);
	}

	public void onUnhover()
	{
		visualiser.tryClose(this);
	}
}
