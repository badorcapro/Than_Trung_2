using System;
using System.Collections;
using GRGLib.Coroutines;
using GRGLib.Input;
using TMPro;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

namespace GRGLib.UI;

[AddComponentMenu("GRGLib/UI/ControllerDropdown")]
public class ControllerDropdown : MonoBehaviour
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

	protected virtual bool UseSelectables => GRGInputHandler.instance.useSelectables();

	private void Update()
	{
		checkSelectable();
	}

	private IEnumerator checkSelectablesWhileTrue(Func<bool> _test)
	{
		while (_test())
		{
			checkSelectable();
			yield return null;
		}
	}

	public void checkSelectable()
	{
		if (!UseSelectables)
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
				content.moveTransform(new Vector3(content.localPosition.x, 0f - component.transform.localPosition.y - upper_diff, content.localPosition.z), 0.2f, CoroutineExtensions.easeInOutFunc, CoroutineExtensions.getUnscaledDeltaTime).start(this);
			}
			else if (0f - component.transform.localPosition.y > vector.y)
			{
				content.moveTransform(new Vector3(content.localPosition.x, vector.x - upper_diff - component.transform.localPosition.y - vector.y, content.localPosition.z), 0.2f, CoroutineExtensions.easeInOutFunc, CoroutineExtensions.getUnscaledDeltaTime).start(this);
			}
		}
	}
}
