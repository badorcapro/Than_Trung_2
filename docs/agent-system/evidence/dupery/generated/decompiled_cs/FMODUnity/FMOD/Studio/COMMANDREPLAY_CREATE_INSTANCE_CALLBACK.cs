using System;

namespace FMOD.Studio;

public delegate RESULT COMMANDREPLAY_CREATE_INSTANCE_CALLBACK(IntPtr replay, int commandindex, IntPtr eventdescription, out IntPtr instance, IntPtr userdata);
