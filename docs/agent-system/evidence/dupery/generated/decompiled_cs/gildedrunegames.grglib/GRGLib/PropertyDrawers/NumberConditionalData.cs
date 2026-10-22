using GRGLib.Extensions.Numbers;

namespace GRGLib.PropertyDrawers;

public class NumberConditionalData : ConditionalData
{
	public readonly NumberComparaison method;

	public readonly string compare;

	public NumberConditionalData(string _field, bool _inverse, NumberComparaison _comparaison, object _number)
		: base(_field, _inverse)
	{
		string text = _number.ToString();
		method = _comparaison;
		compare = text;
	}
}
