using System.Collections;
using System.Collections.Generic;
using Codex;
using GRGLib.Coroutines;
using Leads;
using Quirks;
using UnityEngine;

namespace Visual;

public class CaseQuirkListVisualManager : MonoBehaviour
{
	[SerializeField]
	private CaseQuirksVisualDataSO quirks_data;

	[SerializeField]
	private RoleVisualDataSO roles_data;

	[Header("References")]
	[SerializeField]
	private RectTransform quirk_parents;

	[SerializeField]
	private CaseQuirkExplanation quirk_explanation;

	[Header("Prefabs")]
	[SerializeField]
	private CaseQuirkVisual quirk_visual_prefab;

	[SerializeField]
	private CaseQuirkVisual clue_visual_prefab;

	[Header("Settings")]
	[SerializeField]
	private Vector2 first_quirk_position;

	[SerializeField]
	private Vector2 next_quirk_offset;

	[SerializeField]
	private Vector2 animation_offset;

	private CodexMenu codex_menu;

	private List<CaseQuirkVisual> quirk_visuals = new List<CaseQuirkVisual>();

	public bool is_set_up { get; private set; }

	private void setUpSelectables(List<EmptySlot> _board_min)
	{
		if (is_set_up && quirk_visuals.Count != 0)
		{
			for (int i = 0; i < quirk_visuals.Count; i++)
			{
				quirk_visuals[i].setUpSelectables((i == 0) ? null : quirk_visuals[i - 1].getSelectable(), (i == quirk_visuals.Count - 1) ? null : quirk_visuals[i + 1].getSelectable(), _board_min[0].getSelectable());
			}
			_board_min.ForEach(delegate(EmptySlot _e)
			{
				_e.setUpDownNavigation(quirk_visuals[0].getSelectable());
			});
		}
	}

	public void setUp(CodexMenu _codex, List<Either<CaseQuirkData, Clue>> _quirks_clues, List<EmptySlot> _board_min)
	{
		codex_menu = _codex;
		is_set_up = false;
		setUpAnimated(_quirks_clues).addCallback(delegate
		{
			setUpSelectables(_board_min);
		}).start(this);
	}

	private IEnumerator setUpAnimated(List<Either<CaseQuirkData, Clue>> _quirks_clues)
	{
		for (int i = 0; i < _quirks_clues.Count; i++)
		{
			Vector2 vector = first_quirk_position + next_quirk_offset * i;
			quirk_visuals.Add(createQuirk(_quirks_clues[i], vector + animation_offset, vector));
			yield return 0.1f.wait();
		}
		is_set_up = true;
	}

	private CaseQuirkVisual createQuirk(Either<CaseQuirkData, Clue> _quirk, Vector2 _starting_pos, Vector2 _target_pos)
	{
		CaseQuirkVisual caseQuirkVisual = Object.Instantiate(_quirk.is_a ? quirk_visual_prefab : clue_visual_prefab, quirk_parents);
		(caseQuirkVisual.transform as RectTransform).anchoredPosition = _starting_pos;
		caseQuirkVisual.animateToPosition(_target_pos);
		if (_quirk.is_a)
		{
			caseQuirkVisual.setUp(_quirk.maybe_a.value, quirks_data[_quirk.maybe_a.value.quirk_type], explainQuirk, stopExplaining, openCodexForQuirk);
		}
		else if (_quirk.maybe_b.value is RoleClue roleClue)
		{
			caseQuirkVisual.setUp(roleClue, roles_data[roleClue.role_in_focus], roleClue.getIconColour(roles_data), explainQuirk, stopExplaining);
		}
		else
		{
			Debug.LogError($"No set up function made for clue type {_quirk.maybe_b.value.clue_type}!");
		}
		return caseQuirkVisual;
	}

	private void explainQuirk(CaseQuirkVisual _quirk)
	{
		quirk_explanation.explainText(_quirk, _quirk.explain_string);
	}

	private void stopExplaining(CaseQuirkVisual _quirk)
	{
		quirk_explanation.tryClose(_quirk);
	}

	private void openCodexForQuirk(CaseQuirks _quirk)
	{
		codex_menu.openPage(_quirk);
	}
}
