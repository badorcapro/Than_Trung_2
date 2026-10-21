using System;
using GRGLib.Generic;
using GRGLib.Serializable;
using UnityEngine;
using XNode;

namespace Nodes.Logic;

public class RegionCaseNode : RegionDataNodeBase
{
	[Input(ShowBackingValue.Never, ConnectionType.Multiple, TypeConstraint.None, false)]
	public RegionDataNodeBase enter;

	[Output(ShowBackingValue.Never, ConnectionType.Multiple, TypeConstraint.None, false)]
	public RegionDataNodeBase exit;

	[SerializeField]
	[Range(0f, 1f)]
	private float diff_01;

	[SerializeField]
	private Vector2Int board_size = new Vector2Int(4, 4);

	[SerializeField]
	private MinMaxInt address_size = new MinMaxInt(6, 12);

	[SerializeField]
	private SerializableDictionary<RoleClassifications, MinMaxInt> custom_ratios;

	protected override void doAction(RegionDataGraphNavigator _navigator)
	{
		GameHandler.instance.moveToScene("GameScene");
	}

	protected virtual CaseRatioBuilderData getRatioBuilder()
	{
		throw new NotImplementedException("Region nodes are deprecated!");
	}

	protected virtual CaseReward getCaseReward()
	{
		return base.region_graph.case_type switch
		{
			CaseType.CLOCK => new ClockCaseReward(0, 1, _syndicate_clue: false), 
			CaseType.DOCKS => new DocksCaseReward(0, 1, _syndicate_clue: false), 
			CaseType.CASINO => new CasinoCaseReward(50, _syndicate_clue: false), 
			CaseType.BACK_ALLEYS => new BackAlleysCaseReward(0, 10, _syndicate_clue: false), 
			_ => throw new ArgumentException($"No function set up to create case reward for case type {base.region_graph.case_type}!"), 
		};
	}
}
