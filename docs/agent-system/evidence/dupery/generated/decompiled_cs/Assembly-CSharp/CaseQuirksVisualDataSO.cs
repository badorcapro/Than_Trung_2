using GRGLib.Serializable;
using UnityEngine;

[CreateAssetMenu(menuName = "ScriptableObject/Case Quirks Visual Data SO")]
public class CaseQuirksVisualDataSO : ScriptableObject
{
	[Header("Settings")]
	[SerializeField]
	private SerializableDictionary<CaseQuirks, Sprite> quirk_icons;

	[SerializeField]
	private Color quirk_text_colour;

	[Space]
	[SerializeField]
	private Sprite backup;

	public Sprite this[CaseQuirks _quirk] => getCaseQuirkIcon(_quirk);

	public Color text_colour => quirk_text_colour;

	private Sprite getCaseQuirkIcon(CaseQuirks _quirk)
	{
		if (quirk_icons.ContainsKey(_quirk))
		{
			return quirk_icons[_quirk];
		}
		return backup;
	}
}
