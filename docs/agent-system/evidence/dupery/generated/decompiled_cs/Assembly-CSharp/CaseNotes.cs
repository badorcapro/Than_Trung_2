using System.Collections.Generic;
using GRGLib.Maybe;
using Save;

public class CaseNotes
{
	public PinsSave pins_data;

	public LinesSave lines_data;

	public StringSave strings_data;

	public CaseNotes()
	{
		pins_data = new PinsSave(new List<PinSaveData>());
		lines_data = new LinesSave();
		strings_data = new StringSave();
	}

	public CaseNotes(PinsSave _pins, LinesSave _lines, StringSave _strings)
	{
		pins_data = _pins;
		lines_data = _lines;
		strings_data = _strings;
	}

	public CaseNotes(Maybe<PinsSave> _pins, Maybe<LinesSave> _lines, Maybe<StringSave> _strings)
	{
		pins_data = (_pins.is_some ? _pins.value : new PinsSave(new List<PinSaveData>()));
		lines_data = (_lines.is_some ? _lines.value : new LinesSave());
		strings_data = (_strings.is_some ? _strings.value : new StringSave());
	}
}
