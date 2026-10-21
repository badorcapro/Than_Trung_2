using GRGLib.Maybe;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace Codex;

public class CodexMultiRolePage : CodexRolePage
{
	[Header("Second Role Settings")]
	[SerializeField]
	private Image second_icon;

	[SerializeField]
	private TMP_Text second_name_text;

	[SerializeField]
	private TMP_Text second_classification_text;

	[SerializeField]
	private TMP_Text second_description_text;

	protected override void setUpWithSampleRole(RoleData _sample, Maybe<CaseSnapshot> _snap)
	{
		base.setUpWithSampleRole(_sample, _snap);
		Debug.LogError("THIS IS BROKEN. PLEASE FIX");
	}
}
