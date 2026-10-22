using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using CaseCreation;
using Codex;
using ControllerSupport;
using GRGLib.Coroutines;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using GRGLib.UI;
using UnityEngine;
using UnityEngine.InputSystem;

namespace Visual;

public class SuspectListVisualManager : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private RectTransform region_visuals_parent;

	[SerializeField]
	private PenManager pen_manager;

	[SerializeField]
	private AnimatedLayoutGroup layout_group;

	[SerializeField]
	private SuspectExplanationManager explanation_manager;

	[Header("Prefabs")]
	[SerializeField]
	private SuspectVisual suspect_prefab;

	[Header("Settings")]
	[SerializeField]
	private int max_suspects_allowed = 25;

	private CaseControllerSupportHandler controller_support;

	private CodexMenu codex_menu;

	private List<SuspectVisual> suspects;

	private Func<CaseSnapshot> get_case_snap;

	public RectTransform suspects_parent => layout_group.transform as RectTransform;

	public RectTransform explanation_trans => explanation_manager.transform as RectTransform;

	public SuspectVisual top_most_suspect
	{
		get
		{
			if (suspects.Count != 0)
			{
				return suspects[0];
			}
			return null;
		}
	}

	public void resetList()
	{
		explanation_manager.forceCloseAndReset();
		suspects.destroyAll();
	}

	public bool getIsPointerOverSuspect()
	{
		return suspects.Any((SuspectVisual _e) => _e.getInRange());
	}

	public Maybe<SuspectVisual> getIsSuspectVisualWithPointerOverThem()
	{
		if (!getIsPointerOverSuspect())
		{
			return new Maybe<SuspectVisual>();
		}
		return suspects.Where((SuspectVisual _e) => _e.getInRange()).First().maybe();
	}

	public void setUp(CaseControllerSupportHandler _controller_handler, CodexMenu _codex_menu, PlayerInput _input, CaseSnapshot _snap, HashSet<RoleData> _suspect_list, RoleVisualDataSO _visuals_data, Func<CaseSnapshot> _get_snap)
	{
		controller_support = _controller_handler;
		codex_menu = _codex_menu;
		explanation_manager.setUpReferences(_input);
		get_case_snap = _get_snap;
		Dictionary<Roles, List<RoleData>> dictionary = new Dictionary<Roles, List<RoleData>>();
		_ = _snap.address_occupents;
		foreach (RoleData item in _suspect_list)
		{
			foreach (ITransformationGenerationConstraint item2 in item.getGenerationConstraints().getConstraintOfInterface<ITransformationGenerationConstraint>())
			{
				Maybe<Roles> added_role = item2.getRoleTransformed(item.role, _snap);
				if (added_role.is_some && !_suspect_list.Any((RoleData _r) => _r.role == added_role.value))
				{
					dictionary.addOrCreate(item.role, added_role.value.createEmptyRole());
				}
			}
		}
		List<(RoleData, int)> list = (List<(RoleData, int)>)((dictionary.Count != 0) ? ((IList)(from _s in _suspect_list.Select((RoleData _r) => (_r: _r, new Maybe<Roles>())).ToList().addRange<(RoleData, Maybe<Roles>)>(dictionary.Aggregate(new List<(RoleData, Maybe<Roles>)>(), (List<(RoleData, Maybe<Roles>)> _a, KeyValuePair<Roles, List<RoleData>> _kvp) => _a.addRange<(RoleData, Maybe<Roles>)>(_kvp.Value.Select((RoleData _r) => (_r: _r, _kvp.Key.maybe())))))
			orderby (!_s.Item2.is_some) ? ((float)_s.Item1.role) : ((float)_s.Item2.value + 0.5f)
			select (_s.Item1, _s.Item2.is_some ? 1 : 0)).ToList()) : ((IList)(from _s in _suspect_list
			orderby (int)_s.role
			select (_s: _s, 0)).ToList()));
		suspects = new List<SuspectVisual>();
		float size = 1f;
		if (list.Count > max_suspects_allowed)
		{
			size = (float)max_suspects_allowed / (float)list.Count;
		}
		for (int i = 0; i < list.Count; i++)
		{
			createSuspectVisual(list[i].Item1, list[i].Item2, _visuals_data, size);
		}
		layout_group.forceUpdateSequential(suspects.Count, 0.04f);
	}

	private SuspectVisual createSuspectVisual(RoleData _suspect, int _indent, RoleVisualDataSO _visuals_data, float _size = 1f)
	{
		SuspectVisual suspectVisual = UnityEngine.Object.Instantiate(suspect_prefab, suspects_parent);
		if (_size < 1f)
		{
			suspectVisual.setUpSize(_size);
		}
		suspectVisual.setUp(_suspect, _visuals_data, explanation_manager, _indent, get_case_snap);
		suspectVisual.setUpCallbacks(controller_support.onSelectSuspect, controller_support.onDeselectSuspect, openCodex);
		suspectVisual.setUpCrossOutCallback(pen_manager.cycleSuspectCross);
		suspects.add(suspectVisual);
		explanation_manager.setUpFakeVisual(suspectVisual);
		return suspectVisual;
	}

	public void checkSnapshotForAnimations(CaseSnapshot _snapshot)
	{
		List<RoleData> list = _snapshot.address_occupents.Values.Where((RoleData _a) => _a is IHaveAnimation).toListSafe();
		if (list.Count <= 0)
		{
			return;
		}
		foreach (RoleData occupent in list)
		{
			SuspectVisual suspectVisual = suspects.Find((SuspectVisual _s) => _s.role_type == occupent.role);
			if (suspectVisual != null)
			{
				suspectVisual.checkRoleAnimation(occupent as IHaveAnimation);
			}
		}
	}

	public bool revealAllSuspects(HashSet<RoleData> _suspect_list, RoleVisualDataSO _visuals_data, EmptySlot _right_most)
	{
		if (_suspect_list.Count == suspects.Count((SuspectVisual _s) => !_s.indented))
		{
			return false;
		}
		bool num = suspects.Count == 0;
		_suspect_list.forEach(delegate(RoleData _s)
		{
			addSuspect(_s, _visuals_data);
		});
		setUpSelectables(_right_most);
		if (num)
		{
			return suspects.Count != 0;
		}
		return false;
	}

	public bool checkAddSuspects(HashSet<RoleData> _suspect_list, RoleVisualDataSO _visuals_data, EmptySlot _right_most)
	{
		if (_suspect_list.Count == suspects.Count((SuspectVisual _s) => !_s.indented))
		{
			return false;
		}
		bool num = suspects.Count == 0;
		_suspect_list.forEach(delegate(RoleData _s)
		{
			addSuspect(_s, _visuals_data);
		});
		setUpSelectables(_right_most);
		if (num)
		{
			return suspects.Count != 0;
		}
		return false;
	}

	private void addSuspect(RoleData _suspect, RoleVisualDataSO _visuals_data)
	{
		if (!suspects.Exists((SuspectVisual _s) => _s.role_type == _suspect.role))
		{
			createSuspectVisual(_suspect, 0, _visuals_data);
			layout_group.forceUpdate(suspects.Count);
		}
	}

	public void setUpSelectables(EmptySlot _rightmost_slot)
	{
		for (int i = 0; i < suspects.Count; i++)
		{
			suspects[i].setUpSelectables(_rightmost_slot.getSelectable(), (i == 0) ? null : suspects[i - 1].getSelectable(), (i == suspects.Count - 1) ? null : suspects[i + 1].getSelectable());
		}
	}

	public void trySelectRole(Roles _role)
	{
		foreach (SuspectVisual suspect in suspects)
		{
			if (suspect.role_type == _role)
			{
				suspect.getSelectable().Select();
				break;
			}
		}
	}

	public void openCodex(Roles _role)
	{
		codex_menu.openPage(_role, get_case_snap().maybe());
	}

	public void addSuspectLinesFromSave(Dictionary<Roles, ControllerSuspectLineTypes> _lines)
	{
		1.35f.wait(delegate
		{
			foreach (KeyValuePair<Roles, ControllerSuspectLineTypes> lne in _lines)
			{
				pen_manager.toggleSuspectCross(suspects.Find((SuspectVisual _s) => _s.role_type == lne.Key), lne.Value);
			}
		}).start(this);
	}

	public void setUpForSelection(Action<SuspectAbilityData> _callback)
	{
		suspects.ForEach(delegate(SuspectVisual _s)
		{
			_s.setUpOverrideCallback(delegate(Roles _r)
			{
				_callback(new SuspectAbilityData(_r));
			});
		});
	}

	public void resetNormalSelection()
	{
		suspects.ForEach(delegate(SuspectVisual _s)
		{
			_s.resetCallback();
		});
	}
}
