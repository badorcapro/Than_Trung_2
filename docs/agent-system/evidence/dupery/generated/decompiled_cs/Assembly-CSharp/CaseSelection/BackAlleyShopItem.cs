using System;
using GRGLib.Coroutines;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace CaseSelection;

public class BackAlleyShopItem : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private Image item_icon;

	[SerializeField]
	private TMP_Text item_name;

	[SerializeField]
	private TMP_Text item_price;

	public BackAlleysItemType item_type { get; private set; }

	public string title => item_name.text;

	public BackAlleysItemColour colour { get; private set; }

	public string description { get; private set; }

	public int price { get; private set; }

	public void setUp(BackAlleysItemType _item, Sprite _icon, System.Random _rng)
	{
		item_type = _item;
		item_icon.sprite = _icon;
		BackAlleysItem backAlleysItem = _item.createItem(_rng);
		item_name.text = backAlleysItem.name;
		description = backAlleysItem.description;
		price = backAlleysItem.random_price;
		item_price.text = $"{price}{TextHelper.credits_sprite_link}";
		colour = backAlleysItem.colour;
	}

	public void onBuy()
	{
		Debug.Log("Item bought");
		base.transform.scaleTransform(0f, 0.35f, CoroutineExtensions.easeInOutFunc).addCallback(delegate
		{
			UnityEngine.Object.Destroy(base.gameObject);
		}).start(this);
	}
}
