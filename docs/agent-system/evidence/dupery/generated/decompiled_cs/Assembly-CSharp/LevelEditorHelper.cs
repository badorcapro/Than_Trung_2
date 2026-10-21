using GRGLocalisation;
using Localisation;

public static class LevelEditorHelper
{
	public static string cardAbilityRole => localisation_asset.checkTranslation(loc_car_key, () => englishCardAbilityRole);

	private static string englishCardAbilityRole => Keywords.CARD.toStringCap() + " " + Keywords.ABILITY.toString() + " " + Keywords.ROLE.toString();

	private static AssetKey localisation_asset => LocalisationHelper.misc_asset;

	private static string loc_s_role_avoid_key => "LEValidation [error_sus_avo]";

	private static string loc_ip_role_avoid_key => "LEValidation [error_ip_avo]";

	private static string loc_car_key => "LEMisc [CardAbilityRole]";

	public static string positionMarkersLocalised(GCPosition _position)
	{
		return _position switch
		{
			GCPosition.ADJACENT => Keywords.CARDINALLY_ADJACENT.toStringCap(), 
			GCPosition.SURROUNDING => Keywords.SURROUNDING.toStringCap(), 
			_ => localisation_asset.checkTranslation(positionMarkerLocKeys(_position), () => englishPositionMarkers(_position)), 
		};
	}

	private static string englishPositionMarkers(GCPosition _position)
	{
		return _position switch
		{
			GCPosition.NOT_ADJACENT => "Not " + Keywords.CARDINALLY_ADJACENT.toString(), 
			GCPosition.NOT_SURROUNDING => "Not " + Keywords.SURROUNDING.toString(), 
			GCPosition.ROW => "In row", 
			GCPosition.COLUMN => "In column", 
			GCPosition.COLUMN_OR_ROW => "In column or row", 
			GCPosition.BOARD_EDGE => "On board edge", 
			GCPosition.BOARD_INNER => "Not on board edge", 
			_ => "", 
		};
	}

	private static string positionMarkerLocKeys(GCPosition _position)
	{
		return $"PosMarker [{(int)_position}]";
	}

	public static string generationMarkersLocalised(RoleGenerationMarkers _marker)
	{
		return localisation_asset.checkTranslation(generationMarkerLocKey(_marker), () => englishGenerationMarkers(_marker));
	}

	private static string englishGenerationMarkers(RoleGenerationMarkers _marker)
	{
		return _marker switch
		{
			RoleGenerationMarkers.HAS_ABILITY => Keywords.ABILITY.toStringCap() + " " + Keywords.ROLE.toString(), 
			RoleGenerationMarkers.SELF_CONFIRM => "Self-confirm " + Keywords.ROLE.toString(), 
			RoleGenerationMarkers.TAINTS => TextHelper.taintedRole ?? "", 
			RoleGenerationMarkers.OBSCURES => TextHelper.obscured + " " + Keywords.ROLE.toString(), 
			RoleGenerationMarkers.HIDES => TextHelper.hiddenRole ?? "", 
			RoleGenerationMarkers.INVESTIGATION_BLOCKER => "Investigation".asKeyword(Keywords.INVESTIGATE) + " blocker " + Keywords.ROLE.toString(), 
			_ => "", 
		};
	}

	private static string generationMarkerLocKey(RoleGenerationMarkers _marker)
	{
		return $"GenMarker [{(int)_marker}]";
	}

	public static string suspectAvoidRoleErrorLocalised(Roles _role)
	{
		return localisation_asset.checkTranslationWithData(loc_s_role_avoid_key, englishSuspectAvoidRoleError, _role.toString());
	}

	private static string englishSuspectAvoidRoleError(string _data)
	{
		return "The " + _data + " cannot also be suspected.";
	}

	public static string inPlayAvoidRoleErrorLocalised(Roles _role)
	{
		return localisation_asset.checkTranslationWithData(loc_ip_role_avoid_key, englishInPlayAvoidRoleError, _role.toString());
	}

	private static string englishInPlayAvoidRoleError(string _data)
	{
		return "The " + _data + " cannot also be in play.";
	}
}
