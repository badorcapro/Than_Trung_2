public class SuspectAbilityData : AbilityData
{
	public Roles role;

	public override string as_debug => role.ToString();

	public SuspectAbilityData(Roles _role)
	{
		role = _role;
	}
}
