using GRGLib.Maybe;
using Save;
using UnityEngine;

public class RoleDataInfo
{
	public const char temp_state_sep = '#';

	public RoleClassifications classification;

	public Alignments alignment;

	public int address = -1;

	public Vector2Int board_position = Vector2Int.zero;

	public bool investigated;

	public bool arrested;

	public bool dead;

	public bool lying;

	public bool tainted;

	public bool disguise_tainted;

	public bool obscured;

	public bool hidden;

	public Maybe<string> info_string = new Maybe<string>();

	public string blocking_investigation = "";

	public string temp_states = "";

	public RoleDataInfo(RoleClassifications _classification, Alignments _aligment)
	{
		classification = _classification;
		alignment = _aligment;
	}

	public RoleDataInfo(RoleClassifications _classification, Alignments _aligment, int _address, Vector2Int _board_position)
	{
		classification = _classification;
		alignment = _aligment;
		address = _address;
		board_position = _board_position;
	}

	public RoleDataInfo(RoleInfoSave _save)
	{
		classification = _save.classification;
		alignment = _save.alignment;
		address = _save.address;
		board_position = _save.board_position;
		investigated = _save.investigated;
		tainted = _save.tainted;
		disguise_tainted = _save.disguise_tainted;
		lying = _save.lying;
		arrested = _save.arrested;
		dead = _save.dead;
		obscured = _save.obscured;
		hidden = _save.hidden;
		info_string = _save.info_string;
		blocking_investigation = _save.blocking_investigation;
		temp_states = _save.temp_states;
	}

	public void resetTempState(string _state_key)
	{
		string text = "";
		string[] array = temp_states.Split('#');
		foreach (string text2 in array)
		{
			if (!text2.StartsWith(_state_key))
			{
				text = text + "#" + text2;
			}
		}
		temp_states = text;
	}
}
