using System;
using System.Collections.Generic;
using System.Linq;
using Nodes.Logic;

namespace Leads;

[Serializable]
public struct RoleSetInfoStruct
{
	public string set_name;

	public string lead_suffix;

	public List<Roles> set_roles;

	private RoleSetsGraph.SetsType set_type;

	public RoleSetInfoStruct(RoleSetsGraph _set_graph)
	{
		set_name = _set_graph.getSetName();
		lead_suffix = _set_graph.getLeadTitleSuffix().ToUpper();
		set_roles = _set_graph.getSetRoles();
		set_type = _set_graph.getSetType();
		orderRoles();
	}

	public RoleSetInfoStruct(string _set_name, string _lead_suffix, List<Roles> _roles, RoleSetsGraph.SetsType _type)
	{
		set_name = _set_name;
		lead_suffix = _lead_suffix.ToUpper();
		set_roles = _roles;
		set_type = _type;
		orderRoles();
	}

	public bool hasSameRolesAs(RoleSetInfoStruct _other)
	{
		if (set_roles.Count != _other.set_roles.Count)
		{
			return false;
		}
		return set_roles.All((Roles _r) => _other.set_roles.Contains(_r));
	}

	private void orderRoles()
	{
		set_roles = set_roles.OrderBy((Roles _e) => _e.getClassificationFromRoleType() switch
		{
			RoleClassifications.INNOCENT => 0, 
			RoleClassifications.MEDDLER => 1, 
			RoleClassifications.UNDERLING => 2, 
			RoleClassifications.TRAITOR => 3, 
			_ => -1, 
		}).ToList();
	}
}
