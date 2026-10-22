using System.Collections;
using GRGLib.Coroutines;
using GRGLib.Extensions.Unity;
using GRGLib.Extensions.Vector;
using GRGLib.Maybe;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.Events;
using UnityEngine.InputSystem;

namespace Visual.Drawing;

public class RTBrush : MonoBehaviour, IPointerDownHandler, IEventSystemHandler, IPointerUpHandler
{
	[Header("References")]
	[SerializeField]
	private Canvas canvas;

	[SerializeField]
	private RTDrawer drawer;

	[Header("Settings")]
	[SerializeField]
	private int brush_radius = 4;

	[SerializeField]
	[Range(0f, 2f)]
	private float line_tolerance = 1f;

	[Header("Events")]
	[SerializeField]
	private UnityEvent on_draw_start;

	[SerializeField]
	private UnityEvent on_draw_end;

	[SerializeField]
	private UnityEvent on_pen_end;

	private bool can_draw;

	private Color32 brush_colour = Color.white;

	private Maybe<Vector2Int> previous_pos = new Maybe<Vector2Int>();

	private CoroutineRunner drawing_runner;

	public bool drawing => drawing_runner.is_running;

	public Vector2 mouse_pos => canvas.getPositionToUI(Pointer.current.position.ReadValue());

	private void Awake()
	{
		drawing_runner = new CoroutineRunner(this);
	}

	public void setCanDraw(bool _true = true)
	{
		can_draw = _true;
	}

	public void changeColour(Color _colour)
	{
		brush_colour = _colour;
	}

	public void OnPointerDown(PointerEventData eventData)
	{
		if (eventData.button == PointerEventData.InputButton.Left)
		{
			on_draw_start.Invoke();
			drawing_runner.run(drawMousePosition());
		}
	}

	public void OnPointerUp(PointerEventData eventData)
	{
		if (eventData.button == PointerEventData.InputButton.Left)
		{
			on_draw_end.Invoke();
			drawing_runner.stop();
			previous_pos = new Maybe<Vector2Int>();
		}
		else if (eventData.button == PointerEventData.InputButton.Right)
		{
			drawing_runner.stop();
			previous_pos = new Maybe<Vector2Int>();
			on_pen_end.Invoke();
		}
	}

	private IEnumerator drawMousePosition()
	{
		drawToRT(mouse_pos);
		Vector2 previous_pos = mouse_pos;
		while (true)
		{
			Vector2 vector = mouse_pos;
			if (vector != previous_pos)
			{
				drawToRT(vector);
				previous_pos = vector;
			}
			yield return null;
		}
	}

	private void drawToRT(Vector2 _mouse_pos)
	{
		if (can_draw)
		{
			Vector2Int vector2Int = _mouse_pos.toVector2Int() + new Vector2Int(1920, 1080);
			Vector2Int obj = vector2Int;
			drawer.stampCircleBrush(brush_radius, vector2Int, brush_colour);
			if (previous_pos.is_some && (previous_pos.value - vector2Int).magnitude > (float)brush_radius * line_tolerance)
			{
				drawer.stampLineBrush(previous_pos.value, vector2Int, brush_radius, brush_colour);
			}
			previous_pos = obj.maybe();
		}
	}
}
