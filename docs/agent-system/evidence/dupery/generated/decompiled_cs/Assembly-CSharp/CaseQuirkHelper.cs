using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using Quirks;
using UnityEngine;

public static class CaseQuirkHelper
{
	public static bool inPlay(this List<CaseQuirks> _quirk_list, CaseQuirks _quirk)
	{
		return _quirk_list.Contains(_quirk);
	}

	public static bool anyInPlay(this List<CaseQuirks> _quirk_list, params CaseQuirks[] _quirks)
	{
		return _quirk_list.Exists((CaseQuirks _c) => _c.equalToAny(_quirks));
	}

	public static bool allInPlay(this List<CaseQuirks> _quirk_list, params CaseQuirks[] _quirks)
	{
		return !_quirks.ToList().Exists((CaseQuirks _q) => !_quirk_list.Contains(_q));
	}

	public static CaseQuirkData createQuirk(this CaseQuirks _quirk, bool _completed = false)
	{
		return _quirk switch
		{
			CaseQuirks.EVIL_GAZE => new EvilGaze(), 
			CaseQuirks.GOOD_INTUITION => new GoodIntuition(), 
			CaseQuirks.DARK_WHISPERS => new DarkWhispers(), 
			CaseQuirks.PUBLIC_FAVOUR => new PublicFavour(), 
			CaseQuirks.SHOT_IN_THE_DARK => new ShotInTheDark(_completed), 
			CaseQuirks.VISIBLE_JUSTICE => new VisibleJustice(), 
			CaseQuirks.SWIFT_JUSTICE => new SwiftJustice(), 
			CaseQuirks.DEADLY_AIM => new DeadlyAim(), 
			CaseQuirks.REGAL_HAND => new RegalHand(_completed), 
			CaseQuirks.HIGH_VALUE_TARGET => new HighValueTarget(), 
			CaseQuirks.SOUL_READ => new SoulRead(), 
			CaseQuirks.POKER_FACE => new PokerFace(), 
			CaseQuirks.LOYALTY_CARD => new LoyaltyCard(), 
			CaseQuirks.LOST_AT_SEA => new LostAtSea(), 
			CaseQuirks.SAILBOAT => new Sailboat(), 
			CaseQuirks.REFUEL => new Refuel(), 
			CaseQuirks.JEALOUSY => new Jealousy(), 
			CaseQuirks.TICKING_CLOCK => new TickingClock(_completed), 
			CaseQuirks.MISTY_STREETS => new MistyStreets(), 
			CaseQuirks.HIDDEN_SMIRK => new HiddenSmirk(), 
			CaseQuirks.BAD_INFLUENCES => new BadInfluences(), 
			CaseQuirks.RADIO_INTERFERENCE => new RadioInterference(), 
			CaseQuirks.ANTI_AUTHORITARIANISM => new AntiAuthoritarianism(), 
			CaseQuirks.MORTAL_DREAD => new MortalDread(), 
			CaseQuirks.SETUP => new Setup(), 
			CaseQuirks.MEDICAL_BREAKTHROUGH => new MedicalBreakthrough(), 
			CaseQuirks.PARANOIA => new Paranoia(), 
			CaseQuirks.DIRTY_COP => new DirtyCop(), 
			CaseQuirks.SILENT_ACCOMPLICE => new SilentAccomplice(), 
			CaseQuirks.INSIDER_LOYALTY => new InsiderLoyalty(), 
			CaseQuirks.OUTSIDER_LOYALTY => new OutsiderLoyalty(), 
			CaseQuirks.UNHOLY_LAND => new UnholyLand(), 
			CaseQuirks.SHRINK => new Shrink(), 
			CaseQuirks.THAT_SMILE => new ThatSmile(), 
			CaseQuirks.HAUNTED => new Haunted(), 
			CaseQuirks.PERFECT_CRIME => new PerfectCrime(), 
			CaseQuirks.EVIL_SUSPECTS => new EvilSuspects(), 
			CaseQuirks.BROKEN_CLOCK => new BrokenClock(), 
			CaseQuirks.FAULTY_CLOCK => new FaultyClock(), 
			CaseQuirks.BROKEN_RADIO => new BrokenRadio(), 
			CaseQuirks.BREACH_OF_TRUST => new BreachOfTrust(), 
			CaseQuirks.POCKET_PAIR => new PoketPair(), 
			CaseQuirks.DRAW_LEFT => new DrawLeft(), 
			CaseQuirks.DRAW_RIGHT => new DrawRight(), 
			CaseQuirks.RISK_REWARD => new RiskReward(), 
			CaseQuirks.RIGGED_DECK => new RiggedDeck(), 
			CaseQuirks.DECISION_PARALYSIS => new DecisionParalysis(), 
			CaseQuirks.GAMBLER_FALLACY => new GamblersFallacy(_completed), 
			CaseQuirks.DEADLY_ROYALS => new DeadlyRoyals(), 
			CaseQuirks.AGILE_FINGERS => new AgileFingers(), 
			CaseQuirks.NIGHT_SHIFT => new NightShift(), 
			CaseQuirks.VIOLENT_PIRACY => new ViolentPiracy(), 
			CaseQuirks.FAULTY_GAUGE => new FaultyGauge(), 
			CaseQuirks.CRUEL_SEAS => new CruelSeas(), 
			CaseQuirks.HARSH_WATERS => new HarshWaters(), 
			CaseQuirks.SILENT_MUTINY => new SilentMutiny(_completed), 
			CaseQuirks.PUBLIC_UNREST => new PublicUnrest(), 
			CaseQuirks.SPECTRES_DREAM => new SpectresDream(), 
			CaseQuirks.HIDE_AND_SEEK => new HideAndSeek(), 
			_ => throw new ArgumentException($"No case quirk data set up for quirk {_quirk}!"), 
		};
	}

	public static Maybe<List<CaseQuirks>> getQuirkVetos(this CaseQuirks _quirk)
	{
		return _quirk switch
		{
			CaseQuirks.BROKEN_CLOCK => new List<CaseQuirks> { CaseQuirks.FAULTY_CLOCK }.maybe(), 
			CaseQuirks.BROKEN_RADIO => new List<CaseQuirks> { CaseQuirks.RADIO_INTERFERENCE }.maybe(), 
			CaseQuirks.PERFECT_CRIME => new List<CaseQuirks> { CaseQuirks.EVIL_SUSPECTS }.maybe(), 
			_ => new Maybe<List<CaseQuirks>>(), 
		};
	}

	public static void debugLogCaseQuirks(this List<CaseQuirks> _quirk_list)
	{
		string quirks = "Quirks in game: ";
		_quirk_list.ForEach(delegate(CaseQuirks _q)
		{
			quirks = quirks + _q.ToString() + " / ";
		});
		Debug.Log(quirks);
	}

	public static bool isGoodQuirk(this CaseQuirks _quirk)
	{
		return _quirk < CaseQuirks.JEALOUSY;
	}

	public static bool isBadQuirk(this CaseQuirks _quirk)
	{
		return !_quirk.isGoodQuirk();
	}

	public static bool isSpecialQuirk(this CaseQuirks _quirk)
	{
		return _quirk > (CaseQuirks)20000;
	}

	public static int getCaseQuirkExecutionOrder(this CaseQuirks _quirk)
	{
		return (int)_quirk;
	}

	public static bool isRoundCreationQuirk(this CaseQuirks _quirk)
	{
		return _quirk switch
		{
			CaseQuirks.EVIL_GAZE => true, 
			CaseQuirks.MISTY_STREETS => true, 
			CaseQuirks.BAD_INFLUENCES => true, 
			CaseQuirks.ANTI_AUTHORITARIANISM => true, 
			CaseQuirks.TRICKSTER => true, 
			CaseQuirks.SILENT_ACCOMPLICE => true, 
			_ => false, 
		};
	}

	public static List<CaseQuirks> getAllQuirks()
	{
		return (from _c in new List<CaseQuirks>().addAll()
			where !_c.isScrapped() && (SettingsHandler.allow_test_quirks || (int)_c % 10000 < 5000)
			select _c).toListSafe();
	}

	public static List<CaseQuirks> getAllQuirks(Func<CaseQuirks, bool> _should_add)
	{
		return (from _c in new List<CaseQuirks>().addAll()
			where !_c.isScrapped() && (SettingsHandler.allow_test_quirks || (int)_c % 10000 < 5000) && _should_add(_c)
			select _c).toListSafe();
	}

	public static bool isScrapped(this CaseQuirks _quirk)
	{
		return _quirk >= (CaseQuirks)900000;
	}

	public static bool isTest(this CaseQuirks _quirk)
	{
		return (int)_quirk % 10000 >= 5000;
	}
}
