namespace GRGLib.PropertyDrawers;

public class ConditionalReadOnlyData : ReadOnlyData
{
	private ConditionalData check;

	public ConditionalReadOnlyData(ConditionalData _check)
	{
		check = _check;
	}
}
