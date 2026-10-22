using System.Runtime.InteropServices;

namespace FMOD;

public struct DSP_PARAMETER_DESC
{
	public DSP_PARAMETER_TYPE type;

	[MarshalAs(UnmanagedType.ByValArray, SizeConst = 16)]
	public byte[] name;

	[MarshalAs(UnmanagedType.ByValArray, SizeConst = 16)]
	public byte[] label;

	public string description;

	public DSP_PARAMETER_DESC_UNION desc;
}
