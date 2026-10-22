using GRGLib.Coroutines;
using UnityEngine;
using UnityEngine.UI;

namespace MainMenu;

public class MainMenuSwipe : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private MenuBase main_menu;

	[SerializeField]
	private CanvasGroup group;

	[SerializeField]
	private Image title;

	private void Awake()
	{
		if (!GameHandler.instance.is_first_scene)
		{
			main_menu.forceOpenImmidiate();
			title.color = new Color(1f, 1f, 1f, 1f);
			Object.Destroy(base.gameObject);
		}
	}

	private void Start()
	{
		base.transform.moveTransform(new Vector3(-4000f, 0f), 0.5f, CoroutineExtensions.easeInOutFunc).addCallback(delegate
		{
			main_menu.openMenu();
			title.fade(1f, 0.5f, CoroutineExtensions.easeInOutFunc).start(title);
			Object.Destroy(base.gameObject);
		}).start(this);
	}
}
