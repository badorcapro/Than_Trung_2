using System.Collections.Generic;
using System.Linq;
using UnityEngine;

namespace Nodes.Logic;

public class RoleConditionNode : RoleSetsConditionNodeBase
{
	public enum Match
	{
		NEED_AT_LEAST_ONE,
		NEED_ALL,
		NEED_ONLY_ONE
	}

	[SerializeField]
	private List<Roles> roles;

	[SerializeField]
	[NodeEnum]
	private Match match_type = Match.NEED_ALL;

	public override bool isConditionMet(GameState _state, List<Roles> _current_roles)
	{
		switch (match_type)
		{
		case Match.NEED_AT_LEAST_ONE:
			return roles.Any((Roles _r) => _current_roles.Contains(_r));
		case Match.NEED_ALL:
			return !roles.Any((Roles _r) => !_current_roles.Contains(_r));
		case Match.NEED_ONLY_ONE:
		{
			int num = 0;
			foreach (Roles role in roles)
			{
				if (_current_roles.Contains(role))
				{
					num++;
					if (num >= 2)
					{
						return false;
					}
				}
			}
			return num == 1;
		}
		default:
			Debug.LogError($"No condition set in RoleConditionNode.isConditionMet for match type {match_type}!");
			return false;
		}
	}
}
