using System;
using BackAlleyItems;
using GRGLib.Generic;

public static class BackAlleysHelper
{
	public static BackAlleysItem createItem(this BackAlleysItemType _item, Random _rng)
	{
		return _item switch
		{
			BackAlleysItemType.STAB_VEST => new StabVest(_rng), 
			BackAlleysItemType.FALSE_POLICE_BADGE => new FalsePoliceBadge(_rng), 
			BackAlleysItemType.BUNDLE_OF_STRING => new BundleOfString(_rng), 
			BackAlleysItemType.FAMILIAL_LOCKET => new FamilialLocket(_rng), 
			BackAlleysItemType.LIGHTER => new Lighter(_rng), 
			BackAlleysItemType.FLIP_KNIFE => new FlipKnife(_rng), 
			BackAlleysItemType.CERTIFICATE_OF_CREDIT => new CertificateOfCredit(_rng), 
			BackAlleysItemType.WAD_OF_CASH => new WadOfCash(_rng), 
			BackAlleysItemType.THREE_SHOT_REVOLVER => new ThreeShotRevolver(_rng), 
			BackAlleysItemType.EVIL_MONOCLE => new EvilMonocle(_rng), 
			BackAlleysItemType.SKEPTIC_LOOP => new SkepticLoop(_rng), 
			_ => throw new NotImplementedException($"Item case: '{_item}' not implimented"), 
		};
	}

	public static BackAlleysItem fromSave(BackAlleysItemType _item, int _uses, string _data, Random _rng)
	{
		return _item switch
		{
			BackAlleysItemType.STAB_VEST => new StabVest(_rng, _uses), 
			BackAlleysItemType.FALSE_POLICE_BADGE => new FalsePoliceBadge(_rng, _uses), 
			BackAlleysItemType.BUNDLE_OF_STRING => new BundleOfString(_rng, _uses), 
			BackAlleysItemType.FAMILIAL_LOCKET => new FamilialLocket(_rng, _uses), 
			BackAlleysItemType.LIGHTER => new Lighter(_rng, _uses), 
			BackAlleysItemType.FLIP_KNIFE => new FlipKnife(_rng, _uses), 
			BackAlleysItemType.CERTIFICATE_OF_CREDIT => new CertificateOfCredit(_rng, _uses), 
			BackAlleysItemType.WAD_OF_CASH => new WadOfCash(_rng, _uses), 
			BackAlleysItemType.THREE_SHOT_REVOLVER => new ThreeShotRevolver(_rng, _uses), 
			BackAlleysItemType.EVIL_MONOCLE => new EvilMonocle(_rng, _uses), 
			BackAlleysItemType.SKEPTIC_LOOP => new SkepticLoop(_rng, _uses), 
			_ => throw new NotImplementedException($"Item case: '{_item}' not implimented"), 
		};
	}

	public static MinMaxInt toPrice(this BackAlleysItemCost _cost)
	{
		return _cost switch
		{
			BackAlleysItemCost.VERY_CHEAP => new MinMaxInt(5, 9), 
			BackAlleysItemCost.CHEAP => new MinMaxInt(8, 13), 
			BackAlleysItemCost.NORMAL => new MinMaxInt(12, 18), 
			BackAlleysItemCost.PRICEY => new MinMaxInt(17, 24), 
			BackAlleysItemCost.EXPENSIVE => new MinMaxInt(22, 31), 
			BackAlleysItemCost.ULTRA_EXPENSIVE => new MinMaxInt(29, 40), 
			_ => throw new ArgumentException($"No price set up for enum value {_cost}!"), 
		};
	}
}
