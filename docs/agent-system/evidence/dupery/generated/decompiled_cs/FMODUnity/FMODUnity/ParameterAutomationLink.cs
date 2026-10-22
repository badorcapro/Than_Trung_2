using System;
using FMOD.Studio;

namespace FMODUnity;

[Serializable]
public class ParameterAutomationLink
{
	public string Name;

	public PARAMETER_ID ID;

	public int Slot;
}
