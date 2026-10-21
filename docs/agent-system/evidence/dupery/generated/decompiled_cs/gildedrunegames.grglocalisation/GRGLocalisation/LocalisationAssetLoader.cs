using System;
using System.Collections.Generic;
using UnityEngine;

namespace GRGLocalisation;

public class LocalisationAssetLoader
{
	protected LocalisationLanguageSO language_data;

	protected Dictionary<AssetKey, Dictionary<string, string>> loaded_translations = new Dictionary<AssetKey, Dictionary<string, string>>();

	public LocalisationAssetLoader(LocalisationLanguageSO _language_data)
	{
		language_data = _language_data;
	}

	public string getTranslation(AssetKey _asset, string _key, bool _allow_asset_loading = true)
	{
		if (loaded_translations.ContainsKey(_asset))
		{
			if (loaded_translations[_asset].ContainsKey(_key))
			{
				return loaded_translations[_asset][_key];
			}
			throw new ArgumentException($"No Translation found for key {_key} in asset {_asset}!");
		}
		if (_allow_asset_loading)
		{
			if (loadAsset(_asset))
			{
				return getTranslation(_asset, _key, _allow_asset_loading: false);
			}
			throw new ArgumentException($"Failed to load asset {_asset}!");
		}
		throw new ArgumentException($"No Translation found for key {_key} in asset {_asset}! Asset is not loaded and _allow_asset_loading is set to false!");
	}

	public Sprite getSprite(SpriteAssetKey _asset, string _key)
	{
		return language_data.getSprite(_asset, _key);
	}

	private Dictionary<string, string> loadOrGetAsset(AssetKey _asset_id)
	{
		if (!loaded_translations.ContainsKey(_asset_id))
		{
			loadAsset(_asset_id);
		}
		return loaded_translations[_asset_id];
	}

	public bool loadAsset(AssetKey _asset_id)
	{
		try
		{
			loaded_translations[_asset_id] = language_data.loadCSV(_asset_id);
			return true;
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load asset {_asset_id}!\nError: {arg}");
			return false;
		}
	}

	public void unloadAsset(AssetKey _asset_id)
	{
		loaded_translations.Remove(_asset_id);
	}

	public void unloadAllAssets()
	{
		loaded_translations.Clear();
	}
}
