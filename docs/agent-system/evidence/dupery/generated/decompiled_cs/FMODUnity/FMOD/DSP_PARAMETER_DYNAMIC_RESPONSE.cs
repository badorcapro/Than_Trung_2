using System.Runtime.InteropServices;

namespace FMOD;

public struct DSP_PARAMETER_DYNAMIC_RESPONSE
{
	public int numchannels;

	[MarshalAs(UnmanagedType.ByValArray, SizeConst = 32)]
	public float[] rms;
}
