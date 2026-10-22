using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class FuelMerchant : DocksRoleData
{
	private const int fuel_for_increase = 3;

	private Maybe<OilPlatform> oil_platform = new Maybe<OilPlatform>();

	private int fuel_since_increase;

	private Maybe<int> lying_offset = new Maybe<int>();

	public override Roles role => Roles.FUEL_MERCHANT;

	public override string english_name => "Fuel Merchant";

	public override string english_description => "I " + Keywords.ANNOUNCE.toString() + " how much " + Keywords.FUEL.toString() + " the " + LocationTypes.OIL_PLATFORM.toString() + " contains. I might add 1 " + Keywords.FUEL.toString() + " to the " + LocationTypes.OIL_PLATFORM.toString() + " " + $"every {3} {Keywords.FUEL.toString()} spent. I add an {LocationTypes.OIL_PLATFORM.toString()} when I am {Keywords.SUSPECTED.toString()}.";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, $"I have a 50% chance to add {Keywords.FUEL.toString()} to the {LocationTypes.OIL_PLATFORM.toString()} every {3} spent."));
			list.Add((DescriptionType.SPECIAL, "Once the " + LocationTypes.OIL_PLATFORM.toString() + " is closed, I " + Keywords.ANNOUNCE.toString() + " \"" + RoleData.loc_marker_1 + "\""));
			list.Add((DescriptionType.SPECIAL, TextHelper.iUpdateWhenBoatMoves));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + ", I do not increase the " + Keywords.FUEL.toString() + " contained in the " + LocationTypes.OIL_PLATFORM.toString() + " and " + Keywords.ANNOUNCE.toString() + " an incorrect amount of " + Keywords.FUEL.toString() + "."));
			return list;
		}
	}

	public override bool hasInfo => true;

	private string loc_no_info_key => $"{role} [info_no]";

	public FuelMerchant(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public FuelMerchant(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			string[] array = _save.unique_data.Split(',');
			fuel_since_increase = int.Parse(array[0]);
			if (array[1] == "f")
			{
				lying_offset = new Maybe<int>();
			}
			else
			{
				lying_offset = int.Parse(array[1]).maybe();
			}
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load {role}!\nSave: {_save.unique_data}\nError: {arg}");
			fuel_since_increase = 0;
			lying_offset = new Maybe<int>();
		}
	}

	protected override string fillExtraDescription(string _description, DescriptionType _type)
	{
		if (_type != DescriptionType.SPECIAL)
		{
			return _description;
		}
		return _description.Replace(RoleData.loc_marker_1, checkTranslation(loc_no_info_key, englishNoInfo));
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new SuspectLocationGC(LocationTypes.OIL_PLATFORM));
	}

	private Maybe<OilPlatform> tryGetOilPlatform(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board)
	{
		if (!oil_platform.is_some)
		{
			oil_platform = _board.getLocationsInPlay().Values.ToList().firstIfSome((LocationData _l) => _l is OilPlatform).fmap((LocationData _l) => _l as OilPlatform);
		}
		return oil_platform;
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onFuelUsedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, DocksCaseActionPayload _payload, int _fuel_used)
	{
		if (base.has_bad_info || base.dead || base.arrested)
		{
			return _board;
		}
		Maybe<OilPlatform> maybe = tryGetOilPlatform(_board);
		if (!maybe.is_some)
		{
			Debug.LogError($"{role} could not find the Oil Platform!");
			return _board;
		}
		if (!maybe.value.open)
		{
			return _board;
		}
		fuel_since_increase += _fuel_used;
		while (fuel_since_increase >= 3)
		{
			fuel_since_increase -= 3;
			if (random.Next(0, 2) == 1)
			{
				maybe.value.increaseFuelStored(1);
			}
		}
		resetInfo();
		return base.onFuelUsedAction(_board, _payload, _fuel_used);
	}

	protected override string generateDocksInfoString(DocksCaseSnapshot _snap)
	{
		Maybe<OilPlatform> maybe = tryGetOilPlatform(_snap.board);
		if (!maybe.is_some)
		{
			Debug.LogError($"{role} cannot generate info without the Oil Platform!");
			return "";
		}
		if (!maybe.value.open)
		{
			return checkTranslation(loc_no_info_key, englishNoInfo);
		}
		int num = maybe.value.fuel_contained;
		if (base.has_bad_info)
		{
			if (!lying_offset.is_some)
			{
				int num2 = random.Next(1, 3);
				if (num2 > num || random.Next(0, 2) == 1)
				{
					lying_offset = num2.maybe();
				}
				else
				{
					lying_offset = (-num2).maybe();
				}
			}
			num += lying_offset.value;
		}
		return checkTranslationWithData(englishInfo, num);
	}

	private string englishInfo(string _data)
	{
		return "The Oil Platform has " + _data + " fuel stored.";
	}

	private string englishNoInfo()
	{
		return "The Oil Platform is closed.";
	}

	public override string getUniqueSaveData()
	{
		return string.Format("{0},{1}", fuel_since_increase, lying_offset.is_some ? lying_offset.value.ToString() : "f");
	}
}
