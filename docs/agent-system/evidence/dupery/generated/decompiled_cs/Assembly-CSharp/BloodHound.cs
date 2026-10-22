using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class BloodHound : RoleData
{
	private enum Direction
	{
		EXCEPTION = -1,
		NORTH,
		EAST,
		SOUTH,
		WEST,
		BARK,
		SNIFF
	}

	private Direction direction_said = Direction.EXCEPTION;

	public override Roles role => Roles.BLOOD_HOUND;

	public override string english_name => "Blood Hound";

	public override string english_description => TextHelper.whenInvestigated + ", I " + Keywords.ANNOUNCE.toString() + " the direction of the nearest " + TextHelper.evilRole + " from me that is in my column or row.\nIf the closest " + TextHelper.evilRoles + " are the same distance away from me, I start barking.\nIf I find no " + Alignments.EVIL.toString() + ", I sniff.";

	public override List<(DescriptionType, string)> english_extra_descriptions => new List<(DescriptionType, string)> { (DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + " I " + Keywords.ANNOUNCE.toString() + " a random result from the following list: north, east, south, west, bark, or sniff.\nThis result cannot be truthful.") };

	public override bool hasInfo => true;

	public override bool has_hover_focus => base.info_string.is_some;

	private string loc_info_key => $"{role} [i#]";

	public BloodHound(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public BloodHound(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		direction_said = (Direction)int.Parse(_save.unique_data);
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (!_occupent.is_a || !base.info_string.is_some)
		{
			return false;
		}
		switch (direction_said)
		{
		case Direction.NORTH:
			if (_position.x == base.board_position.x)
			{
				return _position.y < base.board_position.y;
			}
			return false;
		case Direction.EAST:
			if (_position.y == base.board_position.y)
			{
				return _position.x > base.board_position.x;
			}
			return false;
		case Direction.SOUTH:
			if (_position.x == base.board_position.x)
			{
				return _position.y > base.board_position.y;
			}
			return false;
		case Direction.WEST:
			if (_position.y == base.board_position.y)
			{
				return _position.x < base.board_position.x;
			}
			return false;
		case Direction.BARK:
			if (_position.x != base.board_position.x)
			{
				return _position.y == base.board_position.y;
			}
			return true;
		case Direction.SNIFF:
			if (_position.x != base.board_position.x)
			{
				return _position.y != base.board_position.y;
			}
			return false;
		default:
			return false;
		}
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		Dictionary<int, Direction> nearest_direction = new Dictionary<int, Direction>();
		_snap.board.getRolesInPlay().Values.Where((RoleData _e) => _e.getVisualAlignment() == Alignments.EVIL && _e.getAddress() != base.address).ToList().ForEach(delegate(RoleData _e)
		{
			Vector2Int vector2Int = _e.getBoardPosition() - base.board_position;
			if (vector2Int.x == 0 || vector2Int.y == 0)
			{
				int key = Mathf.Abs(vector2Int.x) + Mathf.Abs(vector2Int.y);
				Direction value = ((vector2Int.x != 0) ? ((vector2Int.x > 0) ? Direction.EAST : Direction.WEST) : ((vector2Int.y >= 0) ? Direction.SOUTH : Direction.NORTH));
				if (nearest_direction.ContainsKey(key))
				{
					nearest_direction[key] = Direction.BARK;
				}
				else
				{
					nearest_direction[key] = value;
				}
			}
		});
		if (nearest_direction.Count == 0)
		{
			direction_said = (base.has_bad_info ? ((Direction)random.Next(0, 5)) : Direction.SNIFF);
			return getStringFromDirection(direction_said);
		}
		int key2 = nearest_direction.Keys.OrderBy((int x) => x).First();
		if (base.has_bad_info)
		{
			int num = random.Next(0, 6);
			if (nearest_direction[key2] == (Direction)num)
			{
				num = (num + 1) % 6;
			}
			direction_said = (Direction)num;
			return getStringFromDirection(direction_said);
		}
		direction_said = nearest_direction[key2];
		return getStringFromDirection(direction_said);
	}

	private string getStringFromDirection(Direction _direction)
	{
		return checkTranslation(getLocInfoKey((int)_direction), () => getStringFromDirectionEnglish(_direction));
	}

	private string getStringFromDirectionEnglish(Direction _direction)
	{
		return _direction switch
		{
			Direction.NORTH => "*Points North*", 
			Direction.EAST => "*Points East*", 
			Direction.SOUTH => "*Points South*", 
			Direction.WEST => "*Points West*", 
			Direction.BARK => "BARK BARK BARK!", 
			Direction.SNIFF => "*sniffs*", 
			_ => throw new InvalidOperationException($"No string for direction {_direction} set up!"), 
		};
	}

	public RoleData createAndForceSetInfo(int _direction)
	{
		base.info_string = getStringFromDirectionEnglish((Direction)_direction).maybe();
		return this;
	}

	protected override Alignments getStartingAlignment()
	{
		return Alignments.GOOD;
	}

	protected override RoleClassifications getStartingClassification()
	{
		return RoleClassifications.INNOCENT;
	}

	public override string getUniqueSaveData()
	{
		int num = (int)direction_said;
		return num.ToString();
	}

	private string getLocInfoKey(int _info)
	{
		return loc_info_key.Replace("#", _info.ToString());
	}
}
