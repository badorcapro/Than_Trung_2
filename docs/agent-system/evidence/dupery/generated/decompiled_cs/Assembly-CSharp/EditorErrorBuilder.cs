using CaseCreation;
using GRGLocalisation;
using Localisation;

public abstract class EditorErrorBuilder
{
	public enum EditorErrorType
	{
		REQUIREMENT = 1,
		REQUIREMENT_POSITIONED = 2,
		SPECIAL = 101
	}

	protected abstract EditorErrorType error_type { get; }

	protected static AssetKey localisation_asset => LocalisationHelper.misc_asset;

	protected string loc_error_message_key => $"EditorError [{error_type}]";

	protected abstract string getErrorMessage();

	public virtual ValidationError createValidationError(Roles _self)
	{
		return new ValidationError(getErrorMessage(), _self);
	}

	public ValidationError createValidationError()
	{
		return new ValidationError(getErrorMessage());
	}
}
