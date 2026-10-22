using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Coroutines;
using GRGLib.Extensions.Collections;
using GRGLib.Generic;
using GRGLib.Maybe;
using GRGLib.Serializable;
using TMPro;
using UnityEngine;

namespace Codex;

public class CodexRoleMenu : CodexPage
{
	public class RoleSelectionData
	{
		public Action<List<Roles>> selection_callback;

		public Dictionary<RoleClassifications, int> min_required;

		public List<Roles> selected = new List<Roles>();

		public List<Roles> locked = new List<Roles>();

		public CodexClassInfo info;

		public RoleSelectionData(Action<List<Roles>> _callback, Dictionary<RoleClassifications, int> _min, List<Roles> _locked, List<Roles> _selected, CodexClassInfo _info)
		{
			selection_callback = _callback;
			min_required = _min;
			locked = _locked;
			selected = _selected;
			info = _info;
		}

		public bool tryToggleRole(int _role, bool _to)
		{
			return tryToggleRole((Roles)_role, _to);
		}

		public bool tryToggleRole(Roles _role, bool _to)
		{
			RoleClassifications classification = _role.getClassificationFromRoleType();
			if (_to)
			{
				selected.addIfNotDuplicate(_role);
				info.setUpAsSelection(min_required[classification], selected.Count((Roles _r) => _r.getClassificationFromRoleType() == classification), _roles: true);
				return true;
			}
			int num = selected.Count((Roles _r) => _r.getClassificationFromRoleType() == classification);
			if (num <= min_required[classification])
			{
				return false;
			}
			selected.Remove(_role);
			info.setUpAsSelection(min_required[classification], num - 1, _roles: true);
			return true;
		}
	}

	public class QuirkSelectionData
	{
		public Action<List<CaseQuirks>> selection_callback;

		public MinMaxInt required_range;

		public List<CaseQuirks> selected = new List<CaseQuirks>();

		public List<CaseQuirks> locked = new List<CaseQuirks>();

		public CodexClassInfo info;

		public QuirkSelectionData(Action<List<CaseQuirks>> _callback, MinMaxInt _required, List<CaseQuirks> _locked, List<CaseQuirks> _selected, CodexClassInfo _info)
		{
			selection_callback = _callback;
			required_range = _required;
			selected = _selected;
			locked = _locked;
			info = _info;
		}

		public bool tryToggleQuirk(int _quirk, bool _to)
		{
			return tryToggleQuirk((CaseQuirks)_quirk, _to);
		}

		public bool tryToggleQuirk(CaseQuirks _quirk, bool _to)
		{
			if (_to)
			{
				if (selected.Count >= required_range.max)
				{
					return false;
				}
				selected.addIfNotDuplicate(_quirk);
				setInfoSelectionText();
				return true;
			}
			if (selected.Count <= required_range.min)
			{
				return false;
			}
			selected.Remove(_quirk);
			setInfoSelectionText();
			return true;
		}

		public void setInfoSelectionText()
		{
			if (required_range.min == 0)
			{
				info.setUpAsMaxQuirkSelection(required_range.max, selected.Count);
			}
			else
			{
				info.setUpAsSelection(required_range.min, selected.Count, _roles: false);
			}
		}
	}

	private CodexMenu parent_menu;

	[SerializeField]
	private SerializableDictionary<RoleClassifications, STupple<JiggleButton, TMP_Text>> class_buttons;

	[SerializeField]
	private JiggleButton quirks_button;

	[SerializeField]
	private JiggleButton shortcut_button;

	[SerializeField]
	private CodexSelectionMenu codex_role_selection;

	[SerializeField]
	private CodexClassInfo codex_class_info;

	[SerializeField]
	private CanvasGroup section_swap_group;

	private Maybe<JiggleButton> previous_section_button = new Maybe<JiggleButton>();

	private CoroutineRunner section_swap;

	private JiggleButton close_button;

	private Maybe<Regions> innit_region;

	private Maybe<RoleClassifications> innit_role_class;

	public Maybe<RoleSelectionData> role_selection { get; private set; } = new Maybe<RoleSelectionData>();

	public Maybe<QuirkSelectionData> quirk_selection { get; private set; } = new Maybe<QuirkSelectionData>();

	public void setUpCodexWithSelection(CodexMenu _menu, RoleClassifications _class, JiggleButton _close_button, Regions _region, List<Roles> _locked, List<Roles> _selected, Dictionary<RoleClassifications, int> _min_required, Action<List<Roles>> _callback)
	{
		innit_role_class = _class.maybe();
		innit_region = _region.maybe();
		role_selection = new RoleSelectionData(_callback, _min_required, _locked, _selected, codex_class_info).maybe();
		quirks_button.gameObject.SetActive(value: false);
		shortcut_button.gameObject.SetActive(value: false);
		setUpCodex(_menu, delegate
		{
			setUpClass(_class);
		}, _close_button, _region.maybe());
	}

	public void setUpCodex(CodexMenu _menu, RoleClassifications _class, JiggleButton _close_button, Maybe<Regions> _region)
	{
		innit_role_class = _class.maybe();
		innit_region = _region;
		setUpCodex(_menu, delegate
		{
			setUpClass(_class);
		}, _close_button, _region);
	}

	public void setUpCodexWithSelection(CodexMenu _menu, JiggleButton _close_button, Regions _region, List<CaseQuirks> _locked, List<CaseQuirks> _selected, MinMaxInt _required, Action<List<CaseQuirks>> _callback)
	{
		innit_role_class = new Maybe<RoleClassifications>();
		innit_region = _region.maybe();
		quirk_selection = new QuirkSelectionData(_callback, _required, _locked, _selected, codex_class_info).maybe();
		foreach (KeyValuePair<RoleClassifications, STupple<JiggleButton, TMP_Text>> class_button in class_buttons)
		{
			class_button.Value.Item1.gameObject.SetActive(value: false);
		}
		shortcut_button.gameObject.SetActive(value: false);
		setUpCodex(_menu, setUpQuirks, _close_button, _region.maybe());
	}

	public void setUpCodexQuirks(CodexMenu _menu, JiggleButton _close_button, Maybe<Regions> _region)
	{
		innit_role_class = new Maybe<RoleClassifications>();
		innit_region = _region;
		setUpCodex(_menu, setUpQuirks, _close_button, _region);
	}

	private void setUpCodex(CodexMenu _menu, Action _set_up, JiggleButton _close_button, Maybe<Regions> _region)
	{
		parent_menu = _menu;
		section_swap = new CoroutineRunner(this);
		codex_role_selection.setUp(_menu, class_buttons[RoleClassifications.INNOCENT].Item1, class_buttons[RoleClassifications.MEDDLER].Item1, _close_button, _region);
		_set_up();
		class_buttons[RoleClassifications.INNOCENT].Item1.addUpSelectable(_close_button);
		class_buttons[RoleClassifications.MEDDLER].Item1.addUpSelectable(_close_button);
		class_buttons[RoleClassifications.INNOCENT].Item2.text = RoleClassifications.INNOCENT.toStringPlain();
		class_buttons[RoleClassifications.MEDDLER].Item2.text = RoleClassifications.MEDDLER.toStringPlain();
		class_buttons[RoleClassifications.UNDERLING].Item2.text = RoleClassifications.UNDERLING.toStringPlain();
		class_buttons[RoleClassifications.TRAITOR].Item2.text = RoleClassifications.TRAITOR.toStringPlain();
		_close_button.addDownSelectables(class_buttons[RoleClassifications.INNOCENT].Item1, class_buttons[RoleClassifications.MEDDLER].Item1);
		close_button = _close_button;
	}

	public void openInnocent()
	{
		openPage(RoleClassifications.INNOCENT);
	}

	public void openMeddler()
	{
		openPage(RoleClassifications.MEDDLER);
	}

	public void openUnderling()
	{
		openPage(RoleClassifications.UNDERLING);
	}

	public void openTraitor()
	{
		openPage(RoleClassifications.TRAITOR);
	}

	public void openShortcut()
	{
		if (innit_role_class.is_some)
		{
			parent_menu.openShortcutMenuPage(innit_region, innit_role_class.value);
		}
		else
		{
			parent_menu.openShortcutMenuPage(innit_region);
		}
	}

	private void openPage(RoleClassifications _classification)
	{
		if (!section_swap.is_running)
		{
			section_swap.run(section_swap_group.fade(0f, 0.15f, CoroutineExtensions.easeInOutFunc).addCallback(delegate
			{
				setUpClass(_classification);
				section_swap.run(section_swap_group.fade(1f, 0.35f, CoroutineExtensions.easeInOutFunc));
			}));
		}
	}

	private void setUpClass(RoleClassifications _classification)
	{
		if (previous_section_button.is_some)
		{
			previous_section_button.value.interactable = true;
		}
		previous_section_button = class_buttons[_classification].Item1.maybe();
		class_buttons[_classification].Item1.interactable = false;
		if (role_selection.is_some)
		{
			List<Roles> list = codex_role_selection.setUpClassForSelection(_classification, role_selection.value.locked, role_selection.value.selected, role_selection.value.tryToggleRole, getButtons());
			codex_class_info.setUpAsSelection(role_selection.value.min_required[_classification], role_selection.value.selected.Count((Roles _r) => _r.getClassificationFromRoleType() == _classification), _roles: true);
		}
		else
		{
			List<Roles> list = codex_role_selection.setUpClass(_classification, getButtons());
			codex_class_info.setUpClass(_classification, list);
		}
	}

	public void openQuirks()
	{
		if (!section_swap.is_running)
		{
			section_swap.run(section_swap_group.fade(0f, 0.15f, CoroutineExtensions.easeInOutFunc).addCallback(delegate
			{
				setUpQuirks();
				section_swap.run(section_swap_group.fade(1f, 0.35f, CoroutineExtensions.easeInOutFunc));
			}));
		}
	}

	private void setUpQuirks()
	{
		if (previous_section_button.is_some)
		{
			previous_section_button.value.interactable = true;
		}
		previous_section_button = quirks_button.maybe();
		quirks_button.interactable = false;
		if (quirk_selection.is_some)
		{
			codex_role_selection.setUpQuirsForSelection(quirk_selection.value.locked, quirk_selection.value.selected, quirk_selection.value.tryToggleQuirk, getButtons());
			quirk_selection.value.setInfoSelectionText();
		}
		else
		{
			List<CaseQuirks> upQuirks = codex_role_selection.setUpQuirks(getButtons());
			codex_class_info.setUpQuirks(upQuirks);
		}
	}

	private List<(JiggleButton, Maybe<JiggleButton>)> getButtons()
	{
		return class_buttons.Select((KeyValuePair<RoleClassifications, STupple<JiggleButton, TMP_Text>> _b) => (_b.Value.Item1, (_b.Key == RoleClassifications.MEDDLER) ? class_buttons[RoleClassifications.INNOCENT].Item1.maybe() : ((_b.Key == RoleClassifications.TRAITOR) ? class_buttons[RoleClassifications.UNDERLING].Item1.maybe() : new Maybe<JiggleButton>()))).ToList().add((quirks_button, new Maybe<JiggleButton>()));
	}

	public override void immidiateDestroy()
	{
		close_button.clearUpSelectable();
		base.immidiateDestroy();
	}

	public override void fadeOutAndDestroy()
	{
		section_swap.stop();
		close_button.clearUpSelectable();
		base.fadeOutAndDestroy();
	}
}
