using System;

namespace FMOD.Studio;

[Flags]
public enum COMMANDREPLAY_FLAGS : uint
{
	NORMAL = 0u,
	SKIP_CLEANUP = 1u,
	FAST_FORWARD = 2u,
	SKIP_BANK_LOAD = 4u
}
