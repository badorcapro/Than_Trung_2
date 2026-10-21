using System;
using System.Collections.Generic;
using System.Linq;
using CaseCreation;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using GRGLib.Save;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.InputSystem;

namespace LevelEditor;

public class LevelEditorManager : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private RectTransform background_parent;

	[SerializeField]
	private LERatio ratio;

	[SerializeField]
	private LEBoardManager board_manager;

	[SerializeField]
	private LESuspectList suspect_list;

	[SerializeField]
	private CanvasGroup button_group;

	[SerializeField]
	private LEAdderMenu adder_menu;

	[SerializeField]
	private LERoleInfoMenu info_menu;

	[Header("Event Calls")]
	[SerializeField]
	private UnityEvent<LevelEditorManager, bool> onSetUp;

	[SerializeField]
	private UnityEvent<CaseSnapshot> onUpdate;

	public Case creating_case { get; private set; }

	public Vector2Int board_size { get; private set; }

	private void setUpReferences(PlayerInput _input)
	{
		adder_menu.setPlayerInput(_input);
		info_menu.setPlayerInput(_input);
	}

	public void setUpFromCase(Case _case, PlayerInput _input)
	{
		setUpReferences(_input);
		board_size = _case.board_size;
		creating_case = _case;
		CaseSnapshot caseSnapshot = _case.pregameSnap();
		board_manager.populateEmpty(board_size, _input);
		board_manager.setUpBoard(caseSnapshot.board);
		suspect_list.setUpFromExisting(caseSnapshot.true_suspect_list);
		onSetUp.Invoke(this, arg1: true);
		onLevelUpdate();
	}

	public void setUp(CaseType _type, Vector2Int _board_size, PlayerInput _input)
	{
		setUpReferences(_input);
		board_size = _board_size;
		creating_case = _type switch
		{
			CaseType.CLOCK => new ClockCase(this, _board_size), 
			CaseType.CASINO => new CasinoCase(this, _board_size), 
			CaseType.DOCKS => new DocksCase(this, _board_size), 
			_ => throw new ArgumentException($"No constructor set up for case type {_type}!"), 
		};
		board_manager.populateEmpty(board_size, _input);
		ratio.updateRatio(CaseHelper.getEmptyRatio());
		suspect_list.setUp();
		button_group.interactable = false;
		button_group.blocksRaycasts = false;
		onSetUp.Invoke(this, arg1: false);
		GameHandler.instance.setLevelEditorCase(creating_case, _move_to_game_scene: false);
	}

	public void setBoard(Dictionary<Vector2Int, Either<LEBoardRole, LEBoardLocation>> _board)
	{
		Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> emptyBoard = CaseHelper.getEmptyBoard(board_size);
		foreach (KeyValuePair<Vector2Int, Either<LEBoardRole, LEBoardLocation>> item in _board)
		{
			if (item.Value.is_a)
			{
				emptyBoard[item.Key] = item.Value.maybe_a.value.facade.toEitherA<RoleData, LocationData>().maybe();
			}
			else if (item.Value.is_b)
			{
				emptyBoard[item.Key] = item.Value.maybe_b.value.facade.toEitherB<RoleData, LocationData>().maybe();
			}
		}
		CaseSnapshot snap = creating_case.pregameSnap();
		List<RoleData> list = (from _r in emptyBoard.getRolesInPlay()
			select _r.Value).ToList();
		Dictionary<RoleClassifications, int> class_mod = new Dictionary<RoleClassifications, int>();
		List<Roles> vetoed = list.Aggregate(new List<Roles>(), delegate(List<Roles> _a, RoleData _b)
		{
			foreach (ITransformationGenerationConstraint item2 in _b.generation_constraint.getConstraintOfInterface<ITransformationGenerationConstraint>())
			{
				Maybe<Roles> roleTransformed = item2.getRoleTransformed(_b.role, snap);
				if (roleTransformed.is_some)
				{
					_a.Add(roleTransformed.value);
				}
			}
			foreach (IModifyEditorRatio item3 in _b.generation_constraint.getConstraintOfInterface<IModifyEditorRatio>())
			{
				class_mod.increaseOrCreateRange(item3.getModification());
			}
			return _a;
		});
		suspect_list.updateList(list, vetoed);
		creating_case.setBoardFromLevelEditor(this, emptyBoard, class_mod);
		creating_case.setSuspectListFromLevelEditor(this, suspect_list.suspect_list);
		onLevelUpdate();
	}

	public void setSuspectList(List<Roles> _roles)
	{
		creating_case.setSuspectListFromLevelEditor(this, _roles);
		onLevelUpdate();
	}

	public void setSpecial(Action<LevelEditorManager, Case> _set_special)
	{
		_set_special(this, creating_case);
		onLevelUpdate();
	}

	public void onLevelUpdate()
	{
		CaseSnapshot caseSnapshot = creating_case.pregameSnap();
		bool flag = ratio.updateRatio(caseSnapshot.classification_ratio);
		flag = suspect_list.checkForErrors() && flag;
		flag = board_manager.checkBoard() && flag;
		button_group.interactable = flag;
		button_group.blocksRaycasts = flag;
		onUpdate.Invoke(caseSnapshot);
	}

	public List<ValidationError> checkSuspectList(List<Roles> _suspect_list)
	{
		CaseSnapshot snap = creating_case.pregameSnap();
		return SuspectListFactory.validateSuspectList(creating_case.case_type, snap, _suspect_list);
	}

	public List<ValidationError> checkInPlayList()
	{
		CaseSnapshot caseSnapshot = creating_case.pregameSnap();
		return InPlayListFactory.validateInPlayList(creating_case.case_type, caseSnapshot, caseSnapshot.address_occupents.Values.Select((RoleData _r) => _r.role).ToList());
	}

	public List<ValidationError> checkBoardPositioning()
	{
		CaseSnapshot caseSnapshot = creating_case.pregameSnap();
		return BoardPositioningFactory.validateBoard(creating_case.case_type, caseSnapshot.board, caseSnapshot, creating_case.board_size);
	}

	public List<ValidationError> checkDisguiseErrors()
	{
		List<ValidationError> list = new List<ValidationError>();
		CaseSnapshot caseSnapshot = creating_case.pregameSnap();
		foreach (KeyValuePair<int, RoleData> address_occupent in caseSnapshot.address_occupents)
		{
			if (address_occupent.Value.getDisguise().is_some)
			{
				RoleData value = address_occupent.Value.getDisguise().value;
				if (!address_occupent.Value.getDisguiseCharacteristics(creating_case).validateDisguise(address_occupent.Value.role, value, caseSnapshot) || !value.generation_constraint.validateDisguise(address_occupent.Value, creating_case.board_size, address_occupent.Value.has_bad_info, caseSnapshot.board, caseSnapshot.true_suspect_list.ToList()))
				{
					list.Add(new SpecialEEB(SpecialEEB.SpecialErrors.INVALID_DISGUISE).createValidationError(address_occupent.Value.role));
				}
			}
		}
		return list;
	}

	public void playCase()
	{
		if (button_group.interactable)
		{
			GameHandler.instance.setLevelEditorCase(creating_case);
		}
	}

	public void saveCase()
	{
		if (button_group.interactable)
		{
			FileHandler.writeStringToFile(JsonUtility.ToJson(creating_case.toSave()), "EditorCase.level", "./Build/");
		}
	}
}
