using System;
using GRGLib.Extensions.Unity;
using Leads;
using UnityEngine;
using UnityEngine.UI;

namespace LeadSelection;

public class LeadSelection : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private LeadFacade facade;

	[SerializeField]
	private Button facade_selection;

	[SerializeField]
	private Color selected_colour;

	private Action<Lead> on_selected;

	public void setUpSelection(Lead _lead, System.Random _rng, Action<Lead> _on_selected, string _region_name)
	{
		on_selected = _on_selected;
		facade.setCurrentLead(_lead, _region_name);
	}

	public void selectLead()
	{
		on_selected(facade.current_lead);
	}

	public Lead getLead()
	{
		return facade.current_lead;
	}

	public Selectable getSelectable()
	{
		return facade_selection;
	}

	public void setUpControllerSupport(bool _using_controller, Selectable _left_selectable, Selectable _right_selectable)
	{
		changeInput(_using_controller);
		facade_selection.setNavigationHorizontal(_left_selectable, _right_selectable);
	}

	public void changeInput(bool _using_controller)
	{
		ColorBlock colors = facade_selection.colors;
		colors.selectedColor = (_using_controller ? selected_colour : new Color(1f, 1f, 1f, 0f));
		colors.pressedColor = colors.selectedColor;
		facade_selection.colors = colors;
	}
}
