using System.Collections;
using System.Collections.Generic;
using GRGLib.Coroutines;
using GRGLib.Maybe;
using UnityEngine.InputSystem;

namespace GRGLib.Input;

public static class PlayerInputHelper
{
	public static bool usingController(this PlayerInput _input)
	{
		return _input.currentControlScheme == "Gamepad";
	}

	public static Maybe<Gamepad> tryGetFirstGamePad(this PlayerInput _input)
	{
		for (int i = 0; i < _input.devices.Count; i++)
		{
			if (_input.devices[i] is Gamepad)
			{
				return (_input.devices[i] as Gamepad).maybe();
			}
		}
		return new Maybe<Gamepad>();
	}

	public static List<Gamepad> getAllGamepads(this PlayerInput _input)
	{
		List<Gamepad> list = new List<Gamepad>();
		for (int i = 0; i < _input.devices.Count; i++)
		{
			if (_input.devices[i] is Gamepad)
			{
				list.Add(_input.devices[i] as Gamepad);
			}
		}
		return list;
	}

	public static void shutOffRumble(this Gamepad _gamepad)
	{
		_gamepad.SetMotorSpeeds(0f, 0f);
	}

	public static IEnumerator rumble(this Gamepad _gamepad, float _strength, float _duration)
	{
		_gamepad.SetMotorSpeeds(_strength, _strength);
		yield return _duration.waitReal();
		_gamepad.SetMotorSpeeds(0f, 0f);
	}
}
