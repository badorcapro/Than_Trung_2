using System;
using System.Collections;
using System.Collections.Generic;
using GRGLib.Coroutines;
using Nodes.Logic;
using UnityEngine;

namespace RegionEvents;

public class RegionRoleSetChoiceEventManager : RegionEventBaseManager
{
	[SerializeField]
	private RoleVisualDataSO roles_visual_data;

	[Header("References")]
	[SerializeField]
	private RoleSetChoiceManager choice_1;

	[SerializeField]
	private RoleSetChoiceManager choice_2;

	private (RoleSetsGraph, RoleSetsGraph, List<Roles>) set_choice;

	public override void setUp(RegionDataGraphNavigator _navigator)
	{
		if (!(_navigator.getLastActioned() is RegionSetsChoiceBaseNode regionSetsChoiceBaseNode))
		{
			Debug.LogError("Last actionned role is not SetsRoleNode!!! This is not allowed!!!");
			return;
		}
		set_choice = regionSetsChoiceBaseNode.getChoice(_navigator);
		choiceOpeningAnim(_navigator).start(this);
	}

	private IEnumerator choiceOpeningAnim(RegionDataGraphNavigator _nav)
	{
		throw new NotImplementedException("REGION NODES ARE DEPRECATED!");
	}

	private void onChoiceSelect(List<Roles> _roles)
	{
	}
}
