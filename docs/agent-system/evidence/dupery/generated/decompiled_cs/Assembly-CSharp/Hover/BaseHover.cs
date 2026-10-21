using GRGLib.Coroutines;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace Hover;

public abstract class BaseHover : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	protected TMP_Text text;

	[SerializeField]
	protected HoveringText hovering;

	[SerializeField]
	protected CanvasGroup group;

	[SerializeField]
	protected Image lock_image;

	protected CoroutineRunner fade_runner;

	protected CoroutineRunner lock_runner;

	public RectTransform rect_trans => base.transform as RectTransform;

	public abstract bool is_locked { get; }

	protected virtual void Awake()
	{
		fade_runner = new CoroutineRunner(this);
		lock_runner = new CoroutineRunner(this);
		hovering.enabled = is_locked;
	}

	public void destroySelf(bool _force = false)
	{
		if (!is_locked || _force)
		{
			fade_runner.run(group.fade(0f, 0.2f, CoroutineExtensions.easeInOutFunc).addCallback(delegate
			{
				Object.Destroy(base.gameObject);
			}));
			onDestroySelf();
		}
	}

	protected virtual void onDestroySelf()
	{
	}

	protected virtual void displayLock()
	{
		hovering.enabled = is_locked;
		group.blocksRaycasts = is_locked;
		group.interactable = is_locked;
		if (!is_locked)
		{
			hovering.forceEndCheck();
		}
		lock_runner.run(lock_image.fill(is_locked ? 1 : 0, is_locked ? 0.2f : 0.15f, CoroutineExtensions.easeInOutFunc));
	}
}
