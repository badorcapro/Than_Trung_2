using GRGLib.Serializable;
using GRGLocalisation;
using UnityEngine;

public class LocalisationDeltaSizeChoice : MonoBehaviour
{
	[Header("Settings")]
	[SerializeField]
	private SerializableDictionary<Languages, Vector2> language_size;

	public RectTransform rect_trans => base.transform as RectTransform;

	private void Awake()
	{
		if (language_size.ContainsKey(GRGLocalisationHandler.instance.current_language))
		{
			rect_trans.sizeDelta = language_size[GRGLocalisationHandler.instance.current_language];
		}
	}
}
