using System;
using GRGLib.Extensions.Random;
using Leads;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;

public class LeadStasisManager : MonoBehaviour
{
	[SerializeField]
	private RegionsSO regions_data;

	[Header("References")]
	[SerializeField]
	private LeadFacade facade;

	[SerializeField]
	private QuirksStasisViewer quirks_viewer;

	[SerializeField]
	private LeadStasisRegionManager regional_manager;

	[SerializeField]
	private Button continue_button;

	private void Start()
	{
		Lead value = GameHandler.State.current_lead.value;
		System.Random rng = RandomExtensions.freshRandom();
		facade.setCurrentLead(value, regions_data[value.case_type.fromType()].region_name);
		quirks_viewer.setUpClues(value.clues, rng);
		quirks_viewer.setUpControllerSupport(continue_button);
		regional_manager.setUpLead(value);
		if (GameHandler.instance.using_gamepad)
		{
			continue_button.Select();
		}
	}

	public void continueLead()
	{
		GameHandler.instance.moveToScene("GameScene");
	}

	public void onInputChange(PlayerInput _input)
	{
		if (_input.isUsingGamepad())
		{
			continue_button.Select();
		}
	}
}
