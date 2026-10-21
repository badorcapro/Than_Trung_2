using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using Audio;
using GRGLib.Coroutines;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Unity;
using GRGLib.Maybe;
using GRGLib.Serializable;
using Save;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.Events;
using UnityEngine.InputSystem;

namespace Visual.Drawing;

public class LRBrush : MonoBehaviour, IPointerDownHandler, IEventSystemHandler, IPointerUpHandler
{
	[Header("References")]
	[SerializeField]
	private Canvas canvas;

	[SerializeField]
	private RectTransform lines_parent;

	[SerializeField]
	private PenManager pen_manager;

	[Header("Prefabs")]
	[SerializeField]
	private ModifiedUILineRenderer line_prefab;

	[Header("Events")]
	[SerializeField]
	private UnityEvent on_draw_start;

	[SerializeField]
	private UnityEvent on_draw_end;

	[SerializeField]
	private UnityEvent on_pen_end;

	[SerializeField]
	private UnityEvent on_colour_change_start;

	[SerializeField]
	private UnityEvent on_colour_change_end;

	private Maybe<ModifiedUILineRenderer> current_line = new Maybe<ModifiedUILineRenderer>();

	private List<ModifiedUILineRenderer> lines = new List<ModifiedUILineRenderer>();

	private bool can_draw;

	private Color32 brush_colour = Color.white;

	private Maybe<Vector2Int> previous_pos = new Maybe<Vector2Int>();

	private bool drawing_with_touch;

	private CoroutineRunner drawing_runner;

	private Func<Dictionary<SuspectVisual, (ModifiedUILineRenderer, ControllerSuspectLineTypes)>> get_preset_lines;

	public int line_count => lines.Count;

	public bool drawing => drawing_runner.is_running;

	public Vector2 mouse_pos
	{
		get
		{
			if (!drawing_with_touch)
			{
				return canvas.getPositionToUI(Pointer.current.position.ReadValue());
			}
			return canvas.getPositionToUI(Touchscreen.current.touches[0].position.ReadValue());
		}
	}

	private void Awake()
	{
		drawing_runner = new CoroutineRunner(this);
	}

	public void setReferences(Canvas _canvas)
	{
		canvas = _canvas;
	}

	public void setGetters(Func<Dictionary<SuspectVisual, (ModifiedUILineRenderer, ControllerSuspectLineTypes)>> _preset_lines)
	{
		get_preset_lines = _preset_lines;
	}

	public void setCanDraw(bool _true = true)
	{
		can_draw = _true;
		if (drawing)
		{
			stopDrawing();
		}
	}

	public void changeColour(Color _colour)
	{
		brush_colour = _colour;
		if (current_line.is_some)
		{
			List<Vector2> points = current_line.value.getPoints();
			Vector2 vector = points[points.Count - 1];
			lines.Add(current_line.value);
			makeNewLine();
			current_line.value.setPoints(new List<Vector2> { vector, vector });
			current_line.value.setDotImage(vector, brush_colour);
		}
	}

	public void clear()
	{
		lines.destroyAll();
	}

	public void OnPointerDown(PointerEventData eventData)
	{
		if (eventData.button == PointerEventData.InputButton.Middle)
		{
			on_colour_change_start.Invoke();
		}
		else
		{
			if (eventData.button != 0)
			{
				return;
			}
			if (drawing)
			{
				if (drawing_with_touch && Pointer.current == Touchscreen.current && Touchscreen.current.touches[1].isInProgress)
				{
					pen_manager.changePenColourFromTap();
				}
			}
			else
			{
				drawing_with_touch = Pointer.current == Touchscreen.current;
				on_draw_start.Invoke();
				makeNewLine();
				drawing_runner.run(drawMousePosition());
			}
		}
	}

	private void makeNewLine()
	{
		current_line = UnityEngine.Object.Instantiate(line_prefab, lines_parent).maybe();
		current_line.value.color = brush_colour;
	}

	public void OnPointerUp(PointerEventData eventData)
	{
		if (eventData.button == PointerEventData.InputButton.Left)
		{
			if (drawing_with_touch)
			{
				if (Touchscreen.current != null && Touchscreen.current.primaryTouch.ReadValue().isInProgress)
				{
					return;
				}
				drawing_with_touch = false;
			}
			stopDrawing();
		}
		else if (eventData.button == PointerEventData.InputButton.Right)
		{
			if (drawing)
			{
				stopDrawing();
			}
			current_line = new Maybe<ModifiedUILineRenderer>();
			previous_pos = new Maybe<Vector2Int>();
			on_pen_end.Invoke();
		}
		else if (eventData.button == PointerEventData.InputButton.Middle)
		{
			on_colour_change_end.Invoke();
		}
	}

	public void forceDrawEnd()
	{
		stopDrawing();
	}

	private void stopDrawing()
	{
		AudioHandler.Atmo.stopAtmoIfPlaying(Atmo.PEN_SCRIBLLES);
		on_draw_end.Invoke();
		drawing_runner.stop();
		if (current_line.is_some)
		{
			lines.Add(current_line.value);
			if (GameHandler.instance.current_scene == "GameScene")
			{
				GameHandler.State.getCaseNotes().lines_data.tryAddLine(current_line.value);
				GameHandler.instance.saveGame();
			}
		}
		current_line = new Maybe<ModifiedUILineRenderer>();
		previous_pos = new Maybe<Vector2Int>();
	}

	private IEnumerator drawMousePosition()
	{
		startDrawLine(mouse_pos);
		Vector2 previous_pos = mouse_pos;
		while (true)
		{
			Vector2 vector = mouse_pos;
			if (vector != previous_pos)
			{
				drawToRT(vector);
				previous_pos = vector;
				if (!AudioHandler.Atmo.isAtmoPlaying(Atmo.PEN_SCRIBLLES))
				{
					AudioHandler.Atmo.playAtmoAsSfx(Atmo.PEN_SCRIBLLES);
				}
			}
			else
			{
				AudioHandler.Atmo.stopAtmoIfPlaying(Atmo.PEN_SCRIBLLES);
			}
			yield return null;
		}
	}

	private void startDrawLine(Vector2 _mouse_pos, bool _force = false)
	{
		if ((can_draw || _force) && current_line.is_some)
		{
			current_line.value.setPoints(_mouse_pos.makeListFromItem().add(_mouse_pos + new Vector2(0f, 1f)));
			current_line.value.setDotImage(_mouse_pos, brush_colour);
		}
	}

	private void drawToRT(Vector2 _mouse_pos, bool _force = false)
	{
		if ((can_draw || _force) && current_line.is_some)
		{
			current_line.value.addPointWithIntermidiate(_mouse_pos, 5f);
		}
	}

	public bool eraseAtMousePos(float _rubber_radius, bool _with_touch)
	{
		drawing_with_touch = _with_touch;
		Vector2 erase_pos = mouse_pos;
		bool erased_something = false;
		lines.Where((ModifiedUILineRenderer _l) => checkErase(_l, erase_pos - _l.rectTransform.anchoredPosition, _rubber_radius, delegate
		{
			erased_something = true;
		})).ToList().ForEach(delegate(ModifiedUILineRenderer _l)
		{
			UnityEngine.Object.Destroy(_l.gameObject);
			lines.Remove(_l);
		});
		drawing_with_touch = false;
		return erased_something;
	}

	private bool checkErase(ModifiedUILineRenderer _line, Vector2 _probe_pos, float _rubber_radius, Action _on_erase_part)
	{
		if (_line.special_preset)
		{
			return false;
		}
		List<Vector2> points = _line.getPoints();
		bool flag = false;
		for (int i = 0; i < points.Count; i++)
		{
			if (Vector2.Distance(points[i], _probe_pos) <= _rubber_radius)
			{
				_line.setInvisiblePoints(i);
				flag = true;
			}
		}
		if (flag)
		{
			_line.refreshVertices();
			_on_erase_part();
		}
		return _line.isAllInvisible();
	}

	private bool pointInsideLine(List<Vector2> _points, Vector2 _probe_pos, float _rubber_radius)
	{
		for (int i = 0; i < _points.Count; i++)
		{
			if (Vector2.Distance(_points[i], _probe_pos) <= _rubber_radius)
			{
				return true;
			}
		}
		return false;
	}

	public void destroyLine(ModifiedUILineRenderer _line)
	{
		lines.Remove(_line);
		UnityEngine.Object.Destroy(_line.gameObject);
		resetLineSaves();
	}

	public ModifiedUILineRenderer drawLineAnimated(List<Vector2> _points, Color _colour)
	{
		Color32 color = brush_colour;
		brush_colour = _colour;
		makeNewLine();
		ModifiedUILineRenderer value = current_line.value;
		value.setSpecialPreset();
		drawLineAnimation(value, _points, 0.15f, color).start(value);
		return value;
	}

	private IEnumerator drawLineAnimation(ModifiedUILineRenderer _line, List<Vector2> _points, float _duration, Color _previous_colour)
	{
		startDrawLine(_points[0], _force: true);
		for (int i = 1; i < _points.Count; i++)
		{
			drawToRT(_points[i], _force: true);
		}
		stopDrawing();
		_line.makeAllPointsInvisible();
		brush_colour = _previous_colour;
		float e = 0f;
		int total_points = _line.getPoints().Count;
		int last_point = 0;
		while (e < _duration)
		{
			int num = Mathf.CeilToInt((float)total_points * CoroutineExtensions.easeInOutFunc(e / _duration));
			for (int j = last_point; j < num; j++)
			{
				_line.makePointVisible(j);
			}
			last_point = num;
			e += Time.deltaTime;
			yield return null;
		}
	}

	public void addNewFullyDrawnLine(List<Vector2> _points)
	{
		ModifiedUILineRenderer modifiedUILineRenderer = UnityEngine.Object.Instantiate(line_prefab, lines_parent);
		modifiedUILineRenderer.setPoints(new List<Vector2>
		{
			_points[0],
			_points[0] + new Vector2(1f, 0f)
		});
		modifiedUILineRenderer.color = Color.red;
		modifiedUILineRenderer.setDotImage(_points[0], Color.red);
		for (int i = 1; i < _points.Count; i++)
		{
			modifiedUILineRenderer.addPointWithIntermidiate(_points[i], 3f);
		}
		lines.Add(modifiedUILineRenderer);
	}

	public void resetLineSaves()
	{
		if (GameHandler.instance.current_scene == "GameScene")
		{
			GameHandler.State.getCaseNotes().lines_data = new LinesSave(lines, get_preset_lines());
			GameHandler.instance.saveGame();
		}
	}

	public void drawLinesFromSave(Action<Dictionary<Roles, ControllerSuspectLineTypes>> _on_preset_save)
	{
		if (GameHandler.State.case_notes.is_some)
		{
			LinesSave lines_data = GameHandler.State.getCaseNotes().lines_data;
			for (int i = 0; i < lines_data.lines_data.Count; i++)
			{
				ModifiedUILineRenderer modifiedUILineRenderer = UnityEngine.Object.Instantiate(line_prefab, lines_parent);
				modifiedUILineRenderer.setUpFromSave(lines_data.lines_data[i]);
				lines.Add(modifiedUILineRenderer);
			}
			if (lines_data.suspect_lines != null && lines_data.suspect_lines.Count > 0)
			{
				_on_preset_save(lines_data.suspect_lines.unserialize());
			}
		}
	}
}
