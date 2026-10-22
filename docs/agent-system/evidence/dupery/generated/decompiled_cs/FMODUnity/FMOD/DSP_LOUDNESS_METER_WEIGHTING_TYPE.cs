using System.Runtime.InteropServices;

namespace FMOD;

public struct DSP_LOUDNESS_METER_WEIGHTING_TYPE
{
	[MarshalAs(UnmanagedType.ByValArray, SizeConst = 32)]
	public float[] channelweight;
}
