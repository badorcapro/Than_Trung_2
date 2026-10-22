using GRGLib.Coroutines;
using UnityEngine;
using UnityEngine.UI;

namespace Visual;

public class CasinoBulb : MonoBehaviour
{
	public enum Settings
	{
		DEFAULT,
		ALWAYS_ON,
		ALWAYS_OFF
	}

	[Header("References")]
	[SerializeField]
	private Image off;

	[SerializeField]
	private Image on;

	private CoroutineRunner bulb_state_runner;

	public void setUp()
	{
		bulb_state_runner = new CoroutineRunner(this);
		checkSettings();
	}

	public void checkSettings()
	{
		if (SettingsHandler.casino_lights != 0)
		{
			bulb_state_runner.stop();
			on.color = new Color(1f, 1f, 1f, (SettingsHandler.casino_lights == Settings.ALWAYS_ON) ? 1 : 0);
		}
	}

	public void putOn(bool _on, float _time = 0.15f)
	{
		if (SettingsHandler.casino_lights == Settings.DEFAULT)
		{
			bulb_state_runner.run(on.fade(_on ? 1 : 0, _time, CoroutineExtensions.easeInOutFunc));
		}
	}

	public void putOnOff(float _switch_time, float _wait_time = 0.1f)
	{
		if (SettingsHandler.casino_lights != 0)
		{
			return;
		}
		bulb_state_runner.run(on.fade(1f, _switch_time, CoroutineExtensions.easeInOutFunc).addCallback(delegate
		{
			bulb_state_runner.run(_wait_time.wait(delegate
			{
				bulb_state_runner.run(on.fade(0f, _switch_time, CoroutineExtensions.easeInOutFunc));
			}));
		}));
	}

	public void putOnOffContinuous(float _switch_time = 0.15f)
	{
		if (SettingsHandler.casino_lights == Settings.DEFAULT)
		{
			bulb_state_runner.run(on.fadeInOutContinuous(1f, 0f, _switch_time, _switch_time, CoroutineExtensions.easeInOutFunc));
		}
	}
}
