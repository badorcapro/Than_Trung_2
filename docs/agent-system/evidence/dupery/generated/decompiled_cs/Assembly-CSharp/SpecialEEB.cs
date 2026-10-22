using Localisation;

public class SpecialEEB : EditorErrorBuilder
{
	public enum SpecialErrors
	{
		MUST_HAVE_INNOCENT_SUSPECT,
		CANT_BE_ONLY_INNOCENT_SUSPECT,
		INVALID_DISGUISE,
		CASANOVA_SPECIAL
	}

	protected SpecialErrors error;

	protected override EditorErrorType error_type => EditorErrorType.SPECIAL;

	public SpecialEEB(SpecialErrors _error)
	{
		error = _error;
	}

	protected override string getErrorMessage()
	{
		return EditorErrorBuilder.localisation_asset.checkTranslation(getLocKey(error), () => getEnglish(error));
	}

	private string getLocKey(SpecialErrors _error)
	{
		return $"EditorError [{error_type}_{(int)_error}]";
	}

	private string getEnglish(SpecialErrors _error)
	{
		switch (_error)
		{
		case SpecialErrors.MUST_HAVE_INNOCENT_SUSPECT:
			return englishErrorInnoSus();
		case SpecialErrors.CANT_BE_ONLY_INNOCENT_SUSPECT:
			return englishErrorAloneInnoSus();
		case SpecialErrors.INVALID_DISGUISE:
			return "Invalid Disguise";
		case SpecialErrors.CASANOVA_SPECIAL:
			return "Must be " + Keywords.SURROUNDING.toString() + " an " + TextHelper.innocentRole + " " + Keywords.CARDINALLY_ADJACENT.toString() + " to the " + Roles.ROMANTIC.toString() + ".";
		default:
		{
			global::_003CPrivateImplementationDetails_003E.ThrowSwitchExpressionException(_error);
			string result = default(string);
			return result;
		}
		}
	}

	private string englishErrorInnoSus()
	{
		return "Must have at least 1 " + TextHelper.notInPlayInnocentRole + "!";
	}

	private string englishErrorAloneInnoSus()
	{
		return "Can't be only " + TextHelper.notInPlayInnocentRole + "!";
	}
}
