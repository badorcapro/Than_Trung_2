using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Coroutines;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Unity;
using GRGLib.Maybe;
using GRGLib.UI;
using GRGLocalisation;
using Localisation;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace Codex;

public class CodexSelectionMenu : MonoBehaviour, IAmLocalised
{
	[SerializeField]
	private RoleVisualDataSO visual_data;

	[SerializeField]
	private CaseQuirksVisualDataSO quirks_data;

	[SerializeField]
	private RegionsSO region_data;

	[Header("References")]
	[SerializeField]
	private CanvasGroup group;

	[SerializeField]
	private AnimatedLayoutGroup layout_group;

	[SerializeField]
	private TMP_Text title;

	[Header("Prefabs")]
	[SerializeField]
	private CodexSelection codex_selection_prefab;

	[Header("Settings")]
	[SerializeField]
	private int roles_per_row = 6;

	[SerializeField]
	private Color greyed_colour;

	[SerializeField]
	private Color quirks_greyed_colour;

	private CodexMenu codex;

	private List<CodexSelection> selections = new List<CodexSelection>();

	private RoleClassifications current_classification;

	private Maybe<Regions> region = new Maybe<Regions>();

	private (Selectable, Selectable) top_selectables_right;

	private Selectable close_selectable;

	private AssetKey localisation_asset => LocalisationHelper.ui_asset;

	private string loc_quirks_english => "Quirks";

	public void setUp(CodexMenu _menu, Selectable _top_selectable, Selectable _backup_selectable, Selectable _close, Maybe<Regions> _region)
	{
		codex = _menu;
		top_selectables_right = (_top_selectable, _backup_selectable);
		close_selectable = _close;
		region = _region;
	}

	private List<Roles> setUpClassBase(RoleClassifications _classification)
	{
		selections.destroyAll();
		title.text = _classification.toStringPlain();
		current_classification = _classification;
		if (!region.is_some)
		{
			if (GameHandler.instance.current_scene == "LevelEditorScene" && GameHandler.instance.level_editor_case.is_some)
			{
				return (from _r in GameHandler.instance.level_editor_case.value.case_type.getRoleList()
					where _r.getClassificationFromRoleType() == _classification
					select _r).ToList();
			}
			return _classification switch
			{
				RoleClassifications.INNOCENT => RoleHelper.getInnocentRoleList(), 
				RoleClassifications.MEDDLER => RoleHelper.getMeddlerRoleList(), 
				RoleClassifications.UNDERLING => RoleHelper.getUnderlingRoleList(), 
				RoleClassifications.TRAITOR => RoleHelper.getTraitorRoleList(), 
				_ => throw new ArgumentException($"No list found for classification {_classification}! (CodexSelectionMenu.setUpClass)"), 
			};
		}
		return (from _r in region_data[region.value].getAvailableRoles(GameHandler.MetaData.getTierOfRegion(region.value))
			where _r.getClassificationFromRoleType() == _classification
			select _r).ToList();
	}

	public List<Roles> setUpClassForSelection(RoleClassifications _class, List<Roles> _locked, List<Roles> _selected, Func<int, bool, bool> _callback, List<(JiggleButton, Maybe<JiggleButton>)> _buttons)
	{
		List<Roles> list = setUpClassBase(_class);
		for (int i = 0; i < list.Count; i++)
		{
			CodexSelection codexSelection = UnityEngine.Object.Instantiate(codex_selection_prefab, layout_group.transform);
			codexSelection.setUpAsSelection((int)list[i], visual_data[_class].class_colour, visual_data[list[i]], openRoleSelection, _callback, _selected.Contains(list[i]), _locked.Contains(list[i]));
			selections.Add(codexSelection);
		}
		Selectable top_select = ((_class == RoleClassifications.INNOCENT) ? top_selectables_right.Item2 : top_selectables_right.Item1);
		setUpSelectables(top_select, _buttons);
		return list;
	}

	public List<Roles> setUpClass(RoleClassifications _classification, List<(JiggleButton, Maybe<JiggleButton>)> _buttons)
	{
		List<Roles> list = setUpClassBase(_classification);
		for (int i = 0; i < list.Count; i++)
		{
			CodexSelection codexSelection = UnityEngine.Object.Instantiate(codex_selection_prefab, layout_group.transform);
			bool flag = GameHandler.StatsData.roles_discovered.Contains(list[i]);
			Color colour = (flag ? visual_data[_classification].class_colour : greyed_colour);
			codexSelection.setUp((int)list[i], colour, flag, visual_data[list[i]], openRoleSelection);
			selections.Add(codexSelection);
		}
		Selectable top_select = ((_classification == RoleClassifications.INNOCENT) ? top_selectables_right.Item2 : top_selectables_right.Item1);
		setUpSelectables(top_select, _buttons);
		return list;
	}

	private List<CaseQuirks> setUpBaseQuirks()
	{
		selections.destroyAll();
		title.text = localisation_asset.checkTranslation(loc_quirks_english, () => loc_quirks_english);
		current_classification = (RoleClassifications)(-1);
		if (!region.is_some)
		{
			if (GameHandler.instance.current_scene == "LevelEditorScene" && GameHandler.instance.level_editor_case.is_some)
			{
				CaseType case_type = GameHandler.instance.level_editor_case.value.case_type;
				return CaseQuirkHelper.getAllQuirks((CaseQuirks _q) => _q.createQuirk().isCompatible(case_type));
			}
			return CaseQuirkHelper.getAllQuirks();
		}
		return region_data[region.value].getAvailableQuirks(GameHandler.MetaData.getTierOfRegion(region.value));
	}

	public List<CaseQuirks> setUpQuirsForSelection(List<CaseQuirks> _locked, List<CaseQuirks> _selected, Func<int, bool, bool> _callback, List<(JiggleButton, Maybe<JiggleButton>)> _buttons)
	{
		List<CaseQuirks> list = setUpBaseQuirks();
		for (int i = 0; i < list.Count; i++)
		{
			CodexSelection codexSelection = UnityEngine.Object.Instantiate(codex_selection_prefab, layout_group.transform);
			codexSelection.setUpAsSelection((int)list[i], Color.white, quirks_data[list[i]], openQuirkSelection, _callback, _selected.Contains(list[i]), _locked.Contains(list[i]), 0.93f);
			selections.Add(codexSelection);
		}
		setUpSelectables(top_selectables_right.Item1, _buttons);
		return list;
	}

	public List<CaseQuirks> setUpQuirks(List<(JiggleButton, Maybe<JiggleButton>)> _buttons)
	{
		List<CaseQuirks> list = setUpBaseQuirks();
		for (int i = 0; i < list.Count; i++)
		{
			CodexSelection codexSelection = UnityEngine.Object.Instantiate(codex_selection_prefab, layout_group.transform);
			bool flag = GameHandler.StatsData.played_case_quirks.Contains(list[i]);
			Color colour = (flag ? Color.white : quirks_greyed_colour);
			codexSelection.setUp((int)list[i], colour, flag, quirks_data[list[i]], openQuirkSelection, 0.93f);
			selections.Add(codexSelection);
		}
		setUpSelectables(top_selectables_right.Item1, _buttons);
		return list;
	}

	private void setUpSelectables(Selectable _top_select, List<(JiggleButton, Maybe<JiggleButton>)> _buttons)
	{
		for (int i = 0; i < selections.Count; i++)
		{
			int num = i - roles_per_row;
			int num2 = i + roles_per_row;
			int num3 = ((i % roles_per_row == roles_per_row - 1 || i + 1 >= selections.Count) ? (-1) : (i + 1));
			int id = ((i % roles_per_row == 0) ? (-1) : (i - 1));
			selections[i].setUpNavigation((num < 0) ? close_selectable : getSelectableFromId(num), getSelectableFromId(num2), getSelectableFromId(id), getSelectableFromId(num3));
			if (num3 == -1)
			{
				selections[i].setSpecialRightNavigation(_top_select);
			}
			if (num2 > selections.Count)
			{
				selections[i].setSpecialDownNavigation(_top_select);
			}
		}
		foreach (var _button in _buttons)
		{
			_button.Item1.clearLeftSelectable();
			if (_button.Item2.is_some)
			{
				_button.Item1.addLeftSelectable(_button.Item2.value);
			}
			_button.Item1.addLeftSelectable(selections[selections.Count - 1].getSelectable());
		}
		close_selectable.setNavigationLeft(selections[(roles_per_row <= selections.Count) ? (roles_per_row - 1) : (selections.Count - 1)].getSelectable());
		0.01f.wait(delegate
		{
			layout_group.forceUpdate(selections.Count);
		}).start(this);
		if (GameHandler.instance.using_gamepad)
		{
			selections[0].getSelectable().Select();
		}
	}

	private Selectable getSelectableFromId(int _id)
	{
		if (_id < 0 || _id >= selections.Count)
		{
			return null;
		}
		return selections[_id].getSelectable();
	}

	private void openRoleSelection(int _role)
	{
		openSelection((Roles)_role);
	}

	private void openSelection(Roles _role)
	{
		codex.openPage(_role, new Maybe<CaseSnapshot>(), _open_codex: false);
		codex.changeCloseButtonToBackWithCallback(delegate
		{
			if (region.is_some)
			{
				codex.openRegionPage(region.value, current_classification, _open_codex: false);
			}
			else
			{
				codex.openRoleMenuPage(_open_codex: false, current_classification);
			}
		});
	}

	private void openQuirkSelection(int _quirk)
	{
		openSelection((CaseQuirks)_quirk);
	}

	private void openSelection(CaseQuirks _quirk)
	{
		codex.openPage(_quirk, _open_codex: false);
		codex.changeCloseButtonToBackWithCallback(delegate
		{
			codex.openQuirkMenuPage(region, _open_codex: false);
		});
	}
}
