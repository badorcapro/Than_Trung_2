using GRGLib.Coroutines;
using GRGLib.UI;
using UnityEngine.EventSystems;

public class JiggleButton : AdvancedButton
{
	private CoroutineRunner jiggle_runner;

	protected override void Awake()
	{
		base.Awake();
		jiggle_runner = new CoroutineRunner(this);
	}

	public override void OnPointerEnter(PointerEventData eventData)
	{
		base.OnPointerEnter(eventData);
		if (base.interactable)
		{
			jiggle_runner.run(GetComponentInChildren<JiggleTarget>().rect_trans.jiggle());
		}
	}

	public override void OnSelect(BaseEventData eventData)
	{
		base.OnSelect(eventData);
		if (base.interactable)
		{
			jiggle_runner.run(GetComponentInChildren<JiggleTarget>().rect_trans.jiggle());
		}
	}
}
