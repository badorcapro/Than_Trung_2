using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Stalker : RoleData, IHaveRoleAbility, IHaveAbility
{
	private static int default_kill_chance = 50;

	public override Roles role => Roles.STALKER;

	public override string english_name => "Stalker";

	public override string english_description => Keywords.ABILITY.toStringCap() + ": Pick a " + TextHelper.surroundingNeighbour + ". I " + Keywords.PRETEND.toString() + " to be their " + Keywords.APPEARANCE.toString() + ". I might " + Keywords.KILL.toString() + " them. If they are " + TextHelper.tainted + ", I always " + Keywords.KILL.toString() + " them.";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "When I am not " + TextHelper.lyingOrTainted + ", the information I give when " + TextHelper.pretending + " will always be correct even if the " + Keywords.ROLE.toString() + " picked is " + TextHelper.lyingOrTainted + "."));
			list.Add((DescriptionType.SPECIAL, "I have a 50% chance to " + Keywords.KILL.toString() + " the selected " + Keywords.TARGET.toString() + "."));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + ", I never " + Keywords.KILL.toString() + "."));
			return list;
		}
	}

	public override bool hasInfo => false;

	public bool abilityExhausted => ability_exhausted;

	public int numberTargets => 1;

	public bool allowSelfTarget => false;

	public Stalker(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Stalker(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(RoleGenerationMarkers.HAS_ABILITY, new PositionRoleGC(GCPosition.SURROUNDING, DisguiseConstraintType.NEVER_IGNORE));
	}

	public bool validateTarget(RoleData _roll_candidate)
	{
		if (_roll_candidate.getBoardPosition().isSurroundingOrOn(base.board_position))
		{
			return _roll_candidate.getVisualRole().can_be_disguise;
		}
		return false;
	}

	public string getAbilityPrompt()
	{
		return TextHelper.ab_selectSurroundingRolesLocalised(1);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onAbilityUsedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _ability_user_address, List<int> _target_addresses)
	{
		if (_ability_user_address != base.address || _target_addresses.Count == 0)
		{
			return base.onAbilityUsedAction(_board, _payload, _ability_user_address, _target_addresses);
		}
		if (disguise.is_some)
		{
			return _board;
		}
		RoleData roleData = _board.getRolesInPlay()[_target_addresses[0]];
		RoleData visualRole = roleData.getVisualRole();
		overrideWithNewDisguise(visualRole.getVisualRole().role);
		if (!base.has_bad_info && (roleData.getIsTainted() || random.Next(0, 100) <= default_kill_chance))
		{
			base.case_ref.killAddress(visualRole.getAddress(), ((RoleData)this).maybe());
		}
		return _board.registerRoleChange(base.board_position, this);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
