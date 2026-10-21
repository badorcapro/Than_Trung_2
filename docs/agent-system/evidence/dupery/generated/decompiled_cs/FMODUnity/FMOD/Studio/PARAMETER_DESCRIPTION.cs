namespace FMOD.Studio;

public struct PARAMETER_DESCRIPTION
{
	public StringWrapper name;

	public PARAMETER_ID id;

	public float minimum;

	public float maximum;

	public float defaultvalue;

	public PARAMETER_TYPE type;

	public PARAMETER_FLAGS flags;

	public GUID guid;
}
