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
		if (_context.canceled)
		{
			shift_down = false;
		}
		else if (_context.performed)
		{
			shift_down = true;
		}
	}
}
