namespace GRGLib.PropertyDrawers;

public abstract class ConditionalData
{
	protected readonly string field_to_check;

	protected readonly bool inverse;

	public ConditionalData(string _field, bool _inverse = false)
	{
		bool flag = _inverse;
		field_to_check = _field;
		inverse = flag;
	}
}
