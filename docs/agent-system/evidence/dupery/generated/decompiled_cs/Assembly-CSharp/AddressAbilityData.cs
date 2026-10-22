public class AddressAbilityData : AbilityData
{
	public int address;

	public override string as_debug => address.ToString();

	public AddressAbilityData(int _address)
	{
		address = _address;
	}
}
