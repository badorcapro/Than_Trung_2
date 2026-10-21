using System.Collections;
using System.Collections.Generic;
using GRGLib.Coroutines;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using GRGLib.PropertyDrawers;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.SceneManagement;

namespace GRGLib.Input;

[AddComponentMenu("GRGLib/Input/GRGInputHandler")]
public class GRGInputHandler : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private bool fetch_player_input_on_start = true;

	[SerializeField]
	[ConditionalField("fetch_player_input_on_start", false, new object[] { false })]
	private PlayerInput starting_player_input;

	[Header("Settings")]
	[SerializeField]
	private bool check_control_scheme = true;

	[SerializeField]
	private bool fetch_player_input_on_scene_change = true;

	[SerializeField]
	[Tooltip("Set first item to \"All\" to always use selectables")]
	private List<string> schemes_use_selectables = new List<string> { "Gamepad" };

	[SerializeField]
	private bool default_selectable_use;

	[Header("Log")]
	[SerializeField]
	private bool log_device_change = true;

	protected Maybe<PlayerInput> player_input = new Maybe<PlayerInput>();

	protected List<ISelectables> scene_selectables = new List<ISelectables>();

	public static GRGInputHandler instance { get; private set; }

	private void Awake()
	{
		if (instance != null && instance != this)
		{
			Object.Destroy(this);
			return;
		}
		Object.DontDestroyOnLoad(base.gameObject);
		instance = this;
		setUp();
	}

	protected virtual void setUp()
	{
		SceneManager.sceneLoaded += onSceneLoaded;
		if (fetch_player_input_on_start)
		{
			fecthPlayerInput();
		}
		else if (starting_player_input != null)
		{
			player_input = starting_player_input.maybe();
		}
		checkControls().start(this);
	}

	protected virtual void onSceneLoaded(Scene _scene, LoadSceneMode _mode)
	{
		if (fetch_player_input_on_scene_change)
		{
			scene_selectables.removeNull();
			fecthPlayerInput();
		}
	}

	protected virtual void fecthPlayerInput()
	{
		if (player_input.is_some && player_input.value == null)
		{
			player_input = new Maybe<PlayerInput>();
		}
		if (!player_input.is_some)
		{
			player_input = Object.FindObjectOfType<PlayerInput>().maybe();
		}
	}

	private IEnumerator checkControls()
	{
		if (!check_control_scheme)
		{
			yield break;
		}
		string current_controls = player_input.value.currentControlScheme;
		while (true)
		{
			if (player_input.is_some && player_input.value.currentControlScheme != current_controls)
			{
				current_controls = player_input.value.currentControlScheme;
				onInputDeviceChange(current_controls);
			}
			yield return null;
		}
	}

	public void addSelectable(ISelectables _selectable)
	{
		scene_selectables.add(_selectable);
	}

	public virtual void onInputDeviceChange(string _device)
	{
		if (log_device_change)
		{
			Debug.Log("Input Device Changed: " + _device + "!");
		}
		scene_selectables.ForEach(delegate(ISelectables _s)
		{
			_s?.onControlsChange(_device);
		});
	}

	public virtual bool useSelectables()
	{
		if (schemes_use_selectables.Count > 0 && schemes_use_selectables[0].ToLower() == "all")
		{
			return true;
		}
		if (!player_input.is_some || player_input.value == null)
		{
			return default_selectable_use;
		}
		return schemes_use_selectables.Contains(player_input.value.currentControlScheme);
	}

	public bool usingController()
	{
		if (!player_input.is_some || player_input.value == null)
		{
			return false;
		}
		return player_input.value.usingController();
	}

	public Maybe<Gamepad> getFirstGamepad()
	{
		if (!player_input.is_some || player_input.value == null)
		{
			return new Maybe<Gamepad>();
		}
		return player_input.value.tryGetFirstGamePad();
	}

	public List<Gamepad> getAllGamepads()
	{
		if (!player_input.is_some || player_input.value == null)
		{
			return new List<Gamepad>();
		}
		return player_input.value.getAllGamepads();
	}

	public virtual void rumbleFirstController(float _duration, float _strength)
	{
		if (usingController())
		{
			if (_strength > 1f)
			{
				_strength = 1f;
			}
			Maybe<Gamepad> firstGamepad = getFirstGamepad();
			if (!firstGamepad.is_some)
			{
				Debug.LogError("Trying to rumble inexistant controller");
			}
			else
			{
				firstGamepad.value.rumble(_strength, _duration).start(this);
			}
		}
	}

	public virtual void rumbleAllControllers(float _duration, float _strength)
	{
		if (usingController())
		{
			if (_strength > 1f)
			{
				_strength = 1f;
			}
			getAllGamepads().ForEach(delegate(Gamepad _g)
			{
				_g.rumble(_strength, _duration).start(this);
			});
		}
	}
}
