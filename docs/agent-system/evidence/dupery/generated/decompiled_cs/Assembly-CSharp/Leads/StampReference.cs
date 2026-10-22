using System;

namespace Leads;

[Serializable]
public struct StampReference
{
	public StampType stamp_type;

	public int data;

	public CaseQuirks data_as_quirk => (CaseQuirks)data;

	public Roles data_as_role => (Roles)data;

	public StampReference(StampType _type)
	{
		stamp_type = _type;
		data = 0;
	}

	public StampReference(StampType _type, CaseQuirks _quirk)
	{
		stamp_type = _type;
		data = (int)_quirk;
	}

	public StampReference(StampType _type, Roles _role)
	{
		stamp_type = _type;
		data = (int)_role;
	}

	public StampReference(StampType _type, int _data)
	{
		stamp_type = _type;
		data = _data;
	}

	public bool isSameAs(StampReference _ref)
	{
		if (stamp_type == _ref.stamp_type)
		{
			return data == _ref.data;
		}
		return false;
	}
}
