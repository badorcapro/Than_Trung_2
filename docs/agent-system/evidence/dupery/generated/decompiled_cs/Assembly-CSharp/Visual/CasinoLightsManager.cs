using System;
using System.Collections;
using System.Collections.Generic;
using GRGLib.Coroutines;
using GRGLib.Maybe;
using UnityEngine;

namespace Visual;

public class CasinoLightsManager : MonoBehaviour
{
	public enum CasinoLightsPatterns
	{
		SWAP_HALF = 0,
		SWAP_FULL = 1,
		CIRCLE = 10,
		CIRCLE_2 = 11,
		CIRCLE_4 = 12
	}

	[Header("References")]
	[SerializeField]
	private List<CasinoBulb> bulbs;

	[Header("Settings")]
	[SerializeField]
	private CasinoLightsPatterns starting_pattern;

	[SerializeField]
	private CasinoLightsPatterns arresting_evil_pattern = CasinoLightsPatterns.CIRCLE_2;

	[SerializeField]
	private CasinoLightsPatterns arresting_good_pattern = CasinoLightsPatterns.SWAP_FULL;

	private CoroutineRunner light_pattern_runner;

	private CoroutineRunner pattern_swap_runner;

	public void setUp()
	{
		light_pattern_runner = new CoroutineRunner(this);
		pattern_swap_runner = new CoroutineRunner(this);
		bulbs.ForEach(delegate(CasinoBulb _b)
		{
			_b.setUp();
		});
		playPattern(starting_pattern);
	}

	public void checkBulbSettings()
	{
		bulbs.ForEach(delegate(CasinoBulb _b)
		{
			_b.checkSettings();
		});
		if (SettingsHandler.casino_lights == CasinoBulb.Settings.DEFAULT)
		{
			playPattern(CasinoLightsPatterns.SWAP_HALF);
		}
	}

	public void renew(CasinoCaseSnapshot _snap, Maybe<Alignments> _arrested)
	{
		if (_arrested.is_some)
		{
			if (_arrested.value == Alignments.GOOD)
			{
				playPattern(arresting_good_pattern, 1.2f);
			}
			else
			{
				playPattern(arresting_evil_pattern);
			}
			pattern_swap_runner.run(2.5f.wait(delegate
			{
				playPattern(CasinoLightsPatterns.SWAP_HALF);
			}));
		}
	}

	public void playPattern(CasinoLightsPatterns _pattern, float _speed_multi = 1f)
	{
		switch (_pattern)
		{
		case CasinoLightsPatterns.SWAP_HALF:
			light_pattern_runner.run(animateSwap((int i) => i % 2 == 0, _speed_multi));
			break;
		case CasinoLightsPatterns.SWAP_FULL:
			light_pattern_runner.run(animateSwap((int i) => true, _speed_multi));
			break;
		case CasinoLightsPatterns.CIRCLE:
			light_pattern_runner.run(animateCircle(_direction: true, _speed_multi));
			break;
		case CasinoLightsPatterns.CIRCLE_2:
			light_pattern_runner.run(animateCircle(_direction: true, _speed_multi, 2));
			break;
		case CasinoLightsPatterns.CIRCLE_4:
			light_pattern_runner.run(animateCircle(_direction: true, _speed_multi, 4));
			break;
		default:
			Debug.LogError($"No animation set up for pattern {_pattern}!");
			break;
		}
	}

	private IEnumerator animateSwap(Func<int, bool> _swap, float _speed_multi = 1f)
	{
		float switch_time = 0.05f / _speed_multi;
		float wait_time = 0.5f / _speed_multi;
		bool swap = true;
		while (true)
		{
			for (int i = 0; i < bulbs.Count; i++)
			{
				bulbs[i].putOn(_swap(i) ? swap : (!swap), switch_time);
			}
			yield return wait_time.wait();
			swap = !swap;
		}
	}

	private IEnumerator animateCircle(bool _direction, float _speed_multi = 1f, int _circle_count = 1, int _first_start = 0)
	{
		float switch_time = 0.07f / _speed_multi;
		float move_time = 0.03f / _speed_multi;
		List<int> starting_bulbs = new List<int> { _first_start };
		if (_circle_count > 1)
		{
			float num = (float)bulbs.Count / (float)_circle_count;
			for (int i = 1; i < _circle_count; i++)
			{
				starting_bulbs.Add(Mathf.RoundToInt((float)_first_start + num * (float)i) % bulbs.Count);
			}
		}
		int offset = 0;
		while (true)
		{
			starting_bulbs.ForEach(delegate(int _i)
			{
				bulbs[(_i + offset) % bulbs.Count].putOnOff(switch_time);
			});
			offset = (offset + (_direction ? 1 : (bulbs.Count - 1))) % bulbs.Count;
			yield return move_time.wait();
		}
	}
}
