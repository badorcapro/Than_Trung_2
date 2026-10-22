using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Generic;
using UnityEngine;

namespace Leads;

[Serializable]
public struct ChipsGainEventData
{
	[Serializable]
	public struct GainCap
	{
		public MinMaxInt gain;

		public int cap;

		public GainCap(int _cap, int _min, int _max)
		{
			MinMaxInt minMaxInt = new MinMaxInt(_min, _max);
			cap = _cap;
			gain = minMaxInt;
		}

		public GainCap(string _data)
		{
			try
			{
				string[] array = _data.Split(',');
				cap = int.Parse(array[0]);
				gain = new MinMaxInt(int.Parse(array[1]), int.Parse(array[2]));
			}
			catch (Exception arg)
			{
				Debug.LogError($"Failed to parse data {_data} into gaincap!\nError: {arg}");
				cap = 10;
				gain = new MinMaxInt(5, 10);
			}
		}

		public string toData()
		{
			return $"{cap},{gain.min},{gain.max}";
		}
	}

	public GainCap[] gains;

	public (int, MinMaxInt)[] gains_array => gains.Select((GainCap _g) => (cap: _g.cap, gain: _g.gain)).ToArray();

	public ChipsGainEventData(params GainCap[] _gains)
	{
		gains = _gains;
	}

	public ChipsGainEventData(string _data)
	{
		try
		{
			string[] array = _data.Split('#');
			List<GainCap> list = new List<GainCap>();
			string[] array2 = array;
			foreach (string data in array2)
			{
				list.Add(new GainCap(data));
			}
			gains = list.ToArray();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to parse data {_data}.\nError: {arg}");
			gains = new GainCap[0];
		}
	}

	public string toData()
	{
		return gains.Aggregate("", (string _a, GainCap _g) => (!(_a == "")) ? (_a + "#" + _g.toData()) : _g.toData());
	}
}
