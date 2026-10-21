using System;
using System.Collections.Generic;
using System.Linq;
using ControllerSupport;
using GRGLib.Extensions.Random;
using GRGLib.Serializable;
using Leads;
using UnityEngine;
using UnityEngine.InputSystem;

namespace LeadSelection;

public class LeadSelectionManager : MonoBehaviour
{
	[SerializeField]
	private RegionsSO regions_data;

	[Header("References")]
	[SerializeField]
	private FootprintProgressBar progress_bar;

	[SerializeField]
	private RectTransform leads_parent;

	[SerializeField]
	private BaseInputHandler controller_support;

	[Header("Prefabs")]
	[SerializeField]
	private LeadSelection lead_prefab;

	[Header("Settings")]
	[SerializeField]
	private List<STupple<Vector2, float>> lead_positioning;

	private List<LeadSelection> choices = new List<LeadSelection>();

	private void Start()
	{
		if (GameHandler.State.current_lead.is_some && GameHandler.State.current_lead.value.is_lead_completed && !GameHandler.State.endCurrentLeadWithClue(RandomExtensions.freshRandom()).is_some)
		{
			Debug.LogError("In lead selection scene, ended lead and did not get back a clue!");
		}
		if (GameHandler.State.available_lead_choices.Count > 0)
		{
			setUpLeads(GameHandler.State.available_lead_choices, RandomExtensions.freshRandom(), regions_data[GameHandler.State.current_region].region_name);
			return;
		}
		bool force_new = GameHandler.MetaData.regionWantsNewSets(GameHandler.State.current_region);
		LeadProgressionManager leadProgressionManager;
		if (GameHandler.State.current_region == Regions.SYNDICATE)
		{
			leadProgressionManager = LeadHelper.getSyndicateProgressionManager(GameHandler.State, regions_data);
			force_new = false;
		}
		else
		{
			leadProgressionManager = GameHandler.State.current_region.getLeadProgressionManager(regions_data);
		}
		GameHandler.MetaData.resetRegionWantsNewSet(GameHandler.State.current_region);
		System.Random rng = RandomExtensions.freshRandom();
		setUpLeads(leadProgressionManager.createRegionLeads(rng, force_new), rng, leadProgressionManager.getRegionName());
		GameHandler.State.setLeadChoices(choices.Select((LeadSelection _ls) => _ls.getLead()).ToList());
		GameHandler.instance.saveGame();
	}

	private void setUpLeads(List<Lead> _leads, System.Random _rng, string _region_name)
	{
		for (int i = 0; i < _leads.Count && i < lead_positioning.Count; i++)
		{
			createLeadSelection(lead_positioning[(_leads.Count == 1) ? 1 : i], _leads[i], _rng, _region_name);
		}
		setSelectionControllerSupport();
	}

	private void setSelectionControllerSupport()
	{
		for (int i = 0; i < choices.Count; i++)
		{
			choices[i].setUpControllerSupport(GameHandler.instance.using_gamepad, (i == 0) ? null : choices[i - 1].getSelectable(), (i + 1 < choices.Count) ? choices[i + 1].getSelectable() : null);
		}
		if (GameHandler.instance.using_gamepad)
		{
			choices[0].getSelectable().Select();
		}
	}

	public void onInputDeviceChange(PlayerInput _input)
	{
		choices.ForEach(delegate(LeadSelection _c)
		{
			_c.changeInput(_input.isUsingGamepad());
		});
		if (_input.isUsingGamepad() && !controller_support.isAnythingSelected())
		{
			choices[0].getSelectable().Select();
		}
	}

	private LeadSelection createLeadSelection(STupple<Vector2, float> _position, Lead _lead, System.Random _rng, string _region_name)
	{
		LeadSelection leadSelection = UnityEngine.Object.Instantiate(lead_prefab, leads_parent);
		leadSelection.transform.localPosition = _position.Item1;
		leadSelection.transform.localEulerAngles = new Vector3(0f, 0f, _position.Item2);
		leadSelection.transform.localScale = new Vector3(0.75f, 0.75f);
		leadSelection.setUpSelection(_lead, _rng, selectLead, _region_name);
		choices.Add(leadSelection);
		return leadSelection;
	}

	private void selectLead(Lead _lead)
	{
		if (!TransitionHandler.instance.is_transitioning)
		{
			GameHandler.State.startLead(_lead);
			GameHandler.instance.moveToScene("GameScene", _save: true);
		}
	}
}
