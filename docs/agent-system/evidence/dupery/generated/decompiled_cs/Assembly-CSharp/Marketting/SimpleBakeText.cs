using TMPro;
using UnityEngine;

namespace Marketting;

public class SimpleBakeText : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private TMP_Text text;

	private void Start()
	{
		text.bakeText();
	}
}
