using Hover;
using Leads;
using Quirks;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class StasisPolaroid : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private Image icon;

	[SerializeField]
	private TMP_Text title;

	[SerializeField]
	private HoveringImage hover_image;

	[SerializeField]
	private Button button;

	private Either<CaseQuirkData, RoleData> data;

	public void setStasis(Sprite _sprite, CaseQuirkData _quirk_data)
	{
		icon.sprite = _sprite;
		title.text = _quirk_data.name;
		data = new Either<CaseQuirkData, RoleData>(_quirk_data);
		hover_image.setUp(_quirk_data);
	}

	public void setStasis(Sprite _sprite, Color _colour, RoleClue _clue)
	{
		icon.sprite = _sprite;
		icon.color = _colour;
		title.text = _clue.getName();
		hover_image.setUp(_clue.getName(), _clue.getDescription());
	}

	public Selectable getSelectable()
	{
		return button;
	}
}
