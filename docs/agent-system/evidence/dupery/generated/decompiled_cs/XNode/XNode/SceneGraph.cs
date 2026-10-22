using UnityEngine;

namespace XNode;

public class SceneGraph : MonoBehaviour
{
	public NodeGraph graph;
}
public class SceneGraph<T> : SceneGraph where T : NodeGraph
{
	public new T graph
	{
		get
		{
			return base.graph as T;
		}
		set
		{
			base.graph = value;
		}
	}
}
