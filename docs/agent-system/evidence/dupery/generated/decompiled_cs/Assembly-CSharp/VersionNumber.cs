using TMPro;
using UnityEngine;

public class VersionNumber : MonoBehaviour
{
	[SerializeField]
	private TMP_Text text;

	public void Awake()
	{
		text.text = getCompileSettingsString() + "v" + Application.version;
	}

	private string getCompileSettingsString()
	{
		string text = "";
		text += "STEAM / ";
		if (text.Length > 2)
		{
			return text.Substring(0, text.Length - 2);
		}
		return "";
	}

	public void Reset()
	{
		text = GetComponent<TMP_Text>();
	}
}
