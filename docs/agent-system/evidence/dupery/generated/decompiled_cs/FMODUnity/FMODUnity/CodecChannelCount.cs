using System;

namespace FMODUnity;

[Serializable]
public class CodecChannelCount
{
	public CodecType format;

	public int channels;

	public CodecChannelCount()
	{
	}

	public CodecChannelCount(CodecChannelCount other)
	{
		format = other.format;
		channels = other.channels;
	}
}
