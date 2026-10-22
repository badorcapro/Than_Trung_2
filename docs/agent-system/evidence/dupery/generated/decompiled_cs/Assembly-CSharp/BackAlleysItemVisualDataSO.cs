using GRGLib.Serializable;
using UnityEngine;

[CreateAssetMenu(menuName = "ScriptableObject/Item Visual Data SO")]
public class BackAlleysItemVisualDataSO : ScriptableObject
{
	[Header("Settings")]
	[SerializeField]
	private SerializableDictionary<BackAlleysItemType, Sprite> item_icons;

	[SerializeField]
	private Sprite backup_icon;

	[SerializeField]
	private SerializableDictionary<BackAlleysItemColour, Color> item_colours;

	[SerializeField]
	private Color backup_colour;

	public Sprite this[BackAlleysItemType _item] => getItemIcon(_item);

	public Color this[BackAlleysItemColour _colour] => getItemColour(_colour);

	private Sprite getItemIcon(BackAlleysItemType _item)
	{
		if (!item_icons.ContainsKey(_item))
		{
			return backup_icon;
		}
		return item_icons[_item];
	}

	private Color getItemColour(BackAlleysItemColour _colour)
	{
		if (!item_colours.ContainsKey(_colour))
		{
			return backup_colour;
		}
		return item_colours[_colour];
	}
}
