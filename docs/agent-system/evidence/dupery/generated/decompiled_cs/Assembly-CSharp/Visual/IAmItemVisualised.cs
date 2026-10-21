using UnityEngine;

namespace Visual;

public interface IAmItemVisualised
{
	bool is_full { get; }

	MonoBehaviour mono { get; }

	string title { get; }

	string colour_name { get; }

	string description { get; }
}
