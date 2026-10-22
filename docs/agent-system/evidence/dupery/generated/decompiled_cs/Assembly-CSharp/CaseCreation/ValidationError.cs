using GRGLib.Maybe;

namespace CaseCreation;

public class ValidationError
{
	public Maybe<Roles> related_to = new Maybe<Roles>();

	public string error;

	public ValidationError(string _error)
	{
		error = _error;
	}

	public ValidationError(string _error, Roles _role)
	{
		Maybe<Roles> maybe = _role.maybe();
		error = _error;
		related_to = maybe;
	}
}
