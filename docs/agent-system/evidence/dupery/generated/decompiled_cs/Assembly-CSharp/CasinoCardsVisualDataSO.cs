using System.Collections.Generic;
using GRGLib.Serializable;
using UnityEngine;

[CreateAssetMenu(menuName = "ScriptableObject/Cards Visual Data SO")]
public class CasinoCardsVisualDataSO : ScriptableObject
{
	[Header("Settings")]
	[SerializeField]
	private SerializableDictionary<CasinoCardInfo.Suit, List<Sprite>> cards;

	[SerializeField]
	private Sprite joker;

	public Sprite this[CasinoCardInfo _info] => getCardSprite(_info);

	public Sprite this[CasinoCard _card] => getCardSprite(_card.info);

	private Sprite getCardSprite(CasinoCardInfo _info)
	{
		return cards[_info.suit][_info.value - 1];
	}

	public Sprite getJokerSprite()
	{
		return joker;
	}
}
