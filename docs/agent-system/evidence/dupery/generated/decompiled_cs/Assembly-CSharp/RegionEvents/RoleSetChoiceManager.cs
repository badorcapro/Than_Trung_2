using System;
using System.Collections;
using System.Collections.Generic;
using GRGLib.Coroutines;
using GRGLocalisation;
using Localisation;
using Nodes.Logic;
using TMPro;
using UnityEngine;

namespace RegionEvents;

public class RoleSetChoiceManager : MenuBase, IAmLocalised
{
	[Header("Choice References")]
	[SerializeField]
	private TMP_Text title_text;

	[SerializeField]
	private TMP_Text description_text;

	[SerializeField]
	private DialogueBox description_box;

	[SerializeField]
	private ItemFanManager fan_manager;

	[Header("Prefab")]
	[SerializeField]
	private RoleSetChoiceRolePreshow role_prefab;

	[Header("Selection Animation")]
	[SerializeField]
	private RectTransform scaler_trans;

	[SerializeField]
	private float scale = 1.05f;

	[SerializeField]
	private float movement = 10f;

	[SerializeField]
	private float duration = 0.35f;

	private CoroutineRunner movement_runner;

	private MultiCoroutineRunner selected_runner;

	private string description;

	private Action<List<Roles>> on_choose;

	private List<Roles> roles_to_add;

	private AssetKey localisation_asset => LocalisationHelper.ui_asset;

	private string loc_add_role_key => "RoleSet [add_role]";

	private string loc_add_random_key => "RoleSet [add_random]";

	protected override IEnumerator openingMenuAnimation()
	{
		movement_runner.run(base.transform.moveTransform(new Vector3(base.transform.localPosition.x, 0f), 0.5f, CoroutineExtensions.easeOutFunc));
		yield return base.openingMenuAnimation();
		description_box.writeDialogue(description);
		fan_manager.fanOutChildren();
	}

	public void setChoice(RoleVisualDataSO _role_visual_data, RoleSetsGraph _role_sets, List<Roles> _av_random, System.Random _rng, Action<List<Roles>> _on_choice, bool _open_menu = true)
	{
		movement_runner = new CoroutineRunner(this);
		selected_runner = new MultiCoroutineRunner(this);
		on_choose = _on_choice;
		if (_open_menu)
		{
			openMenu();
		}
	}

	private string englishAddsRole(string _data)
	{
		return "Adds " + _data + ".";
	}

	private string englishAddsMulti(string _data, string _data_2)
	{
		return "Adds " + _data + " random " + _data_2 + ".";
	}

	public void onChoose()
	{
		on_choose(roles_to_add);
	}

	public void onSelected(bool _selected)
	{
		selected_runner.run(scaler_trans.scaleTransform(_selected ? scale : 1f, duration, CoroutineExtensions.easeInOutFunc), scaler_trans.moveTransform(new Vector3(0f, _selected ? movement : 0f), duration, CoroutineExtensions.easeInOutFunc));
	}
}
