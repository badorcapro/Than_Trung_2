using UnityEngine;
using UnityEngine.UI;

namespace RegionEvents;

public class RoleSetChoiceRolePreshow : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private Image role_icon;

	public void setIcon(Sprite _icon, Color _colour)
	{
		role_icon.sprite = _icon;
		role_icon.color = _colour;
	}
}
