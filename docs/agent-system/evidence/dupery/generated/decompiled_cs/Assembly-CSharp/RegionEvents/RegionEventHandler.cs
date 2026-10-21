using Audio;
using GRGLib.Serializable;
using UnityEngine;
using UnityEngine.InputSystem;

namespace RegionEvents;

public class RegionEventHandler : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private PlayerInput player_input;

	[Header("Prefabs")]
	[SerializeField]
	private SerializableDictionary<RegionEventsType, RegionEventBaseManager> event_prefabs;

	private void Start()
	{
		setUp();
		GameHandler.instance.saveGame();
	}

	public void setUp()
	{
		AudioHandler.Atmo.stopAllAtmoAndStart(Atmo.RAIN_WINDOW);
	}
}
