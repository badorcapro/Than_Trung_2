using TMPro;
using UnityEngine;

public class CreditBlock : MonoBehaviour
{
	[SerializeField]
	private TMP_Text block_text;

	public void updateBlock(string _new_text)
	{
		block_text.text = _new_text;
	}
}
