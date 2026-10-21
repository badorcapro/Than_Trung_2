using System;

namespace FMOD.Studio;

public struct BANK_INFO
{
	public int size;

	public IntPtr userdata;

	public int userdatalength;

	public FILE_OPEN_CALLBACK opencallback;

	public FILE_CLOSE_CALLBACK closecallback;

	public FILE_READ_CALLBACK readcallback;

	public FILE_SEEK_CALLBACK seekcallback;
}
