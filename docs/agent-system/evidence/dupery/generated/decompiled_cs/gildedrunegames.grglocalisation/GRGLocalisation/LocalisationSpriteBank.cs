using GRGLib.Serializable;
using UnityEngine;

namespace GRGLocalisation;

[CreateAssetMenu(menuName = "GRGLocalisation/Sprite Bank")]
public class LocalisationSpriteBank : ScriptableObject
{
	[Header("Sprites")]
	[SerializeField]
	private SerializableDictionary<string, Sprite> sprites;

	public Sprite this[string _key] => sprites[_key];
}
