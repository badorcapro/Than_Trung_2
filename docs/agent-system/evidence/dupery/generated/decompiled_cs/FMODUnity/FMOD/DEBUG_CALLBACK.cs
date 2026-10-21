using System;

namespace FMOD;

public delegate RESULT DEBUG_CALLBACK(DEBUG_FLAGS flags, IntPtr file, int line, IntPtr func, IntPtr message);
