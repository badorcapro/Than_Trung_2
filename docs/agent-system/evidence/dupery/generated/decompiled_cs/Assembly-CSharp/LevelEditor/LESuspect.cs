using System;
using GRGLib.Coroutines;
using GRGLib.Maybe;
using GRGLocalisation;
using Localisation;
using TMPro;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

namespace LevelEditor;

public class LESuspect : MonoBehaviour, IAmLocalised
{
	[Header("References")]
	[SerializeField]
	private Image icon;

	[SerializeField]
	private TMP_Text role_name;

	[SerializeField]
	private GameObject transformation_marker;

	private Func<LESuspect, bool> try_remove_role;

	private Maybe<Action<LESuspect>> on_click = new Maybe<Action<LESuspect>>();

	private Action<LESuspect> on_hover_start;

	private Action<LESuspect> on_hover_end;

	private CoroutineRunner shake_runner;

	public Roles role { get; private set; }

	public Maybe<string> error_string { get; private set; } = new Maybe<string>();

	private AssetKey localisation_asset => LocalisationHelper.misc_asset;

	private string loc_add_key => "LE_Suspect [add_sus]";

	public void setUp(Roles _role, RoleVisualDataSO _data, bool _is_transform, Func<LESuspect, bool> _remove_role)
	{
		role = _role;
		shake_runner = new CoroutineRunner(this);
		icon.sprite = _data[_role];
		icon.color = _data[_role.getClassificationFromRoleType()].class_colour;
		role_name.text = _role.toStringPlain();
		transformation_marker.SetActive(_is_transform);
		if (_is_transform)
		{
			role_name.rectTransform.position = role_name.rectTransform.position + new Vector3(50f, 0f, 0f);
		}
		try_remove_role = _remove_role;
	}

	public void setUpHover(Action<LESuspect> _start, Action<LESuspect> _end)
	{
		on_hover_start = _start;
		on_hover_end = _end;
	}

	public void setUpAdding(Action<LESuspect> _on_click)
	{
		role_name.text = localisation_asset.checkTranslation(loc_add_key, englishAddSuspect);
		on_click = _on_click.maybe();
	}

	public void setError(string _error)
	{
		role_name.color = Color.red;
		error_string = _error.maybe();
	}

	public void clearError()
	{
		role_name.color = Color.black;
		error_string = new Maybe<string>();
	}

	private string englishAddSuspect()
	{
		return "Add Suspect";
	}

	public void onHover(bool _start)
	{
		if (_start)
		{
			on_hover_start(this);
		}
		else
		{
			on_hover_end(this);
		}
	}

	public void onClick(PointerEventData _data)
	{
		if (_data.button == PointerEventData.InputButton.Left)
		{
			if (on_click.is_some)
			{
				on_click.value(this);
			}
		}
		else if (_data.button == PointerEventData.InputButton.Right)
		{
			tryRemove();
		}
	}

	private void tryRemove()
	{
		if (try_remove_role(this))
		{
			UnityEngine.Object.Destroy(base.gameObject);
		}
		else
		{
			shake_runner.run(base.transform.shake(0.35f, 2f));
		}
	}
}
