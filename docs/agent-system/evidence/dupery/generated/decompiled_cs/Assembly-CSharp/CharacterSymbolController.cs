using UnityEngine;

public class CharacterSymbolController : MonoBehaviour
{
	[SerializeField]
	private RectTransform arrested_symbol;

	[SerializeField]
	private RectTransform tainted_symbol;

	[SerializeField]
	private RectTransform dead_symbol;

	[SerializeField]
	private RectTransform obscured_symbol;

	public void updateSymbols(bool _arrested, bool _tainted, bool _dead, bool _obscured)
	{
		arrested_symbol.gameObject.SetActive(_arrested);
		tainted_symbol.gameObject.SetActive(_tainted);
		dead_symbol.gameObject.SetActive(_dead);
		obscured_symbol.gameObject.SetActive(_obscured);
		if (_arrested && _tainted && _dead && _obscured)
		{
			arrested_symbol.sizeDelta *= new Vector2(0.82f, 0.82f);
			tainted_symbol.sizeDelta *= new Vector2(0.82f, 0.82f);
			dead_symbol.sizeDelta *= new Vector2(0.82f, 0.82f);
			obscured_symbol.sizeDelta *= new Vector2(0.82f, 0.82f);
		}
	}
}
