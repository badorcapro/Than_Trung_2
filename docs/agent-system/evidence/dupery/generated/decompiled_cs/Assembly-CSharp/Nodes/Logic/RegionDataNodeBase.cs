using GRGLib.Maybe;

namespace Nodes.Logic;

public abstract class RegionDataNodeBase : NodeBase
{
	public RegionDataGraph region_graph => graph as RegionDataGraph;

	public bool nextAction(RegionDataGraphNavigator _navigator)
	{
		Maybe<RegionDataNodeBase> maybe = fetchNext(_navigator);
		if (!maybe.is_some)
		{
			return false;
		}
		_navigator.setLastActioned(maybe.value);
		maybe.value.doAction(_navigator);
		return true;
	}

	protected abstract void doAction(RegionDataGraphNavigator _navigator);

	public virtual Maybe<RegionDataNodeBase> fetchNext(RegionDataGraphNavigator _navigator)
	{
		return tryGetOutputValue<RegionDataNodeBase>("exit");
	}
}
