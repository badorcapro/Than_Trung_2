using System;

namespace FMOD.Studio;

public delegate RESULT COMMANDREPLAY_FRAME_CALLBACK(IntPtr replay, int commandindex, float currenttime, IntPtr userdata);
