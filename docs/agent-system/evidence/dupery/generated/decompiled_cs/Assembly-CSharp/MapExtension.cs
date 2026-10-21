using TMPro;
using UnityEngine;

public class MapExtension : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private CanvasGroup group;

	[SerializeField]
	private TMP_Text button_text;

	[SerializeField]
	private TMP_Text input_action;

	[Header("Settings")]
	[SerializeField]
	private InputAssetPerType controller_input;

	[SerializeField]
	private float normal_button_size = 335f;

	public CanvasGroup getGroup()
	{
		return group;
	}

	public void setInputAction(InputType _input)
	{
		if (_input == InputType.KBM)
		{
			input_action.text = "";
			button_text.rectTransform.sizeDelta = new Vector2(normal_button_size, button_text.rectTransform.sizeDelta.y);
		}
		else
		{
			input_action.text = controller_input.getTextAsset(_input).addColourToSpriteLinks(Color.black);
			button_text.rectTransform.sizeDelta = new Vector2(normal_button_size - 105f, button_text.rectTransform.sizeDelta.y);
		}
	}
}
