using System.Collections.Generic;
using System.Linq;
using CaseCreation;
using GRGLib.Extensions.Collections;
using GRGLib.UI;
using UnityEngine;

namespace LevelEditor;

public class LESuspectList : MonoBehaviour
{
	[SerializeField]
	private RoleVisualDataSO role_data;

	[Header("References")]
	[SerializeField]
	private LevelEditorManager manager;

	[SerializeField]
	private AnimatedLayoutGroup layout_group;

	[SerializeField]
	private LESuspect add_suspect;

	[SerializeField]
	private LEErrorMarker error_marker;

	[SerializeField]
	private LEAdderMenu adder;

	[SerializeField]
	private LEProblemHighlighter problem_highlighter;

	[Header("Prefabs")]
	[SerializeField]
	private LESuspect suspect_prefab;

	private List<Roles> vetoed = new List<Roles>();

	private HashSet<Roles> wanted_roles = new HashSet<Roles>();

	private List<RoleData> in_play = new List<RoleData>();

	private Dictionary<Roles, LESuspect> current_suspects = new Dictionary<Roles, LESuspect>();

	public List<Roles> suspect_list => current_suspects.Keys.ToList();

	public List<Roles> adder_menu_vetoes => suspect_list.addRange(vetoed);

	private LESuspect getSuspect(Roles _role)
	{
		if (!current_suspects.ContainsKey(_role))
		{
			LESuspect lESuspect = Object.Instantiate(suspect_prefab, layout_group.transform);
			lESuspect.setUp(_role, role_data, _is_transform: false, tryRemove);
			lESuspect.setUpHover(onHoverStart, onHoverEnd);
			current_suspects[_role] = lESuspect;
		}
		return current_suspects[_role];
	}

	public void setUpFromExisting(HashSet<RoleData> _suspects)
	{
		setUp();
		wanted_roles = _suspects.Select((RoleData _r) => _r.role).toHashSet();
		updateList(new List<RoleData>(), new List<Roles>());
	}

	public void setUp()
	{
		add_suspect.setUpAdding(delegate
		{
			adder.openMenu();
			adder.setUpRoles(manager.creating_case.case_type, adder_menu_vetoes);
			adder.setUpChoiceCallback(delegate(LEAdderItem _i)
			{
				addRoleToSuspectList(_i.role.value);
			});
		});
		add_suspect.setUpHover(delegate
		{
		}, delegate
		{
		});
	}

	public void updateList(List<RoleData> _in_play_roles, List<Roles> _vetoed)
	{
		vetoed = _vetoed;
		in_play = _in_play_roles.ToList();
		HashSet<Roles> hashSet = wanted_roles.copy();
		foreach (RoleData item in in_play)
		{
			hashSet.Add(item.role);
			if (item.getDisguise().is_some)
			{
				hashSet.add(item.getDisguise().value.role);
			}
		}
		if (vetoed.Count > 0)
		{
			hashSet.RemoveWhere((Roles _r) => vetoed.Contains(_r));
		}
		List<Roles> list = hashSet.ToList();
		List<Roles> list2 = new List<Roles>();
		foreach (KeyValuePair<Roles, LESuspect> current_suspect in current_suspects)
		{
			if (!list.Contains(current_suspect.Key))
			{
				list2.Add(current_suspect.Key);
			}
		}
		list2.ForEach(delegate(Roles _tr)
		{
			Object.Destroy(current_suspects[_tr].gameObject);
			current_suspects.Remove(_tr);
		});
		list.Sort();
		for (int num = list.Count - 1; num >= 0; num--)
		{
			getSuspect(list[num]).transform.SetAsFirstSibling();
		}
		add_suspect.transform.SetAsLastSibling();
	}

	public bool tryRemove(LESuspect _suspect)
	{
		if (in_play.Any((RoleData _r) => _r.role == _suspect.role))
		{
			return false;
		}
		current_suspects.Remove(_suspect.role);
		wanted_roles.Remove(_suspect.role);
		manager.setSuspectList(suspect_list);
		return true;
	}

	public void addRoleToSuspectList(Roles _role)
	{
		wanted_roles.Add(_role);
		updateList(in_play, vetoed);
		manager.setSuspectList(suspect_list);
	}

	public bool checkForErrors()
	{
		List<ValidationError> list = manager.checkSuspectList(suspect_list);
		bool close_error_marker = true;
		foreach (LESuspect value in current_suspects.Values)
		{
			value.clearError();
		}
		list.ForEach(delegate(ValidationError _e)
		{
			if (_e.related_to.is_some)
			{
				current_suspects[_e.related_to.value].setError(_e.error);
			}
			else
			{
				error_marker.openWithError(_e.error);
				close_error_marker = false;
			}
		});
		if (close_error_marker)
		{
			error_marker.closeMenu();
		}
		return list.Count == 0;
	}

	private void onHoverStart(LESuspect _sus)
	{
		problem_highlighter.openFromSuspect(_sus);
	}

	private void onHoverEnd(LESuspect _sus)
	{
		problem_highlighter.tryClose(_sus);
	}
}
