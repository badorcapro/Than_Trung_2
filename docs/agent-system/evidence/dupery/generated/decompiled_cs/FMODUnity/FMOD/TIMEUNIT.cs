using System;

namespace FMOD;

[Flags]
public enum TIMEUNIT : uint
{
	MS = 1u,
	PCM = 2u,
	PCMBYTES = 4u,
	RAWBYTES = 8u,
	PCMFRACTION = 0x10u,
	MODORDER = 0x100u,
	MODROW = 0x200u,
	MODPATTERN = 0x400u
}
