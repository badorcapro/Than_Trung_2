using System;
using System.Collections.Generic;
using System.Linq;
using Localisation;

public class RequirementEEB : EditorErrorBuilder
{
	protected Func<string> fill;

	protected override EditorErrorType error_type => EditorErrorType.REQUIREMENT;

	public RequirementEEB(Roles _role)
	{
		fill = () => _role.toString();
	}

	public RequirementEEB(RoleClassifications _class)
	{
		fill = () => _class.toString();
	}

	public RequirementEEB(List<RoleClassifications> _class)
	{
		fill = () => _class.Aggregate("", (string _a, RoleClassifications _b) => (_a.Length <= 0) ? _b.toString() : (_a + ", " + _b.toString()));
	}

	public RequirementEEB(RoleGenerationMarkers _marker)
	{
		fill = () => LevelEditorHelper.generationMarkersLocalised(_marker);
	}

	public RequirementEEB(LocationTypes _location)
	{
		fill = () => _location.toString();
	}

	public RequirementEEB()
	{
		fill = () => Keywords.ROLE.toStringCap();
	}

	public RequirementEEB(Func<string> _fill)
	{
		fill = _fill;
	}

	protected override string getErrorMessage()
	{
		return EditorErrorBuilder.localisation_asset.checkTranslationWithData(base.loc_error_message_key, englishError, fill());
	}

	private string englishError(string _d1)
	{
		return "Requirement not met: " + _d1 + " needed.";
	}
}
