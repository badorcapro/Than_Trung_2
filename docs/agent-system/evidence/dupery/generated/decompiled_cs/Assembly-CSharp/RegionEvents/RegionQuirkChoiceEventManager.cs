using System.Collections.Generic;
using GRGLib.Extensions.String;
using Nodes.Logic;
using Quirks;
using UnityEngine;

namespace RegionEvents;

public class RegionQuirkChoiceEventManager : RegionEventBaseManager
{
	[SerializeField]
	private CaseQuirksVisualDataSO quirks_visuals;

	[Header("References")]
	[SerializeField]
	private QuirkChoiceManager quirk_choice_1;

	[SerializeField]
	private QuirkChoiceManager quirk_choice_2;

	public override void setUp(RegionDataGraphNavigator _navigator)
	{
		if (!(_navigator.getLastActioned() is QuirkAdditionRegionNodeBase quirkAdditionRegionNodeBase))
		{
			Debug.LogError("Last actionned role is not SetsRoleNode!!! This is not allowed!!!");
			return;
		}
		(CaseQuirks, CaseQuirks) choice = quirkAdditionRegionNodeBase.getChoice(_navigator, new List<CaseQuirks>());
		CaseQuirkData caseQuirkData = choice.Item1.createQuirk();
		quirk_choice_1.setUpChoice(quirks_visuals[choice.Item1], caseQuirkData.name.colour(quirks_visuals.text_colour).bold().sizeRelative(150) + "\n" + caseQuirkData.description_white, choice.Item1, onChoice);
		CaseQuirkData caseQuirkData2 = choice.Item2.createQuirk();
		quirk_choice_2.setUpChoice(quirks_visuals[choice.Item2], caseQuirkData2.name.colour(quirks_visuals.text_colour).bold().sizeRelative(150) + "\n" + caseQuirkData2.description_white, choice.Item2, onChoice);
	}

	private void onChoice(CaseQuirks _quirk)
	{
	}
}
