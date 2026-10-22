using TMPro;
using UnityEngine;

namespace GRGLocalisation;

public class LocalisedStaticText : MonoBehaviour, IAmLocalised
{
	[SerializeField]
	protected TMP_Text text;

	[SerializeField]
	protected AssetKey asset;

	[SerializeField]
	protected string key;

	[SerializeField]
	protected bool allow_asset_loading = true;

	protected virtual void Start()
	{
		if (GRGLocalisationHandler.needs_translation)
		{
			translateText();
		}
	}

	protected virtual void translateText()
	{
		GRGLocalisationHandler.instance.tryTranslate(asset, key, delegate(string _translation)
		{
			text.text = _translation;
		}, allow_asset_loading);
	}

	private void Reset()
	{
		text = GetComponent<TMP_Text>();
		if (!(text == null))
		{
			key = ((text.text.Length < 15) ? text.text : text.text.Substring(0, 15));
		}
	}
}
