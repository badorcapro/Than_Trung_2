using System;
using GRGLib.PropertyDrawers;
using UnityEngine;

[Serializable]
public struct KeywordInfoBuilder
{
	public KeywordType keyword_type;

	[SerializeField]
	[ConditionalField("keyword_type", new object[]
	{
		KeywordType.KEYWORD,
		false
	})]
	private Keywords keyword;

	[SerializeField]
	[ConditionalField("keyword_type", new object[]
	{
		KeywordType.ALIGNMENT,
		false
	})]
	private Alignments alignment;

	[SerializeField]
	[ConditionalField("keyword_type", new object[]
	{
		KeywordType.ROLE_CLASSIFICATION,
		false
	})]
	private RoleClassifications classification;

	[SerializeField]
	[ConditionalField("keyword_type", new object[]
	{
		KeywordType.ROLE,
		false
	})]
	private Roles role;

	[SerializeField]
	[ConditionalField("keyword_type", new object[]
	{
		KeywordType.CASE_QUIRK,
		false
	})]
	private CaseQuirks quirk;

	[SerializeField]
	[ConditionalField("keyword_type", new object[]
	{
		KeywordType.LOCATION,
		false
	})]
	private LocationTypes location;

	[SerializeField]
	[ConditionalField("keyword_type", new object[]
	{
		KeywordType.REPUTATION_STATUS,
		false
	})]
	private ReputationStatus reputation_status;

	[SerializeField]
	[ConditionalField("keyword_type", new object[]
	{
		KeywordType.BA_ITEM_COLOURS,
		false
	})]
	private BackAlleysItemColour item_colour;

	public KeywordInfo getKeyword()
	{
		return keyword_type switch
		{
			KeywordType.KEYWORD => new KeywordInfo(keyword), 
			KeywordType.ALIGNMENT => new KeywordInfo(alignment), 
			KeywordType.ROLE_CLASSIFICATION => new KeywordInfo(classification), 
			KeywordType.ROLE => new KeywordInfo(role), 
			KeywordType.CASE_QUIRK => new KeywordInfo(quirk), 
			KeywordType.LOCATION => new KeywordInfo(location), 
			KeywordType.REPUTATION_STATUS => new KeywordInfo(reputation_status), 
			KeywordType.BA_ITEM_COLOURS => new KeywordInfo(item_colour), 
			_ => throw new ArgumentException($"No to string set up for keyword type {keyword_type}!"), 
		};
	}
}
