using System;
using GRGLib.PropertyDrawers;
using UnityEngine;

namespace GRGLib.Mono;

[AddComponentMenu("GRGLib/Misc/CompileSettingsCheck")]
public class CompileSettingsCheck : MonoBehaviour
{
	public enum CompileSettingsBehaviour
	{
		DESTROY,
		INACTIVE,
		[InspectorName("CREATE (when not removed)")]
		CREATE
	}

	[Flags]
	public enum CompileSettings
	{
		NONE = 0,
		DEMO = 1,
		BETA = 2,
		FULL_GAME = 4,
		STEAM = 8,
		NOT_STEAM = 0x10
	}

	[SerializeField]
	private bool on_awake = true;

	[SerializeField]
	[Tooltip("true = destory, false = inactive")]
	private CompileSettingsBehaviour behaviour;

	[SerializeField]
	[ConditionalField("behaviour", false, new object[] { CompileSettingsBehaviour.CREATE })]
	private GameObject prefab;

	[SerializeField]
	private CompileSettings remove_on;

	public void Awake()
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
		case CompileSettingsBehaviour.DESTROY:
			if (checkSettings())
			{
				UnityEngine.Object.Destroy(base.gameObject);
			}
			break;
		case CompileSettingsBehaviour.INACTIVE:
			if (checkSettings())
			{
				base.gameObject.SetActive(value: false);
			}
			break;
		case CompileSettingsBehaviour.CREATE:
			if (checkSettings())
			{
				UnityEngine.Object.Destroy(base.gameObject);
			}
			else
			{
				UnityEngine.Object.Instantiate(prefab, base.transform);
			}
			break;
		}
	}

	public bool checkSettings()
	{
		if ((remove_on & CompileSettings.FULL_GAME) == CompileSettings.FULL_GAME)
		{
			return true;
		}
		if ((remove_on & CompileSettings.STEAM) == CompileSettings.STEAM)
		{
			return true;
		}
		return false;
	}
}
