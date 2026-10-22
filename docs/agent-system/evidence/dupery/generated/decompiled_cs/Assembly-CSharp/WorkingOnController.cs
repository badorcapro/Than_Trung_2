using UnityEngine;
using UnityEngine.InputSystem;
using Visual;

public class WorkingOnController : MonoBehaviour
{
	[SerializeField]
	private PenManager pen;

	[SerializeField]
	private RubberManager rubber;

	[SerializeField]
	private Canvas canvas;

	[SerializeField]
	private PlayerInput input;

	private void Awake()
	{
		pen.setUpReferences(canvas, input);
		rubber.setUpReferences(canvas, input);
	}
}
