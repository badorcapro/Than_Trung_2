using System.Runtime.InteropServices;

namespace FMOD.Studio;

[StructLayout(LayoutKind.Sequential, Size = 1)]
public struct Util
{
	public static RESULT parseID(string idString, out GUID id)
	{
		using StringHelper.ThreadSafeEncoding threadSafeEncoding = StringHelper.GetFreeHelper();
		return FMOD_Studio_ParseID(threadSafeEncoding.byteFromStringUTF8(idString), out id);
	}

	[DllImport("fmodstudio")]
	private static extern RESULT FMOD_Studio_ParseID(byte[] idString, out GUID id);
}
