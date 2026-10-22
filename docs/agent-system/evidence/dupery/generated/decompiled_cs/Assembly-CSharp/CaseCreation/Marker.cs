namespace CaseCreation;

public class Marker<T>
{
	public T data;

	public bool locked;

	public Marker(T _data, bool _locked = false)
	{
		data = _data;
		locked = _locked;
	}
}
