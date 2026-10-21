using System;
using System.Collections.Generic;
using Audio;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Judge : ClockRoleData, IHaveAnimation, IHaveAudio
{
	private static int hour_trigger = 10;

	private int trigger_odds = 30;

	private bool must_arrest;

	private int hour_to_check = hour_trigger - 2;

	public override Roles role => Roles.JUDGE;

	public override string english_name => "Judge";

	public override string english_description => "Every time you " + Keywords.INVESTIGATE.toString() + " a " + Keywords.ROLE.toString() + ", I may bang my gavel. If you do not " + Keywords.ARREST.toString() + " a " + Keywords.ROLE.toString() + " immediately, I will destroy your " + $"{Keywords.REPUTATION.toString()}. I will never bang my gavel before the {hour_trigger}th hour. {TextHelper.iLieAndPretendNotInPlay}.";

	public override bool hasInfo => false;

	public Maybe<Sfx> play_sfx_immidiate { get; private set; } = new Maybe<Sfx>();

	public Maybe<IHaveAnimation.RoleAnimations> play_animation_immediate { get; private set; } = new Maybe<IHaveAnimation.RoleAnimations>();

	public bool stop_animation_immediate { get; private set; }

	private string loc_news_key => $"{role} [news]";

	public Judge(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Judge(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			string[] array = _save.unique_data.Split(',');
			must_arrest = array[0] == "t";
			trigger_odds = int.Parse(array[1]);
			hour_to_check = int.Parse(array[2]);
			if (must_arrest)
			{
				playJudgeAnimation();
			}
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load {role}!\nData: {_save.unique_data}\nError: {arg}");
			trigger_odds = 30;
			hour_to_check = hour_trigger - 2;
			must_arrest = false;
		}
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.NOT_IN_PLAY);
	}

	public void resetWantedSfx()
	{
		play_sfx_immidiate = new Maybe<Sfx>();
	}

	public void resetWantedAnimation()
	{
		play_animation_immediate = new Maybe<IHaveAnimation.RoleAnimations>();
		stop_animation_immediate = false;
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onArrestAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _arrested_address)
	{
		must_arrest = false;
		stop_animation_immediate = true;
		return _board;
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onInvestigationAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _investigated_address)
	{
		if (!canTrigger())
		{
			return base.onInvestigationAction(_board, _payload, _investigated_address);
		}
		if (!(_payload is ClockCaseActionPayload clockCaseActionPayload))
		{
			Debug.LogError("Judge was not given a clock payload!");
			return base.onInvestigationAction(_board, _payload, _investigated_address);
		}
		if (must_arrest)
		{
			base.clock_case.setReputationExternally(0, checkTranslation(loc_news_key, englishNewsHeadline));
			return _board;
		}
		if (clockCaseActionPayload.hour_passed >= hour_to_check)
		{
			if (random.Next(0, 100) < trigger_odds)
			{
				must_arrest = true;
				playJudgeAnimation();
				trigger_odds = 30;
				hour_to_check = clockCaseActionPayload.hour_passed + 4;
			}
			else
			{
				trigger_odds += 20;
			}
		}
		return base.onInvestigationAction(_board, _payload, _investigated_address);
	}

	private void playJudgeAnimation()
	{
		play_sfx_immidiate = Sfx.JUDGE_GAVEL.maybe();
		stop_animation_immediate = false;
		play_animation_immediate = IHaveAnimation.RoleAnimations.JUDGE_SUSPECT_SHAKE.maybe();
	}

	private string englishNewsHeadline()
	{
		return "JUDGE CONVICTS FAMOUS DETECTIVE!";
	}

	private bool canTrigger()
	{
		if (!base.tainted)
		{
			if (base.dead || base.arrested)
			{
				return base.case_ref.hasMarkerQuirk(CaseQuirks.HAUNTED);
			}
			return true;
		}
		return false;
	}

	public override string getUniqueSaveData()
	{
		return string.Format("{0},{1},{2}", must_arrest ? "t" : "f", trigger_odds, hour_to_check);
	}
}
