using System;
using GRGLib.Maybe;

namespace Save;

[Serializable]
public class RoleSave
{
	public RoleDataSave data;

	public RoleInfoSave info;

	public Maybe<RoleDataSave> disguise;

	public RoleSave(Roles _role, RoleDataInfo _info, bool _ability_exhausted, string _unique_data, Maybe<RoleData> _disguise, Maybe<Roles> _override_reveal, Maybe<RoleClassifications> _over_vis_class, Maybe<Alignments> _over_vis_align)
	{
		data = new RoleDataSave(_role, _ability_exhausted, _unique_data, _override_reveal, _over_vis_class, _over_vis_align);
		info = new RoleInfoSave(_info);
		disguise = (_disguise.is_some ? _disguise.value.toDataSave().maybe() : new Maybe<RoleDataSave>());
	}

	public RoleSave(RoleDataSaveV0_3_12 _old_save, Maybe<RoleDataSaveV0_3_12> _disguise)
	{
		data = new RoleDataSave(_old_save.role, _old_save.ability_exhausted, _old_save.unique_data, new Maybe<Roles>(), new Maybe<RoleClassifications>(), new Maybe<Alignments>());
		info = new RoleInfoSave(_old_save, _disguise.is_some && _disguise.value.tainted);
		disguise = (_disguise.is_some ? new RoleDataSave(_disguise.value.role, _disguise.value.ability_exhausted, _disguise.value.unique_data, new Maybe<Roles>(), new Maybe<RoleClassifications>(), new Maybe<Alignments>()).maybe() : new Maybe<RoleDataSave>());
	}

	public RoleSave(RoleSavev0_4_23 _old_save)
	{
		data = _old_save.data.convert();
		info = _old_save.info.convert();
		disguise = (_old_save.disguise.is_some ? _old_save.disguise.value.convert().maybe() : new Maybe<RoleDataSave>());
	}
}
