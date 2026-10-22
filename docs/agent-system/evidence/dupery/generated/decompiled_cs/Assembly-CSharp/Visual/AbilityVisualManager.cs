using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Coroutines;
using GRGLib.Maybe;
using UnityEngine;
using UnityEngine.InputSystem;

namespace Visual;

public class AbilityVisualManager : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private SpecialAbilityVisualManager special_ability_manager;

	private GameInstructionsManager instructions_manager;

	private BoardVisualManager board_manager;

	private List<int> selected_addresses = new List<int>();

	private int unpickable_address = -1;

	private Maybe<IHaveAbility> selecting_role = new Maybe<IHaveAbility>();

	private CoroutineRunner selection_runner;

	private Maybe<Action> cancel_callback;

	public bool using_ability { get; private set; }

	private void Awake()
	{
		selection_runner = new CoroutineRunner(this);
	}

	public void setUpReferences(GameInstructionsManager _instruction_manager, BoardVisualManager _board_manager, WorldVisualManager _world, SuspectListVisualManager _suspect_list)
	{
		instructions_manager = _instruction_manager;
		board_manager = _board_manager;
		special_ability_manager.setUpReferences(_world, _board_manager, _suspect_list);
	}

	public void attemptRoleAbility(RoleData _role, int _address, Action<List<int>> _on_role_selection_complete, Action<List<AbilityData>> _on_special_selection_complete, Action _on_cancel)
	{
		if (_role.getVisualRole() is IHaveAbility ability_user)
		{
			attemptAbility(ability_user, _on_role_selection_complete, _on_special_selection_complete, _on_cancel, _address);
			return;
		}
		Debug.LogError("Trying to use ability of role that does not have one!");
		_on_cancel();
	}

	public void attemptAbility(IHaveAbility _ability_user, Action<List<int>> _on_role_selection_complete, Action<List<AbilityData>> _on_special_selection_complete, Action _on_cancel, int _address = -1)
	{
		if (_ability_user is IHaveMultiAbility ab_role)
		{
			attemptMultiAbility(ab_role, _address, _on_special_selection_complete, _on_cancel);
		}
		else if (_ability_user is IHaveRoleAbility ab_role2)
		{
			attemptSimpleAbility(ab_role2, _address, _on_role_selection_complete, _on_cancel);
		}
		else if (_ability_user is IHaveSpecialAbility ab_role3)
		{
			attemptSpecialAbility(ab_role3, _address, _on_special_selection_complete, _on_cancel);
		}
		else
		{
			_on_role_selection_complete(new List<int>());
		}
	}

	private void setUpAbility(IHaveAbility _ability, Action _on_cancel)
	{
		cancel_callback = _on_cancel.maybe();
		using_ability = true;
		selecting_role = _ability.maybe();
		instructions_manager.setInstructions(_ability.getAbilityPrompt());
	}

	private void attemptMultiAbility(IHaveMultiAbility _ab_role, int _address, Action<List<AbilityData>> _on_selection_complete, Action _on_cancel)
	{
		if (_ab_role.abilityExhausted)
		{
			Debug.LogError($"Trying to use ability that is exhausted! (Address: {_address})");
			_on_cancel();
		}
		else
		{
			doNextAbility(_ab_role, _address, _on_selection_complete, _on_cancel, new List<AbilityData>(), 0);
		}
	}

	private void doNextAbility(IHaveMultiAbility _ab_role, int _address, Action<List<AbilityData>> _on_selection_complete, Action _on_cancel, List<AbilityData> _data, int _current)
	{
		IHaveAbility ability_user = _ab_role.abilities[_current];
		attemptAbility(ability_user, delegate(List<int> _add)
		{
			_data.AddRange(_add.Select((int _a) => new AddressAbilityData(_a)));
			if (_ab_role.abilities.Count > _current + 1)
			{
				doNextAbility(_ab_role, _address, _on_selection_complete, _on_cancel, _data, _current + 1);
			}
			else
			{
				_on_selection_complete(_data);
			}
		}, delegate(List<AbilityData> _ab_data)
		{
			_data.AddRange(_ab_data);
			if (_ab_role.abilities.Count > _current + 1)
			{
				doNextAbility(_ab_role, _address, _on_selection_complete, _on_cancel, _data, _current + 1);
			}
			else
			{
				_on_selection_complete(_data);
			}
		}, _on_cancel, _address);
	}

	private void attemptSimpleAbility(IHaveRoleAbility _ab_role, int _address, Action<List<int>> _on_selection_complete, Action _on_cancel)
	{
		if (_ab_role.abilityExhausted)
		{
			Debug.LogError($"Trying to use ability that is exhausted! (Address: {_address})");
			_on_cancel();
			return;
		}
		setUpAbility(_ab_role, _on_cancel);
		board_manager.setSelectionOverride(toggleAddress);
		board_manager.abilityHighlight(_address, _ab_role.validateTarget);
		unpickable_address = (_ab_role.allowSelfTarget ? (-1) : _address);
		selection_runner.run(waitForSelection(_ab_role.numberTargets, _on_selection_complete));
	}

	private void attemptSpecialAbility(IHaveSpecialAbility _ab_role, int _address, Action<List<AbilityData>> _on_selection_complete, Action _on_cancel)
	{
		if (_ab_role.abilityExhausted)
		{
			Debug.LogError($"Trying to use ability that is exhausted! (Address: {_address})");
			_on_cancel();
			return;
		}
		if (!special_ability_manager.setUpForSelection(_ab_role.ability_type, _ab_role))
		{
			_on_cancel();
			return;
		}
		setUpAbility(_ab_role, _on_cancel);
		board_manager.setSelectionOverride(delegate
		{
		});
		board_manager.abilityHighlight(_address, (RoleData _r) => false, _ab_role.ability_type != SpecialAbilityType.LOCATION);
		selection_runner.run(special_ability_manager.waitForSpecialAbilitySelection(_ab_role, delegate(List<AbilityData> _data)
		{
			onAbilityUse();
			_on_selection_complete(_data);
		}));
	}

	private IEnumerator waitForSelection(int _targets, Action<List<int>> _on_complete)
	{
		selected_addresses = new List<int>();
		while (selected_addresses.Count < _targets)
		{
			yield return null;
		}
		onAbilityUse();
		_on_complete(selected_addresses);
	}

	private void onAbilityUse()
	{
		board_manager.abilityEnd();
		instructions_manager.closeMenu();
		selecting_role = new Maybe<IHaveAbility>();
		using_ability = false;
		cancel_callback = new Maybe<Action>();
	}

	public void toggleAddress(RoleData _role, int _address)
	{
		if (selecting_role.value is IHaveRoleAbility haveRoleAbility && haveRoleAbility.validateTarget(_role) && _address != unpickable_address)
		{
			board_manager.abilitySelect(_address, !selected_addresses.Contains(_address));
			if (selected_addresses.Contains(_address))
			{
				selected_addresses.Remove(_address);
			}
			else
			{
				selected_addresses.Add(_address);
			}
		}
	}

	public void cancelSelection()
	{
		board_manager.abilityEnd();
		special_ability_manager.cancelAbility(selecting_role);
		selecting_role = new Maybe<IHaveAbility>();
		selection_runner.stop();
		instructions_manager.closeMenu();
		using_ability = false;
		if (cancel_callback.is_some)
		{
			cancel_callback.value();
		}
		cancel_callback = new Maybe<Action>();
	}

	public void cancelIfSelectionExists()
	{
		if (selecting_role.is_some)
		{
			cancelSelection();
		}
	}

	public void tryCancel(InputAction.CallbackContext _context)
	{
		if (using_ability && _context.canceled)
		{
			cancelSelection();
		}
	}
}
