using System;
using GRGLib.Maybe;
using UnityEngine;
using UnityEngine.UI;

namespace LevelEditor;

public class LEAdderItem : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private Image icon;

	private Action<LEAdderItem> on_click;

	public RectTransform rect_trans => base.transform as RectTransform;

	public Maybe<Roles> role { get; private set; } = new Maybe<Roles>();

	public Maybe<LocationTypes> location { get; private set; } = new Maybe<LocationTypes>();

	public Maybe<CaseQuirks> quirk { get; private set; } = new Maybe<CaseQuirks>();

	public void setUp(Roles _role, RoleVisualDataSO _role_data, Action<LEAdderItem> _on_click)
	{
		role = _role.maybe();
		icon.sprite = _role_data[_role];
		icon.color = _role_data[_role.getClassificationFromRoleType()].class_colour;
		on_click = _on_click;
	}

	public void setUp(LocationTypes _location, LocationVisualDataSO _location_data, Action<LEAdderItem> _on_click)
	{
		location = _location.maybe();
		icon.gameObject.SetActive(value: false);
		UnityEngine.Object.Instantiate(_location_data[_location], base.transform).setAsDisplay(_location.createEmptyLocation());
		rect_trans.sizeDelta = new Vector2(400f, 400f);
		on_click = _on_click;
	}

	public void setUp(CaseQuirks _quirk, Action<LEAdderItem> _on_click)
	{
		quirk = _quirk.maybe();
		on_click = _on_click;
	}

	public void onClick()
	{
		on_click(this);
	}
}
