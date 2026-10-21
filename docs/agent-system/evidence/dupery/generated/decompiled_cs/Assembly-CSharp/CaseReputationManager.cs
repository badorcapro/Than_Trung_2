using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using GRGLocalisation;
using Leads;
using LevelEditor;
using Localisation;
using UnityEngine;

public class CaseReputationManager : IAmLocalised
{
	public static int max_reputation = 6;

	protected int _inner_rep;

	public string reputation_comment = "";

	private Func<int, int> on_reputation_change;

	private Action<int> after_change;

	public int reputation
	{
		get
		{
			return _inner_rep;
		}
		set
		{
			if (value > max_reputation)
			{
				value = max_reputation;
			}
			int num = on_reputation_change(value - _inner_rep);
			_inner_rep += num;
			if (num != 0)
			{
				after_change(_inner_rep);
			}
		}
	}

	public bool hidden_reputation { get; private set; }

	private AssetKey localisation_asset => LocalisationHelper.general_case_asset;

	private string loc_arrests_key => "Newspaper [arrest]";

	public CaseReputationManager(int _reputation, Func<int, int> _on_rep_change, Action<int> _after_change)
	{
		_inner_rep = _reputation;
		on_reputation_change = _on_rep_change;
		after_change = _after_change;
	}

	public void onArrest(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, RoleData _arrested_role, List<RoleData> _ordered_roles_for_event_calls)
	{
		if (_arrested_role.getIsArrested() && _arrested_role.getTrueAlignment() == Alignments.GOOD)
		{
			int num = (_board.getRolesInPlay().Values.Any((RoleData _e) => _e.role == Roles.S_LAWYER && _e.getIsInvestigated() && !_e.getIsDead() && !_e.getIsArrested()) ? 1 : 2);
			reputation -= num;
			reputation_comment = localisation_asset.checkTranslationWithData(loc_arrests_key, englishDetectiveArrests, _arrested_role.reveal_as.toStringPlain().ToUpper());
		}
	}

	public void setReputationExternally(int _new_rep, string _headline = "")
	{
		reputation = _new_rep;
		if (_headline != "")
		{
			reputation_comment = _headline;
		}
	}

	public void addReputation(int _add)
	{
		reputation += _add;
	}

	public void hideReputation(string _headline)
	{
		hidden_reputation = true;
		reputation_comment = _headline;
	}

	public void unhideReputation()
	{
		hidden_reputation = false;
		reputation_comment = "";
	}

	public ReputationStatus calculateVisualReputationStatus(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board)
	{
		ReputationStatus reputationStatus = reputation.getTrueReputationStatus();
		foreach (RoleData orderdRolesForEventCall in _board.getOrderdRolesForEventCalls())
		{
			if (orderdRolesForEventCall is IChangeReputationStatus changeReputationStatus)
			{
				reputationStatus = changeReputationStatus.checkVisualReputation(_board, reputation, reputationStatus);
			}
			if (orderdRolesForEventCall.getIsDisguised() && orderdRolesForEventCall.getDisguise().value is IChangeReputationStatus changeReputationStatus2)
			{
				reputationStatus = changeReputationStatus2.checkVisualReputation(_board, reputation, reputationStatus);
			}
		}
		return reputationStatus;
	}

	private string englishDetectiveArrests(string _data)
	{
		return "DETECTIVE ARRESTS " + _data + "!";
	}

	public void setReputationFromLevelEditor(LevelEditorManager _manager, int _rep)
	{
		if (!(_manager == null))
		{
			_inner_rep = _rep;
		}
	}

	public void setReputationFromCBCLead(CaseToCaseLead _cbc_lead, int _rep)
	{
		if (_cbc_lead != null)
		{
			_inner_rep = _rep;
		}
	}
}
