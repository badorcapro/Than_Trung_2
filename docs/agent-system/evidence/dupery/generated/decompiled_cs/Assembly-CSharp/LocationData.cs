using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using GRGLocalisation;
using Localisation;
using Save;
using UnityEngine;

public abstract class LocationData : IAmLocalised
{
	protected Vector2Int board_position = Vector2Int.zero;

	protected System.Random random;

	protected Maybe<LocationData> disguise = new Maybe<LocationData>();

	public abstract LocationTypes location_type { get; }

	public string name => localisation_asset.checkTranslation(this.getLocNameKey(), () => english_name);

	protected abstract string english_name { get; }

	public string description => localisation_asset.checkTranslation(this.getLocDescriptionKey(), () => english_description);

	protected abstract string english_description { get; }

	public bool is_location_disguised => disguise.is_some;

	public LocationData visual_location
	{
		get
		{
			if (!disguise.is_some)
			{
				return this;
			}
			return disguise.value;
		}
	}

	public virtual int execution_order => (int)location_type;

	public bool has_ability => this is IHaveAbility;

	public AssetKey localisation_asset => LocalisationHelper.general_case_asset;

	public abstract bool isOfRegion(Regions _region);

	public Vector2Int getBoardPosition()
	{
		return board_position;
	}

	public LocationData(System.Random _random, Vector2Int _board_position)
	{
		random = _random;
		board_position = _board_position;
	}

	public LocationData(LocationDataSave _save, System.Random _random)
	{
		random = _random;
		board_position = new Vector2Int(_save.board_position.Item1, _save.board_position.Item2);
	}

	public LocationDataSave toSave()
	{
		return new LocationDataSave(location_type, board_position, getUniqueSaveData());
	}

	public LocationDataSave getDisguiseSave()
	{
		if (!disguise.is_some)
		{
			return null;
		}
		return disguise.value.toSave();
	}

	public void setDisguise(LocationTypes _location_type)
	{
		disguise = _location_type.createLocation(board_position, random).maybe();
	}

	public void setDisguiseFromSave(LocationDataSave _disguise)
	{
		disguise = _disguise.fromSave(random).maybe();
	}

	public virtual void useAbility(Case _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<AbilityData> _data)
	{
	}

	protected virtual Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundAwakeAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		return _board;
	}

	protected virtual Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		return _board;
	}

	public Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundAwake(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		_board = onRoundAwakeAction(_board, _payload, _suspects);
		if (disguise.is_some)
		{
			return disguise.value.onRoundAwake(_board, _payload, _suspects);
		}
		return _board;
	}

	public Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStarted(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		_board = onRoundStartAction(_board, _payload, _suspects);
		if (disguise.is_some)
		{
			return disguise.value.onRoundStarted(_board, _payload, _suspects);
		}
		return _board;
	}

	protected abstract string getUniqueSaveData();
}
