using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using ControllerSupport;
using GRGLib.Coroutines;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using UnityEngine;

namespace Visual;

public class BoardVisualManager : MonoBehaviour
{
	[SerializeField]
	private LocationVisualDataSO location_prefabs;

	[Header("References")]
	[SerializeField]
	private SuspectListVisualManager suspect_list_manager;

	[SerializeField]
	private RectTransform characters_parent;

	[SerializeField]
	private RectTransform empty_slots_parent;

	[SerializeField]
	private RevealLinesManager reveal_lines_manager;

	[Header("Prefabs")]
	[SerializeField]
	private CharacterVisual character_prefab;

	[SerializeField]
	private EmptySlot empty_slot_prefab;

	[Header("Region Specific Prefabs")]
	[SerializeField]
	private RippleEffectAnimator ripple_prefab;

	[Header("Settings")]
	[SerializeField]
	private Vector2 cell_size = new Vector2(-600f, -600f);

	[SerializeField]
	private Vector2 grid_start_position = new Vector2(1200f, 1200f);

	[SerializeField]
	private Vector2 grid_center = new Vector2(25f, 87.5f);

	private CaseControllerSupportHandler controller_support;

	private AbilityVisualManager ability_manager;

	private Dictionary<int, CharacterVisual> characters;

	private Dictionary<LocationTypes, LocationVisual> locations;

	private Action<InteractionType, int> interact;

	private Action<int, List<int>> ability;

	private Action<int, List<AbilityData>> special_ability;

	private Action<LocationData, List<AbilityData>> location_ability;

	private Maybe<int> current_hover = new Maybe<int>();

	private bool ability_hover;

	private bool is_set_up;

	private System.Random random = RandomExtensions.freshRandom();

	private Vector2Int board_size;

	public CaseSnapshot current_snapshot { get; private set; }

	public Dictionary<Vector2Int, EmptySlot> empty_slots { get; private set; } = new Dictionary<Vector2Int, EmptySlot>();

	public EmptySlot right_most_slot => empty_slots[new Vector2Int(board_size.x - 1, 0)];

	public List<EmptySlot> bottom_slots { get; private set; }

	public Vector3 getPinPositionOfSlot(Vector2Int _pos, Vector3 _pin_offset)
	{
		return empty_slots[_pos].transform.position + _pin_offset;
	}

	public Vector3 getPositionOfCrimeScene()
	{
		return locations[LocationTypes.CRIME_SCENE].transform.position;
	}

	public Vector2 getTruePosition(Vector2Int _grid_pos)
	{
		return grid_start_position + cell_size * _grid_pos;
	}

	public Vector2 getPointingPosition(Vector2Int _grid_pos, Vector2Int _from, bool _prioritise_x)
	{
		if (_grid_pos.x == _from.x)
		{
			if (_from.y > _grid_pos.y)
			{
				return getTruePosition(_grid_pos) + new Vector2(0f, cell_size.y * 0.45f);
			}
			return getTruePosition(_grid_pos) - new Vector2(0f, cell_size.y * 0.45f);
		}
		if (_prioritise_x || _from.y == _grid_pos.y)
		{
			if (_from.x > _grid_pos.x)
			{
				return getTruePosition(_grid_pos) + new Vector2(cell_size.x * 0.45f, 0f);
			}
			return getTruePosition(_grid_pos) - new Vector2(cell_size.x * 0.45f, 0f);
		}
		if (_from.y > _grid_pos.y)
		{
			return getTruePosition(_grid_pos) + new Vector2(0f, cell_size.y * 0.45f);
		}
		return getTruePosition(_grid_pos) - new Vector2(0f, cell_size.y * 0.45f);
	}

	public void resetBoard()
	{
		characters.destroyAll();
		locations.destroyAll();
	}

	public void setUp(CaseControllerSupportHandler _con_handler, AbilityVisualManager _ab_manager, CaseSnapshot _snap, Vector2Int _board_size, RoleVisualDataSO _visuals_data, Action<InteractionType, int> _interact, Action<int, List<int>> _ability, Action<int, List<AbilityData>> _spe_ability, Action<LocationData, List<AbilityData>> _on_location_ability, SuspectVisual _top_most, Action _set_up_callback)
	{
		board_size = _board_size;
		controller_support = _con_handler;
		ability_manager = _ab_manager;
		interact = _interact;
		ability = _ability;
		special_ability = _spe_ability;
		location_ability = _on_location_ability;
		current_snapshot = _snap;
		populateEmpty(_top_most);
		setUpAnimation(_snap, _visuals_data).addCallback(_set_up_callback).start(this);
	}

	private IEnumerator setUpAnimation(CaseSnapshot _snap, RoleVisualDataSO _visuals_data)
	{
		yield return 0.5f.wait();
		yield return populateLocations(_snap.locations);
		if (_snap is DocksCaseSnapshot)
		{
			yield return populateRoles(_snap.address_occupents, _snap, _visuals_data, locations[LocationTypes.DOCKS].transform.localPosition);
		}
		else
		{
			Vector3 localPosition = locations[LocationTypes.CRIME_SCENE].transform.localPosition;
			if (locations.ContainsKey(LocationTypes.BLOOD_TRACE) && random.Next(0, 2) == 1)
			{
				localPosition = locations[LocationTypes.BLOOD_TRACE].transform.localPosition;
			}
			yield return populateRoles(_snap.address_occupents, _snap, _visuals_data, localPosition);
		}
		foreach (KeyValuePair<LocationTypes, LocationVisual> location in locations)
		{
			location.Value.transform.SetAsFirstSibling();
		}
		renewLocations(_snap);
		is_set_up = true;
	}

	private void populateEmpty(SuspectVisual _top_most)
	{
		int num = Mathf.Max(board_size.x, board_size.y);
		float num2 = ((num == 4) ? 1f : ((num < 4) ? 1.15f : 0.85f));
		controller_support.scaleSelectioner(num2);
		base.transform.localScale = new Vector3(num2, num2, 1f);
		grid_start_position = grid_center - new Vector2((float)(board_size.x - 1) / 2f * cell_size.x, (float)(board_size.y - 1) / 2f * cell_size.y);
		for (int i = 0; i < board_size.x; i++)
		{
			for (int j = 0; j < board_size.y; j++)
			{
				Vector2Int vector2Int = new Vector2Int(i, j);
				EmptySlot emptySlot = UnityEngine.Object.Instantiate(empty_slot_prefab, empty_slots_parent);
				emptySlot.transform.localPosition = getTruePosition(vector2Int);
				emptySlot.setUp(vector2Int, onSlotSelected, onSlotDeselected, onSlotSouthDown, onSlotSouthUp, onSlotWestDown, onSlotWestUp, onSelectButton);
				empty_slots[vector2Int] = emptySlot;
			}
		}
		setBoardToSuspectNavigation(_top_most, _override_when_null: true);
		controller_support.setUpBackupSelection(empty_slots[new Vector2Int(0, 0)]);
		bottom_slots = new List<EmptySlot>();
		for (int k = 0; k < board_size.x; k++)
		{
			bottom_slots.Add(empty_slots[new Vector2Int(k, board_size.y - 1)]);
		}
	}

	public void setBoardToSuspectNavigation(SuspectVisual _top_most, bool _override_when_null = false)
	{
		foreach (KeyValuePair<Vector2Int, EmptySlot> empty_slot in empty_slots)
		{
			EmptySlot orDefault = empty_slots.getOrDefault(empty_slot.Key - new Vector2Int(1, 0), null);
			EmptySlot orDefault2 = empty_slots.getOrDefault(empty_slot.Key - new Vector2Int(-1, 0), null);
			EmptySlot orDefault3 = empty_slots.getOrDefault(empty_slot.Key - new Vector2Int(0, 1), null);
			EmptySlot orDefault4 = empty_slots.getOrDefault(empty_slot.Key - new Vector2Int(0, -1), null);
			empty_slot.Value.setUpNavigation((orDefault == null) ? null : orDefault.getSelectable(), (orDefault2 == null) ? ((_top_most == null) ? null : _top_most.getSelectable()) : orDefault2.getSelectable(), (orDefault3 == null) ? null : orDefault3.getSelectable(), (orDefault4 == null) ? null : orDefault4.getSelectable(), _override_when_null);
		}
	}

	private IEnumerator populateLocations(Dictionary<LocationTypes, LocationData> _locations)
	{
		locations = new Dictionary<LocationTypes, LocationVisual>();
		foreach (KeyValuePair<LocationTypes, LocationData> _location in _locations)
		{
			locations[_location.Key] = createLocationAtPosition(_location.Value, grid_start_position + cell_size * _location.Value.getBoardPosition());
			yield return 0.1f.wait();
		}
		yield return 0.1f.wait();
	}

	private LocationVisual createLocationAtPosition(LocationData _data, Vector2 _position, bool _animate = true, bool _use_visual_location = true)
	{
		LocationVisual locationVisual = UnityEngine.Object.Instantiate(location_prefabs[(_use_visual_location ? _data.visual_location : _data).location_type], characters_parent);
		if (_animate)
		{
			locationVisual.transform.localScale = new Vector3(1.25f, 1.25f, 1f);
			locationVisual.transform.localPosition = _position + new Vector2(0f, 300f);
			locationVisual.fadeIn(0.35f);
			locationVisual.transform.moveTransform(_position, 0.5f, CoroutineExtensions.getCustomEaseOutBackFunc(1f)).start(this);
			locationVisual.transform.scaleTransform(1f, 0.5f, CoroutineExtensions.easeOutBackFunc).start(this);
		}
		else
		{
			locationVisual.transform.localScale = new Vector3(1f, 1f, 1f);
			locationVisual.transform.localPosition = _position;
		}
		locationVisual.setUpLocation(_data, delegate(LocationData _l)
		{
			ability_manager.attemptAbility(_l as IHaveAbility, delegate(List<int> _rls)
			{
				location_ability(_l, ((IEnumerable<int>)_rls).Select((Func<int, AbilityData>)((int _a) => new AddressAbilityData(_a))).toListSafe());
			}, delegate(List<AbilityData> _data)
			{
				location_ability(_l, _data);
			}, delegate
			{
			});
		});
		return locationVisual;
	}

	private IEnumerator populateRoles(Dictionary<int, RoleData> _in_play, CaseSnapshot _snap, RoleVisualDataSO _visuals_data, Vector3 _crime_scene_location)
	{
		System.Random rng = RandomExtensions.freshRandom();
		characters = new Dictionary<int, CharacterVisual>();
		for (int i = 1; i <= _in_play.Keys.Count; i++)
		{
			if (_in_play.ContainsKey(i))
			{
				CharacterVisual characterVisual = UnityEngine.Object.Instantiate(character_prefab, characters_parent);
				characterVisual.transform.localPosition = _crime_scene_location;
				characterVisual.transform.SetAsFirstSibling();
				characterVisual.setUp(_in_play[i], _visuals_data, i, grid_start_position + cell_size * _in_play[i].getBoardPosition(), _snap, rng);
				characterVisual.setUpCallbacks(delegate(int _a)
				{
					interact(InteractionType.INVESTIGATE, _a);
				}, delegate(int _a)
				{
					interact(InteractionType.ARREST, _a);
				}, delegate(RoleData _r, int _a)
				{
					ability_manager.attemptRoleAbility(_r, _a, delegate(List<int> _t)
					{
						ability(_a, _t);
					}, delegate(List<AbilityData> _sd)
					{
						special_ability(_a, _sd);
					}, delegate
					{
					});
				}, roleHover, roleUnhover, endHover, unhoverTruth, changeTruthHoverType, createRippleEffect);
				characters[i] = characterVisual;
				characterVisual.moveToPosition();
				yield return 0.075f.wait();
			}
			else
			{
				Debug.LogError($"In play key {i} was not present in the dictionary even tho _in_play has {_in_play.Keys.Count} keys!\n" + $"In Play key at position {i} is {_in_play.Keys.ElementAt(i)}. Value is a {_in_play[_in_play.Keys.ElementAt(i)].role}");
			}
		}
		yield return 0.5f.wait();
		List<CharacterVisual> source = characters.Values.ToList();
		source = source.OrderBy((CharacterVisual _c) => _c.transform.localPosition.y * 1000f + _c.transform.localPosition.x).ToList();
		for (int j = 0; j < source.Count; j++)
		{
			source[j].transform.SetAsFirstSibling();
		}
	}

	public void renewBoard(CaseSnapshot _snapshot, bool _set_up = false)
	{
		current_snapshot = _snapshot;
		foreach (KeyValuePair<int, RoleData> item in _snapshot.board.getRolesInPlay())
		{
			if (characters.ContainsKey(item.Key))
			{
				characters[item.Key].renew(item.Value, _snapshot, _set_up);
			}
			else
			{
				Debug.LogError($"Trying to renew a role that is not on the board!!! {item.Key} : {item.Value.role}");
			}
		}
		renewLocations(_snapshot);
	}

	private void renewLocations(CaseSnapshot _snap)
	{
		foreach (KeyValuePair<LocationTypes, LocationData> loc in _snap.board.getLocationsInPlay())
		{
			if (locations.ContainsKey(loc.Key))
			{
				locations[loc.Key].renew(loc.Value, _snap, delegate(LocationData _l, Vector3 _p)
				{
					LocationVisual locationVisual = createLocationAtPosition(_l, _p, _animate: false, _use_visual_location: false);
					locationVisual.transform.jiggle().start(this);
					locations[loc.Key] = locationVisual;
				});
			}
			else
			{
				Debug.LogError($"Trying to renew a location that is not on the board!!! {loc.Key}");
			}
		}
	}

	public AbilityVisualManager getAbilityManager()
	{
		return ability_manager;
	}

	public void setSelectionOverride(Action<RoleData, int> _callback)
	{
		foreach (KeyValuePair<int, CharacterVisual> character in characters)
		{
			character.Value.setOverrideCallback(_callback);
		}
	}

	public void removeSelectionOverride()
	{
		foreach (KeyValuePair<int, CharacterVisual> character in characters)
		{
			character.Value.removeOverrideCallback();
		}
	}

	public IEnumerator revealTruth()
	{
		List<(LocationTypes, LocationVisual)> to_modify = new List<(LocationTypes, LocationVisual)>();
		foreach (KeyValuePair<LocationTypes, LocationVisual> location in locations)
		{
			if (location.Value.reveal(delegate(LocationData _l, Vector3 _p)
			{
				LocationVisual locationVisual = createLocationAtPosition(_l, _p, _animate: false, _use_visual_location: false);
				locationVisual.transform.jiggle().start(this);
				to_modify.Add((_l.location_type, locationVisual));
			}))
			{
				yield return 0.15f.wait();
			}
		}
		to_modify.ForEach(delegate((LocationTypes, LocationVisual) _l)
		{
			locations[_l.Item1] = _l.Item2;
		});
		foreach (KeyValuePair<int, CharacterVisual> character in characters)
		{
			character.Value.jiggle();
			character.Value.revealTruth();
			yield return 0.15f.wait();
		}
	}

	public void overrideEmptySlotCallback(Action<EmptySlot, Vector2Int> _on_hover, Action<EmptySlot, Vector2Int> _on_unhover, Action<EmptySlot, Vector2Int> _override_click)
	{
		foreach (KeyValuePair<Vector2Int, EmptySlot> empty_slot in empty_slots)
		{
			empty_slot.Value.setUpOverride(_on_hover, _on_unhover, _override_click);
		}
	}

	public void resetEmptySlotCallbackOverride()
	{
		foreach (KeyValuePair<Vector2Int, EmptySlot> empty_slot in empty_slots)
		{
			empty_slot.Value.resetOverride();
		}
	}

	public Maybe<EmptySlot> findAlreadyHoveringSlot()
	{
		return CollectionsExtension.firstIfSome(empty_slots.Values.ToList(), (EmptySlot _e) => _e.is_hovering);
	}

	public void overrideLocationCallback(Action<LocationAbilityData> _override_click)
	{
		foreach (KeyValuePair<LocationTypes, LocationVisual> location in locations)
		{
			location.Value.setOverrideClick(delegate(Vector2Int _p, LocationTypes _l)
			{
				_override_click(new LocationAbilityData(_p, _l));
			});
			location.Value.focus();
		}
	}

	public void resetLocationCallback()
	{
		foreach (KeyValuePair<LocationTypes, LocationVisual> location in locations)
		{
			location.Value.resetOverrideClick();
			location.Value.resetFocusAndDarken();
		}
	}

	public void abilityHighlight(int _address, Func<RoleData, bool> _validation, bool _darken_locations = true)
	{
		if (!is_set_up || current_snapshot.case_solved)
		{
			return;
		}
		foreach (KeyValuePair<Vector2Int, Maybe<Either<RoleData, LocationData>>> item in current_snapshot.board)
		{
			if (item.Value.is_some && item.Value.value.is_a && item.Value.value.maybe_a.value.getAddress() != _address)
			{
				CharacterVisual characterVisual = characters[item.Value.value.maybe_a.value.getAddress()];
				if (_validation(item.Value.value.maybe_a.value))
				{
					characterVisual.focus();
				}
				else
				{
					characterVisual.darken();
				}
			}
		}
		if (_darken_locations)
		{
			foreach (KeyValuePair<LocationTypes, LocationVisual> location in locations)
			{
				location.Value.darken();
			}
		}
		ability_hover = true;
	}

	public void abilityHighlightEnd()
	{
		foreach (KeyValuePair<int, CharacterVisual> character in characters)
		{
			character.Value.undarkenAndUnfocus();
		}
		foreach (KeyValuePair<LocationTypes, LocationVisual> location in locations)
		{
			location.Value.resetFocusAndDarken();
		}
		ability_hover = false;
	}

	public void roleHover(CharacterVisual _visual, int _address)
	{
		if (is_set_up && !ability_manager.using_ability && !current_snapshot.case_solved && !ability_hover)
		{
			RoleData visualRole = current_snapshot.address_occupents[_address].getVisualRole();
			checkRoleScale(_visual);
			if (visualRole.has_hover_focus)
			{
				current_hover = _address.maybe();
				checkForHover(_address, visualRole.checkHoverFocus);
			}
		}
	}

	public void roleUnhover(CharacterVisual _visual, int _address)
	{
		if (!ability_hover && (!current_hover.is_some || current_hover.value == _address))
		{
			unfocusAndUndarkenAll();
			current_hover = new Maybe<int>();
		}
	}

	private void checkRoleScale(CharacterVisual _visual)
	{
		if (board_size.x >= 5 || board_size.y >= 5)
		{
			_visual.scaleVisual(_up: true);
		}
	}

	public void endHover(RoleData _role, bool _showing_truth)
	{
		checkEndHover(_role, _showing_truth);
	}

	public bool checkEndHover(RoleData _role, bool _showing_truth)
	{
		RoleData roleData = _role;
		if (_showing_truth)
		{
			if (!_role.has_truth_hover_focus)
			{
				if (!_role.getVisualRole().has_truth_hover_focus)
				{
					return false;
				}
				roleData = _role.getVisualRole();
			}
			current_hover = _role.getAddress().maybe();
			checkForHover(current_hover.value, roleData.checkEndHoverTruthFocus);
			return true;
		}
		if (!_role.has_end_info_hover_focus)
		{
			if (!_role.getVisualRole().has_end_info_hover_focus)
			{
				return false;
			}
			roleData = _role.getVisualRole();
		}
		current_hover = _role.getAddress().maybe();
		checkForHover(current_hover.value, roleData.checkEndInfoHoverFocus);
		return true;
	}

	public void unhoverTruth(RoleData _role)
	{
		if (!current_hover.is_some || current_hover.value == _role.getAddress())
		{
			unfocusAndUndarkenAll();
			current_hover = new Maybe<int>();
		}
	}

	public void changeTruthHoverType(RoleData _role, bool _showing_truth)
	{
		if (!current_hover.is_some || current_hover.value == _role.getAddress())
		{
			unfocusAndUndarkenAll();
			checkEndHover(_role, _showing_truth);
		}
	}

	private void checkForHover(int _address, Func<CaseSnapshot, Vector2Int, Either<RoleData, LocationData>, bool> _hover_check)
	{
		foreach (KeyValuePair<Vector2Int, Maybe<Either<RoleData, LocationData>>> item in current_snapshot.board)
		{
			if (!item.Value.is_some || (item.Value.value.is_a && item.Value.value.maybe_a.value.getAddress() == _address))
			{
				continue;
			}
			bool flag = _hover_check(current_snapshot, item.Key, item.Value.value);
			if (item.Value.value.is_a)
			{
				CharacterVisual characterVisual = characters[item.Value.value.maybe_a.value.getAddress()];
				if (flag)
				{
					characterVisual.focus(_true: true, _loop: true);
				}
				else
				{
					characterVisual.darken();
				}
			}
			else
			{
				LocationVisual locationVisual = locations[item.Value.value.maybe_b.value.location_type];
				if (flag)
				{
					locationVisual.focus();
				}
				else
				{
					locationVisual.darken();
				}
			}
		}
	}

	private void unfocusAndUndarkenAll()
	{
		foreach (KeyValuePair<int, CharacterVisual> character in characters)
		{
			character.Value.undarkenAndUnfocus();
		}
		foreach (KeyValuePair<LocationTypes, LocationVisual> location in locations)
		{
			location.Value.resetFocusAndDarken();
		}
	}

	public void abilitySelect(int _address, bool _true)
	{
		characters[_address].abilityFocus(_true);
	}

	public void abilityEnd()
	{
		removeSelectionOverride();
		foreach (KeyValuePair<int, CharacterVisual> character in characters)
		{
			character.Value.abilityFocus(_true: false);
		}
		abilityHighlightEnd();
	}

	public void createRippleEffect(Vector2 _position)
	{
		RippleEffectAnimator rippleEffectAnimator = UnityEngine.Object.Instantiate(ripple_prefab, characters_parent);
		rippleEffectAnimator.transform.localPosition = _position;
		rippleEffectAnimator.setUpAndPlay();
	}

	private void onSlotSelected(EmptySlot _slot, Vector2Int _grid_pos)
	{
		controller_support.onSlotSelect(_slot);
		tryPressButton(_slot, _grid_pos, delegate(CharacterVisual _cr)
		{
			_cr.onHover();
		}, delegate
		{
		});
	}

	private void onSlotDeselected(EmptySlot _slot, Vector2Int _grid_pos)
	{
		controller_support.onSlotDeselect(_slot);
		tryPressButton(_slot, _grid_pos, delegate(CharacterVisual _cr)
		{
			_cr.onUnHover();
		}, delegate
		{
		});
	}

	private void onSlotSouthDown(EmptySlot _slot, Vector2Int _grid_pos)
	{
		tryPressButton(_slot, _grid_pos, delegate(CharacterVisual _c)
		{
			_c.tryInvestigateOrAbility();
		}, delegate
		{
		});
	}

	private void onSlotSouthUp(EmptySlot _slot, Vector2Int _grid_pos)
	{
		tryPressButton(_slot, _grid_pos, delegate(CharacterVisual _c)
		{
			_c.onButtonRelease();
		}, delegate
		{
		});
	}

	private void onSlotWestDown(EmptySlot _slot, Vector2Int _grid_pos)
	{
		tryPressButton(_slot, _grid_pos, delegate(CharacterVisual _c)
		{
			_c.tryArrest();
		}, delegate
		{
		});
	}

	private void onSlotWestUp(EmptySlot _slot, Vector2Int _grid_pos)
	{
		tryPressButton(_slot, _grid_pos, delegate(CharacterVisual _c)
		{
			_c.onButtonRelease();
		}, delegate
		{
		});
	}

	private void onSelectButton(EmptySlot _slot, Vector2Int _grid_pos)
	{
		tryPressButton(_slot, _grid_pos, delegate(CharacterVisual _c)
		{
			if (_c.is_investigated)
			{
				suspect_list_manager.trySelectRole(_c.visual_role);
			}
		}, delegate
		{
		});
	}

	private void tryPressButton(EmptySlot _slot, Vector2Int _grid_pos, Action<CharacterVisual> _on_press_character, Action<LocationVisual> _on_press_location)
	{
		Maybe<Either<RoleData, LocationData>> orDefault = current_snapshot.board.getOrDefault(_grid_pos, new Maybe<Either<RoleData, LocationData>>());
		if (orDefault.is_some && is_set_up)
		{
			if (orDefault.value.is_a)
			{
				_on_press_character(characters[orDefault.value.maybe_a.value.getAddress()]);
			}
			else
			{
				_on_press_location(locations[orDefault.value.maybe_b.value.location_type]);
			}
		}
	}
}
