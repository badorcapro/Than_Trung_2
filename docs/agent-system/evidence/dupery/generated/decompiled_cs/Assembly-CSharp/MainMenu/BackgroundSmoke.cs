using System.Collections;
using GRGLib.Coroutines;
using UnityEngine;

namespace MainMenu;

public class BackgroundSmoke : MonoBehaviour
{
	[Header("Settings")]
	[SerializeField]
	private float target_start;

	[SerializeField]
	private float target_offset = 3940f;

	[SerializeField]
	private float speed = 10f;

	[SerializeField]
	private bool direction = true;

	private float target_x;

	private RectTransform rect_transform => base.transform as RectTransform;

	private void Start()
	{
		target_x = target_start + (direction ? target_offset : (0f - target_offset));
		slide2().start(this);
	}

	private IEnumerator slide()
	{
		yield return base.transform.moveTransform(new Vector3(target_start, base.transform.localPosition.y, base.transform.localPosition.z), 2f, CoroutineExtensions.easeOutFunc);
		float current_speed = 0f;
		while (true)
		{
			if (current_speed < speed)
			{
				current_speed += Time.deltaTime * 0.5f;
				if (current_speed > speed)
				{
					current_speed = speed;
				}
			}
			base.transform.localPosition += new Vector3(current_speed * Time.deltaTime * (float)(direction ? 1 : (-1)), 0f, 0f);
			if ((direction && base.transform.localPosition.x >= target_x) || (!direction && base.transform.localPosition.x <= target_x))
			{
				base.transform.localPosition = new Vector3(target_start, base.transform.localPosition.y, base.transform.localPosition.z);
			}
			yield return null;
		}
	}

	private IEnumerator slide2()
	{
		float current_speed = speed * 3f;
		float deceleration_rate = 1.5f;
		while (current_speed > speed)
		{
			current_speed -= Time.deltaTime * speed * deceleration_rate;
			base.transform.localPosition += new Vector3(current_speed * Time.deltaTime * (float)(direction ? 1 : (-1)), 0f, 0f);
			if (deceleration_rate > 0.1f)
			{
				deceleration_rate -= Time.deltaTime * 1.25f;
			}
			yield return null;
		}
		while (true)
		{
			base.transform.localPosition += new Vector3(current_speed * Time.deltaTime * (float)(direction ? 1 : (-1)), 0f, 0f);
			if ((direction && base.transform.localPosition.x >= target_x) || (!direction && base.transform.localPosition.x <= target_x))
			{
				base.transform.localPosition = new Vector3(target_start, base.transform.localPosition.y, base.transform.localPosition.z);
			}
			yield return null;
		}
	}
}
