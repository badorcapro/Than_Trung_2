using System;
using FMOD;

namespace FMODUnity;

public class BankLoadException : Exception
{
	public string Path;

	public RESULT Result;

	public BankLoadException(string path, RESULT result)
		: base($"[FMOD] Could not load bank '{path}' : {result.ToString()} : {Error.String(result)}")
	{
		Path = path;
		Result = result;
	}

	public BankLoadException(string path, string error)
		: base($"[FMOD] Could not load bank '{path}' : {error}")
	{
		Path = path;
		Result = RESULT.ERR_INTERNAL;
	}
}
