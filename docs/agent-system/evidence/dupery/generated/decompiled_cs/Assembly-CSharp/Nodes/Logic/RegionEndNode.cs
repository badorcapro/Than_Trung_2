using GRGLib.Maybe;
using GRGLib.PropertyDrawers;
using UnityEngine;
using XNode;

namespace Nodes.Logic;

public class RegionEndNode : RegionDataNodeBase
{
	[Input(ShowBackingValue.Never, ConnectionType.Multiple, TypeConstraint.None, false)]
	public RegionDataNodeBase enter;

	[SerializeField]
	private bool move_to_region;

	[SerializeField]
	[ConditionalField("move_to_region")]
	private bool set_region = true;

	[SerializeField]
	[MultiFieldConditional(true, new string[] { "move_to_region", "set_region" })]
	private Regions region;

	protected override void doAction(RegionDataGraphNavigator _navigator)
	{
		Debug.LogError("THIS SHOULD NEVER BE CALLED. IT IS DEPRECATED!");
		_ = move_to_region;
		GameHandler.instance.moveToScene("LevelTransitionScene");
	}

	public override Maybe<RegionDataNodeBase> fetchNext(RegionDataGraphNavigator _navigator)
	{
		return new Maybe<RegionDataNodeBase>();
	}
}
