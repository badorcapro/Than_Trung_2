namespace GRGLib.PropertyDrawers;

public class MultipleValueConditionalData : ValueConditionalData
{
	public readonly string[] fields;

	public readonly bool all_match;

	public MultipleValueConditionalData(object _compare, bool _all_match, bool _inverse, params string[] _fields)
		: base("", _inverse, _compare)
	{
		bool flag = _all_match;
		fields = _fields;
		all_match = flag;
	}
}
