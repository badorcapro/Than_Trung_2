using System;
using FMOD;

namespace FMODUnity;

public class SystemNotInitializedException : Exception
{
	public RESULT Result;

	public string Location;

	public SystemNotInitializedException(RESULT result, string location)
		: base(string.Format("[FMOD] Initialization failed : {2} : {0} : {1}", result.ToString(), Error.String(result), location))
	{
		Result = result;
		Location = location;
	}

	public SystemNotInitializedException(Exception inner)
		: base("[FMOD] Initialization failed", inner)
	{
	}
}
