using System.Collections.Generic;
using GRGLib.UI;
using UnityEngine;

namespace Visual;

public class BackAlleysItemInfoVisualManager : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private AnimatedLayoutGroup layout_group;

	[Header("Prefabs")]
	[SerializeField]
	private BackAlleysItemInfoCard info_card_prefab;

	private List<BackAlleysItemInfoCard> info_cards = new List<BackAlleysItemInfoCard>();

	public void renew(List<string> _info)
	{
		for (int i = 0; i < _info.Count; i++)
		{
			if (info_cards.Count <= i)
			{
				BackAlleysItemInfoCard backAlleysItemInfoCard = Object.Instantiate(info_card_prefab, layout_group.transform);
				backAlleysItemInfoCard.setText(_info[i]);
				info_cards.Add(backAlleysItemInfoCard);
			}
		}
		layout_group.checkUpdate();
	}
}
