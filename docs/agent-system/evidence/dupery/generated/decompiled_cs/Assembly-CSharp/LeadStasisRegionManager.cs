using CaseSelection;
using Leads;
using UnityEngine;
using Visual;

public class LeadStasisRegionManager : MonoBehaviour
{
	[Header("Prefabs")]
	[SerializeField]
	private CaseSelectionReputationManager reputation_manager_prefab;

	[SerializeField]
	private CasinoChipsManager chips_manager_prefab;

	public void setUpLead(Lead _lead)
	{
		if (_lead is OfficeLead officeLead)
		{
			CaseSelectionReputationManager caseSelectionReputationManager = Object.Instantiate(reputation_manager_prefab, base.transform);
			caseSelectionReputationManager.setReputation(officeLead.reputation);
			(caseSelectionReputationManager.transform as RectTransform).anchoredPosition = new Vector3(0f, 0f, 0f);
		}
		else if (_lead is CasinoLead casinoLead)
		{
			CasinoChipsManager casinoChipsManager = Object.Instantiate(chips_manager_prefab, base.transform);
			casinoChipsManager.setUp();
			casinoChipsManager.setChips(casinoLead.chips, _hidden: false);
		}
		else if (_lead is DocksLead docksLead)
		{
			CaseSelectionReputationManager caseSelectionReputationManager2 = Object.Instantiate(reputation_manager_prefab, base.transform);
			caseSelectionReputationManager2.setReputation(docksLead.reputation);
			(caseSelectionReputationManager2.transform as RectTransform).anchoredPosition = new Vector3(0f, 0f, 0f);
		}
	}
}
