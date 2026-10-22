using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Romantic : RoleData
{
	public int partner_address = -1;

	private bool partner_forced;

	public bool is_jelly;

	public override Roles role => Roles.ROMANTIC;

	public override string english_name => "Romantic";

	public override string english_description => "I pick an " + Keywords.CARDINALLY_ADJACENT.toString() + " " + TextHelper.innocentRole + " to be my lover. " + TextHelper.whenInvestigated + ", I " + Keywords.ANNOUNCE.toString() + " their " + Keywords.ADDRESS.toString() + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + ", my lover is an " + RoleClassifications.UNDERLING.toString() + " and I may or may not be " + Keywords.CARDINALLY_ADJACENT.toString() + " to them."));
			list.Add((DescriptionType.SPECIAL, "When the " + Roles.CASANOVA.toString() + " is " + Keywords.IN_PLAY.toString() + " and I am not " + TextHelper.lyingOrTainted + ", I will " + Keywords.ANNOUNCE.toString() + " \"" + RoleData.loc_marker_1 + "\"."));
			list.Add((DescriptionType.SPECIAL, "If I find no valid " + TextHelper.roles + " that satisfy these rules, I will " + Keywords.ANNOUNCE.toString() + " \"" + RoleData.loc_marker_2 + "\"."));
			return list;
		}
	}

	public override bool hasInfo => true;

	public override bool has_hover_focus
	{
		get
		{
			if (partner_address != base.address)
			{
				return partner_address != -1;
			}
			return false;
		}
	}

	private string loc_self_love_key => $"{role} [self_love]";

	private string loc_jelly_key => $"{role} [jelly]";

	public Romantic(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Romantic(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		string[] array = _save.unique_data.Split(',');
		if (array.Length != 0)
		{
			partner_address = int.Parse(array[0]);
			is_jelly = int.Parse(array[1]) == 1;
		}
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new RomanticGC());
	}

	protected override string fillExtraDescription(string _description, DescriptionType _type)
	{
		if (_type != DescriptionType.SPECIAL)
		{
			return _description;
		}
		return _description.Replace(RoleData.loc_marker_1, checkTranslation(loc_jelly_key, getJellyEnglish)).Replace(RoleData.loc_marker_2, checkTranslation(loc_self_love_key, getSelfLoveEnglish));
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (!_occupent.is_a)
		{
			return false;
		}
		return _occupent.maybe_a.value.getAddress() == partner_address;
	}

	private void checkForPartner(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board)
	{
		if (partner_forced)
		{
			return;
		}
		is_jelly = _board.getRolesInPlay().Values.Any((RoleData _e) => _e.role == Roles.CASANOVA && !_e.getIsTainted());
		if (base.has_bad_info)
		{
			List<RoleData> adjacentRolesFromGridPos = _board.getAdjacentRolesFromGridPos(base.board_position, base.case_ref.board_size);
			List<RoleData> list = (from _e in _board.getRolesInPlay()
				select _e.Value into _e
				where _e.getAddress() != base.address && _e.getVisualClassification() == RoleClassifications.UNDERLING
				select _e).ToList();
			if (list.Count == 0)
			{
				partner_address = base.address;
				return;
			}
			foreach (Vector2Int n_pos in adjacentRolesFromGridPos.Select((RoleData _e) => _e.getBoardPosition()))
			{
				if (list.Select((RoleData _e) => _e.getBoardPosition()).Contains(n_pos))
				{
					partner_address = adjacentRolesFromGridPos.Where((RoleData _e) => _e.getBoardPosition() == n_pos).First().getAddress();
					return;
				}
			}
			list.shuffle(random);
			partner_address = list[0].getAddress();
		}
		else if (is_jelly)
		{
			partner_address = base.address;
		}
		else
		{
			List<RoleData> list2 = (from _r in _board.getAdjacentRolesFromGridPos(base.board_position, base.case_ref.board_size)
				where _r.getVisualClassification() == RoleClassifications.INNOCENT
				select _r).ToList();
			if (list2.Count == 0)
			{
				partner_address = getAddress();
			}
			else
			{
				partner_address = list2.getRandomElementFromList(random).getAddress();
			}
		}
	}

	public void setForcedPartner(int _partner)
	{
		partner_address = _partner;
		partner_forced = true;
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		checkForPartner(_snap.board);
		if (is_jelly && !base.has_bad_info)
		{
			return checkTranslation(loc_jelly_key, getJellyEnglish);
		}
		if (partner_address == base.address)
		{
			return checkTranslation(loc_self_love_key, getSelfLoveEnglish);
		}
		return checkTranslationWithData(getInfoEnglish, partner_address);
	}

	private string getSelfLoveEnglish()
	{
		return "I love myself!";
	}

	private string getJellyEnglish()
	{
		return "My lover ran away with somebody else?!";
	}

	private string getInfoEnglish(string _data)
	{
		return "I love #" + _data + "!";
	}

	protected override void onInfoReset()
	{
		partner_address = -1;
		partner_forced = false;
	}

	public override string getTruthString()
	{
		return base.getTruthString();
	}

	public override string getUniqueSaveData()
	{
		return string.Format("{0},{1}", partner_address, is_jelly ? "1" : "0");
	}
}
