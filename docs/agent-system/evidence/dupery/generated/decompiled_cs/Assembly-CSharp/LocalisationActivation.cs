using System.Collections.Generic;
using GRGLocalisation;
using UnityEngine;

public class LocalisationActivation : MonoBehaviour
{
	[Header("Settings")]
	[SerializeField]
	private bool white_list;

	[SerializeField]
	private List<Languages> languages;

	private void Awake()
	{
		bool active = (white_list ? languages.Contains(GRGLocalisationHandler.instance.current_language) : (!languages.Contains(GRGLocalisationHandler.instance.current_language)));
		base.gameObject.SetActive(active);
	}
}
