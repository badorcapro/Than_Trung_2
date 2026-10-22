using System;

namespace FMOD;

public delegate RESULT FILE_OPEN_CALLBACK(IntPtr name, ref uint filesize, ref IntPtr handle, IntPtr userdata);
