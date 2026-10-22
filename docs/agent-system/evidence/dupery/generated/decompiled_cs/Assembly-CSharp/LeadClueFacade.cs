using TMPro;
using UnityEngine;

public class LeadClueFacade : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private RectTransform name_box;

	[SerializeField]
	private TMP_Text clue_name;

	[SerializeField]
	private RectTransform text_box;

	[SerializeField]
	private TMP_Text clue_text;

	public void setUp(string _name, string _text)
	{
		clue_name.text = _name;
		clue_text.text = _text;
	}

	public void scaleUp(float _height = 140f)
	{
		name_box.sizeDelta = new Vector2(name_box.sizeDelta.x, _height);
		text_box.sizeDelta = new Vector2(text_box.sizeDelta.x, _height);
	}
}
