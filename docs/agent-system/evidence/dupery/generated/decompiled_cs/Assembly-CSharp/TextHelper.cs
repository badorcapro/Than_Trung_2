using System;
using System.Collections.Generic;
using GRGLib.Coroutines;
using GRGLib.Extensions.Random;
using GRGLib.Extensions.String;
using GRGLib.Maybe;
using GRGLib.TextAnimation;
using GRGLocalisation;
using Localisation;
using TMPro;
using UnityEngine;

public static class TextHelper
{
	public static string hover_link_start => "HL_";

	public static string ability_off_sprite_link => "<sprite name=\"Ability_Off\">";

	public static string ability_on_sprite_link => "<sprite name=\"Ability_On\">";

	public static string key_point_sprite_link => "<sprite name=\"Keypoint\">";

	public static string adjacent_sprite_link => "<sprite name=\"adjacent\" color=#000000>";

	public static string surrounding_sprite_link => "<sprite name=\"surrounding\" color=#000000>";

	public static string chips_sprite_link => "<sprite name=\"chip\" color=#000000>".asKeyword(Keywords.CHIPS);

	public static string chips_sprite_link_white => "<sprite name=\"chip\">";

	public static string chips_with_link => "<sprite name=\"chip\" color=#000000> chips".asKeyword(Keywords.CHIPS);

	public static string chips_with_link_white => "<sprite name=\"chip\"> chips".asKeyword(Keywords.CHIPS);

	public static string jack_with_link => "<sprite name=\"" + CasinoCardInfo.jack_sprite_link_name + "\" color=#000000> Jack";

	public static string queen_with_link => "<sprite name=\"" + CasinoCardInfo.queen_sprite_link_name + "\" color=#000000> Queen";

	public static string king_with_link => "<sprite name=\"" + CasinoCardInfo.king_sprite_link_name + "\" color=#000000> King";

	public static string affected_by_multi_sprite_link => "";

	public static string credits_sprite_link => "$$$";

	public static string credits_with_link => credits_sprite_link + Keywords.CREDITS.toString();

	public static string ability_with_cost_marker => Keywords.ABILITY.toStringCap() + " [Cost: " + LocalisationHelper.text_marker_1 + chips_sprite_link + "]";

	public static string locations => "locations".asKeyword(Keywords.LOCATION);

	public static string cases => "cases".asKeyword(Keywords.CASE);

	public static string quirks => "quirks".asKeyword(Keywords.QUIRK);

	public static string events => "events".asKeyword(Keywords.EVENT);

	public static string stamps => "stamps".asKeyword(Keywords.STAMP);

	public static string iLieAndPretend => "I " + Keywords.LIE.toString() + " and " + Keywords.PRETEND.toString();

	public static string iLieAndPretendSuspected => iLieAndPretend + " to be a " + suspectedRole;

	public static string iLieAndPretendSuspectedInnocent => iLieAndPretend + " to be a " + suspectedInnocentRole;

	public static string iLieAndPretendInPlay => iLieAndPretend + " to be an " + inPlayRole;

	public static string iLieAndPretendInPlayInnocent => iLieAndPretend + " to be an " + inPlayInnocentRole;

	public static string iLieAndPretendNotInPlay => iLieAndPretend + " to be a " + Keywords.SUSPECTED.toString() + " " + notInPlayRole;

	public static string ipretendSuspected => "I " + Keywords.PRETEND.toString() + " to be a " + suspectedRole;

	public static string ipretendSuspectedInnocent => "I " + Keywords.PRETEND.toString() + " to be a " + suspectedInnocentRole;

	public static string ipretendInPlay => "I " + Keywords.PRETEND.toString() + " to be an " + inPlayRole;

	public static string ipretendInPlayInnocent => "I " + Keywords.PRETEND.toString() + " to be an " + inPlayInnocentRole;

	public static string ipretendNotInPlay => "I " + Keywords.PRETEND.toString() + " to be a " + Keywords.SUSPECTED.toString() + " " + notInPlayRole;

	public static string ipretendNotInPlayInnocent => "I " + Keywords.PRETEND.toString() + " to be a " + Keywords.SUSPECTED.toString() + " " + notInPlayInnocentRole;

	public static string evilRole => Alignments.EVIL.toString() + " " + Keywords.ROLE.toString();

	public static string evilRoles => Alignments.EVIL.toString() + " " + "roles".asKeyword(Keywords.ROLE);

	public static string goodRole => Alignments.GOOD.toString() + " " + Keywords.ROLE.toString();

	public static string goodRoles => Alignments.GOOD.toString() + " " + "roles".asKeyword(Keywords.ROLE);

	public static string innocentRole => RoleClassifications.INNOCENT.toString() + " " + Keywords.ROLE.toString();

	public static string innocentRoles => RoleClassifications.INNOCENT.toString() + " " + "roles".asKeyword(Keywords.ROLE);

	public static string meddlerRole => RoleClassifications.MEDDLER.toString() + " " + Keywords.ROLE.toString();

	public static string meddlerRoles => RoleClassifications.MEDDLER.toString() + " " + "roles".asKeyword(Keywords.ROLE);

	public static string underlingRole => RoleClassifications.UNDERLING.toString() + " " + Keywords.ROLE.toString();

	public static string underlingRoles => RoleClassifications.UNDERLING.toString() + " " + "roles".asKeyword(Keywords.ROLE);

	public static string traitorRole => RoleClassifications.TRAITOR.toString() + " " + Keywords.ROLE.toString();

	public static string traitorRoles => RoleClassifications.TRAITOR.toString() + " " + "roles".asKeyword(Keywords.ROLE);

	public static string innocentOrMeddlerRole => RoleClassifications.INNOCENT.toString() + " or " + meddlerRole;

	public static string innocentOrMeddlerRoles => RoleClassifications.INNOCENT.toString() + " or " + meddlerRoles;

	public static string underlingOrTraitorRole => RoleClassifications.UNDERLING.toString() + " or " + traitorRole;

	public static string underlingOrTraitorRoles => RoleClassifications.UNDERLING.toString() + " or " + traitorRoles;

	public static string inPlayRole => Keywords.IN_PLAY.toString() + " " + Keywords.ROLE.toString();

	public static string inPlayInnocentRole => Keywords.IN_PLAY.toString() + " " + RoleClassifications.INNOCENT.toString() + " " + Keywords.ROLE.toString();

	public static string notInPlayRole => Keywords.NOT_IN_PLAY.toString() + " " + Keywords.ROLE.toString();

	public static string notInPlayInnocentRole => Keywords.NOT_IN_PLAY.toString() + " " + RoleClassifications.INNOCENT.toString() + " " + Keywords.ROLE.toString();

	public static string notInPlayMeddlerRole => Keywords.NOT_IN_PLAY.toString() + " " + RoleClassifications.MEDDLER.toString() + " " + Keywords.ROLE.toString();

	public static string suspectedRole => Keywords.SUSPECTED.toString() + " " + Keywords.ROLE.toString();

	public static string suspectedInnocentRole => Keywords.SUSPECTED.toString() + " " + RoleClassifications.INNOCENT.toString() + " " + Keywords.ROLE.toString();

	public static string suspectedMeddlerRole => Keywords.SUSPECTED.toString() + " " + RoleClassifications.MEDDLER.toString() + " " + Keywords.ROLE.toString();

	public static string suspectedUnderlingRole => Keywords.SUSPECTED.toString() + " " + RoleClassifications.UNDERLING.toString() + " " + Keywords.ROLE.toString();

	public static string suspectedRoles => Keywords.SUSPECTED.toString() + " " + "roles".asKeyword(Keywords.ROLE);

	public static string truthfulRole => Keywords.TRUTHFUL.toString() + " " + Keywords.ROLE.toString();

	public static string truthfulRoles => Keywords.TRUTHFUL.toString() + " " + roles;

	public static string uninvestigatedRole => Keywords.UNINVESTIGATED.toString() + " " + Keywords.ROLE.toString();

	public static string uninvestigatedRoles => Keywords.UNINVESTIGATED.toString() + " " + roles;

	public static string uninvestigatedGoodRole => Keywords.UNINVESTIGATED.toString() + " " + Alignments.GOOD.toString() + " " + Keywords.ROLE.toString();

	public static string uninvestigatedEvilRole => Keywords.UNINVESTIGATED.toString() + " " + Alignments.EVIL.toString() + " " + Keywords.ROLE.toString();

	public static string adjacentToTheBoat => Keywords.CARDINALLY_ADJACENT.toString() + " to the " + Keywords.BOAT.toString();

	public static string adjacentOrOnTheBoat => Keywords.CARDINALLY_ADJACENT.toString() + " or on the " + Keywords.BOAT.toString();

	public static string addresses => "addresses".asKeyword(Keywords.ADDRESS);

	public static string abilities => "abilities".asKeyword(Keywords.ABILITY);

	public static string announcement => "announcement".asKeyword(Keywords.ANNOUNCE);

	public static string roles => "roles".asKeyword(Keywords.ROLE);

	public static string c_roles => "Roles".asKeyword(Keywords.ROLE);

	public static string innocents => "Innocents".asKeyword(RoleClassifications.INNOCENT);

	public static string innocent => "Innocent".asKeyword(RoleClassifications.INNOCENT);

	public static string meddlers => "Meddlers".asKeyword(RoleClassifications.MEDDLER);

	public static string underlings => "Underlings".asKeyword(RoleClassifications.UNDERLING);

	public static string traitors => "Traitors".asKeyword(RoleClassifications.TRAITOR);

	public static string investigated => "investigated".asKeyword(Keywords.INVESTIGATE);

	public static string investigating => "investigating".asKeyword(Keywords.INVESTIGATE);

	public static string whenInvestigated => "When " + investigated;

	public static string whenInvestigatedIAnnounce => whenInvestigated + ", I " + Keywords.ANNOUNCE.toString();

	public static string whileIAmAliveAndNotArrested => "While I am " + Keywords.ALIVE.toString() + " and not " + arrested;

	public static string tainted => "tainted".asKeyword(Keywords.TAINT);

	public static string taints => "taints".asKeyword(Keywords.TAINT);

	public static string tainting => "tainting".asKeyword(Keywords.TAINT);

	public static string taintedRole => tainted + " " + Keywords.ROLE.toString();

	public static string lying => "lying".asKeyword(Keywords.LIE);

	public static string lyingOrTainted => lying + " or " + tainted;

	public static string whenIAmLyingOrTainted => "When I am " + lyingOrTainted;

	public static string whenIAmLyingOrTaintIAnnounce => whenIAmLyingOrTainted + " I " + Keywords.ANNOUNCE.toString();

	public static string whenIAmTainted => "When I am " + tainted;

	public static string whenIAmArrestedOrKilled => "When I am " + arrested + " or " + killed;

	public static string pretending => "pretending".asKeyword(Keywords.PRETEND);

	public static string pretendingRole => pretending + " " + Keywords.ROLE.toString();

	public static string pretendingRoles => pretending + " " + roles;

	public static string reveals => "reveals".asKeyword(Keywords.REVEAL);

	public static string revealed => "revealed".asKeyword(Keywords.REVEAL);

	public static string revealing => "revealing".asKeyword(Keywords.REVEAL);

	public static string arrests => "arrests".asKeyword(Keywords.ARREST);

	public static string arrested => "arrested".asKeyword(Keywords.ARREST);

	public static string arresting => "arresting".asKeyword(Keywords.ARREST);

	public static string obscured => "obscured".asKeyword(Keywords.OBSCURE);

	public static string unobscure => "unobscure".asKeyword(Keywords.OBSCURE);

	public static string unobscured => "unobscured".asKeyword(Keywords.OBSCURE);

	public static string die => "die".asKeyword(Keywords.DEAD);

	public static string dies => "dies".asKeyword(Keywords.DEAD);

	public static string killing => "killing".asKeyword(Keywords.KILL);

	public static string killed => "killed".asKeyword(Keywords.KILL);

	public static string transformed => "transformed".asKeyword(Keywords.TRANSFORM);

	public static string deadOrArrested => Keywords.DEAD.toString() + " or " + arrested;

	public static string step => "step".asKeyword(Keywords.STEPS);

	public static string aliveAndNotArrested => Keywords.ALIVE.toString() + " and not " + arrested;

	public static string adjacentNeighbour => "adjacent neighbour".asKeyword(Keywords.CA_NEIGHBOURS);

	public static string adjacentNeighbourNoSymbol => "adjacent neighbour".asKeyword(Keywords.CA_NEIGHBOURS);

	public static string adjacentNeighbours => "adjacent neighbours".asKeyword(Keywords.CA_NEIGHBOURS);

	public static string surroundingNeighbour => "surrounding neighbour".asKeyword(Keywords.S_NEIGHBOURS);

	public static string surroundingNeighbourNoSymbol => "surrounding neighbour".asKeyword(Keywords.S_NEIGHBOURS);

	public static string surroundingNeighbours => "surrounding neighbours".asKeyword(Keywords.S_NEIGHBOURS);

	public static string reputationAsStatus => "reputation".asKeyword(Keywords.REPUTATION_STATUS);

	public static string poorReputation => ReputationStatus.POOR.toString() + " " + reputationAsStatus;

	public static string goodReputation => ReputationStatus.NEUTRAL.toString() + " " + reputationAsStatus;

	public static string excellentReputation => ReputationStatus.EXCEPTIONAL.toString() + " " + reputationAsStatus;

	public static string cards => "cards".asKeyword(Keywords.CARD);

	public static string cardsValue => "card's value".asKeyword(Keywords.CARD_VALUE);

	public static string cardsValues => "cards' values".asKeyword(Keywords.CARD_VALUE);

	public static string faceCards => "face cards".asKeyword(Keywords.FACE_CARD);

	public static string faceCards_cap => "Face cards".asKeyword(Keywords.FACE_CARD);

	public static string value => "value".asKeyword(Keywords.CARD_VALUE);

	public static string cardsSuit => "card's suit".asKeyword(Keywords.CARD_SUIT);

	public static string suit => "suit".asKeyword(Keywords.CARD_SUIT);

	public static string suitAssociated => "suit associated".asKeyword(Keywords.SUIT_ASSOCIATION);

	public static string associated => "associated".asKeyword(Keywords.SUIT_ASSOCIATION);

	public static string whenIAmOnTheBoat => "When I am on the " + Keywords.BOAT.toString();

	public static string hid => "hid".asKeyword(Keywords.HIDE);

	public static string hidden => "hidden".asKeyword(Keywords.HIDE);

	public static string unhidden => "unhidden".asKeyword(Keywords.HIDE);

	public static string hiddenRole => hidden + " " + Keywords.ROLE.toString();

	public static string hiddenRoles => hidden + " " + roles;

	public static string dredged => "dredged".asKeyword(Keywords.DREDGE);

	public static string dredging => "dredging".asKeyword(Keywords.DREDGE);

	public static string items => "items".asKeyword(Keywords.ITEM);

	public static string pockets => "pockets".asKeyword(Keywords.POCKET);

	public static string held => "held".asKeyword(Keywords.HOLD);

	public static string heldItem => held + " " + Keywords.ITEM.toString();

	public static string heldItems => held + " " + items;

	public static string stolen => "stolen".asKeyword(Keywords.STEAL);

	public static string stole => "stole".asKeyword(Keywords.STEAL);

	public static string lawfulItem => BackAlleysItemColour.LAWFUL.toString() + " " + Keywords.ITEM.toString();

	public static string mischeviousItem => BackAlleysItemColour.MISCHEVIOUS.toString() + " " + Keywords.ITEM.toString();

	public static string illegalItem => BackAlleysItemColour.ILLEGAL.toString() + " " + Keywords.ITEM.toString();

	public static string blackmarketItem => BackAlleysItemColour.BLACKMARKET.toString() + " " + Keywords.ITEM.toString();

	public static string iAmSelfConfirm => "I am considered a " + Keywords.SELF_CONFIRM.toString() + " " + Keywords.ROLE.toString() + ".";

	public static string iAnnounceOppositeOfTrue => "I " + Keywords.ANNOUNCE.toString() + " the opposite of the true statement.";

	public static string whenIAmLyingOrTaintIAnnounceOppositeOfTrue => whenIAmLyingOrTainted + ", " + iAnnounceOppositeOfTrue;

	public static string otherRolesCannotPretendToBeMe => "Other " + roles + " cannot " + Keywords.PRETEND.toString() + " to be me.";

	public static string iCannotNaturallyBeInPlay => "I cannot natually be " + Keywords.IN_PLAY.toString() + ".";

	public static string whenIAmTaintedMyBehaviourRemains => "When I am " + tainted + " I do not change my behaviour.";

	public static string iUpdateWhenBoatMoves => "I update my " + announcement + " whenever the " + Keywords.BOAT.toString() + " moves.";

	public static string iUpdateOnInvestigation => "I update my " + announcement + " whenever any " + Keywords.ROLE.toString() + " is " + investigated + ".";

	public static string iUpdateOnArrest => "I update my " + announcement + " whenever any " + Keywords.ROLE.toString() + " is " + arrested + ".";

	public static string ab_selectACardLocalised => localisation_asset.checkTranslation(loc_ab_selectCard_key, englishSelectACard);

	public static string ab_reselectToConfirmLocalised => localisation_asset.checkTranslation(loc_ab_reselect_key, englishReselectToConfirm);

	public static string ab_selectASuspectLocalised => localisation_asset.checkTranslation(loc_ab_selectSuspect_key, englishSelectASuspect);

	public static string ab_selectALocationLocalised => localisation_asset.checkTranslation(loc_ab_selectLocation_key, englishSelectALocation);

	public static string address_prefix
	{
		get
		{
			if (!(GRGLocalisationHandler.instance.current_language == Languages.SPANISH))
			{
				return "#";
			}
			return "n.º";
		}
	}

	private static string loc_tainted_many_key => "RoleDefault [tainted_many]";

	private static string loc_killed_many_key => "RoleDefault [killed_many]";

	private static string loc_obscured_many_key => "RoleDefault [obs_many]";

	private static string loc_blocked_many_key => "RoleDefault [blk_many]";

	private static string loc_hid_many_key => "RoleDefault [hid_many]";

	private static string loc_made_evil_many_key => "RoleDefault [evil_many]";

	private static string loc_made_good_many_key => "RoleDefault [good_many]";

	private static string loc_transformed_key => "RoleDefault [transformed]";

	private static string loc_ab_selectRoles_key => "RoleDefault [abil_select_role]";

	private static string loc_ab_selectRolesSurrounding_key => "RoleDefault [abil_select_sur_role]";

	private static string loc_ab_selectCard_key => "RoleDefault [abil_select_card]";

	private static string loc_ab_selectSuspect_key => "RoleDefault [abil_select_sus]";

	private static string loc_ab_selectLocation_key => "RoleDefault [abil_select_loc]";

	private static string loc_ab_selectSuspectClass_key => "RoleDefault [abil_select_sus_class]";

	private static string loc_ab_reselect_key => "RoleDefault [abil_reselect]";

	private static string loc_ab_empty_pos_key => "RoleDefault [abil_emp_pos]";

	private static AssetKey localisation_asset => LocalisationHelper.general_case_asset;

	public static string animateLink(this string _content, TextAnimationType _animation)
	{
		return _content.sandwichString("<link=\"" + _animation.toTag() + "\">", "</link>");
	}

	public static Color get(this TextColour _colour)
	{
		return _colour switch
		{
			TextColour.WHITE => Color.white, 
			TextColour.BLACK => Color.black, 
			TextColour.RED => new Color(0.77f, 0.12f, 0.12f), 
			_ => throw new ArgumentException($"No colour set up for setting {_colour}!"), 
		};
	}

	public static void bakeText(this TMP_Text _text, string _content, bool _force = true)
	{
		_text.text = _content;
		_text.bakeText(_force);
	}

	public static void bakeText(this TMP_Text _text, bool _force = false)
	{
		_text.bake("A_", fetchAnimationFromLink, _force);
	}

	public static string toTag(this TextAnimationType _anim)
	{
		return $"A_{(int)_anim}#";
	}

	public static string sandwitchWithColourIfSome(this string _string, Maybe<Color> _colour)
	{
		if (!_colour.is_some)
		{
			return _string;
		}
		return _string.sandwichWithColour(_colour.value);
	}

	public static Maybe<TextAnimationManager> fetchAnimationFromLink(string _link, TMP_Text _text)
	{
		if (_link.Contains(TextAnimationType.VERY_SLOW_WIGGLE.toTag()))
		{
			return createWiggleTextAnimation(_text, 1.2f, 5f).maybe();
		}
		if (_link.Contains(TextAnimationType.SLOW_WIGGLE.toTag()))
		{
			return createWiggleTextAnimation(_text, 0.6f, 5f).maybe();
		}
		if (_link.Contains(TextAnimationType.NORMAL_WIGGLE.toTag()))
		{
			return createWiggleTextAnimation(_text, 0.3f, 5f).maybe();
		}
		if (_link.Contains(TextAnimationType.FAST_WIGGLE.toTag()))
		{
			return createWiggleTextAnimation(_text, 0.15f, 5f).maybe();
		}
		if (_link.Contains(TextAnimationType.VERY_SLOW_STRONG_WIGGLE.toTag()))
		{
			return createWiggleTextAnimation(_text, 1.2f, 15f).maybe();
		}
		if (_link.Contains(TextAnimationType.SLOW_STRONG_WIGGLE.toTag()))
		{
			return createWiggleTextAnimation(_text, 0.6f, 15f).maybe();
		}
		if (_link.Contains(TextAnimationType.NORMAL_STRONG_WIGGLE.toTag()))
		{
			return createWiggleTextAnimation(_text, 0.3f, 15f).maybe();
		}
		if (_link.Contains(TextAnimationType.FAST_STRONG_WIGGLE.toTag()))
		{
			return createWiggleTextAnimation(_text, 0.15f, 15f).maybe();
		}
		if (_link.Contains(TextAnimationType.SLOW_VERY_STRONG_WIGGLE.toTag()))
		{
			return createWiggleTextAnimation(_text, 0.6f, 25f).maybe();
		}
		if (_link.Contains(TextAnimationType.VERY_STRONG_WIGGLE.toTag()))
		{
			return createWiggleTextAnimation(_text, 0.3f, 25f).maybe();
		}
		if (_link.Contains(TextAnimationType.MILD_SHAKE.toTag()))
		{
			return ((TextAnimationManager)new ShakeTextAnimationManager(_text, 1f)).maybe();
		}
		if (_link.Contains(TextAnimationType.NORMAL_SHAKE.toTag()))
		{
			return ((TextAnimationManager)new ShakeTextAnimationManager(_text, 3f)).maybe();
		}
		if (_link.Contains(TextAnimationType.STRONG_SHAKE.toTag()))
		{
			return ((TextAnimationManager)new ShakeTextAnimationManager(_text, 5f)).maybe();
		}
		if (_link.Contains(TextAnimationType.VERY_STRONG_SHAKE.toTag()))
		{
			return ((TextAnimationManager)new ShakeTextAnimationManager(_text, 7f)).maybe();
		}
		if (_link.Contains(TextAnimationType.SLOW_SHAKEY_WIGGLE.toTag()))
		{
			return createCombinedManager(_text, createWiggleTextAnimation(_text, 0.6f, 5f), new ShakeTextAnimationManager(_text, 3f)).maybe();
		}
		if (_link.Contains(TextAnimationType.SHAKEY_WIGGLE.toTag()))
		{
			return createCombinedManager(_text, createWiggleTextAnimation(_text, 0.3f, 5f), new ShakeTextAnimationManager(_text, 3f)).maybe();
		}
		if (_link.Contains(TextAnimationType.FAST_SHAKEY_WIGGLE.toTag()))
		{
			return createCombinedManager(_text, createWiggleTextAnimation(_text, 0.15f, 5f), new ShakeTextAnimationManager(_text, 3f)).maybe();
		}
		if (_link.Contains(TextAnimationType.SLOW_STRONG_SHAKEY_WIGGLE.toTag()))
		{
			return createCombinedManager(_text, createWiggleTextAnimation(_text, 0.6f, 15f), new ShakeTextAnimationManager(_text, 3f)).maybe();
		}
		if (_link.Contains(TextAnimationType.STRONG_SHAKEY_WIGGLE.toTag()))
		{
			return createCombinedManager(_text, createWiggleTextAnimation(_text, 0.3f, 15f), new ShakeTextAnimationManager(_text, 3f)).maybe();
		}
		if (_link.Contains(TextAnimationType.FAST_STRONG_SHAKEY_WIGGLE.toTag()))
		{
			return createCombinedManager(_text, createWiggleTextAnimation(_text, 0.15f, 15f), new ShakeTextAnimationManager(_text, 3f)).maybe();
		}
		if (_link.Contains(TextAnimationType.WIGGLE_RANDOM_SHAKES.toTag()))
		{
			return ((TextAnimationManager)new WiggleAndRandomShakes(_text, new ShakeTextAnimationManager(_text, 3f), TextAnimationHelper.createLoopingAnimationCurve(0.3f, 5f))).maybe();
		}
		if (_link.Contains(TextAnimationType.LINEUP_TITLE_WIGGLE.toTag()))
		{
			return createWiggleTextAnimation(_text, 0.7f, 12f).maybe();
		}
		return TextAnimationHelper.tryGetPresetAnimationManagers(_link, _text);
	}

	private static TextAnimationManager createCombinedManager(TMP_Text _text, params TextAnimationManager[] _managers)
	{
		return new CombineAnimationsManager(_text, _managers);
	}

	private static TextAnimationManager createWiggleTextAnimation(TMP_Text _text, float _x_step, float _y_max)
	{
		return new CurveTextAnimationManager(_text, TextAnimationHelper.createLoopingAnimationCurve(_x_step, _y_max));
	}

	public static Func<float, float> getEaseFunc(this CoroutineEasing _easing)
	{
		return _easing switch
		{
			CoroutineEasing.NONE => (float _f) => _f, 
			CoroutineEasing.IN_OUT => CoroutineExtensions.easeInOutFunc, 
			CoroutineEasing.IN => CoroutineExtensions.easeInFunc, 
			CoroutineEasing.OUT => CoroutineExtensions.easeOutFunc, 
			CoroutineEasing.IN_OUT_BACK => CoroutineExtensions.easeInOutBackFunc, 
			CoroutineEasing.IN_BACK => CoroutineExtensions.easeInBackFunc, 
			CoroutineEasing.OUT_BACK => CoroutineExtensions.easeOutBackFunc, 
			_ => throw new ArgumentException($"No easing function set for easing method {_easing}"), 
		};
	}

	public static string asKeyword(this string _word, Keywords _keyword)
	{
		return GameHandler.Text.asKeyword(_keyword, _word);
	}

	public static string asKeyword(this string _word, RoleClassifications _keyword)
	{
		return GameHandler.Text.asKeyword(_keyword, _word);
	}

	public static string asKeyword(this string _word, Roles _keyword)
	{
		return GameHandler.Text.asKeyword(_word, _keyword);
	}

	public static string toString(this Keywords _keyword)
	{
		return GameHandler.Text.getKeyword(_keyword);
	}

	public static string toStringCap(this Keywords _keyword)
	{
		return GameHandler.Text.getKeywordCap(_keyword);
	}

	public static string toString(this Alignments _alignment)
	{
		return GameHandler.Text.getKeyword(_alignment);
	}

	public static string toStringCap(this Alignments _alignment)
	{
		return GameHandler.Text.getKeywordCap(_alignment);
	}

	public static string toStringPlainCap(this Alignments _alignment)
	{
		return GameHandler.Text.getKeywordAloneCap(_alignment);
	}

	public static string toString(this RoleClassifications _class)
	{
		return GameHandler.Text.getKeyword(_class);
	}

	public static string toStringPlain(this RoleClassifications _class)
	{
		return GameHandler.Text.getKeywordAlone(_class);
	}

	public static string toString(this LocationTypes _loc)
	{
		return GameHandler.Text.getLocationNameTagged(_loc);
	}

	public static string toString(this Roles _role)
	{
		return GameHandler.Text.getRoleNameColoured(_role.createRole(-1, new Vector2Int(-1, -1), RandomExtensions.freshRandom(), new Maybe<RoleData>()));
	}

	public static string toStringPlain(this Roles _role)
	{
		return _role.createRole(-1, new Vector2Int(-1, -1), RandomExtensions.freshRandom(), new Maybe<RoleData>()).name;
	}

	public static string toString(this ReputationStatus _rep)
	{
		return GameHandler.Text.getKeyword(_rep);
	}

	public static string toStringCap(this ReputationStatus _rep)
	{
		return GameHandler.Text.getKeywordCap(_rep);
	}

	public static string toString(this CaseQuirks _quirk)
	{
		return GameHandler.Text.getQuirkNameColoured(_quirk);
	}

	public static string toString(this BackAlleysItemColour _colour)
	{
		return GameHandler.Text.getKeyword(_colour);
	}

	public static string colourSpriteLink(this string _string, string _sprite_id, Color _colour)
	{
		string text = "<sprite name=\"" + _sprite_id + "\"";
		int length = text.Length;
		for (int num = _string.IndexOf(text); num > -1; num = _string.IndexOf(text, num + length))
		{
			int num2 = _string.IndexOf(">", num + length);
			_string = _string.Substring(0, num) + text + " color=#" + ColorUtility.ToHtmlStringRGBA(_colour) + ">" + _string.Substring(num2 + 1);
		}
		return _string;
	}

	public static string addColourToSpriteLinks(this string _string, Color _colour)
	{
		string text = "<sprite";
		int length = text.Length;
		for (int num = _string.IndexOf(text); num > -1; num = _string.IndexOf(text, num + length))
		{
			int num2 = _string.IndexOf(">", num + length);
			_string = _string.Substring(0, num2) + " color=#" + ColorUtility.ToHtmlStringRGBA(_colour) + ">" + _string.Substring(num2 + 1);
		}
		return _string;
	}

	public static bool getPrefixOption(this RoleClassifications _class)
	{
		switch (GRGLocalisationHandler.instance.current_language)
		{
		case Languages.ENGLISH:
			if (_class != RoleClassifications.MEDDLER)
			{
				return _class == RoleClassifications.TRAITOR;
			}
			return true;
		case Languages.CHINESE_SIMPLIFIED:
		case Languages.CHINESE_TRADITIONAL:
		case Languages.JAPANESE:
		case Languages.KOREAN:
		case Languages.THAI:
			return true;
		default:
			Debug.LogError($"No prefix option set up for class {_class} for language {GRGLocalisationHandler.instance.current_language}!");
			return true;
		}
	}

	public static bool getPrefixOption(this ReputationStatus _status)
	{
		switch (GRGLocalisationHandler.instance.current_language)
		{
		case Languages.ENGLISH:
			return _status != ReputationStatus.EXCEPTIONAL;
		case Languages.CHINESE_SIMPLIFIED:
		case Languages.CHINESE_TRADITIONAL:
		case Languages.JAPANESE:
		case Languages.KOREAN:
		case Languages.THAI:
			return true;
		default:
			Debug.LogError($"No prefix option set up for rep status {_status} for current language {GRGLocalisationHandler.instance.current_language}!");
			return true;
		}
	}

	public static bool isLinkHoverable(this string _link_id)
	{
		return _link_id.StartsWith(hover_link_start);
	}

	public static string getHoverLink(this Keywords _keyword)
	{
		string text = hover_link_start;
		int num = (int)_keyword;
		return text + "KW" + num;
	}

	public static string getHoverLink(this Alignments _align)
	{
		string text = hover_link_start;
		int num = (int)_align;
		return text + "AL" + num;
	}

	public static string getHoverLink(this RoleClassifications _class)
	{
		string text = hover_link_start;
		int num = (int)_class;
		return text + "RC" + num;
	}

	public static string getHoverLink(this LocationTypes _location)
	{
		string text = hover_link_start;
		int num = (int)_location;
		return text + "LC" + num;
	}

	public static string getHoverLink(this Roles _roles)
	{
		string text = hover_link_start;
		int num = (int)_roles;
		return text + "RL" + num;
	}

	public static KeywordInfo getKeywordFromLink(this string _link)
	{
		int num = int.Parse(_link.Substring(5));
		if (_link.StartsWith(hover_link_start + "KW"))
		{
			return new KeywordInfo(num, KeywordType.KEYWORD);
		}
		if (_link.StartsWith(hover_link_start + "AL"))
		{
			return new KeywordInfo(num, KeywordType.ALIGNMENT);
		}
		if (_link.StartsWith(hover_link_start + "RC"))
		{
			return new KeywordInfo(num, KeywordType.ROLE_CLASSIFICATION);
		}
		if (_link.StartsWith(hover_link_start + "LC"))
		{
			return new KeywordInfo(num, KeywordType.LOCATION);
		}
		if (_link.StartsWith(hover_link_start + "RL"))
		{
			return new KeywordInfo(num, KeywordType.ROLE);
		}
		throw new ArgumentException("Could not find keyword from hover link! " + _link);
	}

	private static string englishTaintedMany(string _data)
	{
		return "I tainted " + _data + ".";
	}

	public static string taintedManyLocalised(List<int> _tainted)
	{
		return localisation_asset.checkTranslationWithData(loc_tainted_many_key, englishTaintedMany, CaseHelper.getSimpleMultiAddress(_tainted));
	}

	public static string taintedOneLocalised(int _tainted)
	{
		return localisation_asset.checkTranslationWithData(loc_tainted_many_key, englishTaintedMany, $"{address_prefix}{_tainted}");
	}

	private static string englishKilledMany(string _data)
	{
		return "I killed " + _data + ".";
	}

	public static string killedManyLocalised(List<int> _killed)
	{
		return localisation_asset.checkTranslationWithData(loc_killed_many_key, englishKilledMany, CaseHelper.getSimpleMultiAddress(_killed));
	}

	public static string killedOneLocalised(int _killed)
	{
		return localisation_asset.checkTranslationWithData(loc_killed_many_key, englishKilledMany, $"{address_prefix}{_killed}");
	}

	private static string englishObscuredMany(string _data)
	{
		return "I obscured " + _data + ".";
	}

	public static string obscuredManyLocalised(List<int> _obs)
	{
		return localisation_asset.checkTranslationWithData(loc_obscured_many_key, englishObscuredMany, CaseHelper.getSimpleMultiAddress(_obs));
	}

	public static string obscuredOneLocalised(int _obs)
	{
		return localisation_asset.checkTranslationWithData(loc_obscured_many_key, englishObscuredMany, $"{address_prefix}{_obs}");
	}

	private static string englishHidMany(string _data)
	{
		return "I hid " + _data + ".";
	}

	public static string hidManyLocalised(List<int> _hid)
	{
		return localisation_asset.checkTranslationWithData(loc_hid_many_key, englishHidMany, CaseHelper.getSimpleMultiAddress(_hid));
	}

	public static string hidOneLocalised(int _hid)
	{
		return localisation_asset.checkTranslationWithData(loc_hid_many_key, englishHidMany, $"{address_prefix}{_hid}");
	}

	private static string englishBlockedMany(string _data)
	{
		return "I stopped you from investigating " + _data + ".";
	}

	public static string blockedManyLocalised(List<int> _blocked)
	{
		return localisation_asset.checkTranslationWithData(loc_blocked_many_key, englishBlockedMany, CaseHelper.getSimpleMultiAddress(_blocked));
	}

	public static string blockedOneLocalised(int _blocked)
	{
		return localisation_asset.checkTranslationWithData(loc_blocked_many_key, englishBlockedMany, $"{address_prefix}{_blocked}");
	}

	private static string englishMadeEvilMany(string _data)
	{
		return "I made " + _data + " evil.";
	}

	public static string madeEvilManyLocalised(List<int> _evil)
	{
		return localisation_asset.checkTranslationWithData(loc_made_evil_many_key, englishMadeEvilMany, CaseHelper.getSimpleMultiAddress(_evil));
	}

	public static string madeEvilOneLocalised(int _evil)
	{
		return localisation_asset.checkTranslationWithData(loc_made_evil_many_key, englishMadeEvilMany, $"{address_prefix}{_evil}");
	}

	private static string englishMadeGoodMany(string _data)
	{
		return "I made " + _data + " good.";
	}

	public static string madeGoodManyLocalised(List<int> _good)
	{
		return localisation_asset.checkTranslationWithData(loc_made_good_many_key, englishMadeGoodMany, CaseHelper.getSimpleMultiAddress(_good));
	}

	public static string madeGoodOneLocalised(int _good)
	{
		return localisation_asset.checkTranslationWithData(loc_made_good_many_key, englishMadeGoodMany, $"{address_prefix}{_good}");
	}

	private static string englishTransformed(string _d1, string _d2)
	{
		return "I turned #" + _d1 + " into the " + _d2 + ".";
	}

	public static string transformedLocalised(int _address, Roles _role)
	{
		return localisation_asset.checkTranslationWithData(loc_transformed_key, englishTransformed, _address.ToString(), _role.toString());
	}

	private static string englishSelectRoles(string _data)
	{
		return "Select " + _data + " role{#/s}.";
	}

	public static string ab_selectRolesLocalised(int _nb)
	{
		return localisation_asset.checkTranslationWithData(loc_ab_selectRoles_key, englishSelectRoles, _nb).checkPlural(_nb);
	}

	private static string englishSelectSurroundingRoles(string _data)
	{
		return "Select " + _data + " surrounding role{#/s}.";
	}

	public static string ab_selectSurroundingRolesLocalised(int _nb)
	{
		return localisation_asset.checkTranslationWithData(loc_ab_selectRolesSurrounding_key, englishSelectSurroundingRoles, _nb).checkPlural(_nb);
	}

	private static string englishSelectACard()
	{
		return "Select a card.";
	}

	private static string englishReselectToConfirm()
	{
		return "Reselect me to confirm.";
	}

	private static string englishSelectASuspect()
	{
		return "Select a role from the suspect list.";
	}

	private static string englishSelectALocation()
	{
		return "Select a location.";
	}

	private static string englishSelectASuspectOfClass(string _data)
	{
		return "Select a{#/n} " + _data + " role from the suspect list.";
	}

	private static string englishSelectEmptyPosition(string _data)
	{
		return "Select " + _data + " empty position{#/s} on the board.";
	}

	public static string ab_selectSuspectOfClassLocalised(RoleClassifications _class)
	{
		return localisation_asset.checkTranslationWithData(loc_ab_selectSuspectClass_key, englishSelectASuspectOfClass, _class.toStringPlain()).checkOption(_class.getPrefixOption());
	}

	public static string ab_selectEmptyPositionLocalised(int _nb)
	{
		return localisation_asset.checkTranslationWithData(loc_ab_empty_pos_key, englishSelectEmptyPosition, _nb).checkPlural(_nb);
	}
}
