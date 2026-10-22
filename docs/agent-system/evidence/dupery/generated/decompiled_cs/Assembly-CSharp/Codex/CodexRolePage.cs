using System.Collections.Generic;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using TMPro;
using UnityEngine;

namespace Codex;

public class CodexRolePage : CodexEntryPage
{
	[Header("Role Page References")]
	[SerializeField]
	protected TMP_Text classification_text;

	[SerializeField]
	protected TMP_Text bottom_comment_text;

	[SerializeField]
	protected GameObject golden_star;

	[Space]
	[SerializeField]
	protected RoleVisualDataSO role_data;

	public void setUpPage(Roles _role, Maybe<CaseSnapshot> _snap)
	{
		RoleData roleData = _role.createEmptyRole();
		RoleVisualDataSO.ClassificationVisualData classificationVisualData = role_data[_role.getClassificationFromRoleType()];
		setUp(role_data[_role], roleData.name, roleData.description, roleData.extra_descriptions, (roleData.credits.Length > 1) ? new Maybe<(string, Color)>((roleData.credits, classificationVisualData.class_colour)) : new Maybe<(string, Color)>());
		icon_image.color = classificationVisualData.class_colour;
		classification_text.text = _role.getClassificationFromRoleType().toString() + " | " + _role.getAlignmentFromRoleType().toStringCap();
		setUpWithSampleRole(roleData, _snap);
		golden_star.gameObject.SetActive(GameHandler.StatsData.hasWonWithSuspect(_role));
	}

	protected virtual void setUpWithSampleRole(RoleData _sample, Maybe<CaseSnapshot> _snap)
	{
	}

	protected override List<TMP_Text> getAllHoverableTexts()
	{
		return new List<TMP_Text> { classification_text }.addRange(base.getAllHoverableTexts());
	}
}
