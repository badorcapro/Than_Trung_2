using System.Linq;

namespace GRGLib.PropertyDrawers;

public class ValueConditionalData : ConditionalData
{
	protected readonly string[] values_to_compare;

	public ValueConditionalData(string _field, bool _inverse, params object[] _compare)
		: base(_field, _inverse)
	{
		values_to_compare = _compare.Select((object _c) => _c.ToString()).ToArray();
	}
}
