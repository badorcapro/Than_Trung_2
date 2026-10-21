using Audio;
using GRGLib.Coroutines;
using UnityEngine;
using UnityEngine.EventSystems;

public class BobberVisuals : MonoBehaviour, IPointerEnterHandler, IEventSystemHandler
{
	private CoroutineRunner jiggler;

	private void Awake()
	{
		jiggler = new CoroutineRunner(this);
	}

	public void OnPointerEnter(PointerEventData eventData)
	{
		jiggler.run(base.transform.jiggle());
		AudioHandler.Sfx.playSfx(Sfx.PAPER_SHORT, 0.75f);
	}
}
