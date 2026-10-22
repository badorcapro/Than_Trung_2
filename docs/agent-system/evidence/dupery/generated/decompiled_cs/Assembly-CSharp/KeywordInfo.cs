using System;
using GRGLib.Extensions;
using GRGLib.PropertyDrawers;

[Serializable]
public struct KeywordInfo
{
	[ReadOnly]
	public int enum_value;

	public KeywordType keyword_type;

	public bool has_description => keyword_type.equalToAny(KeywordType.KEYWORD, KeywordType.ALIGNMENT, KeywordType.ROLE_CLASSIFICATION, KeywordType.LOCATION);

	public string description => keyword_type switch
	{
		KeywordType.KEYWORD => GameHandler.Text.getDescription((Keywords)enum_value), 
		KeywordType.ALIGNMENT => GameHandler.Text.getDescription((Alignments)enum_value), 
		KeywordType.ROLE_CLASSIFICATION => GameHandler.Text.getDescription((RoleClassifications)enum_value), 
		KeywordType.LOCATION => ((LocationTypes)enum_value).createEmptyLocation().description, 
		KeywordType.ROLE => ((Roles)enum_value).createEmptyRole().description, 
		_ => throw new ArgumentException($"No description set up for keyword type {keyword_type}!"), 
	};

	public KeywordInfo(int _value, KeywordType _type)
	{
		enum_value = _value;
		keyword_type = _type;
	}

	public KeywordInfo(Keywords _word)
	{
		enum_value = (int)_word;
		keyword_type = KeywordType.KEYWORD;
	}

	public KeywordInfo(Alignments _word)
	{
		enum_value = (int)_word;
		keyword_type = KeywordType.ALIGNMENT;
	}

	public KeywordInfo(RoleClassifications _word)
	{
		enum_value = (int)_word;
		keyword_type = KeywordType.ROLE_CLASSIFICATION;
	}

	public KeywordInfo(Roles _word)
	{
		enum_value = (int)_word;
		keyword_type = KeywordType.ROLE;
	}

	public KeywordInfo(CaseQuirks _word)
	{
		enum_value = (int)_word;
		keyword_type = KeywordType.CASE_QUIRK;
	}

	public KeywordInfo(LocationTypes _word)
	{
		enum_value = (int)_word;
		keyword_type = KeywordType.LOCATION;
	}

	public KeywordInfo(ReputationStatus _word)
	{
		enum_value = (int)_word;
		keyword_type = KeywordType.REPUTATION_STATUS;
	}

	public KeywordInfo(BackAlleysItemColour _word)
	{
		enum_value = (int)_word;
		keyword_type = KeywordType.BA_ITEM_COLOURS;
	}

	public string toString()
	{
		return keyword_type switch
		{
			KeywordType.KEYWORD => ((Keywords)enum_value).toString(), 
			KeywordType.ALIGNMENT => ((Alignments)enum_value).toString(), 
			KeywordType.ROLE_CLASSIFICATION => ((RoleClassifications)enum_value).toString(), 
			KeywordType.ROLE => ((Roles)enum_value).toString(), 
			KeywordType.CASE_QUIRK => ((CaseQuirks)enum_value).toString(), 
			KeywordType.LOCATION => ((LocationTypes)enum_value).toString(), 
			KeywordType.REPUTATION_STATUS => ((ReputationStatus)enum_value).toString(), 
			KeywordType.BA_ITEM_COLOURS => ((BackAlleysItemColour)enum_value).toString(), 
			_ => throw new ArgumentException($"No to string set up for keyword type {keyword_type}!"), 
		};
	}

	public string toStringCap()
	{
		return keyword_type switch
		{
			KeywordType.KEYWORD => ((Keywords)enum_value).toStringCap(), 
			KeywordType.ALIGNMENT => ((Alignments)enum_value).toStringCap(), 
			KeywordType.REPUTATION_STATUS => ((ReputationStatus)enum_value).toStringCap(), 
			_ => toString(), 
		};
	}

	public string toStringNoLinkTitle()
	{
		return keyword_type switch
		{
			KeywordType.KEYWORD => GameHandler.Text.getKeywordTitle((Keywords)enum_value), 
			KeywordType.ALIGNMENT => GameHandler.Text.getKeywordColouredCap((Alignments)enum_value), 
			KeywordType.ROLE_CLASSIFICATION => GameHandler.Text.getKeywordColoured((RoleClassifications)enum_value), 
			KeywordType.LOCATION => GameHandler.Text.getLocationName((LocationTypes)enum_value), 
			KeywordType.ROLE => ((Roles)enum_value).createEmptyRole().name, 
			_ => throw new ArgumentException($"No to string set up for keyword type {keyword_type}!"), 
		};
	}

	public string asKeyword(string _string)
	{
		return keyword_type switch
		{
			KeywordType.KEYWORD => _string.asKeyword((Keywords)enum_value), 
			KeywordType.ROLE_CLASSIFICATION => _string.asKeyword((RoleClassifications)enum_value), 
			KeywordType.ROLE => _string.asKeyword((Roles)enum_value), 
			_ => throw new ArgumentException($"No as keyword set up for keyword type {keyword_type}!"), 
		};
	}
}
