using System;
using GRGLib.Maybe;
using UnityEngine;

namespace Save;

[Serializable]
public class RoleInfoSavev0_4_23
{
	public int address;

	public Vector2Int board_position;

	public bool investigated;

	public bool arrested;

	public bool dead;

	public bool tainted;

	public bool disguise_tainted;

	public bool lying;

	public bool obscured;

	public bool hidden;

	public Alignments alignment;

	public RoleClassifications classification;

	public string blocking_investigation;

	public Maybe<string> info_string;

	public RoleInfoSave convert()
	{
		return new RoleInfoSave(this);
	}
}
