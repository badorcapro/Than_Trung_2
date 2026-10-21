using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Wannabe : RoleData
{
	private int target_address = -1;

	public override Roles role => Roles.WANNABE;

	public override string english_name => "Wannabe";

	public override string english_description => "I " + Keywords.PRETEND.toString() + " to be a " + TextHelper.tainted + " " + Keywords.IN_PLAY.toString() + " " + TextHelper.revealed + " " + RoleClassifications.UNDERLING.toString() + ".\nOne " + Keywords.IN_PLAY.toString() + " " + RoleClassifications.UNDERLING.toString() + " is " + TextHelper.revealed + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I may " + Keywords.REVEAL.toString() + " a " + Keywords.ROLE.toString() + " that is not " + TextHelper.pretending + "."));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmTainted + " I do not " + Keywords.REVEAL.toString() + " another " + TextHelper.underlingRole + "."));
			return list;
		}
	}

	public override bool hasInfo => false;

	public override bool can_be_disguise => false;

	public override bool has_truth_hover_focus => target_address > 0;

	public Wannabe(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
		if (base.is_true_self)
		{
			base.role_info.disguise_tainted = true;
		}
	}

	public Wannabe(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			target_address = int.Parse(_save.unique_data);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load {role}! ({_save.unique_data}) Error: {arg}");
		}
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return new DisguiseCharacteristics(DisguiseTarget.IN_PLAY, new List<RoleClassifications> { RoleClassifications.UNDERLING }, new List<Roles>(), _check_disguise_constraints: false);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	public override string getTruthString()
	{
		return ((target_address != -1) ? (checkTranslationWithData(base.loc_default_truth_key, getTruthEnglish, target_address) + "\n") : "") + base.getTruthString();
	}

	private string getTruthEnglish(string _data)
	{
		return "I revealed #" + _data + ".";
	}

	public override bool checkEndHoverTruthFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return _occupent.maybe_a.value.getAddress() == target_address;
		}
		return false;
	}

	public override List<RevealLineSettings> getRevealLines(CaseSnapshot _snap)
	{
		if (target_address != -1)
		{
			return getRevealLineToTarget(target_address, RevealLineColour.WHITE, _snap);
		}
		return new List<RevealLineSettings>();
	}

	protected override Alignments getStartingAlignment()
	{
		return Alignments.GOOD;
	}

	protected override RoleClassifications getStartingClassification()
	{
		return RoleClassifications.MEDDLER;
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onDisguiseSet(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		if (!base.tainted)
		{
			Maybe<RoleData> maybe = (from _e in _board.getRolesInPlay().Values
				where _e.getVisualClassification() == RoleClassifications.UNDERLING
				select _e into _r
				select (!_r.getDisguiseCharacteristics(base.case_ref).disguises) ? (_r: _r, 3) : (_r: _r, 5)).ToList().weightedChoose(random);
			if (!maybe.is_some)
			{
				Debug.LogError("Wannabe could not find a role to reveal??? This should be impossible.");
				return _board;
			}
			maybe.value.setDisguise(new Maybe<RoleData>());
			maybe.value.setForcedDisguised();
			target_address = maybe.value.getAddress();
		}
		return _board;
	}

	public override string getUniqueSaveData()
	{
		return $"{target_address}";
	}
}
