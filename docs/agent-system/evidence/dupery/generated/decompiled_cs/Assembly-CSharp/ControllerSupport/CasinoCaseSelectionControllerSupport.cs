using System.Collections.Generic;
using CaseSelection;
using UnityEngine;

namespace ControllerSupport;

public class CasinoCaseSelectionControllerSupport : CaseSelectionRegionControllerSupport
{
	[SerializeField]
	private LeverHandle lever_handle;

	[SerializeField]
	private CasinoSlotMachine slot_machine;

	protected override void setUpRegionSpecific(CaseSelectionInputHandler _input_handler)
	{
		_input_handler.addActionCallback(ControllerActions.SOUTH, "lever_handle", lever_handle.onSouthButton);
	}

	public override void setBackupSelectable(List<CaseOption> _case_options)
	{
		base.setBackupSelectable(_case_options);
		slot_machine.setUpSelectable(_case_options[1].getSelectable());
	}
}
