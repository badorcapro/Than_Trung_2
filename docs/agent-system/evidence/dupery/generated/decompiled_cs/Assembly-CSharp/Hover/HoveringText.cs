using TMPro;
using UnityEngine;
using UnityEngine.EventSystems;

namespace Hover;

public class HoveringText : MonoBehaviour, IPointerEnterHandler, IEventSystemHandler, IPointerExitHandler
{
	[Header("References")]
	[SerializeField]
	private TMP_Text text;

	public TMP_Text getText()
	{
		return text;
	}

	public void OnPointerEnter(PointerEventData eventData)
	{
		GameHandler.Links.startChecks(text);
	}

	public void OnPointerExit(PointerEventData eventData)
	{
		GameHandler.Links.stopChecks(text);
	}

	public void forceEndCheck()
	{
		GameHandler.Links.stopChecks(text);
	}

	private void Reset()
	{
		text = GetComponent<TMP_Text>();
	}
}
