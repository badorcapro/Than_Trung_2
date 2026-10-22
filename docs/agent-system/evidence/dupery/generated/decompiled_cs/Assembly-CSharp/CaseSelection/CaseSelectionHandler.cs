using System;
using System.Collections;
using System.Collections.Generic;
using Audio;
using ControllerSupport;
using GRGLib.Coroutines;
using GRGLib.Extensions;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Random;
using GRGLib.Generic;
using GRGLib.Maybe;
using GRGLib.Serializable;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.InputSystem;

namespace CaseSelection;

public class CaseSelectionHandler : MonoBehaviour
{
	[SerializeField]
	private RegionsSO regions_data;

	[Header("References")]
	[SerializeField]
	private CaseSelectionRegionControllerSupport controller_support;

	[SerializeField]
	private RectTransform option_parents;

	[Header("Prefabs")]
	[SerializeField]
	private CaseOption option_prefab;

	[Header("Settings")]
	[SerializeField]
	private int choices_number = 3;

	[SerializeField]
	private List<STupple<Vector2, float>> case_positions;

	[SerializeField]
	private STupple<Vector2, float> final_case_position;

	[SerializeField]
	private Vector2 case_drop = new Vector2(0f, 100f);

	private PlayerInput player_input;

	private List<CaseOption> options = new List<CaseOption>();

	private bool case_chosen;

	private Action<CaseBuildData> on_case_selected;

	private Maybe<CaseRatioBuilderData> m_ratio_data = new Maybe<CaseRatioBuilderData>();

	private CaseRatioBuilderData RatioData
	{
		get
		{
			if (!m_ratio_data.is_some)
			{
				m_ratio_data = new CaseRatioBuilderData(GameHandler.State.current_lead.value.lead_roles).maybe();
			}
			return m_ratio_data.value;
		}
	}

	public void setUp(PlayerInput _player_input)
	{
		setUp(_player_input, delegate
		{
		});
	}

	public void setUp(PlayerInput _player_input, Action<CaseBuildData> _on_case_selected)
	{
		player_input = _player_input;
		on_case_selected = _on_case_selected;
		AudioHandler.Atmo.stopAllAtmoAndStart(Atmo.RAIN_WINDOW);
	}

	public void onControlSchemeChange(PlayerInput _input)
	{
		if (!GameHandler.instance.using_gamepad && options.Count != 0 && !EventSystem.current.alreadySelecting && _input.isUsingGamepad())
		{
			options[0].getSelectable().Select();
		}
	}

	public IEnumerator setUpFromSave(List<CaseBuildData> _case_builds, Action<CaseBuildData> _case_selected)
	{
		options = new List<CaseOption>();
		yield return 0.25f.wait();
		for (int i = 0; i < _case_builds.Count; i++)
		{
			spawnCaseAnimation(createCaseOptionFromSave(_case_builds[i], i, _case_selected), case_positions[i]);
			yield return 0.1f.wait();
		}
	}

	public void updateBuiltCases(Func<Case, Case> _case_update)
	{
		options.ForEach(delegate(CaseOption _opt)
		{
			_opt.updateBuiltCase(_case_update);
		});
	}

	private IEnumerator setUp(float _progress0100, List<Roles> _available, Action<CaseBuildData> _case_selected)
	{
		options = new List<CaseOption>();
		if (_progress0100 < 100f)
		{
			return setUpCases(_case_selected, _progress0100);
		}
		if (!_available.Exists(RoleHelper.isTraitor))
		{
			_available.Add(RoleHelper.getTraitorRoleList().getRandomElementFromList(RandomExtensions.freshRandom()));
		}
		return setUpFinalCase(_case_selected);
	}

	private IEnumerator setUpCases(Action<CaseBuildData> _case_selected, float _progress0100)
	{
		yield return 0.25f.wait();
	}

	private IEnumerator setUpFinalCase(Action<CaseBuildData> _case_selected)
	{
		_ = regions_data[GameHandler.State.current_region];
		yield return 0.25f.wait();
		RandomExtensions.freshRandom();
	}

	private void spawnCaseAnimation(CaseOption _option, STupple<Vector2, float> _target_pos)
	{
		_option.transform.localPosition = _target_pos.Item1 + case_drop;
		_option.transform.moveTransform(_target_pos.Item1, 0.5f, CoroutineExtensions.easeInFunc).start(this);
		_option.transform.scaleTransform(1f, 0.5f, CoroutineExtensions.easeInFunc).start(this);
		_option.transform.rotateTransformSmart(_target_pos.Item2, 0.5f, CoroutineExtensions.easeInFunc).start(this);
		_option.getGroup().fade(1f, 0.5f, CoroutineExtensions.easeInOutFunc).start(this);
	}

	private (CaseBuildData, CaseOption) createCaseOption(CaseType _case_type, Maybe<Vector2Int> _board_size, int _index, System.Random _rng, Maybe<CaseQuirks> _new_quirk, float _difficulty, Action<CaseBuildData> _case_selected, int _traitors = -1, bool _final_case = false)
	{
		CaseRatioBuilderData caseRatioBuilderData = ((_traitors == -1) ? RatioData.copy() : RatioData.copy().setForced(RoleClassifications.TRAITOR, _traitors));
		caseRatioBuilderData.address_size = new MinMaxInt(Mathf.RoundToInt(Mathf.Lerp(6f, 10f, _difficulty)), Mathf.RoundToInt(Mathf.Lerp(9f, 13f, _difficulty)));
		CaseBuildData caseBuildData = new CaseBuildData(GameHandler.State.current_lead.value.case_type, _board_size, new List<CaseQuirks>(), _new_quirk, caseRatioBuilderData, _difficulty, _rng);
		CaseOption caseOption = UnityEngine.Object.Instantiate(option_prefab, option_parents);
		caseOption.setUpCase(_index + 1, caseBuildData, _case_selected);
		options.add(caseOption);
		return (caseBuildData, caseOption);
	}

	private CaseOption createCaseOptionFromSave(CaseBuildData _data, int _index, Action<CaseBuildData> _case_selected)
	{
		CaseOption caseOption = UnityEngine.Object.Instantiate(option_prefab, option_parents);
		caseOption.setUpCase(_index + 1, _data, _case_selected);
		options.add(caseOption);
		return caseOption;
	}

	private void onSelectCase(CaseBuildData _case_data)
	{
		if (!TransitionHandler.instance.is_transitioning && !case_chosen)
		{
			case_chosen = true;
			on_case_selected(_case_data);
			GameHandler.instance.setCaseBuildData(_case_data);
			GameHandler.instance.moveToScene("GameScene");
		}
	}

	private void onCaseFinish()
	{
		controller_support.setBackupSelectable(options);
		for (int i = 0; i < options.Count; i++)
		{
			options[i].setUpSelectables((i == 0) ? null : options[i - 1].getSelectable(), (i == options.Count - 1) ? null : options[i + 1].getSelectable());
		}
		if (player_input.currentControlScheme.equalToAny("Gamepad", "SwitchGamepad") || GameHandler.instance.using_gamepad)
		{
			options[0].getSelectable().Select();
		}
		GameHandler.instance.saveGame(_save_stats: true);
	}
}
