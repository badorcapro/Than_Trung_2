using System;
using System.Collections.Generic;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Random;
using GRGLib.Serializable;
using UnityEngine;

[CreateAssetMenu(menuName = "ScriptableObject/Role Visual Data SO")]
public class RoleVisualDataSO : ScriptableObject
{
	[Serializable]
	public struct ClassificationVisualData
	{
		public Color class_colour;

		public Color role_text_colour;

		public ClassificationVisualData(string _name)
		{
			Color white = Color.white;
			Color white2 = Color.white;
			class_colour = white;
			role_text_colour = white2;
		}
	}

	[Header("Settings")]
	[SerializeField]
	private List<Sprite> doors;

	[SerializeField]
	private SerializableDictionary<Roles, Sprite> role_icons;

	[SerializeField]
	private SerializableDictionary<RoleClassifications, ClassificationVisualData> classifications;

	[SerializeField]
	private Color good_alignment_colour;

	[SerializeField]
	private Color evil_alignment_colour;

	[SerializeField]
	private Color icon_suspected_colour;

	[SerializeField]
	private Color icon_not_in_play_colour;

	[SerializeField]
	private Sprite unknown_role_icon;

	[Space]
	[SerializeField]
	private Sprite backup;

	public Sprite this[Roles _role] => getRoleIconSprite(_role);

	public ClassificationVisualData this[RoleClassifications _class] => getClassificationData(_class);

	public Color this[Alignments _alignment] => getRoleAlignmentColour(_alignment);

	private ClassificationVisualData getClassificationData(RoleClassifications _class)
	{
		return classifications.getOrDefault(_class, new ClassificationVisualData("Unknown"));
	}

	private Sprite getRoleIconSprite(Roles _role)
	{
		return role_icons.getOrDefault(_role, backup);
	}

	private Color getRoleAlignmentColour(Alignments _alignment)
	{
		return _alignment switch
		{
			Alignments.GOOD => good_alignment_colour, 
			Alignments.EVIL => evil_alignment_colour, 
			_ => throw new ArgumentException("Was given an alignment that wasnt good or bad!"), 
		};
	}

	public Sprite getRandomDoor(System.Random _rng)
	{
		return doors.getRandomElementFromList(_rng);
	}

	public Sprite getUnknownRoleIcon()
	{
		return unknown_role_icon;
	}

	public Color getIconSuspectedColour()
	{
		return icon_suspected_colour;
	}

	public Color getIconNotInPlayColour()
	{
		return icon_not_in_play_colour;
	}
}
