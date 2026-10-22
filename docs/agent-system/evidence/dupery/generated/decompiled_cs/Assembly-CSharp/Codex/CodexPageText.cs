using GRGLib.Extensions.Unity;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace Codex;

public class CodexPageText : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	protected TMP_Text description;

	[SerializeField]
	protected Image description_icon;

	private float min_text_size = 100f;

	public TMP_Text getText()
	{
		return description;
	}

	public void setUp(string _description, Sprite _icon)
	{
		description.text = _description;
		description.ForceMeshUpdate();
		description_icon.sprite = _icon;
		description_icon.sizeToFit();
		min_text_size = description_icon.rectTransform.sizeDelta.y + 5f;
	}

	public float sizeText(float _total_height)
	{
		float renderedHeight = description.renderedHeight;
		if (renderedHeight < min_text_size)
		{
			renderedHeight = min_text_size;
			description.alignment = TextAlignmentOptions.Left;
		}
		description.rectTransform.sizeDelta = new Vector2(description.rectTransform.sizeDelta.x, renderedHeight);
		return _total_height + renderedHeight;
	}

	public float calculateMaxHeightChange()
	{
		return (description.rectTransform.sizeDelta.y - min_text_size) / 2f;
	}

	public void reduceTextHeightBy(float _size)
	{
		description.rectTransform.sizeDelta = new Vector2(description.rectTransform.sizeDelta.x, description.rectTransform.sizeDelta.y - _size);
		if (!description.enableAutoSizing)
		{
			description.fontSizeMax = description.fontSize;
			description.fontSizeMin = description.fontSize * 0.5f;
			description.enableAutoSizing = true;
		}
	}

	private void Reset()
	{
		description = GetComponent<TMP_Text>();
		description_icon = GetComponentInChildren<Image>();
	}
}
