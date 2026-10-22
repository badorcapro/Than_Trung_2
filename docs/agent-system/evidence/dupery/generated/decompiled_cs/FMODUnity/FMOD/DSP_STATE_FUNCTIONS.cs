using System;
using System.Runtime.InteropServices;

namespace FMOD;

public struct DSP_STATE_FUNCTIONS
{
	public DSP_ALLOC_FUNC alloc;

	public DSP_REALLOC_FUNC realloc;

	public DSP_FREE_FUNC free;

	public DSP_GETSAMPLERATE_FUNC getsamplerate;

	public DSP_GETBLOCKSIZE_FUNC getblocksize;

	public IntPtr dft_internal;

	public IntPtr pan_internal;

	public DSP_GETSPEAKERMODE_FUNC getspeakermode;

	public DSP_GETCLOCK_FUNC getclock;

	public DSP_GETLISTENERATTRIBUTES_FUNC getlistenerattributes;

	public DSP_LOG_FUNC log;

	public DSP_GETUSERDATA_FUNC getuserdata;

	public DSP_STATE_DFT_FUNCTIONS dft => Marshal.PtrToStructure<DSP_STATE_DFT_FUNCTIONS>(dft_internal);

	public DSP_STATE_PAN_FUNCTIONS pan => Marshal.PtrToStructure<DSP_STATE_PAN_FUNCTIONS>(pan_internal);
}
