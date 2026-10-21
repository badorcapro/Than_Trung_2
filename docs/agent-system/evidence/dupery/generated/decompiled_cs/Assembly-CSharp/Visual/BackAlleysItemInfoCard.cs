using GRGLib.Coroutines;
using TMPro;
using UnityEngine;

namespace Visual;

public class BackAlleysItemInfoCard : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private CanvasGroup group;

	[SerializeField]
	private TMP_Text text;

	private void Start()
	{
		group.fade(1f, 0.35f, CoroutineExtensions.easeInOutFunc).start(this);
	}

	public void setText(string _text)
	{
		text.text = _text;
	}
}
