using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using UnityEngine;

public abstract class CaseSnapshot
{
	public Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> board;

	public bool case_solved { get; private set; }

	public CaseActionPayload payload { get; private set; }

	public Dictionary<RoleClassifications, int> classification_ratio { get; private set; }

	public HashSet<RoleData> visual_suspect_list { get; private set; }

	public HashSet<RoleData> true_suspect_list { get; private set; }

	public Dictionary<int, RoleData> address_occupents => board.getRolesInPlay();

	public Dictionary<LocationTypes, LocationData> locations => board.getLocationsInPlay();

	public virtual bool case_over
	{
		get
		{
			if (!case_solved)
			{
				return case_lost;
			}
			return true;
		}
	}

	public abstract bool case_lost { get; }

	public CaseSnapshot(bool _case_solved, CaseActionPayload _payload, Dictionary<RoleClassifications, int> _classification_ratio, HashSet<RoleData> _suspect_list, HashSet<RoleData> _true_suspect_list, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board)
	{
		payload = _payload;
		classification_ratio = _classification_ratio;
		visual_suspect_list = _suspect_list;
		true_suspect_list = _true_suspect_list;
		board = _board;
		case_solved = _case_solved;
	}

	public virtual string debugPrint(List<CaseQuirks> _case_quirks)
	{
		return "Case Over: " + (case_solved ? "Solved!" : (case_lost ? "Lost!" : "false")) + "\n" + $"Classification Ratio: I- {classification_ratio[RoleClassifications.INNOCENT]} | M- {classification_ratio[RoleClassifications.MEDDLER]} | U- {classification_ratio[RoleClassifications.UNDERLING]} | T- {classification_ratio[RoleClassifications.TRAITOR]}\n" + "\nSuspect List: " + true_suspect_list.Aggregate("", (string _a, RoleData _s) => _a = _a + _s.role.ToString() + " | ") + "\n" + ((true_suspect_list.Count != visual_suspect_list.Count) ? ("Visual Suspect List: " + visual_suspect_list.Aggregate("", (string _a, RoleData _s) => _a = _a + _s.role.ToString() + " | ") + "\n") : "") + "Address Occupents: \n\n" + address_occupents.Aggregate("", (string _a, KeyValuePair<int, RoleData> _kvp) => _a += string.Format("{0} {1}: {2} | {3} | {4}\n", _kvp.Key, _kvp.Value.getBoardPosition(), _kvp.Value.role, _kvp.Value.getTrueAlignment(), _kvp.Value.getIsArrested() ? "Arrested" : (_kvp.Value.getIsDead() ? "Dead" : ""))) + "\nLocations: \n" + locations.Aggregate("", (string _a, KeyValuePair<LocationTypes, LocationData> _l) => _a += $"{_l.Key} at {_l.Value.getBoardPosition()}\n") + "\nCase Quirks: " + _case_quirks.Aggregate("", (string _a, CaseQuirks _q) => _a = _a + _q.ToString() + " | ");
	}

	public virtual string debugPrintExtra(List<CaseQuirks> _case_quirks)
	{
		return $"Case Solved: {case_solved}\n" + $"Classification Ratio: I- {classification_ratio[RoleClassifications.INNOCENT]} | M- {classification_ratio[RoleClassifications.MEDDLER]} | U- {classification_ratio[RoleClassifications.UNDERLING]} | T- {classification_ratio[RoleClassifications.TRAITOR]}\n" + "Suspect List: " + true_suspect_list.Aggregate("", (string _a, RoleData _s) => _a = _a + _s.role.ToString() + " | ") + "\n" + ((true_suspect_list.Count != visual_suspect_list.Count) ? ("Visual Suspect List: " + visual_suspect_list.Aggregate("", (string _a, RoleData _s) => _a = _a + _s.role.ToString() + " | ") + "\n") : "") + "Address Occupents: \n" + address_occupents.Aggregate("", (string _a, KeyValuePair<int, RoleData> _kvp) => _a += getOccupentDebug(_kvp)) + "\nLocations: \n" + locations.Aggregate("", (string _a, KeyValuePair<LocationTypes, LocationData> _l) => _a += $"{_l.Key} at {_l.Value.getBoardPosition()}\n") + "\nCase Quirks: " + _case_quirks.Aggregate("", (string _a, CaseQuirks _q) => _a = _a + _q.ToString() + " | ");
	}

	protected string getOccupentDebug(KeyValuePair<int, RoleData> _kvp)
	{
		RoleData visualRole = _kvp.Value.getVisualRole();
		string text = $"{_kvp.Key} {_kvp.Value.getBoardPosition()}: ";
		text += string.Format("{0}{1}", _kvp.Value.role, _kvp.Value.getIsDisguised() ? (" (" + _kvp.Value.getDisguise().value.role.ToString().ToLower() + ")") : "");
		text += string.Format(" | {0}{1}{2}", _kvp.Value.getTrueAlignment(), _kvp.Value.getIsArrested() ? " | Arrested" : (_kvp.Value.getIsDead() ? " | Dead" : (_kvp.Value.getIsInvestigated() ? "| Investigated" : "")), _kvp.Value.getIsObscured() ? " | Obscured " : "");
		if (_kvp.Value.getIsTainted() || _kvp.Value.getVisualRole().getIsTainted())
		{
			text += " | Tainted";
		}
		text = text + " | \"" + ((visualRole.hasInfo && (_kvp.Value.getIsInvestigated() || _kvp.Value.getIsArrested())) ? visualRole.getInfoString(this) : "") + "\"";
		return text + "\n";
	}

	public string occupentDebugString(RoleData _role)
	{
		RoleData visualRole = _role.getVisualRole();
		string text = $"{_role.getAddress()} {_role.getBoardPosition()}: ";
		text += string.Format("{0}{1}", _role.role, _role.getIsDisguised() ? (" (" + _role.getDisguise().value.role.ToString().ToLower() + ")") : "");
		text += string.Format(" | {0}{1}{2}{3}", _role.getTrueAlignment(), _role.getIsArrested() ? " | Arrested" : (_role.getIsDead() ? " | Dead" : (_role.getIsInvestigated() ? " | Investigated" : "")), _role.getIsObscured() ? " | Obscured " : "", _role.getIsHidden() ? " | Hidden " : "");
		if (_role.getIsTainted() || _role.getVisualRole().getIsTainted())
		{
			text += " | Tainted";
		}
		text = text + " | \"" + ((visualRole.hasInfo && (_role.getIsInvestigated() || _role.getIsArrested())) ? visualRole.getInfoString(this) : "") + "\"";
		string truthString = _role.getTruthString();
		if (truthString != "")
		{
			text = text + "\n\n" + truthString;
		}
		return text + "\n";
	}
}
