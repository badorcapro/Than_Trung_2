using System.Collections.Generic;
using GRGLib.Maybe;

namespace CaseCreation;

public interface ISuspectListGenerationConstraint
{
	bool lock_self_suspect { get; }

	bool tryAddSuspect(Roles _role, bool _forced, List<Roles> _from, List<Marker<Roles>> _current_list, List<Roles> _available_roles, SuspectListFactory _factory);

	Maybe<ValidationError> checkSuspectListForError(CaseType _type, Roles _self, List<Roles> _suspect_list, CaseSnapshot _snap);
}
