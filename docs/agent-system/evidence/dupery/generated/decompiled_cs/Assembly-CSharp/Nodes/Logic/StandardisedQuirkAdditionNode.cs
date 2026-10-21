using System;
using System.Collections.Generic;
using UnityEngine;

namespace Nodes.Logic;

public class StandardisedQuirkAdditionNode : QuirkAdditionRegionNodeBase, INodeRegionEvent
{
	public enum QuirkAdditionType
	{
		POSITIVE,
		NEGATIVE,
		ANY
	}

	[SerializeField]
	[NodeEnum]
	protected QuirkAdditionType quirk_type = QuirkAdditionType.ANY;

	protected override List<CaseQuirks> getAllowedQuirks(RegionDataGraphNavigator _navigator)
	{
		return getAllowedQuirks((CaseQuirks _q) => true);
	}

	private List<CaseQuirks> getAllowedQuirks(Func<CaseQuirks, bool> _allowed_quirk_check)
	{
		return quirk_type switch
		{
			QuirkAdditionType.ANY => base.region_graph.getAllowedCaseQuirks(_allowed_quirk_check), 
			QuirkAdditionType.NEGATIVE => base.region_graph.getAllowedCaseQuirks((CaseQuirks _q) => _allowed_quirk_check(_q) && _q.isBadQuirk()), 
			QuirkAdditionType.POSITIVE => base.region_graph.getAllowedCaseQuirks((CaseQuirks _q) => _allowed_quirk_check(_q) && _q.isGoodQuirk()), 
			_ => throw new ArgumentException($"No function set up to get allowed quirks! {quirk_type}!"), 
		};
	}

	public override bool canQuirkAppear(CaseQuirks _quirk)
	{
		return getAllowedQuirks((CaseQuirks _q) => true).Contains(_quirk);
	}
}
