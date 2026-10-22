using System;
using System.Collections.Generic;
using GRGLib.Generic;
using Nodes.Logic;
using Save;
using UnityEngine;

namespace Leads;

public class CaseToCaseLead : Lead
{
	[Serializable]
	public struct CTCLeadData
	{
		public CaseType case_type;

		public List<CaseSave> cases;

		public string region_data;

		public CTCLeadData(CaseType _type, List<CaseSave> _cases, string _data)
		{
			case_type = _type;
			cases = _cases;
			region_data = _data;
		}
	}

	private CTCLeadData lead_data;

	private List<CaseSave> cases => lead_data.cases;

	private string save_data => lead_data.region_data;

	private int data_as_int
	{
		get
		{
			if (!(save_data == ""))
			{
				return int.Parse(save_data);
			}
			return 0;
		}
	}

	public override CaseType case_type => lead_data.case_type;

	public CaseToCaseLead(List<CaseSave> _cases, CaseType _case_type, string _starting_data)
		: base(new List<Roles>(), new List<Vector2Int>(), new MinMaxFloat(0f, 1f), _cases.Count, new RoleSetInfoStruct("", "", new List<Roles>(), RoleSetsGraph.SetsType.NONE))
	{
		lead_data = new CTCLeadData(_case_type, _cases, _starting_data);
	}

	public CaseToCaseLead(LeadSaveData _save)
		: base(_save)
	{
		lead_data = JsonUtility.FromJson<CTCLeadData>(_save.unique_data);
	}

	public override Case createCase(GameState _state)
	{
		return createCaseNumber(Mathf.Clamp(base.current_case, 0, cases.Count - 1));
	}

	private Case createCaseNumber(int _nb)
	{
		Case @case = CaseSave.toCase(cases[_nb]);
		if (@case is ClockCase clockCase)
		{
			clockCase.setReputationFromCBCLead(this, data_as_int);
		}
		else if (@case is CasinoCase casinoCase)
		{
			casinoCase.setChipsFromCBCLead(this, data_as_int);
		}
		else if (@case is DocksCase docksCase)
		{
			docksCase.setReputationFromCBCLead(this, data_as_int);
		}
		return @case;
	}

	public override CaseReward createCaseReward(GameState _state)
	{
		return null;
	}

	public override Case createRandomCase(System.Random _rng)
	{
		return createCaseNumber(_rng.Next(0, cases.Count));
	}

	public override string uniqueSaveData()
	{
		return JsonUtility.ToJson(lead_data);
	}

	protected override void applyReward(Case _case, CaseReward _reward)
	{
	}
}
