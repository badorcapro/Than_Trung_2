using System;
using System.Collections;
using System.Collections.Generic;
using GRGLib.Coroutines;
using GRGLib.Extensions.Unity;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.InputSystem;
using UnityEngine.UI;
using Visual.Drawing;

namespace Visual;

public class PenManager : NotesToolManager
{
	private enum PenState
	{
		NONE,
		SELECTED,
		DRAWING,
		COLOUR_CHANGE
	}

	[Header("Pen References")]
	[SerializeField]
	private CanvasGroup drawing_group;

	[SerializeField]
	private LRBrush lr_brush;

	[SerializeField]
	private RTBrush brush;

	[SerializeField]
	private Image colour_indicator;

	[SerializeField]
	private RubberManager rubber_manager;

	[SerializeField]
	private ColourWheel colour_wheel;

	[Header("Settings")]
	[SerializeField]
	private List<Color> pen_colours;

	[Header("Callbacks")]
	[SerializeField]
	private UnityEvent<Dictionary<Roles, ControllerSuspectLineTypes>> load_suspect_lines;

	private Dictionary<SuspectVisual, (ModifiedUILineRenderer, ControllerSuspectLineTypes)> suspect_controller_lines = new Dictionary<SuspectVisual, (ModifiedUILineRenderer, ControllerSuspectLineTypes)>();

	private int colour_index;

	private CoroutineRunner pen_colour_runner;

	private Vector3 starting_pen_position;

	private PenState pen_state;

	protected override Vector3 starting_tool_position => starting_pen_position;

	protected override Vector2 tool_offset
	{
		get
		{
			if (!lr_brush.drawing)
			{
				return new Vector2(5f, 10f);
			}
			return new Vector2(0f, 0f);
		}
	}

	protected override void Awake()
	{
		base.Awake();
		starting_pen_position = tool_trans.localPosition;
		pen_colour_runner = new CoroutineRunner(this);
		setColour(0);
		lr_brush.setGetters(() => suspect_controller_lines);
	}

	public override void setUpReferences(Canvas _canvas, PlayerInput _player_input)
	{
		base.setUpReferences(_canvas, _player_input);
		lr_brush.setReferences(_canvas);
	}

	protected override bool canSelect()
	{
		return !rubber_manager.tool_selected;
	}

	protected override void onToolSelect()
	{
		drawing_group.blocksRaycasts = true;
		lr_brush.setCanDraw();
		pen_state = PenState.SELECTED;
		pen_colour_runner.run(checkColourChange());
	}

	protected override void onToolDeselect()
	{
		drawing_group.blocksRaycasts = false;
		lr_brush.setCanDraw(_true: false);
		pen_state = PenState.NONE;
		colour_wheel.stopMousePosCheckAndClose();
	}

	public void onDrawStart()
	{
		if (base.tool_selected)
		{
			pen_state = PenState.DRAWING;
			tool_position_runner.run(tool_trans.moveTransform(tool_active_offset, 0.35f, CoroutineExtensions.easeInOutFunc));
			tool_rotation_runner.run(tool_trans.rotateTransformSmart(-125f, 0.35f, CoroutineExtensions.easeInOutFunc));
		}
	}

	public void onDrawEnd()
	{
		if (base.tool_selected)
		{
			pen_state = PenState.SELECTED;
			tool_position_runner.run(tool_trans.moveTransform(tool_inactive_offset, 0.35f, CoroutineExtensions.easeInOutFunc));
			tool_rotation_runner.run(tool_trans.rotateTransformDirection(215f, 0.35f, _clockwise: true, CoroutineExtensions.easeInOutFunc));
		}
	}

	public void onColourSelectStart()
	{
		tool_follow_runner.stop();
		colour_wheel.startMousePosCheck();
		colour_wheel.setColoursAndOpen(pen_colours, base.transform.position, delegate(Color _c)
		{
			setColour(pen_colours.FindIndex(0, (Color _clr) => _clr == _c));
		}, _limit_y: false);
		if (pen_state == PenState.DRAWING)
		{
			lr_brush.forceDrawEnd();
		}
		pen_state = PenState.COLOUR_CHANGE;
		lr_brush.setCanDraw(_true: false);
	}

	public void onColourSelectEnd()
	{
		if (base.tool_selected)
		{
			tool_follow_runner.run(followMouse());
			colour_wheel.stopMousePosCheckAndClose();
			pen_state = PenState.SELECTED;
			lr_brush.setCanDraw();
		}
	}

	public void changePenColourLeft(InputAction.CallbackContext _context)
	{
		if (_context.performed && base.tool_selected)
		{
			setColour((colour_index + pen_colours.Count - 1) % pen_colours.Count);
		}
	}

	public void changePenColourRight(InputAction.CallbackContext _context)
	{
		if (_context.performed && base.tool_selected)
		{
			setColour((colour_index + 1) % pen_colours.Count);
		}
	}

	public void changePenColourFromTap()
	{
		setColour((colour_index + 1) % pen_colours.Count);
	}

	private IEnumerator checkColourChange()
	{
		return checkColourChange(delegate(int _index)
		{
			setColour((colour_index + _index) % pen_colours.Count);
		}, pen_colours.Count);
	}

	private void setColour(int _colour_index)
	{
		colour_index = _colour_index;
		colour_indicator.color = pen_colours[colour_index];
		lr_brush.changeColour(pen_colours[colour_index]);
	}

	public void clearAll()
	{
		lr_brush.clear();
	}

	public void cycleSuspectCross(SuspectVisual _visual)
	{
		if (!suspect_controller_lines.ContainsKey(_visual))
		{
			toggleSuspectCross(_visual, ControllerSuspectLineTypes.CROSS_OUT);
		}
		else if (suspect_controller_lines[_visual].Item2 == ControllerSuspectLineTypes.CROSS_OUT)
		{
			toggleSuspectCross(_visual, ControllerSuspectLineTypes.CHECKMARK);
		}
		else
		{
			toggleSuspectCross(_visual, ControllerSuspectLineTypes.CIRCLE);
		}
	}

	public void toggleSuspectCross(SuspectVisual _suspect, ControllerSuspectLineTypes _wanted)
	{
		if (!suspect_controller_lines.ContainsKey(_suspect))
		{
			suspect_controller_lines[_suspect] = (makeLineOfType(_wanted, _suspect), _wanted);
			return;
		}
		(ModifiedUILineRenderer, ControllerSuspectLineTypes) tuple = suspect_controller_lines[_suspect];
		lr_brush.destroyLine(tuple.Item1);
		if (tuple.Item2 == _wanted)
		{
			suspect_controller_lines.Remove(_suspect);
		}
		else
		{
			suspect_controller_lines[_suspect] = (makeLineOfType(_wanted, _suspect), _wanted);
		}
	}

	private ModifiedUILineRenderer makeLineOfType(ControllerSuspectLineTypes _wanted, SuspectVisual _suspect)
	{
		return _wanted switch
		{
			ControllerSuspectLineTypes.CROSS_OUT => makeCrossOutLine(_suspect), 
			ControllerSuspectLineTypes.CHECKMARK => makeCheckpointLine(_suspect), 
			ControllerSuspectLineTypes.CIRCLE => makeCircleLine(_suspect), 
			_ => throw new ArgumentException($"No line of type {_wanted} set up!"), 
		};
	}

	private ModifiedUILineRenderer makeCrossOutLine(SuspectVisual _suspect)
	{
		Vector2 positionToUI = canvas.getPositionToUI(Camera.main.WorldToScreenPoint(_suspect.transform.position));
		Vector2 item = positionToUI - new Vector2(_suspect.rect_trans.sizeDelta.x * 0.5f, _suspect.rect_trans.sizeDelta.y * 0.5f);
		Vector2 item2 = positionToUI + new Vector2(_suspect.rect_trans.sizeDelta.x * 0.5f, (0f - _suspect.rect_trans.sizeDelta.y) * 0.5f);
		return lr_brush.drawLineAnimated(new List<Vector2> { item, item2 }, pen_colours[2]);
	}

	private ModifiedUILineRenderer makeCheckpointLine(SuspectVisual _suspect)
	{
		Vector2 positionToUI = canvas.getPositionToUI(Camera.main.WorldToScreenPoint(_suspect.transform.position));
		Vector2 item = positionToUI + new Vector2(_suspect.rect_trans.sizeDelta.x * 0.5f - 60f, (0f - _suspect.rect_trans.sizeDelta.y) * 0.5f + 5f);
		Vector2 item2 = positionToUI + new Vector2(_suspect.rect_trans.sizeDelta.x * 0.5f - 45f, (0f - _suspect.rect_trans.sizeDelta.y) * 0.5f - 20f);
		Vector2 item3 = positionToUI + new Vector2(_suspect.rect_trans.sizeDelta.x * 0.5f, (0f - _suspect.rect_trans.sizeDelta.y) * 0.5f + 45f);
		return lr_brush.drawLineAnimated(new List<Vector2> { item, item2, item3 }, pen_colours[1]);
	}

	private ModifiedUILineRenderer makeCircleLine(SuspectVisual _suspect)
	{
		Vector2 vector = canvas.getPositionToUI(Camera.main.WorldToScreenPoint(_suspect.transform.position)) + new Vector2(_suspect.rect_trans.sizeDelta.x * 0.5f - 45f, (0f - _suspect.rect_trans.sizeDelta.y) * 0.5f + 3f);
		float num = 30f;
		List<Vector2> list = new List<Vector2>();
		for (int i = 0; i < 40; i++)
		{
			list.Add(vector + new Vector2(Mathf.Sin(MathF.PI / 180f * (float)i * 9f), Mathf.Cos(MathF.PI / 180f * (float)i * 9f)) * num);
		}
		list.Add(vector + new Vector2(Mathf.Sin(0f), Mathf.Cos(0f)) * num);
		return lr_brush.drawLineAnimated(list, pen_colours[4]);
	}

	public void addFullyDrawnLine(List<Vector2> _points)
	{
		lr_brush.addNewFullyDrawnLine(_points);
	}

	public bool hasAnyLine()
	{
		return lr_brush.line_count > 0;
	}

	public void setUpSave()
	{
		lr_brush.drawLinesFromSave(delegate(Dictionary<Roles, ControllerSuspectLineTypes> _s)
		{
			load_suspect_lines.Invoke(_s);
		});
	}
}
