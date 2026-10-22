using UnityEngine;
using UnityEngine.EventSystems;

public class RubberBrush : MonoBehaviour, IPointerUpHandler, IEventSystemHandler, IPointerDownHandler
{
	[Header("Reference")]
	[SerializeField]
	private RubberManager rubber_manager;

	public void OnPointerUp(PointerEventData eventData)
	{
		rubber_manager.OnPointerUp(eventData);
	}

	public void OnPointerDown(PointerEventData eventData)
	{
		rubber_manager.OnPointerDown(eventData);
	}
}
