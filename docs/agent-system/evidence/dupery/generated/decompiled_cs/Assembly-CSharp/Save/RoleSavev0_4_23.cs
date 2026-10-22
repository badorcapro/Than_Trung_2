using System;
using GRGLib.Maybe;

namespace Save;

[Serializable]
public class RoleSavev0_4_23
{
	public RoleDataSavev0_4_23 data;

	public RoleInfoSavev0_4_23 info;

	public Maybe<RoleDataSavev0_4_23> disguise;

	public RoleSave convert()
	{
		return new RoleSave(this);
	}
}
