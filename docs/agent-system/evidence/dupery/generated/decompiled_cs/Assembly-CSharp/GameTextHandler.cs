using System;
using System.Collections.Generic;
using GRGLib.Extensions.String;
using GRGLib.Maybe;
using GRGLocalisation;
using Localisation;
using UnityEngine;

[Serializable]
public class GameTextHandler : IAmLocalised
{
	[SerializeField]
	private RoleVisualDataSO roles_visual_data;

	[SerializeField]
	private CaseQuirksVisualDataSO quirks_visual_data;

	[SerializeField]
	private BackAlleysItemVisualDataSO item_visual_data;

	[SerializeField]
	private Color neutral_keyword_colour;

	[SerializeField]
	private Color red_keyword_colour;

	[SerializeField]
	private Color purple_keyword_colour;

	private AssetKey localisation_asset => LocalisationHelper.general_case_asset;

	private string loc_quirk_generic_desc => "CaseQuirks_GeneralDescription";

	public string giveRichText(string _word, Roles _role)
	{
		return _word.bold().link(_role.getHoverLink());
	}

	public string giveLocMarker(string _word, Roles _role)
	{
		return _word.sandwichString($"{{R{(int)_role}}}", "{/R}");
	}

	public string getRoleNameColoured(RoleData _role)
	{
		return _role.name.sandwichWithColour(roles_visual_data[_role.role.getClassificationFromRoleType()].role_text_colour).bold().link(_role.role.getHoverLink());
	}

	public string asKeyword(string _word, Roles _role)
	{
		return _word.sandwichWithColour(roles_visual_data[_role.getClassificationFromRoleType()].role_text_colour).bold();
	}

	public string getQuirkNameColoured(CaseQuirks _quirk)
	{
		return _quirk.createQuirk().name.colour(quirks_visual_data.text_colour).bold();
	}

	public string giveRichText(string _word, LocationTypes _loc)
	{
		return _word.bold().link(_loc.getHoverLink());
	}

	public string giveLocMarker(string _word, LocationTypes _loc)
	{
		return _word.sandwichString($"{{L{(int)_loc}}}", "{/L}");
	}

	public string getLocationName(LocationData _location)
	{
		return _location.name;
	}

	public string getLocationName(LocationTypes _location)
	{
		return _location.createEmptyLocation().name;
	}

	public string getLocationNameTagged(LocationTypes _loc)
	{
		return giveRichText(getLocationName(_loc), _loc);
	}

	public string giveRichText(string _word, Alignments _align)
	{
		return _word.sandwichWithColour(getAlignmentColour(_align)).bold().link(_align.getHoverLink());
	}

	public string giveLocMarker(string _word, Alignments _align)
	{
		return _word.sandwichString($"{{A{(int)_align}}}", "{/A}");
	}

	public string getKeyword(Alignments _alignment)
	{
		return giveRichText(getKeywordAlone(_alignment), _alignment);
	}

	public string getKeywordCap(Alignments _alignment)
	{
		return giveRichText(getKeywordAloneCap(_alignment), _alignment);
	}

	public string getKeywordColouredCap(Alignments _alignment)
	{
		return getKeywordAloneCap(_alignment).sandwichWithColour(getAlignmentColour(_alignment));
	}

	public string getKeywordColoured(Alignments _alignment)
	{
		return getKeywordAlone(_alignment).sandwichWithColour(getAlignmentColour(_alignment));
	}

	public string getKeywordAloneCap(Alignments _alignment)
	{
		return getKeywordAlone(_alignment).firstToUpper();
	}

	public string getKeywordAlone(Alignments _alignment)
	{
		return checkTranslation(_alignment, getEnglishKeyword, LocalisationHelper.getLocNameKey);
	}

	public string getEnglishKeyword(Alignments _alignment)
	{
		return _alignment switch
		{
			Alignments.GOOD => "good", 
			Alignments.EVIL => "evil", 
			_ => throw new ArgumentException($"No keyword string set for alignment {_alignment}!"), 
		};
	}

	private Color getAlignmentColour(Alignments _alignment)
	{
		return _alignment switch
		{
			Alignments.GOOD => roles_visual_data[RoleClassifications.INNOCENT].role_text_colour, 
			Alignments.EVIL => roles_visual_data[RoleClassifications.UNDERLING].role_text_colour, 
			_ => throw new ArgumentException($"No colour string set for alignment {_alignment}!"), 
		};
	}

	public string giveRichText(string _word, RoleClassifications _class)
	{
		return _word.sandwichWithColour(roles_visual_data[_class].role_text_colour).bold().link(_class.getHoverLink());
	}

	public string giveLocMarker(string _word, RoleClassifications _class)
	{
		return _word.sandwichString($"{{C{(int)_class}}}", "{/C}");
	}

	public string asKeyword(RoleClassifications _class, string _word)
	{
		return giveRichText(_word, _class);
	}

	public string getKeyword(RoleClassifications _class)
	{
		return giveRichText(getKeywordAlone(_class), _class);
	}

	public string getKeywordColoured(RoleClassifications _class)
	{
		return getKeywordAlone(_class).sandwichWithColour(roles_visual_data[_class].role_text_colour);
	}

	public string getKeywordAlone(RoleClassifications _class)
	{
		return checkTranslation(_class, getEnglishKeyword, LocalisationHelper.getLocNameKey);
	}

	private string getEnglishKeyword(RoleClassifications _class)
	{
		return _class switch
		{
			RoleClassifications.INNOCENT => "Innocent", 
			RoleClassifications.MEDDLER => "Meddler", 
			RoleClassifications.UNDERLING => "Underling", 
			RoleClassifications.TRAITOR => "Traitor", 
			_ => throw new ArgumentException($"No keyword string set for classification {_class}!"), 
		};
	}

	public string getKeyword(ReputationStatus _rep)
	{
		return getKeywordAlone(_rep).bold();
	}

	public string getKeywordCap(ReputationStatus _rep)
	{
		return getKeywordAlone(_rep).firstToUpper().bold();
	}

	public string getKeywordAlone(ReputationStatus _rep)
	{
		return checkTranslation(_rep, getEnglishKeyword, LocalisationHelper.getLocNameKey);
	}

	private string getEnglishKeyword(ReputationStatus _rep)
	{
		return _rep switch
		{
			ReputationStatus.POOR => "poor", 
			ReputationStatus.NEUTRAL => "good", 
			ReputationStatus.EXCEPTIONAL => "excellent", 
			_ => throw new ArgumentException($"No keyword string set for reputation status {_rep}!"), 
		};
	}

	public string asKeyword(BackAlleysItemColour _colour, string _word)
	{
		return _word.sandwichWithColour(item_visual_data[_colour]).bold();
	}

	public string getKeyword(BackAlleysItemColour _colour)
	{
		return getKeywordColoured(_colour).bold();
	}

	public string getKeywordColoured(BackAlleysItemColour _colour)
	{
		return getKeywordAlone(_colour).sandwichWithColour(item_visual_data[_colour]);
	}

	public string getKeywordAlone(BackAlleysItemColour _colour)
	{
		return checkTranslation(_colour, getEnglishKeyword, LocalisationHelper.getLocNameKey);
	}

	private string getEnglishKeyword(BackAlleysItemColour _colour)
	{
		return _colour switch
		{
			BackAlleysItemColour.LAWFUL => "Lawful", 
			BackAlleysItemColour.MISCHEVIOUS => "Mischevious", 
			BackAlleysItemColour.ILLEGAL => "Illegal", 
			BackAlleysItemColour.BLACKMARKET => "Blackmarket", 
			_ => throw new ArgumentException($"No keyword string set for classification {_colour}!"), 
		};
	}

	public string giveRichText(string _word, Keywords _keyword)
	{
		return _word.sandwitchWithColourIfSome(getKeywordColour(_keyword)).bold().link(_keyword.getHoverLink());
	}

	public string giveLocMarker(string _word, Keywords _keyword)
	{
		return _word.sandwichString($"{{K{(int)_keyword}}}", "{/K}");
	}

	public string asKeyword(Keywords _keyword, string _word)
	{
		return giveRichText(_word, _keyword);
	}

	public string getKeyword(Keywords _keyword)
	{
		return giveRichText(getKeywordWithSymbol(_keyword), _keyword);
	}

	public string getKeywordCap(Keywords _keyword)
	{
		return giveRichText(getKeywordWithSymbolCap(_keyword), _keyword);
	}

	public string getKeywordTitle(Keywords _keyword)
	{
		return getKeywordAloneCap(_keyword).sandwitchWithColourIfSome(getKeywordColour(_keyword)).bold();
	}

	public string getKeywordColouredCap(Keywords _keyword)
	{
		return getKeywordWithSymbolCap(_keyword).sandwitchWithColourIfSome(getKeywordColour(_keyword));
	}

	public string getKeywordColoured(Keywords _keyword)
	{
		return getKeywordWithSymbol(_keyword).sandwitchWithColourIfSome(getKeywordColour(_keyword));
	}

	public string getKeywordWithSymbolCap(Keywords _keyword)
	{
		return getKeywordSymbol(_keyword) + getKeywordAloneCap(_keyword);
	}

	public string getKeywordWithSymbol(Keywords _keyword)
	{
		return getKeywordSymbol(_keyword) + getKeywordAlone(_keyword);
	}

	public string getKeywordAloneCap(Keywords _keyword)
	{
		return getKeywordAlone(_keyword).firstToUpper();
	}

	public string getKeywordAlone(Keywords _keyword)
	{
		return checkTranslation(_keyword, getEnglishKeyword, LocalisationHelper.getLocNameKey);
	}

	private string getKeywordSymbol(Keywords _keyword, bool _space = true)
	{
		return _keyword switch
		{
			Keywords.CARDINALLY_ADJACENT => TextHelper.adjacent_sprite_link + (_space ? " " : ""), 
			Keywords.SURROUNDING => TextHelper.surrounding_sprite_link + (_space ? " " : ""), 
			Keywords.CA_NEIGHBOURS => TextHelper.adjacent_sprite_link + (_space ? " " : ""), 
			Keywords.S_NEIGHBOURS => TextHelper.surrounding_sprite_link + (_space ? " " : ""), 
			_ => "", 
		};
	}

	private string getEnglishKeyword(Keywords _keyword)
	{
		return _keyword switch
		{
			Keywords.ROLE => "role", 
			Keywords.TARGET => "target", 
			Keywords.BOARD => "board", 
			Keywords.ALIGNMENT => "alignment", 
			Keywords.REPUTATION => "reputation", 
			Keywords.REPUTATION_STATUS => "reputation status", 
			Keywords.ADDRESS => "address", 
			Keywords.LOCATION => "location", 
			Keywords.SUSPECT_LIST => "suspect list", 
			Keywords.CLASSIFICATION => "classification", 
			Keywords.TRUTHFUL => "truthful", 
			Keywords.QUIRK => "quirk", 
			Keywords.CASE => "case", 
			Keywords.ANNOUNCE => "announce", 
			Keywords.PRETEND => "pretend", 
			Keywords.LIE => "lie", 
			Keywords.TAINT => "taint", 
			Keywords.REVEAL => "reveal", 
			Keywords.TRANSFORM => "transform", 
			Keywords.INVESTIGATE => "investigate", 
			Keywords.UNINVESTIGATED => "uninvestigated", 
			Keywords.ARREST => "arrest", 
			Keywords.UNARRESTED => "unarrested", 
			Keywords.KILL => "kill", 
			Keywords.DEAD => "dead", 
			Keywords.ALIVE => "alive", 
			Keywords.OBSCURE => "obscure", 
			Keywords.SUSPECTED => "suspected", 
			Keywords.IN_PLAY => "in play", 
			Keywords.NOT_IN_PLAY => "not in play", 
			Keywords.ABILITY => "ability", 
			Keywords.APPEARANCE => "appearance", 
			Keywords.SELF_CONFIRM => "self-confirm", 
			Keywords.CARDINALLY_ADJACENT => "adjacent", 
			Keywords.SURROUNDING => "surrounding", 
			Keywords.CA_NEIGHBOURS => "adjacent neighbours", 
			Keywords.S_NEIGHBOURS => "surrounding neighbours", 
			Keywords.STEPS => "steps", 
			Keywords.BOAT => "boat", 
			Keywords.FUEL => "fuel", 
			Keywords.HIDE => "hide", 
			Keywords.DREDGE => "dredge", 
			Keywords.CHIPS => "chips", 
			Keywords.CARD => "card", 
			Keywords.CARD_VALUE => "card value", 
			Keywords.CARD_SUIT => "card suit", 
			Keywords.JOKER => "Joker", 
			Keywords.FACE_CARD => "face card", 
			Keywords.SUIT_ASSOCIATION => "suit association", 
			Keywords.CREDITS => "credits", 
			Keywords.ITEM => "item", 
			Keywords.POCKET => "pocket", 
			Keywords.HOLD => "hold", 
			Keywords.HEALTH => "health", 
			Keywords.STEAL => "steal", 
			Keywords.LEAD => "lead", 
			Keywords.STAMP => "stamp", 
			Keywords.EVENT => "event", 
			Keywords.PRIME_SUSPECTS => "prime suspects", 
			_ => throw new ArgumentException($"No keyword set up for {_keyword}!"), 
		};
	}

	public Maybe<Color> getKeywordColour(Keywords _keyword)
	{
		return _keyword switch
		{
			Keywords.LIE => red_keyword_colour.maybe(), 
			Keywords.TAINT => purple_keyword_colour.maybe(), 
			_ => new Maybe<Color>(), 
		};
	}

	public string getKeywordsExaplanation(List<KeywordInfo> _keyword_info)
	{
		string text = "";
		for (int i = 0; i < _keyword_info.Count; i++)
		{
			if (_keyword_info[i].has_description)
			{
				text = text + "<size=115%>" + _keyword_info[i].toStringCap() + "</size>: " + _keyword_info[i].description + "\n\n";
			}
		}
		return text;
	}

	public string getQuirksDescription()
	{
		return localisation_asset.checkTranslation(loc_quirk_generic_desc, englishQuirksDescription);
	}

	private string englishQuirksDescription()
	{
		return "Case quirks are modifiers that change how certain cases play.";
	}

	public string getDescription(RoleClassifications _classification)
	{
		return checkTranslation(_classification, getDescriptionEnglish, LocalisationHelper.getLocDescriptionKey).checkKeywordLocMarkers();
	}

	private string getDescriptionEnglish(RoleClassifications _classification)
	{
		return _classification switch
		{
			RoleClassifications.INNOCENT => "Helpful " + TextHelper.goodRoles + " that tend to give invaluable information to solve the case.", 
			RoleClassifications.MEDDLER => "Unhelpful " + TextHelper.goodRoles + " that tend to muddy the waters and make solving the case trickier.", 
			RoleClassifications.UNDERLING => "The simple " + TextHelper.evilRoles + " that will often " + getKeyword(Keywords.LIE) + " and " + getKeyword(Keywords.PRETEND) + ".", 
			RoleClassifications.TRAITOR => "The worst of the worst. These " + TextHelper.evilRoles + " will make it much harder to solve the case.", 
			_ => throw new ArgumentException($"No keyword description set for classification {_classification}!"), 
		};
	}

	public string getDescription(Alignments _alignment)
	{
		return checkTranslation(_alignment, getDescriptionEnglish, LocalisationHelper.getLocDescriptionKey).checkKeywordLocMarkers();
	}

	public string getDescriptionEnglish(Alignments _alignment)
	{
		return _alignment switch
		{
			Alignments.GOOD => asKeyword(Keywords.ROLE, "Roles") + " that should not be arrested! " + getKeyword(RoleClassifications.INNOCENT) + " and " + getKeyword(RoleClassifications.MEDDLER) + " " + TextHelper.roles + " are " + getKeyword(Alignments.GOOD) + " unless they have been made " + getKeyword(Alignments.EVIL) + ".", 
			Alignments.EVIL => asKeyword(Keywords.ROLE, "Roles") + " that should be arrested! You win when all " + TextHelper.evilRoles + " are " + TextHelper.arrested + " or " + getKeyword(Keywords.DEAD) + ". " + getKeyword(RoleClassifications.UNDERLING) + " and " + getKeyword(RoleClassifications.TRAITOR) + " " + TextHelper.roles + " are " + getKeyword(Alignments.EVIL) + ".", 
			_ => throw new ArgumentException($"No keyword description set for alignment {_alignment}!"), 
		};
	}

	public string getDescription(Keywords _keyword)
	{
		return checkTranslation(_keyword, getDescriptionEnglish, LocalisationHelper.getLocDescriptionKey).checkKeywordLocMarkers();
	}

	public string getDescriptionEnglish(Keywords _keyword)
	{
		return _keyword switch
		{
			Keywords.ROLE => "A " + getKeyword(Keywords.ROLE) + " is a character that can appear on the " + getKeyword(Keywords.BOARD) + " and in the " + getKeyword(Keywords.SUSPECT_LIST) + ".", 
			Keywords.TARGET => "A " + getKeyword(Keywords.TARGET) + " is a " + getKeyword(Keywords.ROLE) + " that has been picked by another " + getKeyword(Keywords.ROLE) + ".", 
			Keywords.BOARD => "The " + getKeyword(Keywords.BOARD) + " is the grid where all " + getKeyword(Keywords.IN_PLAY) + " " + asKeyword(Keywords.ROLE, "roles") + " and " + asKeyword(Keywords.LOCATION, "locations") + " are.", 
			Keywords.ALIGNMENT => "A " + getKeyword(Keywords.ROLE) + "'s " + getKeyword(Keywords.ALIGNMENT) + " can be " + getKeyword(Alignments.GOOD) + " or " + getKeyword(Alignments.EVIL) + ". Your goal is to " + getKeyword(Keywords.ARREST) + " all " + TextHelper.evilRoles + ".", 
			Keywords.REPUTATION => "How the town sees you. By default you lose 2 " + getKeyword(Keywords.REPUTATION) + " when you " + getKeyword(Keywords.ARREST) + " a " + TextHelper.goodRole + ".", 
			Keywords.REPUTATION_STATUS => "Defined by your " + getKeyword(Keywords.REPUTATION) + ", it can be " + getKeyword(ReputationStatus.POOR) + ", " + getKeyword(ReputationStatus.NEUTRAL) + " or " + getKeyword(ReputationStatus.EXCEPTIONAL) + ".", 
			Keywords.ADDRESS => "Each " + TextHelper.inPlayRole + " has an " + getKeyword(Keywords.ADDRESS) + ". This is shown on their door or beside their icon.", 
			Keywords.LOCATION => asKeyword(Keywords.LOCATION, "Locations") + " are found on the " + getKeyword(Keywords.BOARD) + " and are used by certain " + TextHelper.roles + ".", 
			Keywords.SUSPECT_LIST => "The " + getKeyword(Keywords.SUSPECT_LIST) + " is a list of all " + TextHelper.roles + " that could be " + getKeyword(Keywords.IN_PLAY) + ".", 
			Keywords.CLASSIFICATION => "A " + asKeyword(Keywords.ROLE, "roles") + " " + getKeyword(Keywords.CLASSIFICATION) + " can be any of " + getKeyword(RoleClassifications.INNOCENT) + ", " + getKeyword(RoleClassifications.MEDDLER) + ", " + getKeyword(RoleClassifications.UNDERLING) + " or " + getKeyword(RoleClassifications.TRAITOR) + ". By default, " + getKeyword(RoleClassifications.INNOCENT) + " and " + TextHelper.meddlerRoles + " are " + getKeyword(Alignments.GOOD) + " and " + getKeyword(RoleClassifications.UNDERLING) + " and " + TextHelper.traitorRoles + " are " + Alignments.EVIL.toString() + ".", 
			Keywords.TRUTHFUL => "A " + getKeyword(Keywords.ROLE) + " is considered " + getKeyword(Keywords.TRUTHFUL) + " when they are not " + TextHelper.lyingOrTainted + ".", 
			Keywords.QUIRK => "A " + getKeyword(Keywords.QUIRK) + " is a special rule that augments how " + TextHelper.cases + " are played.", 
			Keywords.CASE => "Cases".asKeyword(Keywords.CASE) + " visualise the Syndicates crimes, allowing you, the detective, to " + getKeyword(Keywords.INVESTIGATE) + " " + TextHelper.roles + " and make " + TextHelper.arrests + ". Each solved " + getKeyword(Keywords.CASE) + " is another step towards the ultimate goal: Taking down the Syndicate!", 
			Keywords.ANNOUNCE => "The act of giving information. What a " + getKeyword(Keywords.ROLE) + " has " + asKeyword(Keywords.ANNOUNCE, "announced") + " is displayed below their name when " + TextHelper.investigated + ".", 
			Keywords.PRETEND => "When a " + getKeyword(Keywords.ROLE) + " is " + TextHelper.pretending + " to be another " + getKeyword(Keywords.ROLE) + ", it appears as that " + getKeyword(Keywords.ROLE) + " when " + TextHelper.investigated + " and, unless they are " + TextHelper.lying + ", will do everything as that " + getKeyword(Keywords.ROLE) + " would do.", 
			Keywords.LIE => "When a " + getKeyword(Keywords.ROLE) + " is " + TextHelper.lying + ", the information they give will be wrong. Abilities used will function incorrectly.", 
			Keywords.TAINT => "When a " + getKeyword(Keywords.ROLE) + " is " + TextHelper.tainted + ", they are being forced to " + getKeyword(Keywords.LIE) + " and will give wrong information.", 
			Keywords.REVEAL => "When a " + getKeyword(Keywords.ROLE) + " is " + TextHelper.revealed + ", they stop " + TextHelper.pretending + " to be another " + getKeyword(Keywords.ROLE) + " and show their true self.", 
			Keywords.TRANSFORM => "When a " + getKeyword(Keywords.ROLE) + " is " + asKeyword(Keywords.TRANSFORM, "transformed") + " into another " + getKeyword(Keywords.ROLE) + ", they become that " + getKeyword(Keywords.ROLE) + ". " + asKeyword(Keywords.TRANSFORM, "Transformations") + " do not update the ratio.", 
			Keywords.INVESTIGATE => "Opening a door to see who is behind it.", 
			Keywords.UNINVESTIGATED => "A " + getKeyword(Keywords.ROLE) + " that has not been " + TextHelper.investigated + " yet. Their door is still closed.", 
			Keywords.ARREST => "Your main way of stopping " + getKeyword(Alignments.EVIL) + "! Putting a " + getKeyword(Keywords.ROLE) + " behind bars also " + TextHelper.reveals + " them.", 
			Keywords.UNARRESTED => "A " + getKeyword(Keywords.ROLE) + " that has not been " + TextHelper.arrested + " yet.", 
			Keywords.KILL => "Makes a " + getKeyword(Keywords.ROLE) + " " + getKeyword(Keywords.DEAD) + ". " + getKeywordCap(Keywords.DEAD) + " " + TextHelper.roles + " do not " + getKeyword(Keywords.REVEAL) + " and information they may have " + asKeyword(Keywords.ANNOUNCE, "announced") + " is lost.", 
			Keywords.DEAD => "A " + getKeyword(Keywords.ROLE) + " that has been " + TextHelper.killed + ". " + getKeywordCap(Keywords.DEAD) + " " + TextHelper.roles + " do not " + getKeyword(Keywords.REVEAL) + " and information they may have " + asKeyword(Keywords.ANNOUNCE, "announced") + " is lost.", 
			Keywords.ALIVE => "A " + getKeyword(Keywords.ROLE) + " that is not " + getKeyword(Keywords.DEAD) + ".", 
			Keywords.OBSCURE => "An " + TextHelper.obscured + " " + getKeyword(Keywords.ROLE) + "'s icon, name and information is hidden except for numbers which stay visible.", 
			Keywords.SUSPECTED => "A " + getKeyword(Keywords.ROLE) + " that is on the " + getKeyword(Keywords.SUSPECT_LIST) + ". Only " + TextHelper.suspectedRoles + " can be " + getKeyword(Keywords.IN_PLAY) + ".", 
			Keywords.IN_PLAY => "A " + getKeyword(Keywords.ROLE) + " that is on the " + getKeyword(Keywords.BOARD) + ".", 
			Keywords.NOT_IN_PLAY => "A " + getKeyword(Keywords.ROLE) + " that is not on the " + getKeyword(Keywords.BOARD) + ".", 
			Keywords.ABILITY => "A " + getKeyword(Keywords.ROLE) + "'s one-use skill that requires your input. These are displayed by a blue hand.", 
			Keywords.APPEARANCE => "The " + getKeyword(Keywords.ROLE) + " that is shown when " + TextHelper.investigated + ".", 
			Keywords.SELF_CONFIRM => "A " + getKeyword(Keywords.ROLE) + " that can prove its own innocence. Multiple self confirm " + TextHelper.roles + " cannot be " + getKeyword(Keywords.IN_PLAY) + " at once.", 
			Keywords.CARDINALLY_ADJACENT => "Something which is " + getKeyword(Keywords.CARDINALLY_ADJACENT) + " is directly north, east, south or west.", 
			Keywords.SURROUNDING => "Something which is " + getKeyword(Keywords.SURROUNDING) + " is anywhere within the 8 tiles around that position.", 
			Keywords.CA_NEIGHBOURS => "An " + TextHelper.adjacentNeighbourNoSymbol + " is a " + getKeyword(Keywords.ROLE) + " that is " + getKeyword(Keywords.CARDINALLY_ADJACENT) + " to another " + getKeyword(Keywords.ROLE) + ". In other words, it is directly north, east, south or west.", 
			Keywords.S_NEIGHBOURS => "A " + TextHelper.surroundingNeighbourNoSymbol + " is a " + getKeyword(Keywords.ROLE) + " that is " + getKeyword(Keywords.SURROUNDING) + " another " + getKeyword(Keywords.ROLE) + ". In other words, it is anywhere within the 8 tiles around that " + getKeyword(Keywords.ROLE) + ".", 
			Keywords.STEPS => "A " + asKeyword(Keywords.STEPS, "step") + " is a movement from one tile to an " + getKeyword(Keywords.CARDINALLY_ADJACENT) + " tile.", 
			Keywords.BOAT => "The " + Keywords.BOAT.toString() + " is unique to the Docks region. You can move it around by going into 'Navigate' mode with the lever. Moving the boat around costs " + Keywords.FUEL.toString() + ". In this region, to " + Keywords.ARREST.toString() + " a " + Keywords.ROLE.toString() + ", you must first move the " + Keywords.BOAT.toString() + " onto the " + Keywords.ROLE.toString() + " you wish to " + Keywords.ARREST.toString() + ".", 
			Keywords.FUEL => Keywords.FUEL.toString() + " is used whenever you move the " + Keywords.BOAT.toString() + ". By default, moving the " + getKeyword(Keywords.BOAT) + " costs 1 " + getKeyword(Keywords.FUEL) + " per " + asKeyword(Keywords.STEPS, "step") + " moved plus 1 " + getKeyword(Keywords.FUEL) + " to start the engine.", 
			Keywords.HIDE => "A " + TextHelper.hiddenRole + " does not appear until they are " + TextHelper.dredged + ". This happens by default when the " + Keywords.BOAT.toString() + " is moved onto them. They still have an " + Keywords.ADDRESS.toString() + " and although you cannot initially see them, all other " + TextHelper.roles + " can.", 
			Keywords.DREDGE => "Dredging".asKeyword(Keywords.DREDGE) + " a " + TextHelper.hiddenRole + " makes them appear on the " + Keywords.BOARD.toString() + ". By default, when the " + getKeyword(Keywords.BOAT) + " is moved onto a " + TextHelper.hiddenRole + ", they are automatically " + TextHelper.dredged + ".", 
			Keywords.CHIPS => Keywords.CHIPS.toStringCap() + " are used whenever you " + getKeyword(Keywords.INVESTIGATE) + " a " + getKeyword(Keywords.ROLE) + " or when you " + getKeyword(Keywords.ARREST) + " a " + TextHelper.goodRole + ".", 
			Keywords.CARD => asKeyword(Keywords.CARD, "Cards") + " are found in and are unique to the Casino region. Many " + TextHelper.roles + " use " + asKeyword(Keywords.CARD, "cards") + " as part of their " + TextHelper.abilities + ".", 
			Keywords.CARD_VALUE => "A " + TextHelper.cardsValue + " is the number on the " + getKeyword(Keywords.CARD) + ". This can be any number between 1 (Ace) and 10 as well " + TextHelper.jack_with_link + ", " + TextHelper.queen_with_link + " or " + TextHelper.king_with_link + ".", 
			Keywords.CARD_SUIT => "A " + TextHelper.cardsSuit + " can be either Hearts, Diamonds, Clubs or Spades.", 
			Keywords.JOKER => "A " + getKeyword(Keywords.JOKER) + " is a " + getKeyword(Keywords.CARD) + " that cannot be drawn naturally. Its " + TextHelper.value + " and " + TextHelper.suit + " are random.", 
			Keywords.FACE_CARD => "A " + getKeyword(Keywords.FACE_CARD) + " is a " + getKeyword(Keywords.CARD) + " whose " + TextHelper.value + " is either " + TextHelper.jack_with_link + ", " + TextHelper.queen_with_link + " or " + TextHelper.king_with_link + ".", 
			Keywords.SUIT_ASSOCIATION => "Each " + TextHelper.suit + " is associated to a " + getKeyword(Keywords.CLASSIFICATION) + ".\nClubs are associated with " + TextHelper.innocents + ".\nDiamonds are associated with " + TextHelper.meddlers + ".\nHearts are associated with " + TextHelper.underlings + ".\nSpades are associated with " + TextHelper.traitors + ".", 
			Keywords.CREDITS => Keywords.CREDITS.toStringCap() + " are gained by solving " + getKeyword(Keywords.CASE) + ". They can be used to purchase " + TextHelper.items + " in the shop between cases.", 
			Keywords.ITEM => "Items".asKeyword(Keywords.ITEM) + " can be used to help you solve cases. They can be passive, having a benefit while you " + getKeyword(Keywords.HOLD) + " them, or active, having a benefit when used in a case.", 
			Keywords.POCKET => "A " + getKeyword(Keywords.POCKET) + " is where " + TextHelper.items + " are " + TextHelper.held + ". By default, you have 4 " + TextHelper.pockets + ".", 
			Keywords.HOLD => "A " + TextHelper.heldItem + " is an " + Keywords.ITEM.toString() + " that you own and have in one of your " + TextHelper.pockets + ". If it is an active " + getKeyword(Keywords.ITEM) + ", it can be used, and if it is a passive " + getKeyword(Keywords.ITEM) + ", you will benefit of its effects.", 
			Keywords.HEALTH => "In the Back Alleys, your " + getKeyword(Keywords.HEALTH) + " are your lives. You will be fired if you ever have 0 " + getKeyword(Keywords.HEALTH) + ". By default, you lose 1 " + getKeyword(Keywords.HEALTH) + " each time you " + getKeyword(Keywords.ARREST) + " a " + TextHelper.goodRole + ".", 
			Keywords.STEAL => "In the Back Alleys, certain " + TextHelper.roles + " can " + getKeyword(Keywords.STEAL) + " " + TextHelper.items + ". A " + TextHelper.stolen + " " + getKeyword(Keywords.ITEM) + " can be regained by " + TextHelper.arresting + " the " + getKeyword(Keywords.ROLE) + " that " + TextHelper.stole + " the " + getKeyword(Keywords.ITEM) + ".", 
			Keywords.LEAD => "A " + getKeyword(Keywords.LEAD) + " is a collection of " + TextHelper.cases + " that share " + getKeyword(Keywords.PRIME_SUSPECTS) + " and must be completed in order to catch the Syndicate!", 
			Keywords.STAMP => "A " + getKeyword(Keywords.STAMP) + " is a marker on a " + getKeyword(Keywords.LEAD) + " that detonates some kind of change based on the " + getKeyword(Keywords.EVENT) + " it was gained from.", 
			Keywords.EVENT => "Events".asKeyword(Keywords.EVENT) + " allow you to alter the remaining " + TextHelper.cases + " left in a " + getKeyword(Keywords.LEAD) + " through the use of " + TextHelper.stamps + ".", 
			Keywords.PRIME_SUSPECTS => "Prime Suspects".asKeyword(Keywords.PRIME_SUSPECTS) + " are a set of " + TextHelper.roles + " that will be " + getKeyword(Keywords.SUSPECTED) + " in every " + getKeyword(Keywords.CASE) + " of a " + getKeyword(Keywords.LEAD) + ".", 
			_ => throw new ArgumentException($"Descripotion for keyword {_keyword} is not set up!"), 
		};
	}

	private string checkTranslation<T>(T _enum_val, Func<T, string> _english, Func<T, string> _loc_key) where T : Enum
	{
		if (GRGLocalisationHandler.needs_translation)
		{
			string _result = "";
			if (GRGLocalisationHandler.instance.translate(localisation_asset, _loc_key(_enum_val), out _result))
			{
				return _result;
			}
		}
		return _english(_enum_val);
	}
}
