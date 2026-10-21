using System.Collections.Generic;

namespace Nodes.Logic;

public abstract class RoleSetsConditionNodeBase : NodeBase
{
	public abstract bool isConditionMet(GameState _state, List<Roles> _current_roles);
}
