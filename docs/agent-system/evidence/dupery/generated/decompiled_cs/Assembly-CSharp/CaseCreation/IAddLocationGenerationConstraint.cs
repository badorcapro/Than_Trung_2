using GRGLib.Maybe;

namespace CaseCreation;

public interface IAddLocationGenerationConstraint
{
	Maybe<LocationTypes> getForcedLocation(bool _is_force_suspected, bool _is_force_in_play);
}
