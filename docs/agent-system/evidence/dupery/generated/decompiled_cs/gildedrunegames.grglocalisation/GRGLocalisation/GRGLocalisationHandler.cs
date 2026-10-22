using System;
using GRGLib.Maybe;
using UnityEngine;

namespace GRGLocalisation;

public class GRGLocalisationHandler : MonoBehaviour
{
	[Header("Settings")]
	[SerializeField]
	protected LocalisationDataSO data;

	private LanguageKey m_language = new LanguageKey(-1);

	public static GRGLocalisationHandler instance { get; private set; }

	protected virtual LanguageKey default_language => new LanguageKey(0);

	public LanguageKey current_language
	{
		get
		{
			return m_language;
		}
		private set
		{
			if (!(m_language == value))
			{
				m_language = value;
				onLanguageChange();
			}
		}
	}

	public static bool needs_translation => instance.current_language != instance.default_language;

	public LocalisationAssetLoader asset_loader { get; protected set; }

	private void Awake()
	{
		if (instance != null && instance != this)
		{
			UnityEngine.Object.Destroy(base.gameObject);
			return;
		}
		UnityEngine.Object.DontDestroyOnLoad(base.gameObject);
		instance = this;
		onAwake();
	}

	public bool setNewLanguage(Languages _language)
	{
		if (current_language == new LanguageKey(_language))
		{
			return false;
		}
		current_language = new LanguageKey(_language);
		return true;
	}

	protected virtual void onAwake()
	{
		m_language = getInitialLanguage();
		if (needs_translation)
		{
			onLanguageChange();
		}
	}

	protected virtual LanguageKey getInitialLanguage()
	{
		return default_language;
	}

	protected virtual void onLanguageChange()
	{
		if (asset_loader != null)
		{
			asset_loader.unloadAllAssets();
		}
		if (!needs_translation)
		{
			asset_loader = null;
			return;
		}
		Maybe<LocalisationLanguageSO> maybe = data[current_language];
		if (!maybe.is_some)
		{
			Debug.LogError("Changed the language to a not supported language!!!");
		}
		else
		{
			asset_loader = new LocalisationAssetLoader(maybe.value);
		}
	}

	public virtual bool isLanguageSupported(LanguageKey _key)
	{
		return data.isSupported(_key);
	}

	public virtual bool translate(AssetKey _asset_key, string _translation_key, out string _result, bool _allow_asset_loading = true)
	{
		try
		{
			_result = asset_loader.getTranslation(_asset_key, _translation_key, _allow_asset_loading);
			return true;
		}
		catch (Exception arg)
		{
			Debug.LogError($"Could not translate {_translation_key} from asset {_asset_key} due to error:\n{arg}");
			_result = "";
			return false;
		}
	}

	public virtual bool translateAndReplace(AssetKey _asset_key, string _translation_key, out string _result, params string[] _put_in)
	{
		return translateAndReplace(_asset_key, _translation_key, out _result, _allow_asset_loading: true, _put_in);
	}

	public virtual bool translateAndReplace(AssetKey _asset_key, string _translation_key, out string _result, bool _allow_asset_loading, params string[] _put_in)
	{
		if (translate(_asset_key, _translation_key, out _result, _allow_asset_loading))
		{
			for (int i = 0; i < _put_in.Length; i++)
			{
				_result = _result.Replace($"{{{i + 1}}}", _put_in[i]);
			}
			return true;
		}
		return false;
	}

	public virtual void tryTranslate(AssetKey _asset_key, string _translation_key, Action<string> _on_translate, bool _allow_asset_loading = true)
	{
		if (translate(_asset_key, _translation_key, out var _result, _allow_asset_loading))
		{
			_on_translate(_result);
		}
	}

	public virtual void tryTranslateAndReplace(AssetKey _asset_key, string _translation_key, Action<string> _on_translate, params string[] _put_in)
	{
		tryTranslateAndReplace(_asset_key, _translation_key, _on_translate, _allow_asset_loading: true, _put_in);
	}

	public virtual void tryTranslateAndReplace(AssetKey _asset_key, string _translation_key, Action<string> _on_translate, bool _allow_asset_loading, params string[] _put_in)
	{
		string _result = "";
		if (translateAndReplace(_asset_key, _translation_key, out _result, _allow_asset_loading, _put_in))
		{
			_on_translate(_result);
		}
	}

	public virtual bool translate(SpriteAssetKey _asset, string _key, out Sprite _result)
	{
		try
		{
			_result = asset_loader.getSprite(_asset, _key);
			return true;
		}
		catch (Exception arg)
		{
			Debug.LogError($"Could not translate image {_key} from asset {_asset} due to error:\n{arg}");
			_result = null;
			return false;
		}
	}

	public virtual void tryTranslate(SpriteAssetKey _asset, string _key, Action<Sprite> _on_translate)
	{
		if (translate(_asset, _key, out var _result))
		{
			_on_translate(_result);
		}
	}
}
