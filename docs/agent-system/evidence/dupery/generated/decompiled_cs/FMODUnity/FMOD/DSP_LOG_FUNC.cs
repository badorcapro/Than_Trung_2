using System;

namespace FMOD;

public delegate void DSP_LOG_FUNC(DEBUG_FLAGS level, IntPtr file, int line, IntPtr function, IntPtr str);
