using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Coroutines;
using GRGLocalisation;
using Localisation;
using TMPro;
using UnityEngine;

namespace LevelEditor;

public class LERoleInfoMenu : MenuBase, IAmLocalised
{
	[SerializeField]
	private RoleVisualDataSO roles_data;

	[Header("References")]
	[SerializeField]
	private LevelEditorManager manager;

	[SerializeField]
	private TMP_Text title_text;

	[SerializeField]
	private RectTransform true_self_group;

	[SerializeField]
	private LEBoardRole true_self_role;

	[SerializeField]
	private RectTransform disguise_group;

	[SerializeField]
	private LEBoardRole disguise_role;

	[SerializeField]
	private LEAdderMenu adder;

	private LEBoardRole selected_board_role;

	private CoroutineRunner shake_runner;

	private RoleData role => selected_board_role.facade;

	private AssetKey localisation_asset => LocalisationHelper.ui_asset;

	private string loc_info_key => "LERIM [r_info]";

	protected override void Awake()
	{
		base.Awake();
		shake_runner = new CoroutineRunner(this);
	}

	public void openWithRole(LEBoardRole _role, Action _close_callback)
	{
		selected_board_role = _role;
		title_text.text = localisation_asset.checkTranslationWithData(loc_info_key, englishInfo, role.name_coloured);
		if (role.getDisguiseCharacteristics(manager.creating_case).disguises)
		{
			true_self_group.anchorMax = new Vector2(0.5f, 1f);
			disguise_group.gameObject.SetActive(value: true);
			if (role.getDisguise().is_some)
			{
				disguise_role.setUpAsRole(role.getBoardPosition(), role.getDisguise().value.toEitherB<Roles, RoleData>(), roles_data, manager.creating_case, null, removeDisguise, delegate
				{
					chooseDisguise();
				}, _force_blank: false, _can_destroy_self: false);
			}
			else
			{
				disguise_role.setUpAsUnknown(roles_data, delegate
				{
					chooseDisguise();
				}, removeDisguise);
			}
		}
		else
		{
			true_self_group.anchorMax = new Vector2(1f, 1f);
			disguise_group.gameObject.SetActive(value: false);
		}
		true_self_role.setUpAsRole(role.getBoardPosition(), role.toEitherB<Roles, RoleData>(), roles_data, manager.creating_case, null, delegate
		{
		}, delegate
		{
		}, _force_blank: true, _can_destroy_self: false);
		openMenu(_close_callback);
	}

	public void chooseDisguise()
	{
		chooseDisguise(delegate(LEAdderItem _i)
		{
			if (!_i.role.is_some)
			{
				Debug.LogError("Cannot set disguise to not a role!");
			}
			else
			{
				selected_board_role.setDisguise(_i.role.value);
				disguise_role.setUpAsRole(role.getBoardPosition(), role.getDisguise().value.toEitherB<Roles, RoleData>(), roles_data, manager.creating_case, null, removeDisguise, delegate
				{
					chooseDisguise();
				}, _force_blank: false, _can_destroy_self: false);
			}
		});
	}

	public void chooseDisguise(Action<LEAdderItem> _on_choice)
	{
		DisguiseCharacteristics disguise_char = role.getDisguiseCharacteristics(manager.creating_case);
		if (!disguise_char.disguises || disguise_char.disguise_as.is_some)
		{
			return;
		}
		List<RoleClassifications> dis_class = disguise_char.can_disguise_as_classification;
		List<Roles> available;
		switch (disguise_char.pretend_target)
		{
		default:
			return;
		case DisguiseTarget.SUSPECTED:
		case DisguiseTarget.CUSTOM_SUSPECTED:
			available = (from _r in manager.creating_case.case_type.getRoleList()
				where dis_class.Contains(_r.getClassificationFromRoleType()) && !disguise_char.disguise_blacklist.Contains(_r) && canRoleBeDisguise(_r)
				select _r).ToList();
			break;
		case DisguiseTarget.IN_PLAY:
		case DisguiseTarget.CUSTOM_IN_PLAY:
			available = (from _r in manager.creating_case.pregameSnap().board.getRolesInPlayOfClass(dis_class.ToArray()).Where(canRoleBeDisguise)
				select _r.role).ToList();
			break;
		case DisguiseTarget.NOT_IN_PLAY:
		case DisguiseTarget.CUSTOM_NOT_IN_PLAY:
		{
			List<Roles> in_play = (from _r in manager.creating_case.pregameSnap().board.getRolesInPlayOfClass(dis_class.ToArray())
				select _r.role).ToList();
			available = (from _r in manager.creating_case.case_type.getRoleList()
				where dis_class.Contains(_r.getClassificationFromRoleType()) && !disguise_char.disguise_blacklist.Contains(_r) && !in_play.Contains(_r) && canRoleBeDisguise(_r)
				select _r).ToList();
			break;
		}
		case DisguiseTarget.NOT_SET:
		case DisguiseTarget.SPECIFIC_ROLE:
			return;
		}
		openNewMenu(adder);
		adder.setUpChoiceCallback(_on_choice);
		adder.setUpRoles(manager.creating_case.case_type, available, dis_class, new List<Roles>());
	}

	private bool canRoleBeDisguise(Roles _role)
	{
		return canRoleBeDisguise(_role.createEmptyRole());
	}

	private bool canRoleBeDisguise(RoleData _role)
	{
		if (_role.can_be_disguise)
		{
			if (role.role != Roles.WANNABE)
			{
				if (!_role.getDisguiseCharacteristics(manager.creating_case).disguises)
				{
					return _role.role != role.role;
				}
				return false;
			}
			return true;
		}
		return false;
	}

	public void removeDisguise(LEBoardRole _disguise)
	{
		if (selected_board_role.facade.getDisguiseCharacteristics(manager.creating_case).disguise_as.is_some)
		{
			shake_runner.run(_disguise.transform.shake(0.2f, 2.5f));
			return;
		}
		selected_board_role.resetDisguise();
		_disguise.setUpAsUnknown(roles_data, delegate
		{
			chooseDisguise();
		}, removeDisguise);
	}

	private string englishInfo(string _d1)
	{
		return _d1 + " info";
	}
}
