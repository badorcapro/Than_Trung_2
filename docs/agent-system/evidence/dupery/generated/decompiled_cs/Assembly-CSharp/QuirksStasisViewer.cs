using System;
using System.Collections.Generic;
using GRGLib.Extensions.Unity;
using GRGLib.UI;
using Leads;
using UnityEngine;
using UnityEngine.UI;

public class QuirksStasisViewer : MonoBehaviour
{
	[SerializeField]
	private CaseQuirksVisualDataSO quirks_data;

	[SerializeField]
	private RoleVisualDataSO roles_data;

	[Header("References")]
	[SerializeField]
	private AnimatedLayoutGroup perm_layout_group;

	[SerializeField]
	private AnimatedLayoutGroup temp_layout_group;

	[Header("Prefabs")]
	[SerializeField]
	private StasisPolaroid perm_quirk_prefab;

	[SerializeField]
	private StasisPolaroid temp_quirk_prefab;

	private List<StasisPolaroid> polaroids = new List<StasisPolaroid>();

	public void setUpPermanentQuirks(List<CaseQuirks> _quirks, System.Random _rng)
	{
		for (int i = 0; i < _quirks.Count; i++)
		{
			StasisPolaroid stasisPolaroid = UnityEngine.Object.Instantiate(perm_quirk_prefab, perm_layout_group.transform);
			stasisPolaroid.transform.localEulerAngles = new Vector3(0f, 0f, _rng.Next(0, 8) * ((i % 2 == 0) ? 1 : (-1)));
			stasisPolaroid.setStasis(quirks_data[_quirks[i]], _quirks[i].createQuirk());
		}
		perm_layout_group.checkUpdate();
	}

	public void setUpClues(List<Clue> _clues, System.Random _rng)
	{
		for (int i = 0; i < _clues.Count; i++)
		{
			StasisPolaroid stasisPolaroid = UnityEngine.Object.Instantiate(temp_quirk_prefab, temp_layout_group.transform);
			stasisPolaroid.transform.localEulerAngles = new Vector3(0f, 0f, _rng.Next(0, 8) * ((i % 2 == 0) ? 1 : (-1)));
			if (_clues[i] is QuirkClue { quirk_in_focus: var quirk_in_focus })
			{
				stasisPolaroid.setStasis(quirks_data[quirk_in_focus], quirk_in_focus.createQuirk());
			}
			else if (_clues[i] is RoleClue { role_in_focus: var role_in_focus } roleClue)
			{
				stasisPolaroid.setStasis(roles_data[role_in_focus], (roleClue.clue_type == ClueTypes.ROLE_SUSPECTED) ? roles_data.getIconSuspectedColour() : ((roleClue.clue_type == ClueTypes.ROLE_IN_PLAY) ? roles_data[role_in_focus.getClassificationFromRoleType()].class_colour : roles_data.getIconNotInPlayColour()), roleClue);
			}
			polaroids.Add(stasisPolaroid);
		}
		temp_layout_group.checkUpdate();
	}

	public void setUpControllerSupport(Selectable _continue_button)
	{
		for (int i = 0; i < polaroids.Count; i++)
		{
			polaroids[i].getSelectable().setNavigationHorizontal((i == 0) ? null : polaroids[i - 1].getSelectable(), (i + 1 < polaroids.Count) ? polaroids[i + 1].getSelectable() : _continue_button);
			polaroids[i].getSelectable().setNavigationVertical((i - 4 >= 0) ? polaroids[i - 4].getSelectable() : null, (i + 4 < polaroids.Count) ? polaroids[i + 4].getSelectable() : _continue_button);
		}
		if (polaroids.Count > 0)
		{
			_continue_button.setNavigationLeft(polaroids[polaroids.Count - 1].getSelectable());
			_continue_button.setNavigationUp(polaroids[polaroids.Count - 1].getSelectable());
		}
	}
}
