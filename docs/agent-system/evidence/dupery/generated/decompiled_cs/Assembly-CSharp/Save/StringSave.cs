using System;
using System.Collections.Generic;
using System.Linq;
using Visual;

namespace Save;

[Serializable]
public class StringSave
{
	public List<StringSaveData> strings_data;

	public bool is_empty => strings_data.Count == 0;

	public StringSave()
	{
		strings_data = new List<StringSaveData>();
	}

	public StringSave(List<ConnectionString> _strings)
	{
		strings_data = _strings.Select((ConnectionString _s) => _s.toSave()).ToList();
	}

	public void addString(StringSaveData _string)
	{
		strings_data.Add(_string);
	}

	public void removeString(int _index_1, int _index_2)
	{
		strings_data.RemoveAll((StringSaveData _p) => _p.pin_connection.Item1 == _index_1 && _p.pin_connection.Item2 == _index_2);
	}
}
