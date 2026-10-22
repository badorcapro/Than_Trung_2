using Lineup;
using TMPro;
using UnityEngine;
using UnityEngine.InputSystem;

namespace ControllerSupport;

public class LineupInputHandler : BaseInputHandler
{
	[Header("References")]
	[SerializeField]
	private LineupController lineup_controller;

	[SerializeField]
	private TMP_Text convict_text;

	[Header("Settings")]
	[SerializeField]
	private InputAssetPerType convict_asset;

	private bool allow_switch = true;

	protected override void Start()
	{
		base.Start();
		if (GameHandler.instance.using_gamepad)
		{
			onChangeToGamepad(player_input);
		}
		else
		{
			onChangeToKBM(player_input);
		}
	}

	protected override void onChangeToGamepad(PlayerInput _input)
	{
		base.onChangeToGamepad(_input);
		convict_text.text = convict_asset.getTextAsset(_input) + " " + lineup_controller.getConvictString();
	}

	protected override void onChangeToKBM(PlayerInput _input)
	{
		base.onChangeToKBM(_input);
		convict_text.text = lineup_controller.getConvictString();
	}

	protected override void onWestButton(InputAction.CallbackContext _context)
	{
		lineup_controller.onBlame();
	}

	protected override void onLeftJoystick(InputAction.CallbackContext _context)
	{
		Vector2 vector = _context.ReadValue<Vector2>();
		if (!allow_switch)
		{
			if (vector.x < 0.1f && vector.x > -0.1f)
			{
				allow_switch = true;
			}
		}
		else if (vector.x > 0.65f)
		{
			lineup_controller.nextSuspect(_right: true);
			allow_switch = false;
		}
		else if (vector.x < -0.65f)
		{
			lineup_controller.nextSuspect(_right: false);
			allow_switch = false;
		}
	}

	protected override void onDpad(InputAction.CallbackContext _context)
	{
		if (_context.performed)
		{
			Vector2 vector = _context.ReadValue<Vector2>();
			if (vector.x > 0.7f)
			{
				lineup_controller.nextSuspect(_right: true);
			}
			else if (vector.x < -0.7f)
			{
				lineup_controller.nextSuspect(_right: false);
			}
		}
	}
}
