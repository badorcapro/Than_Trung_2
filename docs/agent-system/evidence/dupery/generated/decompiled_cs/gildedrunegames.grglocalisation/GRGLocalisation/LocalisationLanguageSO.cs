using System.Collections.Generic;
using GRGLib.Save;
using GRGLib.Serializable;
using UnityEngine;

namespace GRGLocalisation;

[CreateAssetMenu(menuName = "GRGLocalisation/Language Data")]
public class LocalisationLanguageSO : ScriptableObject
{
	[Header("Text Assets")]
	[SerializeField]
	private SerializableDictionary<AssetKey, TextAsset> assets;

	[SerializeField]
	private int translation_column = 1;

	[Header("Sprite Assets")]
	[SerializeField]
	private SerializableDictionary<SpriteAssetKey, LocalisationSpriteBank> sprite_banks;

	public Dictionary<string, string> loadCSV(AssetKey _id)
	{
		return CSVFileHandler.readFromCSVAsDictionary(assets[_id], translation_column - 1, 1);
	}

	public Sprite getSprite(SpriteAssetKey _asset, string _key)
	{
		return sprite_banks[_asset][_key];
	}

	private void Reset()
	{
	}
}
