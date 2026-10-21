using System.Collections.Generic;
using UnityEngine;
using XNode;

namespace Nodes.Logic;

public class RoleRemovalRegionNode : RegionDataNodeBase, INodeRegionEvent
{
	[Input(ShowBackingValue.Never, ConnectionType.Multiple, TypeConstraint.None, false)]
	public RegionDataNodeBase enter;

	[Output(ShowBackingValue.Never, ConnectionType.Multiple, TypeConstraint.None, false)]
	public RegionDataNodeBase exit;

	[SerializeField]
	private int removing = 1;

	[SerializeField]
	private int choice = 5;

	[SerializeField]
	private List<RoleClassifications> vetoed_classes = new List<RoleClassifications> { RoleClassifications.TRAITOR };

	public int getRemoving()
	{
		return removing;
	}

	public int getChoice()
	{
		return choice;
	}

	public List<RoleClassifications> getVetoedClasses()
	{
		return vetoed_classes;
	}

	protected override void doAction(RegionDataGraphNavigator _navigator)
	{
	}
}
