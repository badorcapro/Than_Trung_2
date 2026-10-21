using GRGLib.Coroutines;
using UnityEngine;

namespace Codex;

public abstract class CodexPage : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	protected CanvasGroup group;

	public virtual void immidiateFadeIn()
	{
		group.alpha = 1f;
	}

	public virtual void fadeIn()
	{
		group.fade(1f, 0.35f, CoroutineExtensions.easeInOutFunc).start(this);
	}

	public virtual void fadeOutAndDestroy()
	{
		group.fade(0f, 0.35f, CoroutineExtensions.easeInOutFunc).addCallback(delegate
		{
			Object.Destroy(base.gameObject);
		}).start(this);
	}

	public virtual void immidiateDestroy()
	{
		Object.Destroy(base.gameObject);
	}
}
