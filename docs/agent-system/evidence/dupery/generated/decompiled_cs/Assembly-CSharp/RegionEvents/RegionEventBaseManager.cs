using UnityEngine;

namespace RegionEvents;

public abstract class RegionEventBaseManager : MonoBehaviour
{
	public abstract void setUp(RegionDataGraphNavigator _navigator);
}
