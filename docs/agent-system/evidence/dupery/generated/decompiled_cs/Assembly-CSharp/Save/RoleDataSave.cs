using System;
using GRGLib.Maybe;

namespace Save;

[Serializable]
public class RoleDataSave
{
	public Roles role;

	public string unique_data;

	public bool ability_exhausted;

	public Maybe<Roles> override_reveal;

	public Maybe<RoleClassifications> override_visual_class;

	public Maybe<Alignments> override_visual_alignment;

	public RoleDataSave(Roles _role, bool _ability_exhausted, string _unique_data, Maybe<Roles> _override_reveal, Maybe<RoleClassifications> _over_vis_class, Maybe<Alignments> _over_vis_align)
	{
		role = _role;
		ability_exhausted = _ability_exhausted;
		unique_data = _unique_data;
		override_reveal = _override_reveal;
		override_visual_class = _over_vis_class;
		override_visual_alignment = _over_vis_align;
	}
}
