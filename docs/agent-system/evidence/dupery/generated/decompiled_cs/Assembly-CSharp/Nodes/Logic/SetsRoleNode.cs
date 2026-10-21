using UnityEngine;

namespace Nodes.Logic;

public class SetsRoleNode : NodeBase
{
	[SerializeField]
	private Roles role;

	public Roles getRole()
	{
		return role;
	}
}
