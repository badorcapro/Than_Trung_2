using System;
using System.Collections;
using GRGLib.Coroutines;
using GRGLib.Extensions.Random;
using GRGLib.Generic;
using TMPro;
using UnityEngine;

namespace Visual;

public class FuelVisualManager : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private TMP_Text fuel_number;

	[SerializeField]
	private RectTransform pointer;

	[Header("Pointer Settings")]
	[SerializeField]
	private MinMaxFloat pointer_extremes;

	[SerializeField]
	private float move_speed = 50f;

	[SerializeField]
	private float shake_strength = 2f;

	[SerializeField]
	private float shake_speed = 5f;

	[Header("Text Settings")]
	[SerializeField]
	private Color normal_colour;

	[SerializeField]
	private Color warning_colour;

	[SerializeField]
	private Color red_colour;

	private int max_fuel;

	private int previous_fuel;

	private int previous_diff_to_home = 10;

	private bool hidden_previously;

	private float moving_angle;

	private CoroutineRunner pointer_runner;

	private CoroutineRunner pointer_shake_runner;

	private CoroutineRunner text_runner;

	private CoroutineRunner text_colour_runner;

	private System.Random random = RandomExtensions.freshRandom();

	private float getWantedAngle(float _fuel, float _max)
	{
		return pointer_extremes.estimate(1f - _fuel / _max);
	}

	public void setUp(int _fuel, int _max_fuel)
	{
		pointer_runner = new CoroutineRunner(this);
		pointer_shake_runner = new CoroutineRunner(this);
		text_runner = new CoroutineRunner(this);
		text_colour_runner = new CoroutineRunner(this);
		previous_fuel = _fuel;
		max_fuel = ((_max_fuel == 0) ? 1 : _max_fuel);
		fuel_number.text = _fuel.ToString();
		fuel_number.color = normal_colour;
		float wantedAngle = getWantedAngle(_fuel, max_fuel);
		pointer.localEulerAngles = new Vector3(0f, 0f, wantedAngle);
		pointer_runner.run(shakePointer(wantedAngle));
	}

	public void renew(int _fuel, int _estimate_fuel_home, bool _hidden)
	{
		if (_fuel > max_fuel)
		{
			max_fuel = _fuel;
		}
		if (_hidden)
		{
			if (!hidden_previously)
			{
				hidden_previously = true;
				text_runner.stop();
				fuel_number.text = "?";
				previous_fuel = _fuel;
				pointer_shake_runner.run(wobblePointer(getWantedAngle(-1f, max_fuel), getWantedAngle(max_fuel + 1, max_fuel)));
			}
		}
		else
		{
			hidden_previously = false;
			setText(_fuel, _estimate_fuel_home);
			pointer_shake_runner.run(movePointerAndShake(getWantedAngle(_fuel, max_fuel)));
			previous_fuel = _fuel;
		}
	}

	private void setText(int _fuel, int _estimate_fuel_home)
	{
		text_runner.run(fuel_number.countDown(previous_fuel, _fuel, 0.35f, CoroutineExtensions.easeInOutFunc));
		int num = _fuel - _estimate_fuel_home;
		if (num <= 0)
		{
			if (previous_diff_to_home > 0)
			{
				text_colour_runner.run(fuel_number.fadeToColour(red_colour, 0.5f, CoroutineExtensions.easeInOutFunc));
				previous_diff_to_home = num;
			}
		}
		else if (num <= 2)
		{
			if (previous_diff_to_home > 2)
			{
				text_colour_runner.run(fuel_number.fadeToColour(warning_colour, 0.5f, CoroutineExtensions.easeInOutFunc));
				previous_diff_to_home = num;
			}
		}
		else if (previous_diff_to_home <= 2)
		{
			previous_diff_to_home = num;
			text_colour_runner.run(fuel_number.fadeToColour(normal_colour, 0.5f, CoroutineExtensions.easeInOutFunc));
		}
	}

	private IEnumerator shakePointer(float _angle)
	{
		bool inverse = false;
		while (true)
		{
			float num = random.nextFloat(0f, shake_strength) * (float)((!inverse) ? 1 : (-1));
			float duration = num / shake_speed;
			yield return pointer.rotateTransformSmart(_angle + num, duration, CoroutineExtensions.easeInOutFunc);
			inverse = !inverse;
		}
	}

	private IEnumerator movePointerAndShake(float _angle)
	{
		float move_time = 0.25f + Mathf.Abs(_angle - pointer.eulerAngles.z) / move_speed;
		moving_angle = _angle;
		pointer_runner.run(pointer.rotateTransformToSmartMovingTarget(() => moving_angle, move_time, CoroutineExtensions.easeOutFunc).addCallback(delegate
		{
			pointer_runner.run(shakePointer(_angle));
		}));
		float e = 0f;
		bool inverse = false;
		while (e < move_time)
		{
			float last = moving_angle;
			float num = random.nextFloat(0f, shake_strength) * (float)((!inverse) ? 1 : (-1));
			float diff = _angle + num - last;
			float time = num / shake_speed;
			float starting_e = e;
			while (e - starting_e < time)
			{
				e += Time.deltaTime;
				moving_angle = last + diff * CoroutineExtensions.easeInOutFunc((e - starting_e) / time);
				yield return null;
			}
		}
	}

	private IEnumerator wobblePointer(float _min_angle, float _max_angle)
	{
		while (true)
		{
			yield return pointer.rotateTransformSmart(_min_angle, 1.5f, CoroutineExtensions.easeInOutFunc);
			yield return pointer.rotateTransformSmart(_max_angle, 1.5f, CoroutineExtensions.easeInOutFunc);
		}
	}
}
