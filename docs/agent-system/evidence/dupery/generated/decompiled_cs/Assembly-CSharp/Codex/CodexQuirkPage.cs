using System.Collections.Generic;
using GRGLib.Maybe;
using Quirks;
using UnityEngine;

namespace Codex;

public class CodexQuirkPage : CodexEntryPage
{
	[Space]
	[SerializeField]
	private CaseQuirksVisualDataSO quirk_visuals;

	public void setUpPage(CaseQuirks _quirk)
	{
		CaseQuirkData caseQuirkData = _quirk.createQuirk();
		setUp(quirk_visuals[_quirk], caseQuirkData.name, caseQuirkData.description, (caseQuirkData.extra_description == "") ? new List<(DescriptionType, string)>() : new List<(DescriptionType, string)> { (DescriptionType.SPECIAL, caseQuirkData.extra_description) }, (caseQuirkData.credit.Length > 1) ? new Maybe<(string, Color)>((caseQuirkData.credit, Color.white)) : new Maybe<(string, Color)>());
	}
}
