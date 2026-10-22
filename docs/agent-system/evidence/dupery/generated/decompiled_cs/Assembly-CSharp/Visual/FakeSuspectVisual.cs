using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace Visual;

public class FakeSuspectVisual : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private TMP_Text name_text;

	[SerializeField]
	private Image icon;

	[SerializeField]
	private Image outline;

	private Image outline_to_copy;

	public void setUp(string _name, Image _icon, Image _outline)
	{
		name_text.text = _name;
		icon.sprite = _icon.sprite;
		icon.color = _icon.color;
		outline_to_copy = _outline;
	}

	private void Update()
	{
		if (!(outline_to_copy == null))
		{
			outline.color = outline_to_copy.color;
		}
	}
}
