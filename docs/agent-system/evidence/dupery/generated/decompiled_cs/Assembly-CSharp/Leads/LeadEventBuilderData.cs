using System;

namespace Leads;

[Serializable]
public struct LeadEventBuilderData
{
	public LeadEventType event_type;

	public string data;

	public LeadEventBuilderData(LeadEventType _event_type)
	{
		event_type = _event_type;
		data = "";
	}

	public LeadEventBuilderData(RoleClueEventData _role_data)
	{
		string text = _role_data.toData();
		event_type = LeadEventType.ADD_ROLE_CLUE;
		data = text;
	}

	public LeadEventBuilderData(QuirkClueEventData _quirk_data)
	{
		string text = _quirk_data.toData();
		event_type = LeadEventType.ADD_QUIRK_CLUE;
		data = text;
	}

	public LeadEventBuilderData(params ChipsGainEventData.GainCap[] _gains)
	{
		string text = new ChipsGainEventData(_gains).toData();
		event_type = LeadEventType.CHIPS_GAIN;
		data = text;
	}

	public LeadEventBuilderData(LeadEventType _event_type, string _data)
	{
		event_type = _event_type;
		data = _data;
	}

	public bool isSame(LeadEventBuilderData _data)
	{
		if (event_type == _data.event_type)
		{
			return data == _data.data;
		}
		return false;
	}
}
