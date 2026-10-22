using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Random;
using GRGLib.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public static class CaseHelper
{
	public static int FIRST_IN_ORDER = 1000000;

	public static int LAST_IN_ORDER = -1000000;

	public static int LAST_TRAITOR = 39999;

	public static int LAST_UNDERLING = 29999;

	public static int LAST_MEDDLER = 19999;

	public static int LAST_INNOCENT = 9999;

	public static string getSimpleMultiAddress(List<int> _addresses)
	{
		return getSimpleMultiAddress(_addresses.ToArray());
	}

	public static string getSimpleMultiAddress(params int[] _addresses)
	{
		if (_addresses.Length == 0)
		{
			return "";
		}
		string text = "";
		for (int i = 0; i < _addresses.Length - 1; i++)
		{
			text += $"{TextHelper.address_prefix}{_addresses[i]}, ";
		}
		return text + $"{TextHelper.address_prefix}{_addresses[^1]}";
	}

	public static bool isRoleAtBoardPosition(this Vector2Int _pos, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board)
	{
		if (_board.ContainsKey(_pos) && _board[_pos].is_some)
		{
			return _board[_pos].value.is_a;
		}
		return false;
	}

	public static bool isRoleAtBoardPosition(this Vector2Int _pos, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, Func<RoleData, bool> _requirement)
	{
		if (_pos.isRoleAtBoardPosition(_board))
		{
			return _requirement(_board[_pos].value.maybe_a.value);
		}
		return false;
	}

	public static Maybe<RoleData> getRoleAtBoardPosition(this Vector2Int _pos, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board)
	{
		if (!_pos.isRoleAtBoardPosition(_board))
		{
			return new Maybe<RoleData>();
		}
		return _board[_pos].value.maybe_a;
	}

	public static Maybe<RoleData> getRoleAtBoardPosition(this Vector2Int _pos, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, Func<RoleData, bool> _requirement)
	{
		if (!_pos.isRoleAtBoardPosition(_board, _requirement))
		{
			return new Maybe<RoleData>();
		}
		return _board[_pos].value.maybe_a;
	}

	public static List<RoleData> getAllNotArrestedOrDeadEvil(this Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board)
	{
		return (from _a in _board.Values
			where _a.is_some && _a.value.is_a && !_a.value.maybe_a.value.getIsDead() && !_a.value.maybe_a.value.getIsArrested() && _a.value.maybe_a.value.getTrueAlignment() == Alignments.EVIL
			select _a.value.maybe_a.value).toListSafe();
	}

	public static Dictionary<int, RoleData> getRolesInPlay(this Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board)
	{
		return (from _a in _board.Values
			where _a.is_some && _a.value.is_a
			select _a.value.maybe_a.value).Aggregate(new Dictionary<int, RoleData>(), (Dictionary<int, RoleData> _a, RoleData _b) => _a.addTo(_b.getAddress(), _b));
	}

	public static Dictionary<RoleClassifications, int> getOnBoardRatio(this Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, bool _true_class)
	{
		return _board.Values.Where((Maybe<Either<RoleData, LocationData>> _a) => _a.is_some && _a.value.is_a).Aggregate(getEmptyRatio(), (Dictionary<RoleClassifications, int> _a, Maybe<Either<RoleData, LocationData>> _r) => _a.increaseOrCreate(_true_class ? _r.value.maybe_a.value.getTrueClassification() : _r.value.maybe_a.value.getVisualClassification(), 1));
	}

	public static List<RoleData> getRolesInPlayOfClass(this Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, params RoleClassifications[] _of_class)
	{
		return (from _a in _board.Values
			where _a.is_some && _a.value.is_a && _a.value.maybe_a.value.getVisualClassification().equalToAny(_of_class)
			select _a.value.maybe_a.value).ToList();
	}

	public static List<RoleData> getRolesInPlayOfAlignment(this Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, Alignments _alignment)
	{
		return (from _a in _board.Values
			where _a.is_some && _a.value.is_a && _a.value.maybe_a.value.getVisualAlignment() == _alignment
			select _a.value.maybe_a.value).ToList();
	}

	public static List<RoleData> getAllArrestedRoles(this Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board)
	{
		return (from _a in _board.Values
			where _a.is_some && _a.value.is_a && _a.value.maybe_a.value.getIsArrested()
			select _a.value.maybe_a.value).toListSafe();
	}

	public static List<RoleData> getAllArrestedOrDeadRoles(this Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board)
	{
		return (from _a in _board.Values
			where _a.is_some && _a.value.is_a && (_a.value.maybe_a.value.getIsArrested() || _a.value.maybe_a.value.getIsDead())
			select _a.value.maybe_a.value).toListSafe();
	}

	public static List<RoleData> getRolesNotInPlay(this Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, List<RoleData> _suspects)
	{
		Dictionary<int, RoleData>.ValueCollection roles_in_play = _board.getRolesInPlay().Values;
		return _suspects.Where((RoleData _e) => !roles_in_play.Select((RoleData _e) => _e.role).Contains(_e.role)).ToList();
	}

	public static List<RoleData> getRolesNotInPlay(this Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, HashSet<RoleData> _suspects)
	{
		return _suspects.Where((RoleData _e) => !_board.getRolesInPlay().Values.Select((RoleData _e) => _e.role).Contains(_e.role)).ToList();
	}

	public static List<Roles> getRolesNotInPlay(this Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, HashSet<Roles> _suspects)
	{
		return _suspects.Where((Roles _r) => !_board.getRolesInPlay().Values.Select((RoleData _e) => _e.role).Contains(_r)).ToList();
	}

	public static Dictionary<RoleClassifications, int> getListRatio(this List<Roles> _roles)
	{
		return _roles.Aggregate(new Dictionary<RoleClassifications, int>(), (Dictionary<RoleClassifications, int> _a, Roles _r) => _a.increaseOrCreate(_r.getClassificationFromRoleType(), 1));
	}

	public static List<RoleData> getOrderdRolesForEventCalls(this Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board)
	{
		return (from _x in (from _a in _board.Values
				where _a.is_some && _a.value.is_a
				select _a.value.maybe_a.value).Aggregate(new List<RoleData>(), (List<RoleData> _a, RoleData _b) => _a.add(_b))
			orderby _x.execution_order descending
			select _x).ToList();
	}

	public static List<LocationData> getOrderdLocationsForEventCalls(this Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board)
	{
		return (from _x in (from _b in _board.Values
				where _b.is_some && _b.value.is_b
				select _b.value.maybe_b.value).Aggregate(new List<LocationData>(), (List<LocationData> _a, LocationData _b) => _a.add(_b))
			orderby _x.execution_order descending
			select _x).ToList();
	}

	public static Dictionary<LocationTypes, LocationData> getLocationsInPlay(this Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board)
	{
		return (from _a in _board.Values
			where _a.is_some && _a.value.is_b
			select _a.value.maybe_b.value).Aggregate(new Dictionary<LocationTypes, LocationData>(), (Dictionary<LocationTypes, LocationData> _a, LocationData _b) => _a.addTo(_b.location_type, _b));
	}

	public static RoleData createEmptyRole(this Roles _role)
	{
		return _role.createRole(-1, new Vector2Int(-1, -1), RandomExtensions.freshRandom(), new Maybe<RoleData>());
	}

	public static RoleData createSetRole<T>(this Roles _role, int _address, Vector2Int _board_pos, System.Random _rand, Action<T> _call) where T : RoleData
	{
		RoleData roleData = _role.createRole(_address, _board_pos, _rand, new Maybe<RoleData>());
		_call(roleData as T);
		return roleData;
	}

	public static RoleData createSetRoleWithDisguise<T>(this Roles _role, int _address, Vector2Int _board_pos, System.Random _rand, Roles _disguise, Action<T> _disguise_call) where T : RoleData
	{
		RoleData roleData = _role.createRole(_address, _board_pos, _rand, new Maybe<RoleData>());
		RoleData roleData2 = _disguise.createRole(_address, _board_pos, _rand, roleData.maybe());
		roleData.setForcedDisguised();
		roleData.setDisguise(roleData2.maybe());
		_disguise_call(roleData2 as T);
		return roleData;
	}

	public static RoleData createSetRoleWithDisguise(this Roles _role, int _address, Vector2Int _board_pos, System.Random _rand, Roles _disguise)
	{
		RoleData roleData = _role.createRole(_address, _board_pos, _rand, new Maybe<RoleData>());
		RoleData obj = _disguise.createRole(_address, _board_pos, _rand, roleData.maybe());
		roleData.setForcedDisguised();
		roleData.setDisguise(obj.maybe());
		return roleData;
	}

	public static RoleData createRole(this Roles _role, int _address, Vector2Int _board_pos, System.Random _rand, Maybe<RoleData> _true_self)
	{
		return _role switch
		{
			Roles.PRIVATE_INVESTIGATOR => new PrivateInvestigator(_address, _board_pos, _rand, _true_self), 
			Roles.REPORTER => new Reporter(_address, _board_pos, _rand, _true_self), 
			Roles.ROMANTIC => new Romantic(_address, _board_pos, _rand, _true_self), 
			Roles.THERAPIST => new Therapist(_address, _board_pos, _rand, _true_self), 
			Roles.WEATHERMAN => new Weatherman(_address, _board_pos, _rand, _true_self), 
			Roles.BLOOD_HOUND => new BloodHound(_address, _board_pos, _rand, _true_self), 
			Roles.PRIEST => new Priest(_address, _board_pos, _rand, _true_self), 
			Roles.SKEPTIC => new Skeptic(_address, _board_pos, _rand, _true_self), 
			Roles.VIGILANTE => new Vigilante(_address, _board_pos, _rand, _true_self), 
			Roles.MAILMAN => new Mailman(_address, _board_pos, _rand, _true_self), 
			Roles.TAILOR => new Tailor(_address, _board_pos, _rand, _true_self), 
			Roles.DOPPELGANGER => new Doppelganger(_address, _board_pos, _rand, _true_self), 
			Roles.PARTNER => new Partner(_address, _board_pos, _rand, _true_self), 
			Roles.MATHEMATICIAN => new Mathematician(_address, _board_pos, _rand, _true_self), 
			Roles.GOSSIP => new Gossip(_address, _board_pos, _rand, _true_self), 
			Roles.CLOCK_MAKER => new ClockMaker(_address, _board_pos, _rand, _true_self), 
			Roles.EMPATH => new Empath(_address, _board_pos, _rand, _true_self), 
			Roles.RESEARCHER => new Researcher(_address, _board_pos, _rand, _true_self), 
			Roles.NAVIGATOR => new Navigator(_address, _board_pos, _rand, _true_self), 
			Roles.DIVER => new Diver(_address, _board_pos, _rand, _true_self), 
			Roles.FISHERMAN => new Fisherman(_address, _board_pos, _rand, _true_self), 
			Roles.CRABER => new Craber(_address, _board_pos, _rand, _true_self), 
			Roles.LIGHTHOUSE_KEEPER => new LighthouseKeeper(_address, _board_pos, _rand, _true_self), 
			Roles.LOOKOUT => new Lookout(_address, _board_pos, _rand, _true_self), 
			Roles.COASTGUARD => new Coastguard(_address, _board_pos, _rand, _true_self), 
			Roles.MARINE => new Marine(_address, _board_pos, _rand, _true_self), 
			Roles.NYMPH => new Nymph(_address, _board_pos, _rand, _true_self), 
			Roles.BARRELMAN => new Barrelman(_address, _board_pos, _rand, _true_self), 
			Roles.GENTLEMAN => new Gentleman(_address, _board_pos, _rand, _true_self), 
			Roles.GARGOYLE => new Gargoyle(_address, _board_pos, _rand, _true_self), 
			Roles.MAID => new Maid(_address, _board_pos, _rand, _true_self), 
			Roles.FEARMONGER => new Fearmonger(_address, _board_pos, _rand, _true_self), 
			Roles.BELFRY => new Belfry(_address, _board_pos, _rand, _true_self), 
			Roles.TEACHER => new Teacher(_address, _board_pos, _rand, _true_self), 
			Roles.BROKER => new Broker(_address, _board_pos, _rand, _true_self), 
			Roles.LIBRARIAN => new Librarian(_address, _board_pos, _rand, _true_self), 
			Roles.GOOD_COP => new GoodCop(_address, _board_pos, _rand, _true_self), 
			Roles.CHAUFFEUR => new Chauffeur(_address, _board_pos, _rand, _true_self), 
			Roles.WITNESS => new Witness(_address, _board_pos, _rand, _true_self), 
			Roles.ARTIST => new Artist(_address, _board_pos, _rand, _true_self), 
			Roles.PSYCHIATRIST => new Psychiatrist(_address, _board_pos, _rand, _true_self), 
			Roles.PAPER_BOY => new PaperBoy(_address, _board_pos, _rand, _true_self), 
			Roles.ASSISTANT => new Assistant(_address, _board_pos, _rand, _true_self), 
			Roles.JOURNALIST => new Journalist(_address, _board_pos, _rand, _true_self), 
			Roles.PRODUCER => new Producer(_address, _board_pos, _rand, _true_self), 
			Roles.PUBLISHER => new Publisher(_address, _board_pos, _rand, _true_self), 
			Roles.MYTHOMANIAC => new Mythomaniac(_address, _board_pos, _rand, _true_self), 
			Roles.ICONOGRAPHER => new Iconographer(_address, _board_pos, _rand, _true_self), 
			Roles.POLITICIAN => new Politician(_address, _board_pos, _rand, _true_self), 
			Roles.HERMIT => new Hermit(_address, _board_pos, _rand, _true_self), 
			Roles.PHYSIOGNOMIST => new Physiognomist(_address, _board_pos, _rand, _true_self), 
			Roles.CLAIRVOYANT => new Clairvoyant(_address, _board_pos, _rand, _true_self), 
			Roles.MEDIUM => new Medium(_address, _board_pos, _rand, _true_self), 
			Roles.ALERTER => new Alerter(_address, _board_pos, _rand, _true_self), 
			Roles.SAILOR => new Sailor(_address, _board_pos, _rand, _true_self), 
			Roles.CAPTAIN => new Captain(_address, _board_pos, _rand, _true_self), 
			Roles.SECOND_MATE => new SecondMate(_address, _board_pos, _rand, _true_self), 
			Roles.DECK_CADET => new DeckCadet(_address, _board_pos, _rand, _true_self), 
			Roles.MECHANIC => new Mechanic(_address, _board_pos, _rand, _true_self), 
			Roles.CULTIST => new Cultist(_address, _board_pos, _rand, _true_self), 
			Roles.FUEL_MERCHANT => new FuelMerchant(_address, _board_pos, _rand, _true_self), 
			Roles.DECKHAND => new Deckhand(_address, _board_pos, _rand, _true_self), 
			Roles.SUBMARINE => new Submariner(_address, _board_pos, _rand, _true_self), 
			Roles.SPOTTER => new Spotter(_address, _board_pos, _rand, _true_self), 
			Roles.OPPORTUNIST => new Opportunist(_address, _board_pos, _rand, _true_self), 
			Roles.INFORMANT => new Informant(_address, _board_pos, _rand, _true_self), 
			Roles.HIRED_GUN => new HiredGun(_address, _board_pos, _rand, _true_self), 
			Roles.VISIONARY => new Visionary(_address, _board_pos, _rand, _true_self), 
			Roles.BUYOUT => new Buyout(_address, _board_pos, _rand, _true_self), 
			Roles.CARD_PSYCHIC => new CardPsychic(_address, _board_pos, _rand, _true_self), 
			Roles.VALET => new Valet(_address, _board_pos, _rand, _true_self), 
			Roles.BLACKJACK_PLAYER => new BlackjackPlayer(_address, _board_pos, _rand, _true_self), 
			Roles.DEALER => new Dealer(_address, _board_pos, _rand, _true_self), 
			Roles.BOUNCER => new Bouncer(_address, _board_pos, _rand, _true_self), 
			Roles.CARD_READER => new CardReader(_address, _board_pos, _rand, _true_self), 
			Roles.LOTTO_SCRATCHER => new LottoScratcher(_address, _board_pos, _rand, _true_self), 
			Roles.HOT_SHOT => new HotShot(_address, _board_pos, _rand, _true_self), 
			Roles.TIPSTER => new Tipster(_address, _board_pos, _rand, _true_self), 
			Roles.CARDIOLOGIST => new Cardiologist(_address, _board_pos, _rand, _true_self), 
			Roles.RECEPTIONIST => new Receptionist(_address, _board_pos, _rand, _true_self), 
			Roles.MAGICIAN => new Magician(_address, _board_pos, _rand, _true_self), 
			Roles.WAITER => new Waiter(_address, _board_pos, _rand, _true_self), 
			Roles.PSYCHIC => new Psychic(_address, _board_pos, _rand, _true_self), 
			Roles.HUNTER => new Hunter(_address, _board_pos, _rand, _true_self), 
			Roles.LAWFUL_CITIZEN => new LawfulCitizen(_address, _board_pos, _rand, _true_self), 
			Roles.ENTHUSIAST => new Enthusiast(_address, _board_pos, _rand, _true_self), 
			Roles.SUPPLIER => new Supplier(_address, _board_pos, _rand, _true_self), 
			Roles.SURGIN => new Surgin(_address, _board_pos, _rand, _true_self), 
			Roles.CHATTER_BOX => new ChatterBox(_address, _board_pos, _rand, _true_self), 
			Roles.FALL_GUY => new FallGuy(_address, _board_pos, _rand, _true_self), 
			Roles.YOUNGSTER => new Youngster(_address, _board_pos, _rand, _true_self), 
			Roles.DRUNKARD => new Drunkard(_address, _board_pos, _rand, _true_self), 
			Roles.COPYCAT => new Copycat(_address, _board_pos, _rand, _true_self), 
			Roles.BOUNTY_HUNTER => new BountyHunter(_address, _board_pos, _rand, _true_self), 
			Roles.MILKMAN => new Milkman(_address, _board_pos, _rand, _true_self), 
			Roles.WANNABE => new Wannabe(_address, _board_pos, _rand, _true_self), 
			Roles.STALKER => new Stalker(_address, _board_pos, _rand, _true_self), 
			Roles.SHOWSTEALER => new Showstealer(_address, _board_pos, _rand, _true_self), 
			Roles.JINX => new Jinx(_address, _board_pos, _rand, _true_self), 
			Roles.GHOST => new Ghost(_address, _board_pos, _rand, _true_self), 
			Roles.STOWAWAY => new Stowaway(_address, _board_pos, _rand, _true_self), 
			Roles.GUNNER => new Gunner(_address, _board_pos, _rand, _true_self), 
			Roles.SHIPWRECKED => new Shipwrecked(_address, _board_pos, _rand, _true_self), 
			Roles.RED_HERRING => new RedHerring(_address, _board_pos, _rand, _true_self), 
			Roles.WHALE => new Whale(_address, _board_pos, _rand, _true_self), 
			Roles.TREASURE_HUNTER => new TreasureHunter(_address, _board_pos, _rand, _true_self), 
			Roles.ABSCONDER => new Absconder(_address, _board_pos, _rand, _true_self), 
			Roles.MIRAGE => new Mirage(_address, _board_pos, _rand, _true_self), 
			Roles.TURNCOAT => new Turncoat(_address, _board_pos, _rand, _true_self), 
			Roles.RAT => new Rat(_address, _board_pos, _rand, _true_self), 
			Roles.INTROVERT => new Introvert(_address, _board_pos, _rand, _true_self), 
			Roles.WANDERER => new Wanderer(_address, _board_pos, _rand, _true_self), 
			Roles.PLANT => new Plant(_address, _board_pos, _rand, _true_self), 
			Roles.CLUTZ => new Clutz(_address, _board_pos, _rand, _true_self), 
			Roles.MARKSMAN => new Marksman(_address, _board_pos, _rand, _true_self), 
			Roles.EXTRAVERT => new Extravert(_address, _board_pos, _rand, _true_self), 
			Roles.HIPSTER => new Hipster(_address, _board_pos, _rand, _true_self), 
			Roles.MISGUIDED => new Misguided(_address, _board_pos, _rand, _true_self), 
			Roles.VETERAN => new Veteran(_address, _board_pos, _rand, _true_self), 
			Roles.BAD_MOUTH => new BadMouth(_address, _board_pos, _rand, _true_self), 
			Roles.VICIOUS => new Vicious(_address, _board_pos, _rand, _true_self), 
			Roles.EGOTIST => new Egotist(_address, _board_pos, _rand, _true_self), 
			Roles.U_ADMIRER => new Admirer(_address, _board_pos, _rand, _true_self), 
			Roles.SAWBONES => new Sawbones(_address, _board_pos, _rand, _true_self), 
			Roles.DUBIOUS_CHEF => new DubiousChef(_address, _board_pos, _rand, _true_self), 
			Roles.RECKLESS_GENERAL => new RecklessGeneral(_address, _board_pos, _rand, _true_self), 
			Roles.INCOMPETENT_HELMSMAN => new IncompetentHelmsman(_address, _board_pos, _rand, _true_self), 
			Roles.INEPT_CADET => new IneptCadet(_address, _board_pos, _rand, _true_self), 
			Roles.SCAM_ARTIST => new ScamArtist(_address, _board_pos, _rand, _true_self), 
			Roles.TAXMAN => new Taxman(_address, _board_pos, _rand, _true_self), 
			Roles.MUTT => new Mutt(_address, _board_pos, _rand, _true_self), 
			Roles.TRICKSTER => new Trickster(_address, _board_pos, _rand, _true_self), 
			Roles.BIG_BLIND => new BigBlind(_address, _board_pos, _rand, _true_self), 
			Roles.BARISTA => new Barista(_address, _board_pos, _rand, _true_self), 
			Roles.CRACKPOT => new CrackPot(_address, _board_pos, _rand, _true_self), 
			Roles.MORTICIAN => new Mortician(_address, _board_pos, _rand, _true_self), 
			Roles.OFFEROR => new Offeror(_address, _board_pos, _rand, _true_self), 
			Roles.DIRECTOR => new Director(_address, _board_pos, _rand, _true_self), 
			Roles.DJ => new DJ(_address, _board_pos, _rand, _true_self), 
			Roles.DANCER => new Dancer(_address, _board_pos, _rand, _true_self), 
			Roles.REBEL => new Rebel(_address, _board_pos, _rand, _true_self), 
			Roles.BARKEEP => new Barkeep(_address, _board_pos, _rand, _true_self), 
			Roles.CASANOVA => new Casanova(_address, _board_pos, _rand, _true_self), 
			Roles.MOBSTER => new Mobster(_address, _board_pos, _rand, _true_self), 
			Roles.SPECTRE => new Spectre(_address, _board_pos, _rand, _true_self), 
			Roles.SCOUNDREL => new Scoundrel(_address, _board_pos, _rand, _true_self), 
			Roles.PREACHER => new Preacher(_address, _board_pos, _rand, _true_self), 
			Roles.POISONER => new Poisoner(_address, _board_pos, _rand, _true_self), 
			Roles.ACCOUNTANT => new Accountant(_address, _board_pos, _rand, _true_self), 
			Roles.CONMAN => new Conman(_address, _board_pos, _rand, _true_self), 
			Roles.SERIAL_KILLER => new SerialKiller(_address, _board_pos, _rand, _true_self), 
			Roles.WATCHMAKER => new Watchmaker(_address, _board_pos, _rand, _true_self), 
			Roles.CHARMER => new Charmer(_address, _board_pos, _rand, _true_self), 
			Roles.PIRATE => new Pirate(_address, _board_pos, _rand, _true_self), 
			Roles.SHARK => new Shark(_address, _board_pos, _rand, _true_self), 
			Roles.MUTINEER => new Mutineer(_address, _board_pos, _rand, _true_self), 
			Roles.MINELAYER => new Minelayer(_address, _board_pos, _rand, _true_self), 
			Roles.ANGLERFISH => new Anglerfish(_address, _board_pos, _rand, _true_self), 
			Roles.SQUID => new Squid(_address, _board_pos, _rand, _true_self), 
			Roles.OMEN => new Omen(_address, _board_pos, _rand, _true_self), 
			Roles.POWDER_MERCHANT => new PowderMerchant(_address, _board_pos, _rand, _true_self), 
			Roles.CANNONEER => new Cannoneer(_address, _board_pos, _rand, _true_self), 
			Roles.HERRING => new Herring(_address, _board_pos, _rand, _true_self), 
			Roles.DEEP_ONE => new DeepOne(_address, _board_pos, _rand, _true_self), 
			Roles.VANDAL => new Vandal(_address, _board_pos, _rand, _true_self), 
			Roles.CLEANUP_CREW => new CleanupCrew(_address, _board_pos, _rand, _true_self), 
			Roles.BAD_COP => new BadCop(_address, _board_pos, _rand, _true_self), 
			Roles.FUGITIVE => new Fugitive(_address, _board_pos, _rand, _true_self), 
			Roles.LANDLORD => new Landlord(_address, _board_pos, _rand, _true_self), 
			Roles.TRAVEL_AGENT => new TravelAgent(_address, _board_pos, _rand, _true_self), 
			Roles.STRANGLER => new Strangler(_address, _board_pos, _rand, _true_self), 
			Roles.SNIPER => new Sniper(_address, _board_pos, _rand, _true_self), 
			Roles.DOWNPLAYER => new Downplayer(_address, _board_pos, _rand, _true_self), 
			Roles.BUREAUCRAT => new Bureaucrat(_address, _board_pos, _rand, _true_self), 
			Roles.TACITURN => new Taciturn(_address, _board_pos, _rand, _true_self), 
			Roles.RENEGADE => new Renegade(_address, _board_pos, _rand, _true_self), 
			Roles.DETRACTOR => new Detractor(_address, _board_pos, _rand, _true_self), 
			Roles.MOLE => new Mole(_address, _board_pos, _rand, _true_self), 
			Roles.RAIDER => new Raider(_address, _board_pos, _rand, _true_self), 
			Roles.ENFORCER => new Enforcer(_address, _board_pos, _rand, _true_self), 
			Roles.HARPOONIST => new Harpoonist(_address, _board_pos, _rand, _true_self), 
			Roles.SIREN => new Siren(_address, _board_pos, _rand, _true_self), 
			Roles.PRICE_FIXER => new PriceFixer(_address, _board_pos, _rand, _true_self), 
			Roles.DEBT_COLLECTOR => new DebtCollector(_address, _board_pos, _rand, _true_self), 
			Roles.JOKER_R => new Joker(_address, _board_pos, _rand, _true_self), 
			Roles.PICKPOCKET => new Pickpocket(_address, _board_pos, _rand, _true_self), 
			Roles.CASHIER => new Cashier(_address, _board_pos, _rand, _true_self), 
			Roles.CHEAT => new Cheat(_address, _board_pos, _rand, _true_self), 
			Roles.SNITCH => new Snitch(_address, _board_pos, _rand, _true_self), 
			Roles.VIP => new VIP(_address, _board_pos, _rand, _true_self), 
			Roles.CROUPIER => new Croupier(_address, _board_pos, _rand, _true_self), 
			Roles.SELLOUT => new Sellout(_address, _board_pos, _rand, _true_self), 
			Roles.SMUGLER => new Smugler(_address, _board_pos, _rand, _true_self), 
			Roles.THIEF => new Thief(_address, _board_pos, _rand, _true_self), 
			Roles.JUDGE => new Judge(_address, _board_pos, _rand, _true_self), 
			Roles.IDOL => new Idol(_address, _board_pos, _rand, _true_self), 
			Roles.KINGPIN => new Kingpin(_address, _board_pos, _rand, _true_self), 
			Roles.HITMAN => new Hitman(_address, _board_pos, _rand, _true_self), 
			Roles.CRITIC => new Critic(_address, _board_pos, _rand, _true_self), 
			Roles.RECRUITER => new Recruiter(_address, _board_pos, _rand, _true_self), 
			Roles.KRAKEN => new Kraken(_address, _board_pos, _rand, _true_self), 
			Roles.PIRATE_CAPTAIN => new PirateCaptain(_address, _board_pos, _rand, _true_self), 
			Roles.JELLYFISH => new Jellyfish(_address, _board_pos, _rand, _true_self), 
			Roles.OIL_BARON => new OilBaron(_address, _board_pos, _rand, _true_self), 
			Roles.OCTOPUS => new Octopus(_address, _board_pos, _rand, _true_self), 
			Roles.HOOK => new Hook(_address, _board_pos, _rand, _true_self), 
			Roles.RAT_KING => new RatKing(_address, _board_pos, _rand, _true_self), 
			Roles.ASSASSIN => new Assassin(_address, _board_pos, _rand, _true_self), 
			Roles.SCRAMBLER => new Scrambler(_address, _board_pos, _rand, _true_self), 
			Roles.BOMBER => new Bomber(_address, _board_pos, _rand, _true_self), 
			Roles.RIDLER => new Ridler(_address, _board_pos, _rand, _true_self), 
			Roles.GODFATHER => new Godfather(_address, _board_pos, _rand, _true_self), 
			Roles.COSTUME_MAKER => new CostumeMaker(_address, _board_pos, _rand, _true_self), 
			Roles.SMOKER => new Smoker(_address, _board_pos, _rand, _true_self), 
			Roles.INTERCEPTOR => new Interceptor(_address, _board_pos, _rand, _true_self), 
			Roles.THE_HOUSE => new House(_address, _board_pos, _rand, _true_self), 
			Roles.VIOLENT_HOST => new ViolentHost(_address, _board_pos, _rand, _true_self), 
			Roles.INVESTOR => new Investor(_address, _board_pos, _rand, _true_self), 
			Roles.PAPARAZZI => new Paparazzi(_address, _board_pos, _rand, _true_self), 
			Roles.DEVIL => new Devil(_address, _board_pos, _rand, _true_self), 
			Roles.S_LAWYER => new Lawyer_dep(_address, _board_pos, _rand, _true_self), 
			Roles.S_TABBY_CAT => new TabbyCat_dep(_address, _board_pos, _rand, _true_self), 
			Roles.S_FANATIC => new Fanatic_dep(_address, _board_pos, _rand, _true_self), 
			_ => throw new NotImplementedException($"Role case: '{_role}' not implimented (createRole)"), 
		};
	}

	public static RoleData fromSave(this RoleSave _save, System.Random _rand)
	{
		return _save.data.fromSave(_save.info.maybe(), _save.disguise, _rand);
	}

	public static RoleData disguiseFromSave(this RoleDataSave _save, System.Random _rand)
	{
		return _save.fromSave(new Maybe<RoleInfoSave>(), new Maybe<RoleDataSave>(), _rand);
	}

	private static RoleData fromSave(this RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _rand)
	{
		return _save.role switch
		{
			Roles.PRIVATE_INVESTIGATOR => new PrivateInvestigator(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.REPORTER => new Reporter(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.ROMANTIC => new Romantic(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.THERAPIST => new Therapist(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.WEATHERMAN => new Weatherman(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.BLOOD_HOUND => new BloodHound(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.PRIEST => new Priest(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.SKEPTIC => new Skeptic(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.VIGILANTE => new Vigilante(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.MAILMAN => new Mailman(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.TAILOR => new Tailor(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.DOPPELGANGER => new Doppelganger(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.PARTNER => new Partner(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.MATHEMATICIAN => new Mathematician(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.GOSSIP => new Gossip(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.CLOCK_MAKER => new ClockMaker(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.EMPATH => new Empath(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.RESEARCHER => new Researcher(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.NAVIGATOR => new Navigator(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.DIVER => new Diver(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.FISHERMAN => new Fisherman(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.CRABER => new Craber(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.LIGHTHOUSE_KEEPER => new LighthouseKeeper(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.LOOKOUT => new Lookout(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.COASTGUARD => new Coastguard(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.MARINE => new Marine(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.NYMPH => new Nymph(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.BARRELMAN => new Barrelman(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.GENTLEMAN => new Gentleman(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.GARGOYLE => new Gargoyle(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.MAID => new Maid(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.FEARMONGER => new Fearmonger(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.BELFRY => new Belfry(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.TEACHER => new Teacher(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.BROKER => new Broker(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.LIBRARIAN => new Librarian(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.GOOD_COP => new GoodCop(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.CHAUFFEUR => new Chauffeur(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.WITNESS => new Witness(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.ARTIST => new Artist(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.PSYCHIATRIST => new Psychiatrist(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.PAPER_BOY => new PaperBoy(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.ASSISTANT => new Assistant(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.JOURNALIST => new Journalist(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.PRODUCER => new Producer(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.PUBLISHER => new Publisher(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.MYTHOMANIAC => new Mythomaniac(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.ICONOGRAPHER => new Iconographer(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.POLITICIAN => new Politician(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.HERMIT => new Hermit(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.PHYSIOGNOMIST => new Physiognomist(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.CLAIRVOYANT => new Clairvoyant(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.MEDIUM => new Medium(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.ALERTER => new Alerter(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.SAILOR => new Sailor(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.CAPTAIN => new Captain(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.DECK_CADET => new DeckCadet(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.SECOND_MATE => new SecondMate(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.MECHANIC => new Mechanic(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.CULTIST => new Cultist(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.FUEL_MERCHANT => new FuelMerchant(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.DECKHAND => new Deckhand(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.SUBMARINE => new Submariner(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.SPOTTER => new Spotter(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.OPPORTUNIST => new Opportunist(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.INFORMANT => new Informant(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.HIRED_GUN => new HiredGun(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.VISIONARY => new Visionary(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.BUYOUT => new Buyout(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.CARD_PSYCHIC => new CardPsychic(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.VALET => new Valet(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.BLACKJACK_PLAYER => new BlackjackPlayer(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.DEALER => new Dealer(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.BOUNCER => new Bouncer(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.CARD_READER => new CardReader(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.LOTTO_SCRATCHER => new LottoScratcher(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.HOT_SHOT => new HotShot(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.TIPSTER => new Tipster(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.CARDIOLOGIST => new Cardiologist(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.RECEPTIONIST => new Receptionist(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.MAGICIAN => new Magician(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.WAITER => new Waiter(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.PSYCHIC => new Psychic(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.HUNTER => new Hunter(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.LAWFUL_CITIZEN => new LawfulCitizen(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.ENTHUSIAST => new Enthusiast(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.SUPPLIER => new Supplier(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.SURGIN => new Surgin(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.CHATTER_BOX => new ChatterBox(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.FALL_GUY => new FallGuy(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.YOUNGSTER => new Youngster(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.DRUNKARD => new Drunkard(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.COPYCAT => new Copycat(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.BOUNTY_HUNTER => new BountyHunter(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.MILKMAN => new Milkman(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.WANNABE => new Wannabe(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.STALKER => new Stalker(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.SHOWSTEALER => new Showstealer(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.JINX => new Jinx(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.GHOST => new Ghost(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.STOWAWAY => new Stowaway(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.GUNNER => new Gunner(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.SHIPWRECKED => new Shipwrecked(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.RED_HERRING => new RedHerring(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.WHALE => new Whale(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.TREASURE_HUNTER => new TreasureHunter(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.ABSCONDER => new Absconder(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.MIRAGE => new Mirage(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.TURNCOAT => new Turncoat(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.RAT => new Rat(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.INTROVERT => new Introvert(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.WANDERER => new Wanderer(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.PLANT => new Plant(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.CLUTZ => new Clutz(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.MARKSMAN => new Marksman(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.EXTRAVERT => new Extravert(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.HIPSTER => new Hipster(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.MISGUIDED => new Misguided(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.VETERAN => new Veteran(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.BAD_MOUTH => new BadMouth(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.VICIOUS => new Vicious(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.EGOTIST => new Egotist(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.U_ADMIRER => new Admirer(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.SAWBONES => new Sawbones(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.DUBIOUS_CHEF => new DubiousChef(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.RECKLESS_GENERAL => new RecklessGeneral(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.INCOMPETENT_HELMSMAN => new IncompetentHelmsman(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.INEPT_CADET => new IneptCadet(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.SCAM_ARTIST => new ScamArtist(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.TAXMAN => new Taxman(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.MUTT => new Mutt(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.TRICKSTER => new Trickster(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.BIG_BLIND => new BigBlind(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.BARISTA => new Barista(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.CRACKPOT => new CrackPot(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.MORTICIAN => new Mortician(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.OFFEROR => new Offeror(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.DIRECTOR => new Director(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.DJ => new DJ(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.DANCER => new Dancer(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.REBEL => new Rebel(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.BARKEEP => new Barkeep(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.CASANOVA => new Casanova(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.MOBSTER => new Mobster(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.SPECTRE => new Spectre(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.SCOUNDREL => new Scoundrel(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.PREACHER => new Preacher(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.POISONER => new Poisoner(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.ACCOUNTANT => new Accountant(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.CONMAN => new Conman(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.SERIAL_KILLER => new SerialKiller(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.WATCHMAKER => new Watchmaker(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.CHARMER => new Charmer(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.PIRATE => new Pirate(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.SHARK => new Shark(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.MUTINEER => new Mutineer(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.MINELAYER => new Minelayer(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.ANGLERFISH => new Anglerfish(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.SQUID => new Squid(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.OMEN => new Omen(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.POWDER_MERCHANT => new PowderMerchant(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.CANNONEER => new Cannoneer(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.HERRING => new Herring(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.DEEP_ONE => new DeepOne(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.VANDAL => new Vandal(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.CLEANUP_CREW => new CleanupCrew(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.BAD_COP => new BadCop(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.FUGITIVE => new Fugitive(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.LANDLORD => new Landlord(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.TRAVEL_AGENT => new TravelAgent(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.STRANGLER => new Strangler(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.SNIPER => new Sniper(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.DOWNPLAYER => new Downplayer(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.BUREAUCRAT => new Bureaucrat(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.TACITURN => new Taciturn(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.RENEGADE => new Renegade(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.DETRACTOR => new Detractor(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.MOLE => new Mole(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.RAIDER => new Raider(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.ENFORCER => new Enforcer(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.HARPOONIST => new Harpoonist(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.SIREN => new Siren(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.PRICE_FIXER => new PriceFixer(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.DEBT_COLLECTOR => new DebtCollector(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.JOKER_R => new Joker(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.PICKPOCKET => new Pickpocket(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.CASHIER => new Cashier(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.CHEAT => new Cheat(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.SNITCH => new Snitch(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.VIP => new VIP(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.CROUPIER => new Croupier(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.SELLOUT => new Sellout(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.SMUGLER => new Smugler(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.THIEF => new Thief(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.JUDGE => new Judge(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.IDOL => new Idol(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.KINGPIN => new Kingpin(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.HITMAN => new Hitman(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.CRITIC => new Critic(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.RECRUITER => new Recruiter(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.KRAKEN => new Kraken(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.PIRATE_CAPTAIN => new PirateCaptain(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.JELLYFISH => new Jellyfish(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.OIL_BARON => new OilBaron(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.OCTOPUS => new Octopus(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.HOOK => new Hook(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.RAT_KING => new RatKing(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.ASSASSIN => new Assassin(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.SCRAMBLER => new Scrambler(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.BOMBER => new Bomber(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.RIDLER => new Ridler(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.GODFATHER => new Godfather(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.COSTUME_MAKER => new CostumeMaker(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.SMOKER => new Smoker(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.INTERCEPTOR => new Interceptor(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.THE_HOUSE => new House(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.VIOLENT_HOST => new ViolentHost(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.INVESTOR => new Investor(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.PAPARAZZI => new Paparazzi(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.DEVIL => new Devil(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.S_LAWYER => new Lawyer_dep(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.S_TABBY_CAT => new TabbyCat_dep(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			Roles.S_FANATIC => new Fanatic_dep(_save, _info, _disguise, _rand, (RoleDataSave _rs) => _rs.disguiseFromSave(_rand)), 
			_ => throw new NotImplementedException($"Role case: '{_save.role}' not implimented (fromSave)"), 
		};
	}

	public static L createLocation<L>(Vector2Int _board_pos, System.Random _rand) where L : LocationData
	{
		return Activator.CreateInstance(typeof(LocationData), _board_pos, _rand) as L;
	}

	public static LocationData createEmptyLocation(this LocationTypes _location)
	{
		return _location.createLocation(new Vector2Int(-1, -1), new System.Random());
	}

	public static LocationData createLocation(this LocationTypes _location, Vector2Int _board_pos, System.Random _rand)
	{
		return _location switch
		{
			LocationTypes.CRIME_SCENE => new CrimeScene(_rand, _board_pos), 
			LocationTypes.CLOCK_TOWER => new ClockTower(_rand, _board_pos), 
			LocationTypes.BLOOD_TRACE => new BloodTrace(_rand, _board_pos), 
			LocationTypes.BOMB => new Bomb(_rand, _board_pos), 
			LocationTypes.BOMB_THREAT => new BombThreat(_rand, _board_pos), 
			LocationTypes.DOCKS => new Docks(_rand, _board_pos), 
			LocationTypes.LIGHTHOUSE => new Lighthouse(_rand, _board_pos), 
			LocationTypes.NAVAL_MINE => new NavalMine(_rand, _board_pos), 
			LocationTypes.OIL_PLATFORM => new OilPlatform(_rand, _board_pos), 
			LocationTypes.ROULETTE_TABLE => new RouletteTable(_rand, _board_pos), 
			LocationTypes.CARD_SHUFFLER => new CardShuffler(_rand, _board_pos), 
			LocationTypes.SLOT_MACHINE => new SlotMachine(_rand, _board_pos), 
			_ => throw new NotImplementedException($"Location case: '{_location}' not implimented"), 
		};
	}

	public static LocationData fromSave(this LocationDataSave _save, System.Random _rand)
	{
		return _save.location_type switch
		{
			LocationTypes.CRIME_SCENE => new CrimeScene(_save, _rand), 
			LocationTypes.CLOCK_TOWER => new ClockTower(_save, _rand), 
			LocationTypes.BLOOD_TRACE => new BloodTrace(_save, _rand), 
			LocationTypes.BOMB => new Bomb(_save, _rand), 
			LocationTypes.BOMB_THREAT => new BombThreat(_save, _rand), 
			LocationTypes.DOCKS => new Docks(_save, _rand), 
			LocationTypes.LIGHTHOUSE => new Lighthouse(_save, _rand), 
			LocationTypes.NAVAL_MINE => new NavalMine(_save, _rand), 
			LocationTypes.OIL_PLATFORM => new OilPlatform(_save, _rand), 
			LocationTypes.ROULETTE_TABLE => new RouletteTable(_save, _rand), 
			LocationTypes.CARD_SHUFFLER => new CardShuffler(_save, _rand), 
			LocationTypes.SLOT_MACHINE => new SlotMachine(_save, _rand), 
			_ => throw new NotImplementedException($"Location case: '{_save.location_type}' not implimented"), 
		};
	}

	public static bool isLocationOfCaseType(this LocationTypes _location, CaseType _type)
	{
		return _location switch
		{
			LocationTypes.CRIME_SCENE => _type.equalToAny(CaseType.CLOCK, CaseType.CASINO, CaseType.BACK_ALLEYS), 
			LocationTypes.BLOOD_TRACE => _type.equalToAny(CaseType.CLOCK, CaseType.CASINO, CaseType.BACK_ALLEYS), 
			LocationTypes.CLOCK_TOWER => _type == CaseType.CLOCK, 
			LocationTypes.BOMB => _type == CaseType.CLOCK, 
			LocationTypes.BOMB_THREAT => _type == CaseType.CLOCK, 
			LocationTypes.DOCKS => _type == CaseType.DOCKS, 
			LocationTypes.LIGHTHOUSE => _type == CaseType.DOCKS, 
			LocationTypes.NAVAL_MINE => _type == CaseType.DOCKS, 
			LocationTypes.OIL_PLATFORM => _type == CaseType.DOCKS, 
			LocationTypes.ROULETTE_TABLE => _type == CaseType.CASINO, 
			LocationTypes.CARD_SHUFFLER => _type == CaseType.CASINO, 
			LocationTypes.SLOT_MACHINE => _type == CaseType.CASINO, 
			_ => false, 
		};
	}

	public static bool isScrapped(this LocationTypes _location)
	{
		return _location > (LocationTypes)9000;
	}

	public static Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> registerRoleChange(this Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, Vector2Int _pos, RoleData _new)
	{
		_board[_pos] = _new.toEitherA<RoleData, LocationData>().maybe();
		return _board;
	}

	public static Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> registerLocationChange(this Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, Vector2Int _pos, LocationData _new)
	{
		_board[_pos] = _new.toEitherB<RoleData, LocationData>().maybe();
		return _board;
	}

	public static Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> recalculateAddresses(this Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board)
	{
		int i = 0;
		_board.Keys.OrderBy((Vector2Int x) => x.y * 100 + x.x).ToList().ForEach(delegate(Vector2Int _loc)
		{
			if (_board[_loc].is_some && _board[_loc].value.is_a)
			{
				i++;
				_board[_loc].value.maybe_a.value.setAddress(i);
			}
		});
		return _board;
	}

	public static RoleClassifications getClassificationFromRoleType(this Roles _role)
	{
		if (!_role.isInnocent())
		{
			if (!_role.isMeddler())
			{
				if (!_role.isUnderling())
				{
					if (!_role.isTraitor())
					{
						throw new ArgumentException("Could not find role classification from role!");
					}
					return RoleClassifications.TRAITOR;
				}
				return RoleClassifications.UNDERLING;
			}
			return RoleClassifications.MEDDLER;
		}
		return RoleClassifications.INNOCENT;
	}

	public static Alignments getAlignmentFromRoleType(this Roles _role)
	{
		return _role.getClassificationFromRoleType() switch
		{
			RoleClassifications.INNOCENT => Alignments.GOOD, 
			RoleClassifications.MEDDLER => Alignments.GOOD, 
			RoleClassifications.UNDERLING => Alignments.EVIL, 
			RoleClassifications.TRAITOR => Alignments.EVIL, 
			_ => throw new ArgumentException("Could not find Alignment from role!"), 
		};
	}

	public static bool isPositionInsideGrid(this Vector2Int _coord, Vector2Int _grid_size)
	{
		if (_coord.x >= 0 && _coord.y >= 0 && _coord.x < _grid_size.x)
		{
			return _coord.y < _grid_size.y;
		}
		return false;
	}

	public static List<Vector2Int> getNeighboursFromPositionWithinGrid(this Vector2Int _coord, Vector2Int _grid_size)
	{
		List<Vector2Int> list = new List<Vector2Int>();
		foreach (Vector2Int item in new List<Vector2Int>
		{
			new Vector2Int(-1, -1),
			new Vector2Int(0, -1),
			new Vector2Int(1, -1),
			new Vector2Int(-1, 0),
			new Vector2Int(1, 0),
			new Vector2Int(-1, 1),
			new Vector2Int(0, 1),
			new Vector2Int(1, 1)
		})
		{
			Vector2Int vector2Int = new Vector2Int(item.x + _coord.x, item.y + _coord.y);
			if (vector2Int.isPositionInsideGrid(_grid_size))
			{
				list.Add(vector2Int);
			}
		}
		return list;
	}

	public static List<Vector2Int> getCardinalNeighboursFromPositionWithinGrid(this Vector2Int _coord, Vector2Int _board_size)
	{
		List<Vector2Int> list = new List<Vector2Int>();
		foreach (Vector2Int item in new List<Vector2Int>
		{
			new Vector2Int(0, -1),
			new Vector2Int(-1, 0),
			new Vector2Int(1, 0),
			new Vector2Int(0, 1)
		})
		{
			Vector2Int vector2Int = new Vector2Int(item.x + _coord.x, item.y + _coord.y);
			if (vector2Int.isPositionInsideGrid(_board_size))
			{
				list.Add(vector2Int);
			}
		}
		return list;
	}

	public static bool isInnerPositionOnGrid(this Vector2Int _coord, Vector2Int _board_size)
	{
		if (_coord.x != 0 && _coord.x != _board_size.x - 1 && _coord.y != 0)
		{
			return _coord.y != _board_size.y - 1;
		}
		return false;
	}

	public static bool isEdgePositionOnGrid(this Vector2Int _coord, Vector2Int _board_size)
	{
		return !_coord.isInnerPositionOnGrid(_board_size);
	}

	public static bool inSameColumnOrRow(this Vector2Int _pos_1, Vector2Int _pos_2)
	{
		if (!_pos_1.inSameColumn(_pos_2))
		{
			return _pos_1.inSameRow(_pos_2);
		}
		return true;
	}

	public static bool inSameColumn(this Vector2Int _pos_1, Vector2Int _pos_2)
	{
		return _pos_1.x == _pos_2.x;
	}

	public static bool inSameRow(this Vector2Int _pos_1, Vector2Int _pos_2)
	{
		return _pos_1.y == _pos_2.y;
	}

	public static List<Vector2Int> getPositionsOfColumnX(this int _x_pos, Vector2Int _board_size)
	{
		List<Vector2Int> list = new List<Vector2Int>();
		for (int i = 0; i < _board_size.y; i++)
		{
			list.Add(new Vector2Int(_x_pos, i));
		}
		return list;
	}

	public static List<Vector2Int> getPositionsOfRowY(this int _y_pos, Vector2Int _board_size)
	{
		List<Vector2Int> list = new List<Vector2Int>();
		for (int i = 0; i < _board_size.x; i++)
		{
			list.Add(new Vector2Int(i, _y_pos));
		}
		return list;
	}

	public static List<Vector2Int> getPositionsInSameColumn(this Vector2Int _board_position, Vector2Int _board_size, bool _include_self = true)
	{
		if (!_include_self)
		{
			return _board_position.x.getPositionsOfColumnX(_board_size).remove(_board_position);
		}
		return _board_position.x.getPositionsOfColumnX(_board_size);
	}

	public static List<Vector2Int> getPositionsInSameRow(this Vector2Int _board_position, Vector2Int _board_size, bool _include_self = true)
	{
		if (!_include_self)
		{
			return _board_position.y.getPositionsOfRowY(_board_size).remove(_board_position);
		}
		return _board_position.y.getPositionsOfRowY(_board_size);
	}

	public static List<Vector2Int> getPositionsInSameColumnOrRow(this Vector2Int _board_position, Vector2Int _board_size, bool _include_self = false)
	{
		return _board_position.getPositionsInSameColumn(_board_size, _include_self).addRange(_board_position.getPositionsInSameRow(_board_size, _include_self: false));
	}

	public static List<Vector2Int> getEmptySpaces(this Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board)
	{
		List<Vector2Int> list = new List<Vector2Int>();
		foreach (KeyValuePair<Vector2Int, Maybe<Either<RoleData, LocationData>>> item in _board)
		{
			if (!item.Value.is_some)
			{
				list.Add(item.Key);
			}
		}
		return list;
	}

	public static Vector2Int getMirroredPosition(this Vector2Int _position, Vector2Int _board_size)
	{
		return _board_size - new Vector2Int(1, 1) - _position;
	}

	public static int cardinalDistance(this Vector2Int _position, Vector2Int _other)
	{
		return Mathf.Abs(_position.x - _other.x) + Mathf.Abs(_position.y - _other.y);
	}

	public static bool isOnBoard(this Vector2Int _position, Vector2Int _board_size)
	{
		if (_position.x >= 0 && _position.x < _board_size.x && _position.y >= 0)
		{
			return _position.y < _board_size.y;
		}
		return false;
	}

	public static bool isAdjacent(this Vector2Int _position, Vector2Int _other)
	{
		return _position.cardinalDistance(_other) == 1;
	}

	public static bool isSurrounding(this Vector2Int _position, Vector2Int _other)
	{
		if (_position.isSurroundingOrOn(_other))
		{
			return _position != _other;
		}
		return false;
	}

	public static bool isAdjacentOrOn(this Vector2Int _position, Vector2Int _other)
	{
		return _position.cardinalDistance(_other) <= 1;
	}

	public static bool isSurroundingOrOn(this Vector2Int _position, Vector2Int _other)
	{
		if (Mathf.Abs(_position.x - _other.x) <= 1)
		{
			return Mathf.Abs(_position.y - _other.y) <= 1;
		}
		return false;
	}

	public static List<Vector2Int> getAllPositions(this Vector2Int _board_size, Func<Vector2Int, bool> _condition)
	{
		List<Vector2Int> list = new List<Vector2Int>();
		for (int i = 0; i < _board_size.x; i++)
		{
			for (int j = 0; j < _board_size.y; j++)
			{
				Vector2Int vector2Int = new Vector2Int(i, j);
				if (_condition(vector2Int))
				{
					list.Add(vector2Int);
				}
			}
		}
		return list;
	}

	public static List<Vector2Int> getAdjacentPositionsOnBoard(this Vector2Int _position, Vector2Int _size)
	{
		return (from _p in _position.getAdjacentPositions()
			where _p.isOnBoard(_size)
			select _p).ToList();
	}

	public static List<Vector2Int> getAdjacentPositions(this Vector2Int _position)
	{
		return new List<Vector2Int>
		{
			_position + new Vector2Int(0, 1),
			_position + new Vector2Int(1, 0),
			_position + new Vector2Int(0, -1),
			_position + new Vector2Int(-1, 0)
		};
	}

	public static List<Vector2Int> getSurroundingPositions(this Vector2Int _position)
	{
		return new List<Vector2Int>
		{
			_position + new Vector2Int(0, 1),
			_position + new Vector2Int(1, 1),
			_position + new Vector2Int(1, 0),
			_position + new Vector2Int(1, -1),
			_position + new Vector2Int(0, -1),
			_position + new Vector2Int(-1, -1),
			_position + new Vector2Int(-1, 0),
			_position + new Vector2Int(-1, 1)
		};
	}

	public static List<Vector2Int> getNotAdjacentPositions(this Vector2Int _position, Vector2Int _size)
	{
		return _size.getAllPositions((Vector2Int _p) => !_p.isAdjacentOrOn(_position));
	}

	public static List<Vector2Int> getNotSurroundingPositions(this Vector2Int _position, Vector2Int _size)
	{
		return _size.getAllPositions((Vector2Int _p) => !_p.isSurroundingOrOn(_position));
	}

	public static List<Vector2Int> getBoardEdgePositions(this Vector2Int _size)
	{
		return _size.getAllPositions((Vector2Int _p) => _p.x.equalToAny(0, _size.x - 1) || _p.y.equalToAny(0, _size.y - 1));
	}

	public static List<Vector2Int> getBoardInnerPositions(this Vector2Int _size)
	{
		return _size.getAllPositions((Vector2Int _p) => !_p.x.equalToAny(0, _size.x - 1) && !_p.y.equalToAny(0, _size.y - 1));
	}

	public static List<RoleData> getRolesInColumnOrRow(this Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, Vector2Int _position, Vector2Int _board_size, bool _include_self = false)
	{
		return _position.getPositionsInSameColumnOrRow(_board_size, _include_self).whereSelect((Vector2Int _p) => _p.isRoleAtBoardPosition(_board), (Vector2Int _p) => _board[_p].value.maybe_a.value);
	}

	public static List<RoleData> getRolesInColumnOrRow(this Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, Vector2Int _position, Vector2Int _board_size, Func<RoleData, bool> _extra_condition, bool _include_self = false)
	{
		return _position.getPositionsInSameColumnOrRow(_board_size, _include_self).whereSelect((Vector2Int _p) => _p.isRoleAtBoardPosition(_board, _extra_condition), (Vector2Int _p) => _board[_p].value.maybe_a.value);
	}

	public static List<RoleData> getRolesInColumn(this Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, Vector2Int _position, Vector2Int _board_size, bool _include_self = false)
	{
		return (from _p in _position.getPositionsInSameColumn(_board_size, _include_self)
			where _p.isRoleAtBoardPosition(_board)
			select _board[_p].value.maybe_a.value).toListSafe();
	}

	public static List<RoleData> getRolesInColumn(this Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, Vector2Int _position, Vector2Int _board_size, Func<RoleData, bool> _extra_condition, bool _include_self = false)
	{
		return (from _p in _position.getPositionsInSameColumn(_board_size, _include_self)
			where _p.isRoleAtBoardPosition(_board, _extra_condition)
			select _board[_p].value.maybe_a.value).toListSafe();
	}

	public static List<RoleData> getRolesInRow(this Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, Vector2Int _position, Vector2Int _board_size, bool _include_self = false)
	{
		return (from _p in _position.getPositionsInSameRow(_board_size, _include_self)
			where _p.isRoleAtBoardPosition(_board)
			select _board[_p].value.maybe_a.value).toListSafe();
	}

	public static List<RoleData> getRolesInRow(this Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, Vector2Int _position, Vector2Int _board_size, Func<RoleData, bool> _extra_condition, bool _include_self = false)
	{
		return (from _p in _position.getPositionsInSameRow(_board_size, _include_self)
			where _p.isRoleAtBoardPosition(_board, _extra_condition)
			select _board[_p].value.maybe_a.value).toListSafe();
	}

	public static List<RoleData> getSurroundingRolesFromGridPos(this Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, Vector2Int _pos, Vector2Int _board_size)
	{
		List<RoleData> list = new List<RoleData>();
		foreach (Vector2Int item in _pos.getNeighboursFromPositionWithinGrid(_board_size))
		{
			Maybe<Either<RoleData, LocationData>> maybe = _board[item];
			if (maybe.is_some && maybe.value.is_a)
			{
				list.Add(maybe.value.maybe_a.value);
			}
		}
		return list;
	}

	public static List<RoleData> getAdjacentRolesFromGridPos(this Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, Vector2Int _pos, Vector2Int _board_size)
	{
		List<RoleData> list = new List<RoleData>();
		foreach (Vector2Int item in _pos.getCardinalNeighboursFromPositionWithinGrid(_board_size))
		{
			Maybe<Either<RoleData, LocationData>> maybe = _board[item];
			if (maybe.is_some && maybe.value.is_a)
			{
				list.Add(maybe.value.maybe_a.value);
			}
		}
		return list;
	}

	public static List<RoleData> getNonSurroundingRolesFromGridPos(this Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, Vector2Int _pos)
	{
		List<RoleData> list = new List<RoleData>();
		foreach (KeyValuePair<Vector2Int, Maybe<Either<RoleData, LocationData>>> item in _board)
		{
			if (item.Value.is_some && item.Value.value.is_a && !item.Key.isSurroundingOrOn(_pos))
			{
				list.Add(item.Value.value.maybe_a.value);
			}
		}
		return list;
	}

	public static List<RoleData> getNonAdjacentRolesFromGridPos(this Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, Vector2Int _pos)
	{
		List<RoleData> list = new List<RoleData>();
		foreach (KeyValuePair<Vector2Int, Maybe<Either<RoleData, LocationData>>> item in _board)
		{
			if (item.Value.is_some && item.Value.value.is_a && !item.Key.isAdjacentOrOn(_pos))
			{
				list.Add(item.Value.value.maybe_a.value);
			}
		}
		return list;
	}

	public static Maybe<RoleData> getClosestEvilAlignedFromCurrentPos(this Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, Vector2Int _pos, bool _include_self = false)
	{
		IEnumerable<RoleData> source = _board.getRolesInPlay().Values.Where((RoleData _h) => _h.getVisualAlignment() == Alignments.EVIL && (_include_self || _h.getBoardPosition() != _pos));
		if (source.Count() == 0)
		{
			return new Maybe<RoleData>();
		}
		return source.OrderBy((RoleData _e) => _e.getBoardPosition().cardinalDistance(_pos)).First().maybe();
	}

	public static List<RoleData> getClosestAliveAndUnarrestedEvilFromCurrentPos(this Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, Vector2Int _pos, bool _include_self = false)
	{
		IEnumerable<RoleData> enumerable = _board.getRolesInPlay().Values.Where((RoleData _h) => _h.getVisualAlignment() == Alignments.EVIL && !_h.getIsArrested() && !_h.getIsDead() && (_include_self || _h.getBoardPosition() != _pos));
		if (enumerable.Count() == 0)
		{
			return new List<RoleData>();
		}
		List<RoleData> list = new List<RoleData>();
		int num = -1;
		foreach (RoleData item in enumerable)
		{
			int num2 = item.getBoardPosition().cardinalDistance(_pos);
			if (num == -1 || num2 < num)
			{
				list = item.makeListFromItem();
				num = num2;
			}
			else if (num == num2)
			{
				list.Add(item);
			}
		}
		return list;
	}

	public static ReputationStatus getVisualReputationStatus(Case _case)
	{
		if (_case is ClockCase clockCase)
		{
			return clockCase.reputation_status;
		}
		if (_case is DocksCase docksCase)
		{
			return docksCase.reputation_status;
		}
		Debug.LogError($"Could not get reputation status from case type {_case.case_type}!");
		return ReputationStatus.NEUTRAL;
	}

	public static DisguiseCharacteristics getGoodDisguise(DisguiseTarget _target)
	{
		return new DisguiseCharacteristics(_target, new List<RoleClassifications>
		{
			RoleClassifications.INNOCENT,
			RoleClassifications.MEDDLER
		}, new List<Roles>());
	}

	public static DisguiseCharacteristics getInnocentDisguise(DisguiseTarget _target)
	{
		return new DisguiseCharacteristics(_target, new List<RoleClassifications> { RoleClassifications.INNOCENT }, new List<Roles>());
	}

	public static Dictionary<RoleClassifications, int> generateRatio(float _dif01, CaseRatioBuilderData _ratio_data, System.Random _random)
	{
		MinMaxInt address_size = _ratio_data.address_size;
		if (address_size.max - address_size.min > 2)
		{
			if (_dif01 < 0.4f)
			{
				address_size.max = Mathf.CeilToInt(_ratio_data.address_size.average);
			}
			else if (_dif01 < 0.7f)
			{
				address_size.min += Mathf.RoundToInt((_ratio_data.address_size.average - (float)address_size.min) * ((_dif01 - 0.4f) / 0.3f));
				address_size.max -= Mathf.RoundToInt(((float)address_size.max - _ratio_data.address_size.average) * (1f - (_dif01 - 0.4f) / 0.3f));
			}
			else
			{
				address_size.min = Mathf.FloorToInt(_ratio_data.address_size.average);
			}
		}
		int desired_addresses = address_size.get(_random);
		Dictionary<RoleClassifications, int> ratio = new Dictionary<RoleClassifications, int>();
		if (_ratio_data.innocents.forced != -1)
		{
			ratio[RoleClassifications.INNOCENT] = _ratio_data.innocents.forced;
		}
		if (_ratio_data.meddlers.forced != -1)
		{
			ratio[RoleClassifications.MEDDLER] = _ratio_data.meddlers.forced;
		}
		if (_ratio_data.underlings.forced != -1)
		{
			ratio[RoleClassifications.UNDERLING] = _ratio_data.underlings.forced;
		}
		if (_ratio_data.traitors.forced != -1)
		{
			ratio[RoleClassifications.TRAITOR] = _ratio_data.traitors.forced;
		}
		int num = ratio.Values.Aggregate(0, (int _a, int _r) => _a + _r);
		List<RoleClassifications> list = (from _r in new List<RoleClassifications>().addAll()
			where !ratio.ContainsKey(_r)
			select _r).toListSafe();
		if (list.Count == 0)
		{
			return ratio;
		}
		if (num >= desired_addresses)
		{
			foreach (RoleClassifications item in list)
			{
				ratio[item] = 0;
			}
			if (ratio[RoleClassifications.UNDERLING] == 0)
			{
				ratio[RoleClassifications.UNDERLING] = 1;
			}
			return ratio;
		}
		Dictionary<RoleClassifications, (int, float)> weights = getWeightedClassification(_dif01, desired_addresses, _ratio_data);
		int num2 = list.Aggregate(0, (int _a, RoleClassifications _c) => _a + weights[_c].Item1) + num;
		if (num2 > _ratio_data.address_size.max)
		{
			int num3 = num2 - _ratio_data.address_size.max;
			weights[RoleClassifications.INNOCENT] = (weights[RoleClassifications.INNOCENT].Item1 - num3, weights[RoleClassifications.INNOCENT].Item2);
			if (weights[RoleClassifications.INNOCENT].Item1 < 3)
			{
				throw new ArgumentException($"Min required roles ({num2}) is bigger than max address size ({_ratio_data.address_size.max}) & backup has too few innocents!" + weights.Aggregate("", (string _a, KeyValuePair<RoleClassifications, (int, float)> _kvp) => _a + $"\n{_kvp.Key} - {_kvp.Value.Item1}"));
			}
		}
		foreach (RoleClassifications item2 in list)
		{
			ratio[item2] = Mathf.Min(weights[item2].Item1, _ratio_data[item2].max_allowed);
			num += ratio[item2];
		}
		List<(RoleClassifications, int)> list2 = (from _c in list
			select (_c: _c, Mathf.RoundToInt((weights[_c].Item2 * (float)desired_addresses - (float)ratio.getOrCreate(_c, 0)) * 100f)) into _ws
			where _ws.Item2 != 0
			select _ws).toListSafe();
		while (num < desired_addresses)
		{
			Maybe<RoleClassifications> choice = new Maybe<RoleClassifications>();
			if (ratio.Count((KeyValuePair<RoleClassifications, int> _kvp) => _kvp.Value >= ratio[RoleClassifications.INNOCENT]) > 1)
			{
				choice = RoleClassifications.INNOCENT.maybe();
			}
			else
			{
				choice = list2.weightedChoose(_random);
			}
			if (!choice.is_some)
			{
				Debug.LogError("Something went wrong getting classification ratio!\n" + _ratio_data.print());
				return ratio;
			}
			ratio[choice.value]++;
			num++;
			if (ratio[choice.value] >= _ratio_data[choice.value].max_allowed)
			{
				ratio[choice.value] = _ratio_data[choice.value].max_allowed;
				list2.RemoveAll(((RoleClassifications, int) _v) => _v.Item1 == choice.value);
			}
		}
		return ratio;
	}

	private static Dictionary<RoleClassifications, (int, float)> getWeightedClassification(float _diff01, int _address_count, CaseRatioBuilderData _ratio_data)
	{
		Dictionary<RoleClassifications, (int, float)> dictionary = new Dictionary<RoleClassifications, (int, float)>();
		dictionary.Add(RoleClassifications.INNOCENT, (Mathf.Max(Mathf.RoundToInt((float)_address_count * (0.65f - Mathf.Min(_diff01, 0.5f) * 0.4f - Mathf.Max(_diff01 - 0.5f, 0f) * 0.14f)), _ratio_data.innocents.min_wanted), 0.7f - Mathf.Min(_diff01, 0.5f) * 0.26f - Mathf.Max(_diff01 - 0.5f, 0f) * 0.3f));
		dictionary.Add(RoleClassifications.MEDDLER, (Mathf.Max(Mathf.RoundToInt((float)_address_count * Mathf.Min(_diff01, 0.5f) * 0.18f + Mathf.Max(_diff01 - 0.5f, 0f) * 0.1f), _ratio_data.meddlers.min_wanted), 0.1f + Mathf.Min(_diff01, 0.5f) * 0.2f + Mathf.Max(_diff01 - 0.5f, 0f) * 0.08f));
		dictionary.Add(RoleClassifications.UNDERLING, (Mathf.Max(Mathf.RoundToInt((float)_address_count * (0.1f + _diff01 * 0.1f)), _ratio_data.underlings.min_wanted, (!(_diff01 > 0.2f)) ? 1 : 2), 0.2f + _diff01 * 0.06f));
		dictionary.Add(RoleClassifications.TRAITOR, (Mathf.Max(Mathf.RoundToInt((float)_address_count * (0f + Mathf.Max(_diff01 - 0.5f, 0f) * 0.12f)), _ratio_data.traitors.min_wanted), 0f + Mathf.Max(_diff01 - 0.5f, 0f) * 0.16f));
		return dictionary;
	}

	public static Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> getEmpty4x4Board()
	{
		return getEmptyBoard(new Vector2Int(4, 4));
	}

	public static Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> getEmptyBoard(Vector2Int _size)
	{
		Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> dictionary = new Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>>();
		for (int i = 0; i < _size.y; i++)
		{
			for (int j = 0; j < _size.x; j++)
			{
				dictionary[new Vector2Int(j, i)] = new Maybe<Either<RoleData, LocationData>>();
			}
		}
		return dictionary;
	}

	public static Dictionary<RoleClassifications, int> getEmptyRatio()
	{
		return new Dictionary<RoleClassifications, int>
		{
			{
				RoleClassifications.INNOCENT,
				0
			},
			{
				RoleClassifications.MEDDLER,
				0
			},
			{
				RoleClassifications.UNDERLING,
				0
			},
			{
				RoleClassifications.TRAITOR,
				0
			}
		};
	}

	public static CasinoCardInfo.Suit toSuit(this RoleClassifications _class)
	{
		return _class switch
		{
			RoleClassifications.INNOCENT => CasinoCardInfo.Suit.CLUBS, 
			RoleClassifications.MEDDLER => CasinoCardInfo.Suit.DIAMONDS, 
			RoleClassifications.UNDERLING => CasinoCardInfo.Suit.HEARTS, 
			RoleClassifications.TRAITOR => CasinoCardInfo.Suit.SPADES, 
			_ => throw new ArgumentException($"No suit set up for classification {_class}!"), 
		};
	}

	public static RoleClassifications toClass(this CasinoCardInfo.Suit _suit)
	{
		return _suit switch
		{
			CasinoCardInfo.Suit.CLUBS => RoleClassifications.INNOCENT, 
			CasinoCardInfo.Suit.DIAMONDS => RoleClassifications.MEDDLER, 
			CasinoCardInfo.Suit.HEARTS => RoleClassifications.UNDERLING, 
			CasinoCardInfo.Suit.SPADES => RoleClassifications.TRAITOR, 
			_ => throw new ArgumentException($"No classification set up for suit {_suit}!"), 
		};
	}

	public static List<CasinoCard> getCards(List<CasinoCard> _drawn, Maybe<CasinoCardInfo.Suit> _suit)
	{
		if (!_suit.is_some)
		{
			return getCards(_drawn);
		}
		return getCards(_drawn, _suit.value);
	}

	public static List<CasinoCard> getCards(List<CasinoCard> _drawn, CasinoCardInfo.Suit _suit)
	{
		return getCards((CasinoCardInfo _i) => !_drawn.Any((CasinoCard _c) => _c.info == _i), _suit);
	}

	public static List<CasinoCard> getCards(List<CasinoCard> _drawn)
	{
		return getCards((CasinoCardInfo _i) => !_drawn.Any((CasinoCard _c) => _c.info == _i), CasinoCardInfo.Suit.DIAMONDS, CasinoCardInfo.Suit.CLUBS, CasinoCardInfo.Suit.HEARTS, CasinoCardInfo.Suit.SPADES);
	}

	public static List<CasinoCard> getCards(Func<CasinoCardInfo, bool> _valid_card, params CasinoCardInfo.Suit[] _suits)
	{
		List<CasinoCard> list = new List<CasinoCard>();
		foreach (CasinoCardInfo.Suit suit in _suits)
		{
			for (int j = 0; j < 13; j++)
			{
				CasinoCardInfo casinoCardInfo = new CasinoCardInfo(j + 1, suit);
				if (_valid_card(casinoCardInfo))
				{
					list.Add(new CasinoCard(casinoCardInfo));
				}
			}
		}
		return list;
	}
}
