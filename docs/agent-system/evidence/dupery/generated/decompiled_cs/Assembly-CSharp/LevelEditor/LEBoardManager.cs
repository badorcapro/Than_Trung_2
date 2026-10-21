using System.Collections.Generic;
using System.Linq;
using CaseCreation;
using GRGLib.Maybe;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.InputSystem;

namespace LevelEditor;

public class LEBoardManager : MonoBehaviour
{
	[SerializeField]
	private RoleVisualDataSO role_visual_data;

	[SerializeField]
	private LocationVisualDataSO location_visual_data;

	[Header("References")]
	[SerializeField]
	private LevelEditorManager manager;

	[SerializeField]
	private LERoleInfoMenu role_info_menu;

	[SerializeField]
	private LEAdderMenu adder_menu;

	[SerializeField]
	private LEProblemHighlighter problem_highlighter;

	[SerializeField]
	private RectTransform characters_parent;

	[SerializeField]
	private RectTransform empty_slots_parent;

	[Header("Prefabs")]
	[SerializeField]
	private LEBoardRole character_prefab;

	[SerializeField]
	private LEBoardLocation location_prefab;

	[SerializeField]
	private LEBoardSlot empty_slot_prefab;

	[Header("Settings")]
	[SerializeField]
	private Vector2 cell_size = new Vector2(-600f, -600f);

	[SerializeField]
	private Vector2 grid_start_position = new Vector2(1200f, 1200f);

	[SerializeField]
	private Vector2 grid_center = new Vector2(25f, 87.5f);

	public Dictionary<Vector2Int, LEBoardSlot> empty_slots = new Dictionary<Vector2Int, LEBoardSlot>();

	public Dictionary<Vector2Int, Either<LEBoardRole, LEBoardLocation>> board = new Dictionary<Vector2Int, Either<LEBoardRole, LEBoardLocation>>();

	public Vector2Int board_size { get; private set; }

	public Vector2 getTruePosition(Vector2Int _grid_pos)
	{
		return grid_start_position + cell_size * _grid_pos;
	}

	public void populateEmpty(Vector2Int _board_size, PlayerInput _input)
	{
		board_size = _board_size;
		int num = Mathf.Max(board_size.x, board_size.y);
		float num2 = ((num == 4) ? 1f : ((num < 4) ? 1.15f : 0.85f));
		base.transform.localScale = new Vector3(num2, num2, 1f);
		grid_start_position = grid_center - new Vector2((float)(board_size.x - 1) / 2f * cell_size.x, (float)(board_size.y - 1) / 2f * cell_size.y);
		for (int i = 0; i < board_size.x; i++)
		{
			for (int j = 0; j < board_size.y; j++)
			{
				Vector2Int vector2Int = new Vector2Int(i, j);
				LEBoardSlot lEBoardSlot = Object.Instantiate(empty_slot_prefab, empty_slots_parent);
				lEBoardSlot.transform.localPosition = getTruePosition(vector2Int);
				lEBoardSlot.setUp(vector2Int, onSlotClicked, _input);
				empty_slots[vector2Int] = lEBoardSlot;
			}
		}
	}

	public void setUpBoard(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board)
	{
		foreach (KeyValuePair<Vector2Int, Maybe<Either<RoleData, LocationData>>> item in _board)
		{
			if (item.Value.is_some)
			{
				if (item.Value.value.is_a)
				{
					addRoleToBoard(item.Value.value.maybe_a.value, item.Key);
				}
				else if (item.Value.value.is_b)
				{
					addLocationToBoard(item.Value.value.maybe_b.value, item.Key);
				}
			}
		}
	}

	public void onSlotClicked(LEBoardSlot _slot, PointerEventData _event_data)
	{
		if (_event_data.button == PointerEventData.InputButton.Left)
		{
			adder_menu.setUpChoiceCallback(delegate(LEAdderItem _i)
			{
				if (_i.role.is_some)
				{
					addRoleToBoard(_i.role.value, _slot.grid_position);
				}
				else
				{
					Debug.LogError("Choice callback was not of expected type (role)");
				}
			});
			adder_menu.openMenu();
			adder_menu.setUpRoles(manager.creating_case.case_type, (from _e in board.Values
				where _e.is_a
				select _e.maybe_a.value.facade.role).ToList());
		}
		else
		{
			if (_event_data.button != PointerEventData.InputButton.Right)
			{
				return;
			}
			adder_menu.setUpChoiceCallback(delegate(LEAdderItem _i)
			{
				if (_i.location.is_some)
				{
					addLocationToBoard(_i.location.value, _slot.grid_position);
				}
				else
				{
					Debug.LogError("Choice callback was not of expected type (location)");
				}
			});
			adder_menu.openMenu();
			adder_menu.setUpLocations(manager.creating_case.case_type, (from _e in board.Values
				where _e.is_b
				select _e.maybe_b.value.facade.location_type).ToList());
		}
	}

	private void addRoleToBoard(RoleData _role, Vector2Int _slot)
	{
		addRoleToBoard(_role.toEitherB<Roles, RoleData>(), _slot);
	}

	private void addRoleToBoard(Roles _role, Vector2Int _slot)
	{
		addRoleToBoard(_role.toEitherA<Roles, RoleData>(), _slot);
	}

	private void addRoleToBoard(Either<Roles, RoleData> _role, Vector2Int _slot)
	{
		LEBoardRole lEBoardRole = Object.Instantiate(character_prefab, characters_parent);
		lEBoardRole.setUpAsRole(_slot, _role, role_visual_data, manager.creating_case, problem_highlighter, removeRoleFromBoard, boardRoleChanged);
		lEBoardRole.transform.localPosition = getTruePosition(_slot);
		board[_slot] = lEBoardRole.toEitherA<LEBoardRole, LEBoardLocation>();
		calculateAddresses();
		manager.setBoard(board);
	}

	private void addLocationToBoard(LocationData _location, Vector2Int _slot)
	{
		addLocationToBoard(_location.toEitherB<LocationTypes, LocationData>(), _slot);
	}

	private void addLocationToBoard(LocationTypes _location, Vector2Int _slot)
	{
		addLocationToBoard(_location.toEitherA<LocationTypes, LocationData>(), _slot);
	}

	private void addLocationToBoard(Either<LocationTypes, LocationData> _location, Vector2Int _slot)
	{
		LEBoardLocation lEBoardLocation = Object.Instantiate(location_prefab, characters_parent);
		lEBoardLocation.setUp(_slot, _location, location_visual_data, boardLocationChanged, removeLocationFromBoard);
		lEBoardLocation.transform.localPosition = getTruePosition(_slot);
		board[_slot] = lEBoardLocation.toEitherB<LEBoardRole, LEBoardLocation>();
		manager.setBoard(board);
		if (manager.creating_case is DocksCase docksCase && ((_location.is_a && _location.maybe_a.value == LocationTypes.DOCKS) || (_location.is_b && _location.maybe_b.value.location_type == LocationTypes.DOCKS)))
		{
			docksCase.boat.position = _slot;
		}
	}

	private void calculateAddresses()
	{
		List<KeyValuePair<Vector2Int, Either<LEBoardRole, LEBoardLocation>>> list = board.ToList();
		list.Sort((KeyValuePair<Vector2Int, Either<LEBoardRole, LEBoardLocation>> _a, KeyValuePair<Vector2Int, Either<LEBoardRole, LEBoardLocation>> _b) => (_a.Key.y * 10000 + _a.Key.x).CompareTo(_b.Key.y * 10000 + _b.Key.x));
		int num = 1;
		for (int i = 0; i < list.Count; i++)
		{
			if (list[i].Value.is_a)
			{
				list[i].Value.maybe_a.value.updateAddress(num);
				num++;
			}
		}
	}

	private void removeRoleFromBoard(LEBoardRole _role)
	{
		board.Remove(_role.facade.getBoardPosition());
		calculateAddresses();
		manager.setBoard(board);
	}

	private void boardRoleChanged(LEBoardRole _role)
	{
		role_info_menu.openWithRole(_role, delegate
		{
			manager.setBoard(board);
		});
	}

	private void removeLocationFromBoard(LEBoardLocation _loc)
	{
		board.Remove(_loc.facade.getBoardPosition());
		calculateAddresses();
		manager.setBoard(board);
	}

	private void boardLocationChanged(LEBoardLocation _loc)
	{
	}

	public bool checkBoard()
	{
		List<ValidationError> list = manager.checkInPlayList();
		List<ValidationError> list2 = manager.checkBoardPositioning();
		List<ValidationError> l = manager.checkDisguiseErrors();
		foreach (LEBoardRole role in (from _e in board.Values
			where _e.is_a
			select _e.maybe_a.value).ToList())
		{
			Maybe<ValidationError> maybe = list2.firstIfSome((ValidationError _e) => _e.related_to.is_some && _e.related_to.value == role.facade.role);
			if (maybe.is_some)
			{
				role.setError(maybe.value.error);
				continue;
			}
			Maybe<ValidationError> maybe2 = list.firstIfSome((ValidationError _e) => _e.related_to.is_some && _e.related_to.value == role.facade.role);
			if (maybe2.is_some)
			{
				role.setError(maybe2.value.error);
				continue;
			}
			Maybe<ValidationError> maybe3 = l.firstIfSome((ValidationError _e) => _e.related_to.is_some && _e.related_to.value == role.facade.role);
			if (maybe3.is_some)
			{
				role.setError(maybe3.value.error);
			}
			else
			{
				role.closeError();
			}
		}
		if (list.Count == 0)
		{
			return list2.Count == 0;
		}
		return false;
	}
}
