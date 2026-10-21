using System;

namespace FMOD;

public struct ADVANCEDSETTINGS
{
	public int cbSize;

	public int maxMPEGCodecs;

	public int maxADPCMCodecs;

	public int maxXMACodecs;

	public int maxVorbisCodecs;

	public int maxAT9Codecs;

	public int maxFADPCMCodecs;

	public int maxOpusCodecs;

	public int ASIONumChannels;

	public IntPtr ASIOChannelList;

	public IntPtr ASIOSpeakerList;

	public float vol0virtualvol;

	public uint defaultDecodeBufferSize;

	public ushort profilePort;

	public uint geometryMaxFadeTime;

	public float distanceFilterCenterFreq;

	public int reverb3Dinstance;

	public int DSPBufferPoolSize;

	public DSP_RESAMPLER resamplerMethod;

	public uint randomSeed;

	public int maxConvolutionThreads;

	public int maxSpatialObjects;
}
