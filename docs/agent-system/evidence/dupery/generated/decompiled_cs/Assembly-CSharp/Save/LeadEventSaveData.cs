using System;
using Leads;

namespace Save;

[Serializable]
public class LeadEventSaveData
{
	public LeadEventType type;

	public bool show_exact;

	public string data;

	public LeadEventSaveData(LeadEventType _type, bool _show_exact, string _data)
	{
		type = _type;
		show_exact = _show_exact;
		data = _data;
	}
}
