using System;
using GRGLib.Maybe;
using GRGLib.Serializable;

namespace Save;

[Serializable]
public class RoleDataSaveV0_3_12
{
	public Roles role;

	public int address;

	public STupple<int, int> board_position;

	public bool investigated;

	public string blocking_investigation;

	public bool tainted;

	public bool arrested;

	public bool lying;

	public bool dead;

	public bool ability_exhausted;

	public bool obscured;

	public Alignments alignment;

	public RoleClassifications classification;

	public Maybe<string> info_string;

	public string unique_data;

	[NonSerialized]
	public Maybe<RoleDataSaveV0_3_12> disguise = new Maybe<RoleDataSaveV0_3_12>();
}
