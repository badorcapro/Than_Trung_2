using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Mutt : CasinoRoleData
{
	private CasinoCardInfo left_card;

	private CasinoCardInfo right_card;

	public override Roles role => Roles.MUTT;

	public override string english_name => "Mutt";

	public override string english_description => TextHelper.whenInvestigated + ", discard and redraw both " + TextHelper.cards + " in your hand. I " + Keywords.ANNOUNCE.toString() + " what your " + TextHelper.cards + " used to be.";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + " I will still discard and redraw both " + TextHelper.cards + " in your hand but I will " + Keywords.ANNOUNCE.toString() + " 2 random " + TextHelper.cards + " that you did not have in your hand."));
			return list;
		}
	}

	public override bool hasInfo => true;

	public Mutt(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Mutt(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new PositionRolesIfExistsGC(GCPosition.NOT_SURROUNDING, DisguiseConstraintType.NEVER_IGNORE, Roles.EXTRAVERT));
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onInvestigationAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _investigated_address)
	{
		if (_investigated_address != base.address)
		{
			return base.onInvestigationAction(_board, _payload, _investigated_address);
		}
		if (!(_payload is CasinoCaseActionPayload casinoCaseActionPayload))
		{
			Debug.LogError("Payload is not casino payload! This is not allowed!");
			return _board;
		}
		left_card = casinoCaseActionPayload.left_card.info;
		right_card = casinoCaseActionPayload.right_card.info;
		base.casino_case.drawNewCards();
		return _board;
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		if (base.has_bad_info)
		{
			CasinoCardInfo casinoCardInfo = new CasinoCardInfo(random);
			CasinoCardInfo casinoCardInfo2 = new CasinoCardInfo(random);
			while (casinoCardInfo == left_card || casinoCardInfo == right_card)
			{
				casinoCardInfo = new CasinoCardInfo(random);
			}
			while (casinoCardInfo2 == left_card || casinoCardInfo2 == right_card)
			{
				casinoCardInfo2 = new CasinoCardInfo(random);
			}
			return getInfo(casinoCardInfo, casinoCardInfo2);
		}
		if (!base.investigated || left_card.value == 0)
		{
			return "";
		}
		return getInfo(left_card, right_card);
	}

	private string getInfo(CasinoCardInfo _card_1, CasinoCardInfo _card_2)
	{
		return checkTranslationWithReplace(() => infoEnglish(_card_1.toSymbolString(), _card_2.toSymbolString()), () => _card_1.toSymbolString(), () => _card_2.toSymbolString());
	}

	private string infoEnglish(string _data1, string _data2)
	{
		return "I discarded the " + _data1 + " and the " + _data2 + ".";
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
