using TMPro;
using UnityEngine;

namespace GRGLocalisation;

public class LocalisedStaticDropDown : MonoBehaviour, IAmLocalised
{
	[SerializeField]
	private TMP_Dropdown dropdown;

	[SerializeField]
	protected AssetKey asset;

	[SerializeField]
	protected string key_base;

	[SerializeField]
	protected bool allow_asset_loading = true;

	protected virtual void Awake()
	{
		checkOptionsLocalisation();
	}

	public void checkOptionsLocalisation()
	{
		if (!GRGLocalisationHandler.needs_translation)
		{
			return;
		}
		dropdown.options.ForEach(delegate(TMP_Dropdown.OptionData _o)
		{
			if (GRGLocalisationHandler.instance.translate(asset, key_base + _o.text, out var _result))
			{
				_o.text = _result;
			}
			else
			{
				Debug.LogError("Could not find localisation for dropdown value " + _o.text + "!");
			}
		});
	}

	private void Reset()
	{
		dropdown = GetComponent<TMP_Dropdown>();
		if (!(dropdown == null))
		{
			key_base = ((dropdown.name.Length < 15) ? dropdown.name : dropdown.name.Substring(0, 15));
		}
	}
}
