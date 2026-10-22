using System;
using Localisation;

public class RequirementPositionedEEB : EditorErrorBuilder
{
	protected Func<string> fill1;

	protected GCPosition position;

	protected override EditorErrorType error_type => EditorErrorType.REQUIREMENT_POSITIONED;

	public RequirementPositionedEEB(Roles _role, GCPosition _position)
	{
		Func<string> func = () => _role.toString();
		fill1 = func;
		position = _position;
	}

	public RequirementPositionedEEB(RoleClassifications _class, GCPosition _position)
	{
		Func<string> func = () => _class.toString();
		fill1 = func;
		position = _position;
	}

	public RequirementPositionedEEB(RoleGenerationMarkers _marker, GCPosition _position)
	{
		Func<string> func = () => LevelEditorHelper.generationMarkersLocalised(_marker);
		fill1 = func;
		position = _position;
	}

	public RequirementPositionedEEB(LocationTypes _location, GCPosition _position)
	{
		Func<string> func = () => _location.toString();
		fill1 = func;
		position = _position;
	}

	public RequirementPositionedEEB(GCPosition _position)
	{
		Func<string> func = () => Keywords.ROLE.toStringCap();
		fill1 = func;
		position = _position;
	}

	protected override string getErrorMessage()
	{
		return EditorErrorBuilder.localisation_asset.checkTranslationWithData(base.loc_error_message_key, englishError, fill1(), LevelEditorHelper.positionMarkersLocalised(position));
	}

	private string englishError(string _d1, string _d2)
	{
		return "Requirement not met: " + _d1 + " needed at position: " + _d2 + ".";
	}
}
