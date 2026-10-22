using System;
using System.Collections;
using UnityEngine;

namespace GRGLib.Resolution;

[AddComponentMenu("GRGLib/Misc/CameraResolution")]
public class CameraResolution : MonoBehaviour
{
	[Header("Reference")]
	[SerializeField]
	private Camera main_camera;

	[Header("Settings")]
	[SerializeField]
	private Vector2 template_resolution = new Vector2(16f, 9f);

	[SerializeField]
	private float leway = 0.005f;

	[SerializeField]
	private bool force_ratio_on_wider = true;

	[SerializeField]
	private bool force_ratio_on_taller = true;

	public static float resolution_ratio => (float)Screen.width / (float)Screen.height;

	public float comparative_resolution_ratio => resolution_ratio / (template_resolution.x / template_resolution.y);

	private void Awake()
	{
		setRes();
	}

	public void forceUpdate(Vector2Int _res)
	{
		StartCoroutine(waitForScreenSize(_res, delegate
		{
			setRes(_force_normal: true);
		}));
	}

	private void setRes(bool _force_normal = false)
	{
		if (force_ratio_on_wider && comparative_resolution_ratio > 1f + leway)
		{
			float num = 1f / comparative_resolution_ratio;
			float x = (1f - num) / 2f;
			main_camera.rect = new Rect(x, 0f, num, 1f);
		}
		if (force_ratio_on_taller && comparative_resolution_ratio < 1f - leway)
		{
			float num2 = comparative_resolution_ratio;
			float y = (1f - num2) / 2f;
			main_camera.rect = new Rect(0f, y, 1f, num2);
		}
		if (_force_normal && comparative_resolution_ratio > 1f - leway && comparative_resolution_ratio < 1f + leway)
		{
			main_camera.rect = new Rect(0f, 0f, 1f, 1f);
		}
	}

	private IEnumerator waitForScreenSize(Vector2Int _res, Action _callback)
	{
		while (_res.x != Screen.width || _res.y != Screen.height)
		{
			yield return null;
		}
		_callback();
	}
}
