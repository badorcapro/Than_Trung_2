using GRGLib.Mono;
using GRGLib.PropertyDrawers;
using UnityEngine;

public class CheatCompileSettingCheck : MonoBehaviour
{
	[SerializeField]
	private bool on_awake = true;

	[SerializeField]
	private CompileSettingsCheck.CompileSettingsBehaviour behaviour;

	[SerializeField]
	[ConditionalField("behaviour", false, new object[] { CompileSettingsCheck.CompileSettingsBehaviour.CREATE })]
	private GameObject prefab;

	[SerializeField]
	private bool trigger_not_cheat = true;

	private void Awake()
	{
		if (on_awake)
		{
			checkDelete();
		}
	}

	public void checkDelete()
	{
		switch (behaviour)
		{
		case CompileSettingsCheck.CompileSettingsBehaviour.DESTROY:
			if (checkSettings())
			{
				Object.Destroy(base.gameObject);
			}
			break;
		case CompileSettingsCheck.CompileSettingsBehaviour.INACTIVE:
			if (checkSettings())
			{
				base.gameObject.SetActive(value: false);
			}
			break;
		case CompileSettingsCheck.CompileSettingsBehaviour.CREATE:
			if (checkSettings())
			{
				Object.Destroy(base.gameObject);
			}
			else
			{
				Object.Instantiate(prefab, base.transform);
			}
			break;
		}
	}

	public bool checkSettings()
	{
		return trigger_not_cheat;
	}
}
