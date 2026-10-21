using UnityEngine;

namespace Nodes.Logic;

public class SetsDataNode : NodeBase
{
	[SerializeField]
	private string roleSetName;

	[SerializeField]
	[TextArea(5, 5)]
	private string roleSetDesctiption;

	public string getName()
	{
		return roleSetName;
	}

	public string getDescription()
	{
		return roleSetDesctiption;
	}
}
