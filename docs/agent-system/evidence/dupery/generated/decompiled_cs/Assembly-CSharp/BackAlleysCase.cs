using System;
using System.Collections.Generic;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using GameStats;
using Leads;
using Save;
using UnityEngine;

public class BackAlleysCase : Case
{
	public static int default_max_health = 6;

	private Dictionary<BackAlleysItemType, int> items_used = new Dictionary<BackAlleysItemType, int>();

	private Action<BackAlleysItem, bool, Func<Maybe<Vector2Int>, BackAlleysCaseSnapshot>> add_new_item_call;

	public override CaseType case_type => CaseType.BACK_ALLEYS;

	public int max_health { get; private set; }

	public int current_health { get; private set; }

	public BackAlleysPouch pouch { get; protected set; }

	public BackAlleysCase(int _health, BackAlleysPouch _pouch, CaseBuildData _case_data, List<Roles> _available_roles)
		: base(_case_data)
	{
		max_health = default_max_health;
		current_health = _health;
		pouch = new BackAlleysPouch(_pouch, onItemUsed, onItemAdded);
		createBoardAndStart(_available_roles, _case_data.case_quirks);
		pouch.onCaseBegin(board, this);
	}

	public BackAlleysCase(CaseSave _case, Maybe<Lead> _current_lead)
		: base(_case, _current_lead)
	{
		try
		{
			BackAlleyCaseUniqueSaveData backAlleyCaseUniqueSaveData = JsonUtility.FromJson<BackAlleyCaseUniqueSaveData>(_case.unique_data);
			current_health = backAlleyCaseUniqueSaveData.health;
			max_health = default_max_health;
			pouch = new BackAlleysPouch(backAlleyCaseUniqueSaveData.pouch, random, onItemUsed, onItemAdded);
			items_used = backAlleyCaseUniqueSaveData.items_used.toDictionary();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Trying to parse in reputation and pouch failed! ({_case.unique_data}) Error below.\n{arg}");
			current_health = 1;
			max_health = default_max_health;
			pouch = new BackAlleysPouch(onItemUsed, onItemAdded);
		}
		if (!base.began)
		{
			pouch.onCaseBegin(board, this);
		}
	}

	public BackAlleysCase(int _health, List<Roles> _suspect_list, List<RoleData> _board_roles, List<LocationData> _board_locations, Maybe<int> _tutorial, Dictionary<RoleClassifications, int> _forced_ratio)
		: base(new Vector2Int(4, 4), _suspect_list, _board_roles, _board_locations, _tutorial, _forced_ratio)
	{
		max_health = default_max_health;
		current_health = _health;
		pouch = new BackAlleysPouch(onItemUsed, onItemAdded);
		startFromPresetBoard();
		pouch.onCaseBegin(board, this);
	}

	public BackAlleysCase(int _health, BackAlleysPouch _pouch, List<Roles> _suspect_list, List<RoleData> _board_roles, List<LocationData> _board_locations, Maybe<int> _tutorial, Dictionary<RoleClassifications, int> _forced_ratio)
		: base(new Vector2Int(4, 4), _suspect_list, _board_roles, _board_locations, _tutorial, _forced_ratio)
	{
		max_health = default_max_health;
		current_health = _health;
		pouch = new BackAlleysPouch(_pouch, onItemUsed, onItemAdded);
		startFromPresetBoard();
		pouch.onCaseBegin(board, this);
	}

	public BackAlleysCase(int _health, List<BackAlleysItemType> _items, float _difficulty_01, List<CaseQuirks> _case_quirks, List<Roles> _forced_roles, int _forced_address_size = -1, int _forced_innocents = -1, int _forced_meddlers = -1, int _forced_underlings = -1, int _forced_traitors = -1, bool _remove_extra_suspects = false)
		: base(new Vector2Int(4, 4), _difficulty_01, _forced_address_size, _forced_innocents, _forced_meddlers, _forced_underlings, _forced_traitors, _remove_extra_suspects)
	{
		current_health = _health;
		max_health = default_max_health;
		pouch = new BackAlleysPouch(onItemUsed, onItemAdded);
		_items.ForEach(delegate(BackAlleysItemType _i)
		{
			pouch.fillNextItemSlot(_i, random);
		});
		createBoardAndStart(new List<Roles>(), _forced_roles, _case_quirks);
		pouch.onCaseBegin(board, this);
	}

	public override CaseActionPayload getPayload()
	{
		return new BackAlleysCaseActionPayload(current_health, max_health, pouch);
	}

	protected override void onArrest(RoleData _arrested_role, List<RoleData> _ordered_roles_for_event_calls)
	{
		pouch.onArrest(board, this, _arrested_role.getAddress());
		if (_arrested_role.getTrueAlignment() == Alignments.GOOD)
		{
			current_health--;
		}
	}

	public override CaseSnapshot onCaseOver(bool _won)
	{
		pouch.onCaseEnd(board, this, !_won);
		return base.onCaseOver(_won);
	}

	private int onHealthChange(int _change)
	{
		return pouch.onHealthChange(board, this, current_health, _change);
	}

	public void setHealthExternally(int _new_rep)
	{
		int change = _new_rep - current_health;
		current_health = Mathf.Min(current_health - onHealthChange(change), max_health);
	}

	public void addHealth(int _add)
	{
		current_health = Mathf.Min(current_health + onHealthChange(_add), max_health);
	}

	public CaseSnapshot itemAbility(Vector2Int _item_slot, List<AbilityData> _data)
	{
		pouch.tryUseAbility(_item_slot, _data, board, this);
		return snapshot();
	}

	public CaseSnapshot swapItems(Vector2Int _slot_1, Vector2Int _slot_2)
	{
		pouch.swapItems(_slot_1, _slot_2);
		return snapshot();
	}

	private void onItemUsed(BackAlleysItemType _item)
	{
		items_used.increaseOrCreate(_item, 1);
	}

	public void setUpAddNewItemCall(Action<BackAlleysItem, bool, Func<Maybe<Vector2Int>, BackAlleysCaseSnapshot>> _try_add_item)
	{
		add_new_item_call = _try_add_item;
	}

	private void onItemAdded(BackAlleysItem _item, bool _forced, Action<Maybe<Vector2Int>> _add_item)
	{
		add_new_item_call(_item, _forced, delegate(Maybe<Vector2Int> _m)
		{
			_add_item(_m);
			return snapshot() as BackAlleysCaseSnapshot;
		});
	}

	protected override CaseSnapshot generateCaseSnapshot(bool _silent = false)
	{
		return new BackAlleysCaseSnapshot(getPayload() as BackAlleysCaseActionPayload, base.case_solved, _silent ? classification_ratio : public_classification_ratio, _silent ? suspect_list : visual_suspect_list, suspect_list, board);
	}

	protected override CaseStats setRegionStats()
	{
		return new BackAlleyCaseStats
		{
			items_used = items_used
		};
	}

	protected override string getUniqueSaveData()
	{
		return JsonUtility.ToJson(new BackAlleyCaseUniqueSaveData(current_health, pouch.toSaveData(), items_used));
	}
}
