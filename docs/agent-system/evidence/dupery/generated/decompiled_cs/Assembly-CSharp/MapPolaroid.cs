using System.Collections;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Coroutines;
using GRGLib.Extensions.Collections;
using GRGLib.Serializable;
using TMPro;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.InputSystem;

public abstract class MapPolaroid : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	protected CanvasGroup group;

	[SerializeField]
	protected TMP_Text title;

	[SerializeField]
	private GameObject hover_block;

	[SerializeField]
	private List<STupple<MapExtension, Vector2>> extensions;

	[SerializeField]
	private UnityEvent<MapPolaroid> on_extensions_open;

	[SerializeField]
	private UnityEvent<MapPolaroid> on_extensions_close;

	private MultiCoroutineRunner extension_runner;

	public bool discovered { get; protected set; }

	public bool selected { get; protected set; }

	private void Awake()
	{
		extension_runner = new MultiCoroutineRunner(this);
	}

	protected virtual void setDiscovered(bool _true)
	{
		discovered = _true;
		group.interactable = _true;
	}

	public void openExtension()
	{
		if (!discovered)
		{
			return;
		}
		hover_block.SetActive(value: true);
		extension_runner.run(extensions.Aggregate(new List<IEnumerator>(), (List<IEnumerator> _c, STupple<MapExtension, Vector2> _e) => _c.add(_e.Item1.getGroup().fade(1f, 0.35f, CoroutineExtensions.easeInOutFunc).addCallback(delegate
		{
			_e.Item1.getGroup().interactable = true;
			_e.Item1.getGroup().blocksRaycasts = true;
		})).add(_e.Item1.transform.moveTransform(_e.Item2, 0.65f, CoroutineExtensions.easeOutBackFunc))).ToArray());
		on_extensions_open.Invoke(this);
	}

	public void closeExtension()
	{
		hover_block.SetActive(value: false);
		extensions.ForEach(delegate(STupple<MapExtension, Vector2> _e)
		{
			_e.Item1.getGroup().interactable = false;
			_e.Item1.getGroup().blocksRaycasts = false;
		});
		extension_runner.run(extensions.Aggregate(new List<IEnumerator>(), (List<IEnumerator> _c, STupple<MapExtension, Vector2> _e) => _c.add(_e.Item1.getGroup().fade(0f, 0.65f, CoroutineExtensions.easeInOutFunc)).add(_e.Item1.transform.moveTransform(Vector3.zero, 0.65f, CoroutineExtensions.easeInBackFunc))).ToArray());
		on_extensions_close.Invoke(this);
	}

	public virtual void onPolaroidSelect(bool _select)
	{
		selected = _select;
	}

	public void onControlsChanged(PlayerInput _input)
	{
		InputType input_type = _input.getInputType();
		extensions.ForEach(delegate(STupple<MapExtension, Vector2> _e)
		{
			_e.Item1.setInputAction(input_type);
		});
	}

	public void onControllerSouth(InputAction.CallbackContext _context)
	{
		if (selected && _context.canceled)
		{
			onA();
		}
	}

	protected virtual void onA()
	{
	}

	public void onControllerWest(InputAction.CallbackContext _context)
	{
		if (selected && _context.canceled)
		{
			onX();
		}
	}

	protected virtual void onX()
	{
	}

	public void onControllerNorth(InputAction.CallbackContext _context)
	{
		if (selected && _context.canceled)
		{
			onY();
		}
	}

	protected virtual void onY()
	{
	}

	public void onControllerSelect(InputAction.CallbackContext _context)
	{
		if (selected && _context.canceled)
		{
			onSelect();
		}
	}

	protected virtual void onSelect()
	{
	}
}
