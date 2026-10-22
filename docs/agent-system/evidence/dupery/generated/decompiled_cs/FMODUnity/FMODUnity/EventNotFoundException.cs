using System;
using FMOD;

namespace FMODUnity;

public class EventNotFoundException : Exception
{
	public GUID Guid;

	public string Path;

	public EventNotFoundException(string path)
		: base("[FMOD] Event not found: '" + path + "'")
	{
		Path = path;
	}

	public EventNotFoundException(GUID guid)
		: base("[FMOD] Event not found: " + ((GUID)guid/*cast due to .constrained prefix*/).ToString())
	{
		Guid = guid;
	}

	public EventNotFoundException(EventReference eventReference)
		: base("[FMOD] Event not found: " + eventReference.ToString())
	{
		Guid = eventReference.Guid;
	}
}
