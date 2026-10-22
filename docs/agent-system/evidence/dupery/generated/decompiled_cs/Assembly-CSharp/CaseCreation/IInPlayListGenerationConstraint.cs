using System.Collections.Generic;
using GRGLib.Maybe;

namespace CaseCreation;

public interface IInPlayListGenerationConstraint
{
	bool tryAddRoleInPlay(ChainMarker<Roles> _self, bool _forced, Maybe<ChainMarker<Roles>> _from, List<ChainMarker<Roles>> _current_list, List<Roles> _suspect_list, InPlayListFactory _factory);

	bool canReplaceRoleInPlay(RoleData _role, ChainMarker<Roles> _to_replace, Maybe<ChainMarker<Roles>> _self, InPlayListFactory _factory);

	Maybe<ValidationError> checkInPlayListForError(CaseType _type, Roles _self, List<Roles> _in_play_list, CaseSnapshot _snap);
}
