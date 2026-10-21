using System;
using System.Collections.Generic;
using GRGLib.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class DocksCaseBuildData : CaseBuildData
{
	private MinMaxFloat base_fuel;

	private MinMaxFloat fuel_per_good;

	private MinMaxFloat fuel_per_evil;

	public DocksCaseBuildData(Maybe<Vector2Int> _board_size, List<CaseQuirks> _quirks, Maybe<CaseQuirks> _new_quirk, CaseRatioBuilderData _ratio_data, float _diff, System.Random _rng)
		: base(CaseType.DOCKS, _board_size, _quirks, _new_quirk, _ratio_data, _diff, _rng)
	{
		setFuelMinMaxes(_diff);
	}

	public DocksCaseBuildData(CaseBuildDataSave _data)
		: base(_data)
	{
		try
		{
			string[] array = _data.unique_data.Split('#');
			string[] array2 = array[0].Split(',');
			string[] array3 = array[1].Split(',');
			string[] array4 = array[2].Split(',');
			base_fuel = new MinMaxFloat(float.Parse(array2[0]), float.Parse(array2[1]));
			fuel_per_good = new MinMaxFloat(float.Parse(array3[0]), float.Parse(array3[1]));
			fuel_per_evil = new MinMaxFloat(float.Parse(array4[0]), float.Parse(array4[1]));
		}
		catch (Exception arg)
		{
			Debug.LogError($"Loading Failed! DocksCaseBuildData! ({_data.unique_data}) Error: {arg}");
			setFuelMinMaxes(difficulty_01);
		}
	}

	private void setFuelMinMaxes(float _diff)
	{
		base_fuel = new MinMaxFloat(7f - _diff * 3f, 9f - _diff * 2f);
		fuel_per_good = new MinMaxFloat(0.01f, 0.23f);
		fuel_per_evil = new MinMaxFloat(1.5f, 2.3f);
	}

	private float calculateFuelForRatio(int _ratio, MinMaxFloat _min_max, System.Random _rng)
	{
		float num = 0f;
		for (int i = 0; i < _ratio; i++)
		{
			num += _min_max.get(_rng);
		}
		return num;
	}

	public int calculateStartingFuel(Dictionary<RoleClassifications, int> _ratio, System.Random _rng)
	{
		return Mathf.RoundToInt(base_fuel.get(_rng) + calculateFuelForRatio(_ratio[RoleClassifications.INNOCENT] + _ratio[RoleClassifications.MEDDLER], fuel_per_good, _rng) + calculateFuelForRatio(_ratio[RoleClassifications.UNDERLING] + _ratio[RoleClassifications.TRAITOR], fuel_per_evil, _rng));
	}

	protected override string getUniqueData()
	{
		return $"{base_fuel.min},{base_fuel.max}#{fuel_per_good.min},{fuel_per_good.max}#{fuel_per_evil.min},{fuel_per_evil.max}";
	}
}
