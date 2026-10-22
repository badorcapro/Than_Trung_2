using GRGLib.Coroutines;
using GRGLib.Extensions.Unity;
using UnityEngine;
using UnityEngine.InputSystem;

public class CursorController : MonoBehaviour
{
	[SerializeField]
	private SpriteRenderer cursor_sr;

	private CoroutineRunner cursor_visibility_runner;

	public static CursorController instance { get; private set; }

	public bool is_hidden { get; private set; }

	private void Awake()
	{
		if (instance != null && instance != this)
		{
			Object.Destroy(base.gameObject);
			return;
		}
		Object.DontDestroyOnLoad(base.gameObject);
		instance = this;
		Cursor.visible = false;
		cursor_visibility_runner = new CoroutineRunner(this);
	}

	private void Update()
	{
		if (Pointer.current != null && Pointer.current.wasUpdatedThisFrame)
		{
			Vector2 vector = Camera.main.ScreenToWorldPoint(Pointer.current.position.ReadValue());
			base.transform.position = vector;
		}
	}

	public void setHidden(bool _new_state, bool _immidiate = false)
	{
		if (_immidiate)
		{
			cursor_visibility_runner.stop();
			is_hidden = _new_state;
			updateHiddenState();
		}
		else if (_new_state == is_hidden)
		{
			cursor_visibility_runner.stop();
		}
		else
		{
			cursor_visibility_runner.run((_new_state ? 0.25f : 0.1f).wait(delegate
			{
				setHidden(_new_state, _immidiate: true);
			}));
		}
	}

	public void toggleHidden(bool _immidiate = false)
	{
		setHidden(!is_hidden, _immidiate);
	}

	private void updateHiddenState()
	{
		cursor_sr.setAlpha((!is_hidden) ? 1 : 0);
	}
}
