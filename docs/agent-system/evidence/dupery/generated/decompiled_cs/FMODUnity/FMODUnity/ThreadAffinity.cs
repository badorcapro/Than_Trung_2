using System;

namespace FMODUnity;

[Flags]
public enum ThreadAffinity : uint
{
	Any = 0u,
	Core0 = 1u,
	Core1 = 2u,
	Core2 = 4u,
	Core3 = 8u,
	Core4 = 0x10u,
	Core5 = 0x20u,
	Core6 = 0x40u,
	Core7 = 0x80u,
	Core8 = 0x100u,
	Core9 = 0x200u,
	Core10 = 0x400u,
	Core11 = 0x800u,
	Core12 = 0x1000u,
	Core13 = 0x2000u,
	Core14 = 0x4000u,
	Core15 = 0x8000u
}
