using System;
using System.Runtime.InteropServices;

namespace FMOD;

public struct CREATESOUNDEXINFO
{
	public int cbsize;

	public uint length;

	public uint fileoffset;

	public int numchannels;

	public int defaultfrequency;

	public SOUND_FORMAT format;

	public uint decodebuffersize;

	public int initialsubsound;

	public int numsubsounds;

	public IntPtr inclusionlist;

	public int inclusionlistnum;

	public IntPtr pcmreadcallback_internal;

	public IntPtr pcmsetposcallback_internal;

	public IntPtr nonblockcallback_internal;

	public IntPtr dlsname;

	public IntPtr encryptionkey;

	public int maxpolyphony;

	public IntPtr userdata;

	public SOUND_TYPE suggestedsoundtype;

	public IntPtr fileuseropen_internal;

	public IntPtr fileuserclose_internal;

	public IntPtr fileuserread_internal;

	public IntPtr fileuserseek_internal;

	public IntPtr fileuserasyncread_internal;

	public IntPtr fileuserasynccancel_internal;

	public IntPtr fileuserdata;

	public int filebuffersize;

	public CHANNELORDER channelorder;

	public IntPtr initialsoundgroup;

	public uint initialseekposition;

	public TIMEUNIT initialseekpostype;

	public int ignoresetfilesystem;

	public uint audioqueuepolicy;

	public uint minmidigranularity;

	public int nonblockthreadid;

	public IntPtr fsbguid;

	public SOUND_PCMREAD_CALLBACK pcmreadcallback
	{
		get
		{
			if (!(pcmreadcallback_internal == IntPtr.Zero))
			{
				return Marshal.GetDelegateForFunctionPointer<SOUND_PCMREAD_CALLBACK>(pcmreadcallback_internal);
			}
			return null;
		}
		set
		{
			pcmreadcallback_internal = ((value == null) ? IntPtr.Zero : Marshal.GetFunctionPointerForDelegate(value));
		}
	}

	public SOUND_PCMSETPOS_CALLBACK pcmsetposcallback
	{
		get
		{
			if (!(pcmsetposcallback_internal == IntPtr.Zero))
			{
				return Marshal.GetDelegateForFunctionPointer<SOUND_PCMSETPOS_CALLBACK>(pcmsetposcallback_internal);
			}
			return null;
		}
		set
		{
			pcmsetposcallback_internal = ((value == null) ? IntPtr.Zero : Marshal.GetFunctionPointerForDelegate(value));
		}
	}

	public SOUND_NONBLOCK_CALLBACK nonblockcallback
	{
		get
		{
			if (!(nonblockcallback_internal == IntPtr.Zero))
			{
				return Marshal.GetDelegateForFunctionPointer<SOUND_NONBLOCK_CALLBACK>(nonblockcallback_internal);
			}
			return null;
		}
		set
		{
			nonblockcallback_internal = ((value == null) ? IntPtr.Zero : Marshal.GetFunctionPointerForDelegate(value));
		}
	}

	public FILE_OPEN_CALLBACK fileuseropen
	{
		get
		{
			if (!(fileuseropen_internal == IntPtr.Zero))
			{
				return Marshal.GetDelegateForFunctionPointer<FILE_OPEN_CALLBACK>(fileuseropen_internal);
			}
			return null;
		}
		set
		{
			fileuseropen_internal = ((value == null) ? IntPtr.Zero : Marshal.GetFunctionPointerForDelegate(value));
		}
	}

	public FILE_CLOSE_CALLBACK fileuserclose
	{
		get
		{
			if (!(fileuserclose_internal == IntPtr.Zero))
			{
				return Marshal.GetDelegateForFunctionPointer<FILE_CLOSE_CALLBACK>(fileuserclose_internal);
			}
			return null;
		}
		set
		{
			fileuserclose_internal = ((value == null) ? IntPtr.Zero : Marshal.GetFunctionPointerForDelegate(value));
		}
	}

	public FILE_READ_CALLBACK fileuserread
	{
		get
		{
			if (!(fileuserread_internal == IntPtr.Zero))
			{
				return Marshal.GetDelegateForFunctionPointer<FILE_READ_CALLBACK>(fileuserread_internal);
			}
			return null;
		}
		set
		{
			fileuserread_internal = ((value == null) ? IntPtr.Zero : Marshal.GetFunctionPointerForDelegate(value));
		}
	}

	public FILE_SEEK_CALLBACK fileuserseek
	{
		get
		{
			if (!(fileuserseek_internal == IntPtr.Zero))
			{
				return Marshal.GetDelegateForFunctionPointer<FILE_SEEK_CALLBACK>(fileuserseek_internal);
			}
			return null;
		}
		set
		{
			fileuserseek_internal = ((value == null) ? IntPtr.Zero : Marshal.GetFunctionPointerForDelegate(value));
		}
	}

	public FILE_ASYNCREAD_CALLBACK fileuserasyncread
	{
		get
		{
			if (!(fileuserasyncread_internal == IntPtr.Zero))
			{
				return Marshal.GetDelegateForFunctionPointer<FILE_ASYNCREAD_CALLBACK>(fileuserasyncread_internal);
			}
			return null;
		}
		set
		{
			fileuserasyncread_internal = ((value == null) ? IntPtr.Zero : Marshal.GetFunctionPointerForDelegate(value));
		}
	}

	public FILE_ASYNCCANCEL_CALLBACK fileuserasynccancel
	{
		get
		{
			if (!(fileuserasynccancel_internal == IntPtr.Zero))
			{
				return Marshal.GetDelegateForFunctionPointer<FILE_ASYNCCANCEL_CALLBACK>(fileuserasynccancel_internal);
			}
			return null;
		}
		set
		{
			fileuserasynccancel_internal = ((value == null) ? IntPtr.Zero : Marshal.GetFunctionPointerForDelegate(value));
		}
	}
}
