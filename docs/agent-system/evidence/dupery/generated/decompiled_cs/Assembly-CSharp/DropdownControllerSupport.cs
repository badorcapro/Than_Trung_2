using GRGLib.Coroutines;
using TMPro;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class DropdownControllerSupport : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private TMP_Dropdown dropdown;

	[SerializeField]
	private RectTransform dropdown_zone;

	[SerializeField]
	private RectTransform content;

	[Header("Settings")]
	[SerializeField]
	private float upper_diff = 30f;

	private Toggle last_selected;

	private CoroutineRunner content_mover;

	private void Awake()
	{
		content_mover = new CoroutineRunner(this);
	}

	private void Update()
	{
		checkSelectable();
	}

	public void checkSelectable()
	{
		if (!GameHandler.instance.using_gamepad)
		{
			return;
		}
		GameObject currentSelectedGameObject = EventSystem.current.currentSelectedGameObject;
		if (currentSelectedGameObject == null || !currentSelectedGameObject.transform.IsChildOf(dropdown.transform))
		{
			return;
		}
		Toggle component = currentSelectedGameObject.GetComponent<Toggle>();
		if (!(component == null) && !(component == last_selected))
		{
			last_selected = component;
			Vector2 vector = new Vector2(content.localPosition.y + upper_diff, content.localPosition.y + dropdown_zone.sizeDelta.y - upper_diff);
			if (0f - component.transform.localPosition.y < vector.x)
			{
				content_mover.run(content.moveTransform(new Vector3(content.localPosition.x, 0f - component.transform.localPosition.y - upper_diff, content.localPosition.z), 0.2f, CoroutineExtensions.easeInOutFunc, CoroutineExtensions.getUnscaledDeltaTime));
			}
			else if (0f - component.transform.localPosition.y > vector.y)
			{
				content_mover.run(content.moveTransform(new Vector3(content.localPosition.x, vector.x - upper_diff - component.transform.localPosition.y - vector.y, content.localPosition.z), 0.2f, CoroutineExtensions.easeInOutFunc, CoroutineExtensions.getUnscaledDeltaTime));
			}
		}
	}
}
