using System;
using GRGLib.Maybe;
using UnityEngine;

namespace Save;

[Serializable]
public class RoleInfoSave
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

	public string temp_states;

	public RoleInfoSave(RoleDataInfo _info)
	{
		address = _info.address;
		board_position = _info.board_position;
		investigated = _info.investigated;
		arrested = _info.arrested;
		dead = _info.dead;
		tainted = _info.tainted;
		disguise_tainted = _info.disguise_tainted;
		lying = _info.lying;
		obscured = _info.obscured;
		hidden = _info.hidden;
		alignment = _info.alignment;
		classification = _info.classification;
		blocking_investigation = _info.blocking_investigation;
		info_string = _info.info_string;
		temp_states = _info.temp_states;
	}

	public RoleInfoSave(RoleDataSaveV0_3_12 _old_save, bool _disguise_tainted)
	{
		address = _old_save.address;
		board_position = new Vector2Int(_old_save.board_position.Item1, _old_save.board_position.Item2);
		investigated = _old_save.investigated;
		arrested = _old_save.arrested;
		dead = _old_save.dead;
		tainted = _old_save.tainted;
		disguise_tainted = _disguise_tainted;
		lying = _old_save.lying;
		obscured = _old_save.obscured;
		hidden = false;
		alignment = _old_save.alignment;
		classification = _old_save.classification;
		blocking_investigation = _old_save.blocking_investigation;
		info_string = _old_save.info_string;
		temp_states = "";
	}

	public RoleInfoSave(RoleInfoSavev0_4_23 _old_save)
	{
		address = _old_save.address;
		board_position = _old_save.board_position;
		investigated = _old_save.investigated;
		arrested = _old_save.arrested;
		dead = _old_save.dead;
		tainted = _old_save.tainted;
		disguise_tainted = _old_save.disguise_tainted;
		lying = _old_save.lying;
		obscured = _old_save.obscured;
		hidden = _old_save.hidden;
		alignment = _old_save.alignment;
		classification = _old_save.classification;
		blocking_investigation = _old_save.blocking_investigation;
		info_string = _old_save.info_string;
		temp_states = "";
	}
}
