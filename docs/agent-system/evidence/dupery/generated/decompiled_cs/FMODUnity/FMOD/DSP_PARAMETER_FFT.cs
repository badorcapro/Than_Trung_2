using System;
using System.Runtime.InteropServices;

namespace FMOD;

public struct DSP_PARAMETER_FFT
{
	public int length;

	public int numchannels;

	[MarshalAs(UnmanagedType.ByValArray, SizeConst = 32)]
	private IntPtr[] spectrum_internal;

	public float[][] spectrum
	{
		get
		{
			float[][] array = new float[numchannels][];
			for (int i = 0; i < numchannels; i++)
			{
				array[i] = new float[length];
				Marshal.Copy(spectrum_internal[i], array[i], 0, length);
			}
			return array;
		}
	}

	public void getSpectrum(ref float[][] buffer)
	{
		int num = Math.Min(buffer.Length, numchannels);
		for (int i = 0; i < num; i++)
		{
			getSpectrum(i, ref buffer[i]);
		}
	}

	public void getSpectrum(int channel, ref float[] buffer)
	{
		int num = Math.Min(buffer.Length, length);
		Marshal.Copy(spectrum_internal[channel], buffer, 0, num);
	}
}
