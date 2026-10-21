using System;
using GRGLib.Maybe;
using GRGLocalisation;
using Localisation;
using TMPro;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

namespace LevelEditor;

public class LEBoardRole : MonoBehaviour, IAmLocalised
{
	[Header("References")]
	[SerializeField]
	private Image icon;

	[SerializeField]
	private TMP_Text address;

	[SerializeField]
	private TMP_Text title;

	[SerializeField]
	private TMP_Text description;

	[SerializeField]
	private LEErrorMarker error_marker;

	private Action<LEBoardRole> on_remove;

	private Action<LEBoardRole> on_change;

	private bool can_destroy_self = true;

	public RoleData facade { get; private set; }

	private AssetKey localisation_asset => LocalisationHelper.misc_asset;

	private string loc_disg_as_key => "LE_BR [pr_as]";

	public void setUpAsRole(Vector2Int _pos, Either<Roles, RoleData> _role, RoleVisualDataSO _visual_data, Case _empty_case, LEProblemHighlighter _ph, Action<LEBoardRole> _remove, Action<LEBoardRole> _on_change, bool _force_blank = false, bool _can_destroy_self = true)
	{
		error_marker.setReference(_ph);
		error_marker.highlighter_offset = new Vector2(0f, (_pos.y == 0) ? (-190) : 190);
		facade = (_role.is_a ? _role.maybe_a.value.createEmptyRole() : _role.maybe_b.value);
		icon.sprite = _visual_data[facade.role];
		icon.color = _visual_data[facade.role.getClassificationFromRoleType()].class_colour;
		facade.setBoardPosition(_pos);
		title.text = facade.name_coloured;
		if (!_force_blank && facade.getDisguise().is_some)
		{
			setDescriptionText(facade.getDisguise().value.name_coloured, facade.getDisguise().value.getNamePrefixOption());
		}
		else if (!_force_blank && facade.getDisguiseCharacteristics(_empty_case).disguises)
		{
			DisguiseCharacteristics disguiseCharacteristics = facade.getDisguiseCharacteristics(_empty_case);
			if (disguiseCharacteristics.disguise_as.is_some)
			{
				setDisguise(disguiseCharacteristics.disguise_as.value);
			}
			else
			{
				setDescriptionText("???", _option: false);
			}
		}
		else
		{
			description.text = "";
		}
		on_remove = _remove;
		on_change = _on_change;
		can_destroy_self = _can_destroy_self;
	}

	public void setUpAsUnknown(RoleVisualDataSO _visual_data, Action<LEBoardRole> _on_change, Action<LEBoardRole> _on_remove)
	{
		icon.sprite = _visual_data.getUnknownRoleIcon();
		title.text = "???";
		on_change = _on_change;
		on_remove = _on_remove;
		can_destroy_self = false;
	}

	public void updateAddress(int _address)
	{
		address.text = _address.ToString();
		facade.setAddress(_address);
	}

	public void setError(string _error)
	{
		error_marker.openWithError(_error);
	}

	public void closeError()
	{
		error_marker.closeMenu();
	}

	public void onClick(PointerEventData _event_data)
	{
		if (_event_data.button == PointerEventData.InputButton.Left)
		{
			trySetInfo();
		}
		else if (_event_data.button == PointerEventData.InputButton.Right)
		{
			tryRemove();
		}
	}

	private void trySetInfo()
	{
		on_change(this);
	}

	private void tryRemove()
	{
		on_remove(this);
		if (can_destroy_self)
		{
			UnityEngine.Object.Destroy(base.gameObject);
		}
	}

	public void setDisguise(Roles _role)
	{
		RoleData roleData = _role.createEmptyRole();
		facade.setDisguise(roleData.maybe());
		facade.setForcedDisguised();
		setDescriptionText(roleData.name_coloured, roleData.getNamePrefixOption());
	}

	public void resetDisguise()
	{
		facade.setDisguise(new Maybe<RoleData>());
		facade.setForcedDisguised(_forced: false);
		setDescriptionText("???", _option: false);
	}

	private void setDescriptionText(string _name, bool _option)
	{
		description.text = LocalisationHelper.checkOption(localisation_asset.checkTranslationWithData(loc_disg_as_key, englishDisguisesAs, _name), _option);
	}

	private string englishDisguisesAs(string _data)
	{
		return "pretending to be a{#/n} " + _data + ".";
	}
}
