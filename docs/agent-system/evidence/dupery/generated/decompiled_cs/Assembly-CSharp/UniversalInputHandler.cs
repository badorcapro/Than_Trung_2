using UnityEngine;
using UnityEngine.InputSystem;

public class UniversalInputHandler : MonoBehaviour
{
	public bool shift_down { get; private set; }

	private void Start()
	{
		GameHandler.instance.setUniversalInputHandlerReference(this);
	}

	public void onShiftKey(InputAction.CallbackContext _context)
	{
	}
}
