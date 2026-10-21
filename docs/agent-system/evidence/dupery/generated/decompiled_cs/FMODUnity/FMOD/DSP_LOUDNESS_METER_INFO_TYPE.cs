using System.Runtime.InteropServices;

namespace FMOD;

public struct DSP_LOUDNESS_METER_INFO_TYPE
{
	public float momentaryloudness;

	public float shorttermloudness;

	public float integratedloudness;

	public float loudness10thpercentile;

	public float loudness95thpercentile;

	[MarshalAs(UnmanagedType.ByValArray, SizeConst = 66)]
	public float[] loudnesshistogram;

	public float maxtruepeak;

	public float maxmomentaryloudness;
}
