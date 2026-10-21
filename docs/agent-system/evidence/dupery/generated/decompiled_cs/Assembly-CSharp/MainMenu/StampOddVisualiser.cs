using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Coroutines;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using Leads;
using TMPro;
using UnityEngine;

namespace MainMenu;

public class StampOddVisualiser : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private TMP_Dropdown stamp_type_dropdown;

	[SerializeField]
	private TMP_InputField stamp_odd_input;

	private List<LeadEventType> dropdown_options = new List<LeadEventType>();

	private Action<StampOddVisualiser> on_type_change;

	private Func<StampOddVisualiser, bool> try_remove_self;

	private CoroutineRunner shake_runner;

	public RectTransform rect_trans => base.transform as RectTransform;

	public LeadEventBuilderData event_data { get; private set; }

	public int event_odd { get; private set; }

	public LeadEventType event_type => event_data.event_type;

	public void setUp(List<LeadEventType> _events, Action<StampOddVisualiser> _on_type_change, Func<StampOddVisualiser, bool> _remove)
	{
		shake_runner = new CoroutineRunner(this);
		on_type_change = _on_type_change;
		try_remove_self = _remove;
		setDropdownOptions(_events, new Maybe<LeadEventType>());
		event_data = new LeadEventBuilderData(dropdown_options[0]);
		event_odd = 500;
		stamp_odd_input.SetTextWithoutNotify(event_odd.ToString());
	}

	public void resetDropdownOptions(List<LeadEventType> _events)
	{
		setDropdownOptions(_events, dropdown_options[stamp_type_dropdown.value].maybe());
	}

	private void setDropdownOptions(List<LeadEventType> _events, Maybe<LeadEventType> _current)
	{
		dropdown_options = new List<LeadEventType>().addIfSome(_current).addRange(_events);
		stamp_type_dropdown.ClearOptions();
		stamp_type_dropdown.AddOptions(dropdown_options.Select((LeadEventType _et) => LeadEvent.createEmpty(_et).empty_name).ToList());
		stamp_type_dropdown.SetValueWithoutNotify(0);
	}

	public void onDropdownChange(int _option)
	{
		event_data = new LeadEventBuilderData(dropdown_options[_option]);
		on_type_change(this);
	}

	public void onInputChange(string _input)
	{
		try
		{
			if (_input == "")
			{
				event_odd = 1;
			}
			else
			{
				event_odd = int.Parse(_input);
			}
		}
		catch (Exception)
		{
			Debug.LogError("Failed to parse event odd input " + _input + "!");
			event_odd = 500;
			stamp_odd_input.SetTextWithoutNotify(event_odd.ToString());
		}
	}

	public void onRemove()
	{
		if (try_remove_self(this))
		{
			UnityEngine.Object.Destroy(base.gameObject);
		}
		else
		{
			shake_runner.run(base.transform.shake(0.25f, 2.5f));
		}
	}
}
