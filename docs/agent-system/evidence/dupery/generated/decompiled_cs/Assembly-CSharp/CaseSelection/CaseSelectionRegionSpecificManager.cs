using ControllerSupport;
using UnityEngine;

namespace CaseSelection;

public abstract class CaseSelectionRegionSpecificManager : MonoBehaviour
{
	public abstract void setUp(_dep_RegionState _region, CaseSelectionInputHandler _input_handler);
}
