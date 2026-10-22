using UnityEngine;
using UnityEngine.UI;
using Visual;

namespace ControllerSupport;

public class BoardControllerSupportManager : MonoBehaviour
{
	[Header("Internal References")]
	[SerializeField]
	protected CanvasGroup support_group;

	[SerializeField]
	protected Image role_selectioner;

	[Header("External References")]
	[SerializeField]
	protected PinsController pins_controller;

	[SerializeField]
	protected PenManager pen_manager;

	[SerializeField]
	protected RubberManager rubber_manager;

	[SerializeField]
	protected StringManager string_manager;

	[SerializeField]
	protected ColourWheel colour_wheel;

	public virtual void setUp(BoardVisualManager _board_manager)
	{
	}

	public virtual void setControllerSupportReferences(CaseControllerSupportHandler _controller_support_handler)
	{
		_controller_support_handler.setReferences(support_group, role_selectioner, pins_controller, pen_manager, rubber_manager, string_manager, colour_wheel);
	}
}
