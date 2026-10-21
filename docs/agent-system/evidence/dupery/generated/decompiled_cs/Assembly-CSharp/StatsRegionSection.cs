using System;
using GRGLib.Coroutines;
using GRGLib.Maybe;
using GRGLib.Menus;
using GRGLocalisation;
using GameStats;
using Localisation;
using UnityEngine;

public abstract class StatsRegionSection : MenuBase, IAmLocalised
{
	public RectTransform rect_trans => base.transform as RectTransform;

	protected AssetKey localisation_asset => LocalisationHelper.ui_asset;

	public void setUp(RunStats _stats, CaseStats _region_stats, Maybe<CaseType> _region)
	{
		setUpSection(_stats, _region_stats, _region);
		if (!base.is_open)
		{
			openMenu();
		}
	}

	protected abstract void setUpSection(RunStats _stats, CaseStats _region_stats, Maybe<CaseType> _region);

	public void closeAndReopen(Action _callback)
	{
		if (base.is_closed || base.current_state == MenuState.CLOSING)
		{
			_callback();
			openMenu();
			return;
		}
		menuing_anim.run(closingMenuAnimation().addCallback(delegate
		{
			_callback();
			menuing_anim.run(openingMenuAnimation());
		}));
	}

	protected string translate(string _key, Func<string, string> _english, int _data)
	{
		return localisation_asset.checkTranslationWithData(_key, _english, _data);
	}

	protected string translate(string _key, Func<string, string> _english, string _data)
	{
		return localisation_asset.checkTranslationWithData(_key, _english, _data);
	}

	protected string translate(string _key, Func<string, string, string> _english, int _data_1, int _data_2)
	{
		return localisation_asset.checkTranslationWithReplace(_key, () => _english(_data_1.ToString(), _data_2.ToString()), true, _data_1, _data_2);
	}

	protected string translate(string _key, Func<string, string, string> _english, string _data_1, string _data_2)
	{
		return localisation_asset.checkTranslationWithReplace(_key, () => _english(_data_1, _data_2), true, _data_1, _data_2);
	}

	protected string translate(string _key, Func<string, string, string, string> _english, int _data_1, int _data_2, int _data_3)
	{
		return localisation_asset.checkTranslationWithReplace(_key, () => _english(_data_1.ToString(), _data_2.ToString(), _data_3.ToString()), true, _data_1, _data_2, _data_3);
	}

	protected string translate(string _key, Func<string, string, string, string> _english, string _data_1, string _data_2, string _data_3)
	{
		return localisation_asset.checkTranslationWithReplace(_key, () => _english(_data_1, _data_2, _data_3), true, _data_1, _data_2, _data_3);
	}
}
