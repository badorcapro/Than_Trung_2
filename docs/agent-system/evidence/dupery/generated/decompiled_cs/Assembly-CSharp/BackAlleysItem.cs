using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using GRGLocalisation;
using Localisation;
using UnityEngine;

public abstract class BackAlleysItem : IAmLocalised
{
	public const char split_char = '|';

	protected BackAlleySlot slot_reference;

	protected System.Random random;

	public abstract BackAlleysItemType type { get; }

	public abstract BackAlleysItemColour colour { get; }

	public abstract BackAlleysItemCost cost { get; }

	public string name => localisation_asset.checkTranslation(loc_name_key, () => english_name);

	protected abstract string english_name { get; }

	public string description => localisation_asset.checkTranslation(loc_description_key, () => english_description);

	protected abstract string english_description { get; }

	public abstract bool is_active { get; }

	public virtual bool destroy_onced_used => uses_per_case == -1;

	public virtual int uses_per_case => -1;

	public int uses_remaining { get; private set; }

	public int random_price => cost.toPrice().get(random);

	protected AssetKey localisation_asset => LocalisationHelper.general_case_asset;

	private string loc_name_key => $"{type} [name]";

	private string loc_description_key => $"{type} [desc]";

	public static BackAlleysItem load(string _save_data, Action _remove, System.Random _rng)
	{
		string[] array = _save_data.Split('|');
		return BackAlleysHelper.fromSave((BackAlleysItemType)int.Parse(array[0]), int.Parse(array[1]), (array.Length > 2) ? array[2] : "", _rng);
	}

	public BackAlleysItem(System.Random _rng, int _usages = -1)
	{
		random = _rng;
		int num2 = (uses_remaining = _usages);
	}

	public void setSlotReference(BackAlleySlot _slot)
	{
		slot_reference = _slot;
	}

	public void spendUse(int _usages = 1)
	{
		uses_remaining -= _usages;
		slot_reference.onItemUsed(type);
		if (uses_remaining == 0 && destroy_onced_used)
		{
			slot_reference.destroyFilledItem();
		}
	}

	public void increaseAvailableUsages(int _increase_by = 1)
	{
		uses_remaining += _increase_by;
	}

	public void onCaseBegin(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, BackAlleysCase _case)
	{
		if (uses_per_case > 0)
		{
			uses_remaining = uses_per_case;
		}
		caseBegin(_board, _case);
	}

	protected virtual void caseBegin(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, BackAlleysCase _case)
	{
	}

	public virtual void onCaseEnd(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, BackAlleysCase _case, bool _lost)
	{
	}

	public virtual void useItemAbility(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, List<AbilityData> _data, BackAlleysCase _case)
	{
	}

	public virtual void onItemUsed(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, BackAlleySlot _used_item_slot, BackAlleysCase _case)
	{
	}

	public virtual void onArrest(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, BackAlleysCase _case, int _arresting)
	{
	}

	public virtual int onHealthChange(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, BackAlleysCase _case, int _old_rep, int _current_change)
	{
		return _current_change;
	}

	public string toSaveData()
	{
		return $"{(int)type}{'|'}{uses_remaining}{'|'}{getUniqueSaveData()}";
	}

	protected abstract string getUniqueSaveData();
}
