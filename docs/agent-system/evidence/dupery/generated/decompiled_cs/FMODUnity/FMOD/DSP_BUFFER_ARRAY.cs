using System;
using System.Runtime.InteropServices;

namespace FMOD;

public struct DSP_BUFFER_ARRAY
{
	public int numbuffers;

	public IntPtr buffernumchannels;

	public IntPtr bufferchannelmask;

	public IntPtr buffers;

	public SPEAKERMODE speakermode;

	public int numchannels
	{
		get
		{
			if (buffernumchannels != IntPtr.Zero && numbuffers != 0)
			{
				return Marshal.ReadInt32(buffernumchannels);
			}
			return 0;
		}
		set
		{
			if (buffernumchannels != IntPtr.Zero && numbuffers != 0)
			{
				Marshal.WriteInt32(buffernumchannels, value);
			}
		}
	}

	public IntPtr buffer
	{
		get
		{
			if (buffers != IntPtr.Zero && numbuffers != 0)
			{
				return Marshal.ReadIntPtr(buffers);
			}
			return IntPtr.Zero;
		}
		set
		{
			if (buffers != IntPtr.Zero && numbuffers != 0)
			{
				Marshal.WriteIntPtr(buffers, value);
			}
		}
	}
}
