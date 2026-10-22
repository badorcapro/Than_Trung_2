using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Numbers;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public static class RoleHelper
{
	public static ReputationStatus getTrueReputationStatus(this int _rep)
	{
		return _rep switch
		{
			1 => ReputationStatus.POOR, 
			2 => ReputationStatus.POOR, 
			3 => ReputationStatus.NEUTRAL, 
			4 => ReputationStatus.NEUTRAL, 
			5 => ReputationStatus.EXCEPTIONAL, 
			6 => ReputationStatus.EXCEPTIONAL, 
			_ => returnPoorWithError(_rep), 
		};
	}

	private static ReputationStatus returnPoorWithError(int _rep)
	{
		return ReputationStatus.POOR;
	}

	public static string getStringFromAlignment(this Alignments _a)
	{
		return _a switch
		{
			Alignments.GOOD => "Good", 
			Alignments.EVIL => "Evil", 
			_ => throw new NotImplementedException("This world is literally black and white"), 
		};
	}

	public static bool isRoleOfCaseType(this Roles _role, CaseType _case_type, bool _allow_generic = true)
	{
		return _case_type switch
		{
			CaseType.CLOCK => _role.isClockRole(_allow_generic), 
			CaseType.DOCKS => _role.isDocksRole(_allow_generic), 
			CaseType.CASINO => _role.isCasinoRole(_allow_generic), 
			CaseType.BACK_ALLEYS => _role.isBackAlleysRole(_allow_generic), 
			_ => throw new ArgumentException($"CaseType {_case_type} not set up in func isRoleOfCaseType!"), 
		};
	}

	public static bool isClockRole(this Roles _role, bool _allow_generic = true)
	{
		return _role switch
		{
			Roles.PRIVATE_INVESTIGATOR => true, 
			Roles.SKEPTIC => true, 
			Roles.VIGILANTE => true, 
			Roles.TAILOR => true, 
			Roles.DOPPELGANGER => true, 
			Roles.CLOCK_MAKER => true, 
			Roles.EMPATH => true, 
			Roles.RESEARCHER => true, 
			Roles.ICONOGRAPHER => true, 
			Roles.GARGOYLE => true, 
			Roles.GENTLEMAN => true, 
			Roles.CLAIRVOYANT => true, 
			Roles.ALERTER => true, 
			Roles.BROKER => true, 
			Roles.LIBRARIAN => true, 
			Roles.WITNESS => true, 
			Roles.JOURNALIST => true, 
			Roles.PUBLISHER => true, 
			Roles.GOOD_COP => true, 
			Roles.SURGIN => true, 
			Roles.CHATTER_BOX => true, 
			Roles.MILKMAN => true, 
			Roles.STALKER => true, 
			Roles.YOUNGSTER => true, 
			Roles.BELFRY => true, 
			Roles.RAT => true, 
			Roles.PLANT => true, 
			Roles.S_FANATIC => true, 
			Roles.MARKSMAN => true, 
			Roles.HIPSTER => true, 
			Roles.SAWBONES => true, 
			Roles.SERIAL_KILLER => true, 
			Roles.MAID => true, 
			Roles.WATCHMAKER => true, 
			Roles.MOLE => true, 
			Roles.CLEANUP_CREW => true, 
			Roles.SNIPER => true, 
			Roles.BUREAUCRAT => true, 
			Roles.TACITURN => true, 
			Roles.DETRACTOR => true, 
			Roles.BAD_COP => true, 
			Roles.JUDGE => true, 
			Roles.HITMAN => true, 
			Roles.CRITIC => true, 
			Roles.SMOKER => true, 
			Roles.FEARMONGER => true, 
			Roles.RAT_KING => true, 
			Roles.BOMBER => true, 
			Roles.RIDLER => true, 
			_ => _allow_generic && _role.isGenericRole(), 
		};
	}

	public static bool isDocksRole(this Roles _role, bool _allow_generic = true)
	{
		return _role switch
		{
			Roles.SKEPTIC => true, 
			Roles.VIGILANTE => true, 
			Roles.TAILOR => true, 
			Roles.DOPPELGANGER => true, 
			Roles.EMPATH => true, 
			Roles.RESEARCHER => true, 
			Roles.CLAIRVOYANT => true, 
			Roles.NAVIGATOR => true, 
			Roles.SAILOR => true, 
			Roles.DIVER => true, 
			Roles.FISHERMAN => true, 
			Roles.LIGHTHOUSE_KEEPER => true, 
			Roles.LOOKOUT => true, 
			Roles.CAPTAIN => true, 
			Roles.MARINE => true, 
			Roles.DECK_CADET => true, 
			Roles.SECOND_MATE => true, 
			Roles.BARRELMAN => true, 
			Roles.JOURNALIST => true, 
			Roles.PUBLISHER => true, 
			Roles.COASTGUARD => true, 
			Roles.CRABER => true, 
			Roles.NYMPH => true, 
			Roles.MECHANIC => true, 
			Roles.CULTIST => true, 
			Roles.FUEL_MERCHANT => true, 
			Roles.DECKHAND => true, 
			Roles.SUBMARINE => true, 
			Roles.ALERTER => true, 
			Roles.SPOTTER => true, 
			Roles.STALKER => true, 
			Roles.YOUNGSTER => true, 
			Roles.DUBIOUS_CHEF => true, 
			Roles.RECKLESS_GENERAL => true, 
			Roles.INCOMPETENT_HELMSMAN => true, 
			Roles.INEPT_CADET => true, 
			Roles.GUNNER => true, 
			Roles.SHIPWRECKED => true, 
			Roles.MARKSMAN => true, 
			Roles.SAWBONES => true, 
			Roles.STOWAWAY => true, 
			Roles.RED_HERRING => true, 
			Roles.WHALE => true, 
			Roles.TREASURE_HUNTER => true, 
			Roles.ABSCONDER => true, 
			Roles.MIRAGE => true, 
			Roles.TURNCOAT => true, 
			Roles.DETRACTOR => true, 
			Roles.PIRATE => true, 
			Roles.SHARK => true, 
			Roles.HARPOONIST => true, 
			Roles.MUTINEER => true, 
			Roles.SIREN => true, 
			Roles.MINELAYER => true, 
			Roles.ANGLERFISH => true, 
			Roles.SQUID => true, 
			Roles.OMEN => true, 
			Roles.POWDER_MERCHANT => true, 
			Roles.CANNONEER => true, 
			Roles.HERRING => true, 
			Roles.DEEP_ONE => true, 
			Roles.VANDAL => true, 
			Roles.CRITIC => true, 
			Roles.SMOKER => true, 
			Roles.KRAKEN => true, 
			Roles.PIRATE_CAPTAIN => true, 
			Roles.JELLYFISH => true, 
			Roles.RIDLER => true, 
			Roles.OIL_BARON => true, 
			Roles.OCTOPUS => true, 
			Roles.HOOK => true, 
			_ => _allow_generic && _role.isGenericRole(), 
		};
	}

	public static bool isCasinoRole(this Roles _role, bool _allow_generic = true)
	{
		return _role switch
		{
			Roles.OPPORTUNIST => true, 
			Roles.INFORMANT => true, 
			Roles.HIRED_GUN => true, 
			Roles.VISIONARY => true, 
			Roles.BUYOUT => true, 
			Roles.VALET => true, 
			Roles.DEALER => true, 
			Roles.BOUNCER => true, 
			Roles.CARD_READER => true, 
			Roles.LOTTO_SCRATCHER => true, 
			Roles.HOT_SHOT => true, 
			Roles.CARDIOLOGIST => true, 
			Roles.CHAUFFEUR => true, 
			Roles.RECEPTIONIST => true, 
			Roles.ICONOGRAPHER => true, 
			Roles.MAGICIAN => true, 
			Roles.WAITER => true, 
			Roles.PSYCHIC => true, 
			Roles.HUNTER => true, 
			Roles.BROKER => true, 
			Roles.WITNESS => true, 
			Roles.CARD_PSYCHIC => true, 
			Roles.BLACKJACK_PLAYER => true, 
			Roles.SCAM_ARTIST => true, 
			Roles.TAXMAN => true, 
			Roles.MUTT => true, 
			Roles.TRICKSTER => true, 
			Roles.BIG_BLIND => true, 
			Roles.BARISTA => true, 
			Roles.CRACKPOT => true, 
			Roles.MORTICIAN => true, 
			Roles.OFFEROR => true, 
			Roles.DJ => true, 
			Roles.DANCER => true, 
			Roles.HIPSTER => true, 
			Roles.PRICE_FIXER => true, 
			Roles.DEBT_COLLECTOR => true, 
			Roles.JOKER_R => true, 
			Roles.PICKPOCKET => true, 
			Roles.CASHIER => true, 
			Roles.SNITCH => true, 
			Roles.VIP => true, 
			Roles.CROUPIER => true, 
			Roles.SELLOUT => true, 
			Roles.MOLE => true, 
			Roles.CLEANUP_CREW => true, 
			Roles.CHEAT => true, 
			Roles.THE_HOUSE => true, 
			Roles.VIOLENT_HOST => true, 
			Roles.INVESTOR => true, 
			Roles.PAPARAZZI => true, 
			Roles.DEVIL => true, 
			Roles.BOMBER => true, 
			_ => _allow_generic && _role.isGenericRole(), 
		};
	}

	public static bool isBackAlleysRole(this Roles _role, bool _allow_generic = true)
	{
		return _role switch
		{
			Roles.VIGILANTE => true, 
			Roles.TAILOR => true, 
			Roles.DOPPELGANGER => true, 
			Roles.EMPATH => true, 
			Roles.RESEARCHER => true, 
			Roles.LAWFUL_CITIZEN => true, 
			Roles.ENTHUSIAST => true, 
			Roles.SUPPLIER => true, 
			Roles.STALKER => true, 
			Roles.REBEL => true, 
			Roles.MARKSMAN => true, 
			Roles.HIPSTER => true, 
			Roles.SMUGLER => true, 
			_ => _allow_generic && _role.isGenericRole(), 
		};
	}

	public static bool isGenericRole(this Roles _role)
	{
		return _role switch
		{
			Roles.REPORTER => true, 
			Roles.ROMANTIC => true, 
			Roles.THERAPIST => true, 
			Roles.WEATHERMAN => true, 
			Roles.BLOOD_HOUND => true, 
			Roles.PRIEST => true, 
			Roles.MAILMAN => true, 
			Roles.PARTNER => true, 
			Roles.MATHEMATICIAN => true, 
			Roles.GOSSIP => true, 
			Roles.POLITICIAN => true, 
			Roles.ASSISTANT => true, 
			Roles.PHYSIOGNOMIST => true, 
			Roles.MEDIUM => true, 
			Roles.PSYCHIATRIST => true, 
			Roles.VETERAN => true, 
			Roles.TIPSTER => true, 
			Roles.PAPER_BOY => true, 
			Roles.TEACHER => true, 
			Roles.PRODUCER => true, 
			Roles.HERMIT => true, 
			Roles.MYTHOMANIAC => true, 
			Roles.ARTIST => true, 
			Roles.FALL_GUY => true, 
			Roles.DRUNKARD => true, 
			Roles.COPYCAT => true, 
			Roles.BOUNTY_HUNTER => true, 
			Roles.WANNABE => true, 
			Roles.WANDERER => true, 
			Roles.SHOWSTEALER => true, 
			Roles.EXTRAVERT => true, 
			Roles.BAD_MOUTH => true, 
			Roles.VICIOUS => true, 
			Roles.EGOTIST => true, 
			Roles.JINX => true, 
			Roles.GHOST => true, 
			Roles.DIRECTOR => true, 
			Roles.BARKEEP => true, 
			Roles.CASANOVA => true, 
			Roles.MOBSTER => true, 
			Roles.SPECTRE => true, 
			Roles.SCOUNDREL => true, 
			Roles.PREACHER => true, 
			Roles.POISONER => true, 
			Roles.ACCOUNTANT => true, 
			Roles.CONMAN => true, 
			Roles.STRANGLER => true, 
			Roles.CHARMER => true, 
			Roles.RAIDER => true, 
			Roles.ENFORCER => true, 
			Roles.FUGITIVE => true, 
			Roles.LANDLORD => true, 
			Roles.TRAVEL_AGENT => true, 
			Roles.DOWNPLAYER => true, 
			Roles.RENEGADE => true, 
			Roles.IDOL => true, 
			Roles.KINGPIN => true, 
			Roles.ASSASSIN => true, 
			Roles.GODFATHER => true, 
			Roles.INTERCEPTOR => true, 
			Roles.RECRUITER => true, 
			Roles.SCRAMBLER => true, 
			_ => false, 
		};
	}

	public static bool isDemoRole(this Roles _role)
	{
		return _role switch
		{
			Roles.PRIVATE_INVESTIGATOR => true, 
			Roles.REPORTER => true, 
			Roles.ROMANTIC => true, 
			Roles.THERAPIST => true, 
			Roles.WEATHERMAN => true, 
			Roles.BLOOD_HOUND => true, 
			Roles.PRIEST => true, 
			Roles.SKEPTIC => true, 
			Roles.VIGILANTE => true, 
			Roles.MAILMAN => true, 
			Roles.TAILOR => true, 
			Roles.DOPPELGANGER => true, 
			Roles.PARTNER => true, 
			Roles.MATHEMATICIAN => true, 
			Roles.GOSSIP => true, 
			Roles.CLOCK_MAKER => true, 
			Roles.EMPATH => true, 
			Roles.RESEARCHER => true, 
			Roles.SURGIN => true, 
			Roles.CHATTER_BOX => true, 
			Roles.FALL_GUY => true, 
			Roles.YOUNGSTER => true, 
			Roles.DRUNKARD => true, 
			Roles.COPYCAT => true, 
			Roles.BOUNTY_HUNTER => true, 
			Roles.MILKMAN => true, 
			Roles.WANNABE => true, 
			Roles.STALKER => true, 
			Roles.JINX => true, 
			Roles.BARKEEP => true, 
			Roles.CASANOVA => true, 
			Roles.MOBSTER => true, 
			Roles.SPECTRE => true, 
			Roles.SCOUNDREL => true, 
			Roles.PREACHER => true, 
			Roles.POISONER => true, 
			Roles.ACCOUNTANT => true, 
			Roles.CONMAN => true, 
			Roles.SERIAL_KILLER => true, 
			Roles.JUDGE => true, 
			Roles.IDOL => true, 
			Roles.CRITIC => true, 
			Roles.KINGPIN => true, 
			Roles.HITMAN => true, 
			Roles.RECRUITER => true, 
			_ => false, 
		};
	}

	public static List<Roles> getRoleList(this CaseType _case_type, bool _allow_test = false, bool _allow_generic = true)
	{
		return _case_type switch
		{
			CaseType.CLOCK => getRoleList((Roles _r) => _r.isClockRole(_allow_generic), _allow_test), 
			CaseType.DOCKS => getRoleList((Roles _r) => _r.isDocksRole(_allow_generic), _allow_test), 
			CaseType.CASINO => getRoleList((Roles _r) => _r.isCasinoRole(_allow_generic), _allow_test), 
			CaseType.BACK_ALLEYS => getRoleList((Roles _r) => _r.isBackAlleysRole(_allow_generic), _allow_test), 
			_ => throw new ArgumentException($"No role list set up for region {_case_type}!"), 
		};
	}

	public static List<Roles> getClassification(this List<Roles> _roles, RoleClassifications _classification)
	{
		return _classification switch
		{
			RoleClassifications.INNOCENT => _roles.getInnocents(), 
			RoleClassifications.MEDDLER => _roles.getMeddlers(), 
			RoleClassifications.UNDERLING => _roles.getUnderlings(), 
			RoleClassifications.TRAITOR => _roles.getTraitors(), 
			_ => throw new ArgumentException($"No function set up for getClassification of type {_classification}!"), 
		};
	}

	public static List<Roles> getInnocents(this List<Roles> _available_roles)
	{
		return _available_roles.Where(isInnocent).toListSafe();
	}

	public static List<Roles> getMeddlers(this List<Roles> _available_roles)
	{
		return _available_roles.Where(isMeddler).toListSafe();
	}

	public static List<Roles> getUnderlings(this List<Roles> _available_roles)
	{
		return _available_roles.Where(isUnderling).toListSafe();
	}

	public static List<Roles> getTraitors(this List<Roles> _available_roles)
	{
		return _available_roles.Where(isTraitor).toListSafe();
	}

	public static List<Roles> getInnocentRoleList(bool _allow_test = false)
	{
		return getRoleList(isInnocent, _allow_test);
	}

	public static List<Roles> getMeddlerRoleList(bool _allow_test = false)
	{
		return getRoleList(isMeddler, _allow_test);
	}

	public static List<Roles> getUnderlingRoleList(bool _allow_test = false)
	{
		return getRoleList(isUnderling, _allow_test);
	}

	public static List<Roles> getTraitorRoleList(bool _allow_test = false)
	{
		return getRoleList(isTraitor, _allow_test);
	}

	public static List<Roles> getRoleList(bool _allow_test = false)
	{
		return getRoleList((Roles _r) => true, _allow_test);
	}

	public static List<Roles> getRoleList(Func<Roles, bool> _predicate, bool _allow_test)
	{
		List<Roles> list = (from _r in new List<Roles>().addAll()
			where _predicate(_r) && !_r.isScrapped()
			select _r).toListSafe();
		if (!_allow_test)
		{
			list.removeAll(isTest);
		}
		return list;
	}

	public static bool isInnocent(this Roles _role)
	{
		return ((int)_role).between(9999, 20000);
	}

	public static bool isMeddler(this Roles _role)
	{
		return ((int)_role).between(19999, 30000);
	}

	public static bool isUnderling(this Roles _role)
	{
		return ((int)_role).between(29999, 40000);
	}

	public static bool isTraitor(this Roles _role)
	{
		return ((int)_role).between(39999, 50000);
	}

	public static bool isScrapped(this Roles _role)
	{
		return _role >= (Roles)900000;
	}

	public static bool isTest(this Roles _role)
	{
		return (int)_role % 10000 >= 5000;
	}

	public static int tryLoadSingleValueFromUniqueData(Roles _role, RoleDataSave _save, int _default = -1)
	{
		try
		{
			return int.Parse(_save.unique_data);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load {_role}!\nData: {_save.unique_data}\nError: {arg}");
			return _default;
		}
	}

	public static Maybe<T> tryLoadSimpleMaybeFromUniqueData<T>(Roles _role, RoleDataSave _save, Func<int, T> _converter)
	{
		try
		{
			if (_save.unique_data == "f")
			{
				return new Maybe<T>();
			}
			return _converter(int.Parse(_save.unique_data)).maybe();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load {_role}!\nData: {_save.unique_data}\nError: {arg}");
			return new Maybe<T>();
		}
	}

	public static bool tryLoadSingleBoolFromUniqueData(Roles _role, RoleDataSave _save, bool _default = false)
	{
		try
		{
			return _save.unique_data == "t";
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load {_role}!\nData: {_save.unique_data}\nError: {arg}");
			return _default;
		}
	}

	public static List<int> tryLoadListFromUniqueData(Roles _role, RoleDataSave _save)
	{
		try
		{
			return _save.unique_data.fromStringCommaSeperate();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load {_role}!\nData: {_save.unique_data}\nError: {arg}");
			return new List<int>();
		}
	}

	public static string saveSimpleMaybe<T>(Maybe<T> _to_save, Func<T, int> _converter)
	{
		if (!_to_save.is_some)
		{
			return "f";
		}
		return _converter(_to_save.value).ToString();
	}
}
