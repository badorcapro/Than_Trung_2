using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class PrimeSuspectVisual : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private Image icon;

	[SerializeField]
	private TMP_Text role_name;

	public void setUp(Roles _role, RoleVisualDataSO _role_data)
	{
		icon.sprite = _role_data[_role];
		icon.color = _role_data[_role.getClassificationFromRoleType()].class_colour;
		role_name.text = _role.toString();
	}

	public void setUpEmpty(RoleVisualDataSO _role_data)
	{
		icon.sprite = _role_data.getUnknownRoleIcon();
		icon.color = Color.white;
		role_name.text = "???";
	}
}
