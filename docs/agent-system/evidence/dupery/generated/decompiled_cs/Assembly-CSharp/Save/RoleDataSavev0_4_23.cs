using System;
using GRGLib.Maybe;

namespace Save;

[Serializable]
public class RoleDataSavev0_4_23
{
	public Roles role;

	public string unique_data;

	public bool ability_exhausted;

	public RoleDataSave convert()
	{
		return new RoleDataSave(role, ability_exhausted, unique_data, new Maybe<Roles>(), new Maybe<RoleClassifications>(), new Maybe<Alignments>());
	}
}
