using System;
using System.Collections.Generic;

namespace FMODUnity;

[Serializable]
public class ThreadAffinityGroup
{
	public List<ThreadType> threads = new List<ThreadType>();

	public ThreadAffinity affinity;

	public ThreadAffinityGroup()
	{
	}

	public ThreadAffinityGroup(ThreadAffinityGroup other)
	{
		threads = new List<ThreadType>(other.threads);
		affinity = other.affinity;
	}

	public ThreadAffinityGroup(ThreadAffinity affinity, params ThreadType[] threads)
	{
		this.threads = new List<ThreadType>(threads);
		this.affinity = affinity;
	}
}
