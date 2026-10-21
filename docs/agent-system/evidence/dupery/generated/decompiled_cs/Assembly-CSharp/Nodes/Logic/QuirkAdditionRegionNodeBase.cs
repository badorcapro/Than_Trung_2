using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using XNode;

namespace Nodes.Logic;

public abstract class QuirkAdditionRegionNodeBase : RegionDataNodeBase
{
	[Input(ShowBackingValue.Never, ConnectionType.Multiple, TypeConstraint.None, false)]
	public RegionDataNodeBase enter;

	[Output(ShowBackingValue.Never, ConnectionType.Multiple, TypeConstraint.None, false)]
	public RegionDataNodeBase exit;

	protected override void doAction(RegionDataGraphNavigator _navigator)
	{
	}

	public virtual (CaseQuirks, CaseQuirks) getChoice(RegionDataGraphNavigator _navigator, List<CaseQuirks> _current)
	{
		List<CaseQuirks> list = (from _q in getAllowedQuirks(_navigator)
			where true
			select _q).ToList();
		if (list.Count < 2)
		{
			throw new ArgumentException("Cannot set up event scene with choice as not enough quirks are allowed!!!");
		}
		List<CaseQuirks> randomElementsFromList = list.getRandomElementsFromList(_navigator.random, 2);
		return (randomElementsFromList[0], randomElementsFromList[1]);
	}

	protected abstract List<CaseQuirks> getAllowedQuirks(RegionDataGraphNavigator _navigator);

	public abstract bool canQuirkAppear(CaseQuirks _quirk);
}
