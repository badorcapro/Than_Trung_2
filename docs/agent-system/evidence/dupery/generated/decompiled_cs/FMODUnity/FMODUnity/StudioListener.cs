using System.Collections.Generic;
using UnityEngine;

namespace FMODUnity;

[AddComponentMenu("FMOD Studio/FMOD Studio Listener")]
public class StudioListener : MonoBehaviour
{
	[SerializeField]
	private bool nonRigidbodyVelocity;

	[SerializeField]
	private GameObject attenuationObject;

	private Vector3 lastFramePosition = Vector3.zero;

	private Rigidbody rigidBody;

	private Rigidbody2D rigidBody2D;

	private static List<StudioListener> listeners = new List<StudioListener>();

	public GameObject AttenuationObject
	{
		get
		{
			return attenuationObject;
		}
		set
		{
			attenuationObject = value;
		}
	}

	public static int ListenerCount => listeners.Count;

	public int ListenerNumber => listeners.IndexOf(this);

	public static float DistanceToNearestListener(Vector3 position)
	{
		float num = float.MaxValue;
		for (int i = 0; i < listeners.Count; i++)
		{
			num = ((!(listeners[i].attenuationObject == null)) ? Mathf.Min(num, Vector3.Distance(position, listeners[i].attenuationObject.transform.position)) : Mathf.Min(num, Vector3.Distance(position, listeners[i].transform.position)));
		}
		return num;
	}

	public static float DistanceSquaredToNearestListener(Vector3 position)
	{
		float num = float.MaxValue;
		for (int i = 0; i < listeners.Count; i++)
		{
			num = ((!(listeners[i].attenuationObject == null)) ? Mathf.Min(num, (position - listeners[i].attenuationObject.transform.position).sqrMagnitude) : Mathf.Min(num, (position - listeners[i].transform.position).sqrMagnitude));
		}
		return num;
	}

	private static void AddListener(StudioListener listener)
	{
		if (listeners.Contains(listener))
		{
			Debug.LogWarning($"[FMOD] Listener has already been added at index {listener.ListenerNumber}.");
			return;
		}
		if (listeners.Count >= 8)
		{
			Debug.LogWarning($"[FMOD] Max number of listeners reached : {8}.");
		}
		listeners.Add(listener);
		RuntimeManager.StudioSystem.setNumListeners(Mathf.Clamp(listeners.Count, 1, 8));
	}

	private static void RemoveListener(StudioListener listener)
	{
		listeners.Remove(listener);
		RuntimeManager.StudioSystem.setNumListeners(Mathf.Clamp(listeners.Count, 1, 8));
	}

	private void OnEnable()
	{
		RuntimeUtils.EnforceLibraryOrder();
		rigidBody = base.gameObject.GetComponent<Rigidbody>();
		if (nonRigidbodyVelocity && (bool)rigidBody)
		{
			Debug.LogWarning($"[FMOD] Non-Rigidbody Velocity is enabled on Listener attached to GameObject \"{base.name}\", which also has a Rigidbody component attached - this will be disabled in favor of velocity from Rigidbody component.");
			nonRigidbodyVelocity = false;
		}
		rigidBody2D = base.gameObject.GetComponent<Rigidbody2D>();
		if (nonRigidbodyVelocity && (bool)rigidBody2D)
		{
			Debug.LogWarning($"[FMOD] Non-Rigidbody Velocity is enabled on Listener attached to GameObject \"{base.name}\", which also has a Rigidbody2D component attached - this will be disabled in favor of velocity from Rigidbody2D component.");
			nonRigidbodyVelocity = false;
		}
		AddListener(this);
		lastFramePosition = base.transform.position;
	}

	private void OnDisable()
	{
		RemoveListener(this);
	}

	private void Update()
	{
		if (ListenerNumber < 0 || ListenerNumber >= 8)
		{
			return;
		}
		if (nonRigidbodyVelocity)
		{
			Vector3 velocity = Vector3.zero;
			Vector3 position = base.transform.position;
			if (Time.deltaTime != 0f)
			{
				velocity = (position - lastFramePosition) / Time.deltaTime;
				velocity = Vector3.ClampMagnitude(velocity, 20f);
			}
			lastFramePosition = position;
			RuntimeManager.SetListenerLocation(ListenerNumber, base.gameObject, attenuationObject, velocity);
		}
		else if ((bool)rigidBody)
		{
			RuntimeManager.SetListenerLocation(ListenerNumber, base.gameObject, rigidBody, attenuationObject);
		}
		else if ((bool)rigidBody2D)
		{
			RuntimeManager.SetListenerLocation(ListenerNumber, base.gameObject, rigidBody2D, attenuationObject);
		}
		else
		{
			RuntimeManager.SetListenerLocation(ListenerNumber, base.gameObject, attenuationObject);
		}
	}
}
