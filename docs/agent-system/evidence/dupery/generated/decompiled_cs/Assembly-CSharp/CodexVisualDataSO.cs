using GRGLib.Extensions.Collections;
using GRGLib.Serializable;
using UnityEngine;

[CreateAssetMenu(menuName = "ScriptableObject/Codex Visual Data SO")]
public class CodexVisualDataSO : ScriptableObject
{
	[Header("Settings")]
	[SerializeField]
	private SerializableDictionary<DescriptionType, Sprite> description_symbols;

	public Sprite this[DescriptionType _type] => getDescriptionIcon(_type);

	private Sprite getDescriptionIcon(DescriptionType _type)
	{
		return description_symbols.getOrDefault(_type, description_symbols[DescriptionType.SPECIAL]);
	}
}
