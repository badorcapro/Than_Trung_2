using System.Collections.Generic;
using CaseSelection;
using UnityEngine;

namespace ControllerSupport;

public class CaseSelectionRegionControllerSupport : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	protected CaseSelectionHandler selection_handler;

	protected CaseSelectionInputHandler input_handler;

	public void setUp(CaseSelectionInputHandler _input_handler)
	{
		input_handler = _input_handler;
		setUpRegionSpecific(_input_handler);
	}

	protected virtual void setUpRegionSpecific(CaseSelectionInputHandler _input_handler)
	{
	}

	public virtual void setBackupSelectable(List<CaseOption> _case_options)
	{
		input_handler.setBackupSelectable(_case_options[0].getSelectable());
	}
}
