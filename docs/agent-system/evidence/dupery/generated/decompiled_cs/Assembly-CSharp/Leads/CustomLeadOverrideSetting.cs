using System;
using System.Collections.Generic;
using System.Linq;
using AlternateModes;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using GRGLib.Serializable;
using UnityEngine;

namespace Leads;

public class CustomLeadOverrideSetting
{
	[Serializable]
	private struct SettingsSave
	{
		public SerializableDictionary<int, LeadEventType> override_event;

		public List<LeadEventType> vetoed;

		public SettingsSave(Dictionary<int, LeadEventType> _events, HashSet<LeadEventType> _vetoed)
		{
			SerializableDictionary<int, LeadEventType> serializableDictionary = _events.toSerializableDictionary();
			List<LeadEventType> list = _vetoed.ToList();
			override_event = serializableDictionary;
			vetoed = list;
		}
	}

	private const string no_events_save_key = "SKIP";

	public bool remove_stamps;

	public Dictionary<int, LeadEventType> override_event = new Dictionary<int, LeadEventType>();

	public HashSet<LeadEventType> vetoed = new HashSet<LeadEventType>();

	public Maybe<AlternateModeData> mode_data = new Maybe<AlternateModeData>();

	public CustomLeadOverrideSetting()
	{
	}

	public CustomLeadOverrideSetting(string _save_data, Maybe<AlternateModeData> _mode)
	{
		if (_save_data == "SKIP")
		{
			remove_stamps = true;
			return;
		}
		mode_data = _mode;
		try
		{
			SettingsSave settingsSave = JsonUtility.FromJson<SettingsSave>(_save_data);
			override_event = settingsSave.override_event.unserialize();
			vetoed = settingsSave.vetoed.toHashSet();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load CustomLeadOverrideSetting!\nData: {_save_data}\nError: {arg}");
			remove_stamps = false;
			override_event = new Dictionary<int, LeadEventType>();
			vetoed = new HashSet<LeadEventType>();
		}
	}

	public string toSaveData()
	{
		if (remove_stamps)
		{
			return "SKIP";
		}
		return JsonUtility.ToJson(new SettingsSave(override_event, vetoed));
	}
}
