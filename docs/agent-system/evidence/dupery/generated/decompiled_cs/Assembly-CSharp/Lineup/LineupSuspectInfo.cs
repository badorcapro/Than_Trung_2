using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions;
using GRGLib.Generic;
using UnityEngine;

namespace Lineup;

public class LineupSuspectInfo
{
	public enum ClueConformType
	{
		CONFORM_ALL,
		CONFORM_NONE,
		CONFORM_SOME,
		RANDOM_NOT_ALL
	}

	public List<LineupSuspect.SuspectElements> suspect_elements;

	public bool male;

	public bool has_scar;

	public bool has_hair;

	public bool has_hat;

	public bool has_face_object;

	public bool has_glasses;

	public bool has_facial_hair;

	public bool has_earing;

	public int age;

	public int height_index;

	public int first_name_index;

	public int second_name_index;

	public LineupSuspectInfo(System.Random _rng, List<LineupClue> _clues, ClueConformType _conform)
	{
		LineupSuspectInfo lineupSuspectInfo = this;
		if (_conform == ClueConformType.CONFORM_NONE)
		{
			male = !_clues.getDataFromClueOrRandom(ClueElementTypes.GENDER, _rng, ClueConformType.CONFORM_ALL);
			has_hair = !_clues.getDataFromClueOrRandom(ClueElementTypes.HAIR_OR_HAT, _rng, ClueConformType.CONFORM_ALL);
			has_glasses = !_clues.getDataFromClueOrRandom(ClueElementTypes.GLASSES, _rng, ClueConformType.CONFORM_ALL);
			has_facial_hair = !_clues.getDataFromClueOrRandom(ClueElementTypes.FACIAL_HAIR, _rng, ClueConformType.CONFORM_ALL);
			has_earing = !_clues.getDataFromClueOrRandom(ClueElementTypes.EARING, _rng, ClueConformType.CONFORM_ALL);
			age = _clues.getNoneConformingData(ClueElementTypes.AGE, _rng, new MinMaxInt(21, 46));
			height_index = _clues.getNoneConformingData(ClueElementTypes.HEIGHT, _rng, new MinMaxInt(0, 12));
			(int, int) nameDataFromClueOrRandom = _clues.getNameDataFromClueOrRandom(_rng, male, ClueConformType.RANDOM_NOT_ALL);
			(first_name_index, _) = nameDataFromClueOrRandom;
			(second_name_index, _) = nameDataFromClueOrRandom;
		}
		else
		{
			male = _clues.getDataFromClueOrRandom(ClueElementTypes.GENDER, _rng, _conform);
			has_hair = _clues.getDataFromClueOrRandom(ClueElementTypes.HAIR_OR_HAT, _rng, _conform);
			has_glasses = _clues.getDataFromClueOrRandom(ClueElementTypes.GLASSES, _rng, _conform);
			has_facial_hair = _clues.getDataFromClueOrRandom(ClueElementTypes.FACIAL_HAIR, _rng, _conform);
			has_earing = _clues.getDataFromClueOrRandom(ClueElementTypes.EARING, _rng, _conform);
			age = _clues.getDataFromClueOrRandom(ClueElementTypes.AGE, _rng, new MinMaxInt(21, 46), _conform);
			height_index = _clues.getDataFromClueOrRandom(ClueElementTypes.HEIGHT, _rng, new MinMaxInt(0, 12), _conform);
			(first_name_index, second_name_index) = _clues.getNameDataFromClueOrRandom(_rng, male, _conform);
			if (_conform.equalToAny(ClueConformType.CONFORM_SOME, ClueConformType.RANDOM_NOT_ALL) && _clues.All((LineupClue _c) => _c.conforms(lineupSuspectInfo)))
			{
				if (!_clues.Any((LineupClue _c) => _c.forceError(lineupSuspectInfo, _rng)))
				{
					Debug.LogError("No clue could be forced as wrong! This isnt supposed to be able to happen...");
				}
			}
			else if (_conform == ClueConformType.CONFORM_SOME && _clues.All((LineupClue _c) => !_c.conforms(lineupSuspectInfo)) && !_clues.Any((LineupClue _c) => _c.forceTruth(lineupSuspectInfo, _rng)))
			{
				Debug.LogWarning("No clue could be forced as true! How? This should be impossible...");
			}
		}
		has_scar = _rng.Next(0, 2) == 1;
		has_face_object = _rng.Next(0, 2) == 1;
		has_hat = !has_hair;
		suspect_elements = new List<LineupSuspect.SuspectElements>();
		createTrueSuspectElements(_rng);
	}

	private void createTrueSuspectElements(System.Random _rng)
	{
		List<LineupSuspect.SuspectElements> list = suspect_elements;
		list.Add(_rng.Next(0, 3) switch
		{
			0 => male ? LineupSuspect.SuspectElements.MALE_BODY_1 : LineupSuspect.SuspectElements.FEMALE_BODY_1, 
			1 => (!male) ? LineupSuspect.SuspectElements.FEMALE_BODY_2 : LineupSuspect.SuspectElements.MALE_BODY_2, 
			2 => male ? LineupSuspect.SuspectElements.MALE_BODY_3 : LineupSuspect.SuspectElements.FEMALE_BODY_3, 
			_ => throw new NotImplementedException(), 
		});
		if (has_scar)
		{
			list = suspect_elements;
			list.Add(_rng.Next(0, 4) switch
			{
				0 => male ? LineupSuspect.SuspectElements.MALE_SCAR_1 : LineupSuspect.SuspectElements.FEMALE_SCAR_1, 
				1 => male ? LineupSuspect.SuspectElements.MALE_SCAR_2 : LineupSuspect.SuspectElements.FEMALE_SCAR_2, 
				2 => male ? LineupSuspect.SuspectElements.MALE_SCAR_3 : LineupSuspect.SuspectElements.FEMALE_SCAR_3, 
				3 => male ? LineupSuspect.SuspectElements.MALE_SCAR_4 : LineupSuspect.SuspectElements.FEMALE_SCAR_4, 
				_ => throw new NotImplementedException(), 
			});
		}
		if (has_hair)
		{
			list = suspect_elements;
			list.Add(_rng.Next(0, 6) switch
			{
				0 => male ? LineupSuspect.SuspectElements.MALE_HAIR_1 : LineupSuspect.SuspectElements.FEMALE_HAIR_1, 
				1 => male ? LineupSuspect.SuspectElements.MALE_HAIR_2 : LineupSuspect.SuspectElements.FEMALE_HAIR_2, 
				2 => male ? LineupSuspect.SuspectElements.MALE_HAIR_3 : LineupSuspect.SuspectElements.FEMALE_HAIR_3, 
				3 => male ? LineupSuspect.SuspectElements.MALE_HAIR_4 : LineupSuspect.SuspectElements.FEMALE_HAIR_4, 
				4 => male ? LineupSuspect.SuspectElements.MALE_HAIR_5 : LineupSuspect.SuspectElements.FEMALE_HAIR_5, 
				5 => male ? LineupSuspect.SuspectElements.MALE_HAIR_6 : LineupSuspect.SuspectElements.FEMALE_HAIR_6, 
				_ => throw new NotImplementedException(), 
			});
		}
		else
		{
			list = suspect_elements;
			list.Add(_rng.Next(0, 3) switch
			{
				0 => male ? LineupSuspect.SuspectElements.MALE_HAT_1 : LineupSuspect.SuspectElements.FEMALE_HAT_1, 
				1 => male ? LineupSuspect.SuspectElements.MALE_HAT_2 : LineupSuspect.SuspectElements.FEMALE_HAT_2, 
				2 => male ? LineupSuspect.SuspectElements.MALE_HAT_3 : LineupSuspect.SuspectElements.FEMALE_HAT_3, 
				_ => throw new NotImplementedException(), 
			});
		}
		if (has_face_object)
		{
			list = suspect_elements;
			list.Add(_rng.Next(0, 5) switch
			{
				0 => male ? LineupSuspect.SuspectElements.MALE_FACE_1 : LineupSuspect.SuspectElements.FEMALE_FACE_1, 
				1 => male ? LineupSuspect.SuspectElements.MALE_FACE_2 : LineupSuspect.SuspectElements.FEMALE_FACE_2, 
				2 => male ? LineupSuspect.SuspectElements.MALE_FACE_3 : LineupSuspect.SuspectElements.FEMALE_FACE_3, 
				3 => male ? LineupSuspect.SuspectElements.MALE_FACE_4 : LineupSuspect.SuspectElements.FEMALE_FACE_4, 
				4 => male ? LineupSuspect.SuspectElements.MALE_FACE_5 : LineupSuspect.SuspectElements.FEMALE_FACE_5, 
				_ => throw new NotImplementedException(), 
			});
		}
		if (has_glasses)
		{
			list = suspect_elements;
			list.Add(_rng.Next(0, 2) switch
			{
				0 => male ? LineupSuspect.SuspectElements.MALE_GLASSES_1 : LineupSuspect.SuspectElements.FEMALE_GLASSES_1, 
				1 => male ? LineupSuspect.SuspectElements.MALE_GLASSES_2 : LineupSuspect.SuspectElements.FEMALE_GLASSES_2, 
				_ => throw new NotImplementedException(), 
			});
		}
		if (has_facial_hair)
		{
			list = suspect_elements;
			list.Add(_rng.Next(0, 4) switch
			{
				0 => LineupSuspect.SuspectElements.MALE_FACE_HAIR_1, 
				1 => LineupSuspect.SuspectElements.MALE_FACE_HAIR_2, 
				2 => LineupSuspect.SuspectElements.MALE_FACE_HAIR_3, 
				3 => LineupSuspect.SuspectElements.MALE_FACE_HAIR_4, 
				_ => throw new NotImplementedException(), 
			});
		}
		if (has_earing)
		{
			suspect_elements.Add(male ? LineupSuspect.SuspectElements.MALE_EAR_1 : LineupSuspect.SuspectElements.FEMALE_EAR_1);
		}
	}
}
