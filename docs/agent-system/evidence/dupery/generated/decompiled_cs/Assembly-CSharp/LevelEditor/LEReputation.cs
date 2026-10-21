using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace LevelEditor;

public class LEReputation : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private LevelEditorManager manager;

	[SerializeField]
	private Slider slider;

	[SerializeField]
	private TMP_Text slider_text;

	public void onSetUp(LevelEditorManager _manager, bool _save)
	{
		if (!_save)
		{
			slider.value = 5f;
		}
		else if (_manager.creating_case is DocksCase docksCase)
		{
			slider.value = docksCase.reputation;
		}
		else if (_manager.creating_case is ClockCase clockCase)
		{
			slider.value = clockCase.reputation;
		}
		else
		{
			Debug.LogError("Trying to load reputation while not creating a docks or office case!");
		}
	}

	public void onInput(float _value)
	{
		int rep = Mathf.RoundToInt(_value);
		slider_text.text = rep.ToString();
		manager.setSpecial(delegate(LevelEditorManager _m, Case _c)
		{
			if (_c is DocksCase docksCase)
			{
				docksCase.setReputationFromLevelEditor(_m, rep);
			}
			else if (_c is ClockCase clockCase)
			{
				clockCase.setReputationFromLevelEditor(_m, rep);
			}
			else
			{
				Debug.LogError("Trying to set reputation while not creating a docks or office case!");
			}
		});
	}
}
