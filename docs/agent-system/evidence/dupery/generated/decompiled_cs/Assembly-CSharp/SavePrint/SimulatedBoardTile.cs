using System;
using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLib.Serializable;
using TMPro;
using UnityEngine;

namespace SavePrint;

public class SimulatedBoardTile : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private TMP_Text text;

	private Vector2Int board_position;

	private Action<Vector2Int> on_click;

	public void setUp(Action<Vector2Int> _on_click, Vector2Int _board_pos)
	{
		on_click = _on_click;
		board_position = _board_pos;
	}

	public void setOccupent(RoleData _role)
	{
		string text = $"{_role.getAddress()}\n{_role.role.toString()}";
		if (_role.getIsTainted())
		{
			text += "\nTainted";
		}
		if (_role.getIsArrested())
		{
			text += "\nArrested";
		}
		else if (_role.getIsDead())
		{
			text += "\nDead";
		}
		else if (_role.getIsInvestigated())
		{
			text += "\nInvestigated";
		}
		this.text.text = text;
	}

	public void setLocation(LocationData _loc)
	{
		string text = $"{_loc.location_type}";
		if (_loc is ClockTower clockTower)
		{
			text = text + "\nRings at " + clockTower.recorded_rings.copy().addRange(clockTower.scheduled_rings.Select((STupple<int, ClockTower.ClockTowerRingAttribution> _s) => _s.Item1)).toStringCommaSeperated() + ".";
		}
		if (_loc.is_location_disguised)
		{
			text += $"\n({_loc.visual_location.location_type})";
		}
		this.text.text = text;
	}

	public void setEmpty()
	{
		text.text = "";
	}

	public void setNull()
	{
		text.text = "<size=200%>X</size>";
	}

	public void click()
	{
		on_click(board_position);
	}

	private void Reset()
	{
		text = GetComponent<TMP_Text>();
	}
}
