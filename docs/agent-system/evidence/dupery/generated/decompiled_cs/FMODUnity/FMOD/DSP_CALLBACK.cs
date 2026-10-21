using System;

namespace FMOD;

public delegate RESULT DSP_CALLBACK(IntPtr dsp, DSP_CALLBACK_TYPE type, IntPtr data);
