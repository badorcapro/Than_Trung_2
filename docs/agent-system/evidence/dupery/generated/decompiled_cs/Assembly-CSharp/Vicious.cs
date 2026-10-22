using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Vicious : RoleData
{
	private bool obscured_neighbours;

	public override Roles role => Roles.VICIOUS;

	public override string english_name => "Vicious";

	public override string english_description => TextHelper.ipretendSuspectedInnocent + ". When I am " + TextHelper.arrested + ", I " + Keywords.OBSCURE.toString() + " all " + Keywords.S_NEIGHBOURS.toString() + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmTainted + ", I do not " + Keywords.OBSCURE.toString() + " any " + TextHelper.roles + " when I am " + TextHelper.arrested + "."));
			return list;
		}
	}

	public override string credits => "Sam sam";

	public override bool hasInfo => false;

	public override bool has_truth_hover_focus => obscured_neighbours;

	public Vicious(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Vicious(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		obscured_neighbours = _save.unique_data == "t";
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getInnocentDisguise(DisguiseTarget.SUSPECTED);
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new PositionRoleGC(GCPosition.SURROUNDING, DisguiseConstraintType.NEVER_IGNORE));
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	public override string getTruthString()
	{
		return (obscured_neighbours ? (checkTranslation(base.loc_default_truth_key, getTruthEnglish) + "\n") : "") + base.getTruthString();
	}

	private string getTruthEnglish()
	{
		return "I obscured all my neighbours when I was arrested.";
	}

	public override bool checkEndHoverTruthFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (obscured_neighbours && _occupent.is_a && _position.isSurroundingOrOn(base.board_position))
		{
			return _position != base.board_position;
		}
		return false;
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onArrestAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _arrested_address)
	{
		if (_arrested_address != base.address || base.has_bad_info || base.dead)
		{
			return _board;
		}
		_board.getSurroundingRolesFromGridPos(base.board_position, base.case_ref.board_size).ForEach(delegate(RoleData _r)
		{
			_r.setObscured(_new: true);
		});
		return _board;
	}

	public override string getUniqueSaveData()
	{
		if (!obscured_neighbours)
		{
			return "f";
		}
		return "t";
	}
}
