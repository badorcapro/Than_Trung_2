using System.Collections;
using GRGLib.Coroutines;
using UnityEngine;

namespace Visual;

public class JudgeGavelAnimationEffect : WorldAnimationEffect
{
	[Header("References")]
	[SerializeField]
	private CanvasGroup group;

	private CoroutineRunner group_runner;

	public override void startAnimation(RoleData _role, CaseSnapshot _snap, BoardVisualManager _board_visual)
	{
		base.transform.position = _board_visual.getPositionOfCrimeScene();
		group_runner = new CoroutineRunner(this);
		group_runner.run(group.fade(1f, 0.35f));
		shakeContinuous().start(this);
	}

	public override void stopAnimation()
	{
		group_runner.run(group.fade(0f, 0.15f).addCallback(delegate
		{
			Object.Destroy(base.gameObject);
		}));
	}

	private IEnumerator shakeContinuous()
	{
		while (true)
		{
			yield return base.transform.shake(1f, 1f);
		}
	}
}
