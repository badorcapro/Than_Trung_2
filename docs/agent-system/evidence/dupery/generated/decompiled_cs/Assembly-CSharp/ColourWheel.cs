using System;
using System.Collections;
using System.Collections.Generic;
using GRGLib.Coroutines;
using GRGLib.Extensions.Vector;
using GRGLib.Maybe;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;

public class ColourWheel : MenuBase
{
	private static float y_limit = 920f;

	private static float deadzone_inner = 0.65f;

	private static float deadzone_outer = 0.9f;

	[Header("References")]
	[SerializeField]
	private List<ColourWheelSegment> colour_segments;

	[SerializeField]
	private List<Image> colour_symbols;

	[SerializeField]
	private Image circle_marker;

	private Maybe<(float, int)> picked_colour = new Maybe<(float, int)>();

	private Maybe<Action<Color>> on_colour_callback = new Maybe<Action<Color>>();

	private CoroutineRunner mouse_check_runner;

	protected override void Awake()
	{
		base.Awake();
		mouse_check_runner = new CoroutineRunner(this);
	}

	public void setColoursAndOpen(List<Color> _colours, Vector2 _position, Action<Color> _callback, bool _limit_y = true, bool _is_pin = false)
	{
		if (_colours.Count != 7)
		{
			Debug.LogError("7 Colours are required for the colour wheel");
		}
		bool flag = _is_pin && SettingsHandler.show_pin_symbols;
		for (int i = 0; i < _colours.Count && i < colour_segments.Count; i++)
		{
			colour_segments[i].color = _colours[i];
			colour_symbols[i].gameObject.SetActive(flag);
			if (flag)
			{
				colour_symbols[i].color = _colours[i];
			}
		}
		on_colour_callback = _callback.maybe();
		if (picked_colour.is_some)
		{
			on_colour_callback.value(colour_segments[picked_colour.value.Item2].color);
		}
		base.transform.position = _position;
		base.transform.localPosition = new Vector3(base.transform.localPosition.x, base.transform.localPosition.y, 0f);
		if (_limit_y && base.transform.localPosition.y > y_limit)
		{
			base.transform.localPosition = new Vector3(base.transform.localPosition.x, y_limit, base.transform.localPosition.z);
		}
		openMenu();
	}

	public bool checkController(Vector2 _joy_pos)
	{
		circle_marker.rectTransform.anchoredPosition = _joy_pos * (base.transform as RectTransform).sizeDelta / 2f;
		if (_joy_pos.magnitude < deadzone_inner)
		{
			return false;
		}
		if (!picked_colour.is_some || _joy_pos.magnitude > deadzone_outer || _joy_pos.magnitude > picked_colour.value.Item1)
		{
			checkNewColour(_joy_pos);
		}
		return true;
	}

	public void startMousePosCheck()
	{
		mouse_check_runner.run(checkMousePos(Pointer.current.position.ReadValue()));
	}

	public void stopMousePosCheckAndClose()
	{
		mouse_check_runner.stop();
		closeMenu();
	}

	private IEnumerator checkMousePos(Vector2 _start_pos)
	{
		float size_magnitude = (base.transform as RectTransform).sizeDelta.magnitude * 0.35f;
		float deadzone_inner_real = deadzone_inner * size_magnitude;
		float deadzone_outter_real = deadzone_outer * size_magnitude;
		Vector2 screen_multi = new Vector2(3840f, 2160f) / StaticHelper.ui_ratio;
		_start_pos *= screen_multi;
		while (true)
		{
			Vector2 vector = Pointer.current.position.ReadValue() * screen_multi - _start_pos;
			circle_marker.rectTransform.anchoredPosition = ((vector.magnitude < size_magnitude) ? vector : (vector.normalized * size_magnitude));
			if (vector.magnitude < deadzone_inner_real)
			{
				if (picked_colour.is_some)
				{
					colour_segments[picked_colour.value.Item2].scaleDown();
					picked_colour = new Maybe<(float, int)>();
				}
			}
			else if (!picked_colour.is_some || vector.magnitude > deadzone_outter_real || vector.magnitude > (float)picked_colour.value.Item2)
			{
				checkNewColour(vector);
			}
			yield return null;
		}
	}

	private void checkNewColour(Vector2 _pos)
	{
		int colourByPosition = getColourByPosition(_pos);
		int num;
		if (picked_colour.is_some)
		{
			num = ((picked_colour.value.Item2 != colourByPosition) ? 1 : 0);
			if (num == 0)
			{
				goto IL_005e;
			}
		}
		else
		{
			num = 1;
		}
		if (picked_colour.is_some)
		{
			colour_segments[picked_colour.value.Item2].scaleDown();
		}
		goto IL_005e;
		IL_005e:
		picked_colour = (_pos.magnitude, colourByPosition).maybe();
		if (num != 0)
		{
			colour_segments[colourByPosition].scaleUp();
			if (on_colour_callback.is_some)
			{
				on_colour_callback.value(colour_segments[colourByPosition].color);
			}
		}
	}

	private int getColourByPosition(Vector2 _pos)
	{
		Vector2 vector = _pos.cartesianToPolar();
		float num = 51.42857f;
		float num2 = vector.y * 180f / 3.1415f;
		num2 = Mathf.Max(0f, (_pos.x < 0f) ? (270f - num2) : (90f - num2));
		return Mathf.FloorToInt(num2 / num);
	}

	protected override void onMenuClosing()
	{
		base.onMenuClosing();
		on_colour_callback = new Maybe<Action<Color>>();
		picked_colour = new Maybe<(float, int)>();
	}

	protected override void onMenuClosed()
	{
		base.onMenuClosed();
		foreach (ColourWheelSegment colour_segment in colour_segments)
		{
			colour_segment.forceReset();
		}
	}
}
