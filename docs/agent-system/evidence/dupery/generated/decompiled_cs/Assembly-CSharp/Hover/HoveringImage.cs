using Quirks;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

namespace Hover;

public class HoveringImage : MonoBehaviour, IPointerEnterHandler, IEventSystemHandler, IPointerExitHandler
{
	[Header("References")]
	[SerializeField]
	private Image image;

	private string title;

	private string description;

	public void setUp(CaseQuirks _quirk)
	{
		setUp(_quirk.createQuirk());
	}

	public void setUp(CaseQuirkData _quirk)
	{
		setUp(_quirk.name, _quirk.description);
	}

	public void setUp(string _title, string _description)
	{
		title = _title;
		description = _description;
	}

	public void OnPointerEnter(PointerEventData eventData)
	{
		GameHandler.Links.createImageHover(image, title, description);
	}

	public void OnPointerExit(PointerEventData eventData)
	{
		GameHandler.Links.deleteImageHover(image);
	}

	public void asPointerEnter()
	{
		OnPointerEnter(null);
	}

	public void asPointerExit()
	{
		OnPointerExit(null);
	}

	public void forceEndCheck()
	{
		GameHandler.Links.deleteImageHover(image);
	}

	private void Reset()
	{
		image = GetComponent<Image>();
	}
}
