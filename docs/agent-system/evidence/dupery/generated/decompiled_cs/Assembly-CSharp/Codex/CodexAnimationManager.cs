using GRGLib.Coroutines;
using UnityEngine;

namespace Codex;

public class CodexAnimationManager : ParalaxAnimationManager
{
	[Header("Codex References")]
	[SerializeField]
	private RectTransform background;

	private CoroutineRunner scale_runner;

	private Vector2 start_scale = new Vector2(0.9f, 0.9f);

	protected override void Awake()
	{
		base.Awake();
		scale_runner = new CoroutineRunner(this);
		start_scale = background.localScale;
	}

	public void openAnimation()
	{
		animateObjects("open");
		scale_runner.run(background.scaleTransform(1f, 0.5f, CoroutineExtensions.easeOutFunc));
	}

	public void closeAnimation()
	{
		animateObjects("close");
		scale_runner.run(background.scaleTransform(start_scale, 0.5f, CoroutineExtensions.easeOutFunc));
	}
}
