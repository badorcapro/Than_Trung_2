using System;
using System.Collections.Generic;
using UnityEngine;
using Visual;

public struct PureLogicCalls
{
	public Func<InteractionType, int, CaseSnapshot> do_interaction;

	public Func<int, List<int>, CaseSnapshot> do_ability;

	public Func<int, List<AbilityData>, CaseSnapshot> do_special_ability;

	public Func<LocationData, List<AbilityData>, CaseSnapshot> do_location_ability;

	public Func<Vector2Int, CaseSnapshot> move_boat_interaction;

	public Func<CaseSnapshot> finish_case;

	public Func<Vector2Int, List<AbilityData>, CaseSnapshot> do_item_ability;

	public Func<Vector2Int, Vector2Int, CaseSnapshot> exchange_items;

	public PureLogicCalls(Func<InteractionType, int, CaseSnapshot> _interact, Func<int, List<int>, CaseSnapshot> _ability, Func<int, List<AbilityData>, CaseSnapshot> _spe_ability, Func<LocationData, List<AbilityData>, CaseSnapshot> _location_ability, Func<Vector2Int, List<AbilityData>, CaseSnapshot> _item_ability, Func<Vector2Int, Vector2Int, CaseSnapshot> _exchange_items, Func<Vector2Int, CaseSnapshot> _move_boat, Func<CaseSnapshot> _finish_case)
	{
		do_interaction = _interact;
		do_ability = _ability;
		do_special_ability = _spe_ability;
		do_location_ability = _location_ability;
		move_boat_interaction = _move_boat;
		finish_case = _finish_case;
		do_item_ability = _item_ability;
		exchange_items = _exchange_items;
	}
}
