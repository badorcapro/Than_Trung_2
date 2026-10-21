using System;

namespace FMOD.Studio;

[Flags]
public enum SYSTEM_CALLBACK_TYPE : uint
{
	PREUPDATE = 1u,
	POSTUPDATE = 2u,
	BANK_UNLOAD = 4u,
	LIVEUPDATE_CONNECTED = 8u,
	LIVEUPDATE_DISCONNECTED = 0x10u,
	ALL = uint.MaxValue
}
