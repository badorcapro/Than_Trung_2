using System;
using System.Linq;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class BlackjackPlayer : CasinoRoleData
{
	private const int blackjack = 21;

	public override Roles role => Roles.BLACKJACK_PLAYER;

	public override string english_name => "Blackjack Player";

	public override string english_description => $"{TextHelper.whenInvestigatedIAnnounce} \"{englishBlackjack()}\" if the sum of all {TextHelper.evilRole} {TextHelper.addresses} is {21}. " + $"If the sum of all {TextHelper.evilRole} {TextHelper.addresses} is less than {21}, I {Keywords.ANNOUNCE.toString()} \"{englishHitMe()}\". Otherwise I {Keywords.ANNOUNCE.toString()} \"{englishBust()}\"";

	public override string credits => "wrigglys";

	public override bool hasInfo => true;

	private string loc_info_hit_me => $"{role} [info_hm]";

	private string loc_info_bust => $"{role} [info_b]";

	public BlackjackPlayer(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public BlackjackPlayer(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	protected override Alignments getStartingAlignment()
	{
		return Alignments.GOOD;
	}

	protected override RoleClassifications getStartingClassification()
	{
		return RoleClassifications.INNOCENT;
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		int num = _snap.address_occupents.Values.Aggregate(0, (int _a, RoleData _r) => (_r.getVisualAlignment() == Alignments.EVIL) ? _r.getAddress() : 0);
		if (num < 21)
		{
			if (base.has_bad_info)
			{
				if (random.Next(0, 2) == 1)
				{
					return checkTranslation(englishBlackjack);
				}
				return checkTranslation(loc_info_bust, englishBust);
			}
			return checkTranslation(loc_info_hit_me, englishHitMe);
		}
		if (num == 21)
		{
			if (base.has_bad_info)
			{
				if (random.Next(0, 2) == 1)
				{
					return checkTranslation(loc_info_hit_me, englishHitMe);
				}
				return checkTranslation(loc_info_bust, englishBust);
			}
			return checkTranslation(englishBlackjack);
		}
		if (base.has_bad_info)
		{
			if (random.Next(0, 2) == 1)
			{
				return checkTranslation(englishBlackjack);
			}
			return checkTranslation(loc_info_bust, englishHitMe);
		}
		return checkTranslation(loc_info_hit_me, englishBust);
	}

	private string englishBlackjack()
	{
		return "Blackjack!";
	}

	private string englishHitMe()
	{
		return "Hit me!";
	}

	private string englishBust()
	{
		return "I'm bust!";
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
