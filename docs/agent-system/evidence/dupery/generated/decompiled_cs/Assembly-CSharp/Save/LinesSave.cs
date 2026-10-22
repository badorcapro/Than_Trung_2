using System;
using System.Collections.Generic;
using GRGLib.Serializable;
using UnityEngine;
using Visual;

namespace Save;

[Serializable]
public class LinesSave
{
	public static int max_lines_saved = 200;

	public List<LineSaveData> lines_data;

	public SerializableDictionary<Roles, ControllerSuspectLineTypes> suspect_lines;

	public bool is_empty => lines_data.Count == 0;

	public LinesSave()
	{
		List<LineSaveData> list = new List<LineSaveData>();
		SerializableDictionary<Roles, ControllerSuspectLineTypes> serializableDictionary = new SerializableDictionary<Roles, ControllerSuspectLineTypes>();
		lines_data = list;
		suspect_lines = serializableDictionary;
	}

	public LinesSave(List<ModifiedUILineRenderer> _ui_lines, Dictionary<SuspectVisual, (ModifiedUILineRenderer, ControllerSuspectLineTypes)> _suspect_lines)
	{
		lines_data = new List<LineSaveData>();
		for (int i = Mathf.Max(0, _ui_lines.Count - max_lines_saved); i < _ui_lines.Count; i++)
		{
			tryAddLine(_ui_lines[i]);
		}
		resetSuspectLines(_suspect_lines);
	}

	private void addLine(LineSaveData _line)
	{
		lines_data.Add(_line);
	}

	public void tryAddLine(ModifiedUILineRenderer _line_renderer)
	{
		if (!_line_renderer.special_preset && _line_renderer.tryGetSaveData(out var _data))
		{
			if (lines_data.Count >= max_lines_saved)
			{
				lines_data.RemoveAt(0);
			}
			addLine(_data);
		}
	}

	public void resetSuspectLines(Dictionary<SuspectVisual, (ModifiedUILineRenderer, ControllerSuspectLineTypes)> _suspect_lines)
	{
		suspect_lines = new SerializableDictionary<Roles, ControllerSuspectLineTypes>();
		foreach (KeyValuePair<SuspectVisual, (ModifiedUILineRenderer, ControllerSuspectLineTypes)> _suspect_line in _suspect_lines)
		{
			suspect_lines[_suspect_line.Key.role_type] = _suspect_line.Value.Item2;
		}
	}
}
