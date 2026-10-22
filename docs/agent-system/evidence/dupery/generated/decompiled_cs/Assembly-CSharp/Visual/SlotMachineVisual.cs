using System;
using GRGLib.Coroutines;
using GRGLocalisation;
using Localisation;
using TMPro;
using UnityEngine;

namespace Visual;

public class SlotMachineVisual : LocationVisual, IAmLocalised
{
	[Header("References")]
	[SerializeField]
	private TMP_Text ability_cost_text;

	[SerializeField]
	private CanvasGroup info_group;

	[SerializeField]
	private TMP_Text info_text;

	private CoroutineRunner info_group_runner;

	private bool info_state;

	private AssetKey localisation_asset => LocalisationHelper.ui_asset;

	private string loc_cost_key => "SlotMachine [cost]";

	public override void setUpLocation(LocationData _data, Action<LocationData> _use_ability)
	{
		base.setUpLocation(_data, _use_ability);
		info_group.alpha = 0f;
		info_group_runner = new CoroutineRunner(this);
		if (!(_data is SlotMachine))
		{
			Debug.LogError($"Data is not of correct type! Expecting SlotMachine, recieved {_data.location_type}!");
		}
		else
		{
			ability_cost_text.text = getCostText(15.ToString());
		}
	}

	public override void renew(LocationData _data, CaseSnapshot _snap, Action<LocationData, Vector3> _replace_location)
	{
		base.renew(_data, _snap, _replace_location);
		if (!(_data is SlotMachine slotMachine))
		{
			Debug.LogError($"Data is not of correct type! Expecting SlotMachine, recieved {_data.location_type}!");
		}
		else if (slotMachine.abilityExhausted && !info_state)
		{
			info_state = true;
			info_text.text = slotMachine.info;
			info_group_runner.run(info_group.fade(1f, 0.4f, CoroutineExtensions.easeInOutFunc));
		}
	}

	private string getCostText(string _data)
	{
		if (GRGLocalisationHandler.needs_translation)
		{
			string _result = "";
			if (GRGLocalisationHandler.instance.translateAndReplace(localisation_asset, loc_cost_key, out _result, _data))
			{
				return _result;
			}
		}
		return costEnglish(_data);
	}

	private string costEnglish(string _data)
	{
		return "Check how many players I have had for " + _data + " chips!";
	}
}
