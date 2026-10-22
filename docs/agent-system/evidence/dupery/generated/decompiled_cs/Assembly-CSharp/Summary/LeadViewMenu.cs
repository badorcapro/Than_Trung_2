using System.Collections;
using GRGLib.Coroutines;
using UnityEngine;

namespace Summary;

public class LeadViewMenu : MenuBase
{
	[Header("Lead View Settings")]
	[SerializeField]
	private SummarySceneManager scene_manager;

	[SerializeField]
	private Vector3 starting_lead_pos;

	private CoroutineRunner lead_runner;

	protected override void Awake()
	{
		base.Awake();
		lead_runner = new CoroutineRunner(this);
	}

	protected override void onMenuOpening()
	{
		base.onMenuOpening();
		if (scene_manager.current_facade.is_some)
		{
			scene_manager.current_facade.value.transform.localPosition = starting_lead_pos;
			lead_runner.run(scene_manager.current_facade.value.transform.moveTransform(new Vector3(101f, 0f), 0.85f, CoroutineExtensions.easeOutBackFunc));
		}
	}

	protected override void onMenuClosing()
	{
		base.onMenuClosing();
		if (scene_manager.current_facade.is_some)
		{
			lead_runner.run(scene_manager.current_facade.value.transform.moveTransform(new Vector3(starting_lead_pos.x, 0f - starting_lead_pos.y, 0f), 0.85f, CoroutineExtensions.easeInBackFunc));
		}
	}

	protected override IEnumerator closingMenuAnimation()
	{
		yield return 0.4f.wait();
		yield return base.closingMenuAnimation();
	}
}
