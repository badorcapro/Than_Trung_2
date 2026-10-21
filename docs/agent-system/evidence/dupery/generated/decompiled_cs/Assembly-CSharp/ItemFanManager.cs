using System.Collections;
using System.Collections.Generic;
using GRGLib.Coroutines;
using GRGLib.Extensions.Unity;
using GRGLib.Extensions.Vector;
using GRGLib.Generic;
using UnityEngine;

public class ItemFanManager : MonoBehaviour
{
	[Header("Fan Settings")]
	[SerializeField]
	private float degree_per_item = 10f;

	[SerializeField]
	private MinMaxFloat fan_extremes = new MinMaxFloat(-90f, 90f);

	[SerializeField]
	private Vector2 rotate_around = new Vector2(0f, 0f);

	[SerializeField]
	private bool invert;

	[Header("Animation Settings")]
	[SerializeField]
	private float animation_duration = 0.5f;

	private List<Transform> children = new List<Transform>();

	private MultiCoroutineRunner item_fan_runner;

	private void Awake()
	{
		item_fan_runner = new MultiCoroutineRunner(this);
	}

	public void fanOutChildren(bool _animated = true, bool _fetch_children = true)
	{
		if (_fetch_children)
		{
			children = base.transform.childTransforms();
		}
		if (children.Count != 0)
		{
			if (_animated)
			{
				animateFanOut();
			}
			else
			{
				fanOutImmidiate();
			}
		}
	}

	private void animateFanOut()
	{
		float num = degree_per_item;
		if (fan_extremes.max - fan_extremes.min < num * (float)children.Count)
		{
			num = (fan_extremes.max - fan_extremes.min) / (float)children.Count;
		}
		float num2 = fan_extremes.average - num * ((float)(children.Count - 1) / 2f);
		List<IEnumerator> list = new List<IEnumerator>();
		for (int i = 0; i < children.Count; i++)
		{
			float num3 = num2 + num * (float)i;
			int index = (invert ? (children.Count - 1 - i) : i);
			list.Add(children[index].rotateTransformSmart(num3, animation_duration, CoroutineExtensions.easeInOutFunc));
			if (rotate_around != Vector2.zero)
			{
				Vector3 target = VectorExtensions.Rotate(-rotate_around, num3).addVector2(rotate_around);
				list.Add(children[index].moveTransform(target, animation_duration, CoroutineExtensions.easeInOutFunc));
			}
		}
		item_fan_runner.run(list.ToArray());
	}

	private void fanOutImmidiate()
	{
		float num = degree_per_item;
		if (fan_extremes.max - fan_extremes.min < num * (float)children.Count)
		{
			num = (fan_extremes.max - fan_extremes.min) / (float)children.Count;
		}
		float num2 = fan_extremes.average - num * ((float)(children.Count - 1) / 2f);
		for (int i = 0; i < children.Count; i++)
		{
			float num3 = num2 + num * (float)i;
			int index = (invert ? (children.Count - 1 - i) : i);
			children[index].transform.localEulerAngles = new Vector3(0f, 0f, num3);
			children[index].transform.localPosition = VectorExtensions.Rotate(-rotate_around, num3).addVector2(rotate_around);
		}
	}
}
