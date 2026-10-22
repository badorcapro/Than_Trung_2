using System;
using System.Collections;
using System.Collections.Generic;
using GRGLib.Coroutines;
using GRGLib.Extensions.Collections;
using UnityEngine;
using UnityEngine.UI;

namespace Visual;

public class KnockVisual : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private CanvasGroup group;

	[SerializeField]
	private Image circle;

	[SerializeField]
	private List<Image> knock_particles;

	[Header("Settings")]
	[SerializeField]
	private float knock_duration = 0.45f;

	[SerializeField]
	private List<Vector2> starting_positions;

	[SerializeField]
	private List<Vector2> end_positions;

	[SerializeField]
	private float starting_scale = 0.8f;

	[SerializeField]
	private float ending_scale = 0.9f;

	private MultiCoroutineRunner knock_runner;

	private MultiCoroutineRunner end_runner;

	private float last_e;

	public bool is_running => knock_runner.is_running;

	private void Awake()
	{
		knock_runner = new MultiCoroutineRunner(this);
		end_runner = new MultiCoroutineRunner(this);
	}

	public void animateKnock(Action _callback)
	{
		end_runner.stop();
		circle.fillAmount = 0f;
		List<IEnumerator> list = circle.fill(1f, 0.45f, CoroutineExtensions.easeInOutFunc).addCallback(_callback).addCallback(delegate
		{
			end_runner.run(group.fade(0f, 0.35f, CoroutineExtensions.easeInOutFunc));
		})
			.makeListFromItem();
		list.Add(knockImpacts(knock_duration / 3f));
		group.alpha = 1f;
		knock_runner.run(list.ToArray());
	}

	private IEnumerator rotationAnimated(float _duration, bool _reversed = false)
	{
		float e = (_reversed ? last_e : 0f);
		float step = 1f / (float)knock_particles.Count;
		while (_reversed ? (e > 0f) : (e < _duration))
		{
			e = (last_e = e + Time.deltaTime * (float)((!_reversed) ? 1 : (-1)));
			float num = CoroutineExtensions.easeInOutFunc(e / _duration);
			for (int i = 0; i < knock_particles.Count; i++)
			{
				float value = (num - (float)i * step) / step;
				knock_particles[i].fillAmount = Mathf.Clamp(value, 0f, 1f);
			}
			yield return null;
		}
		knock_particles.ForEach(delegate(Image _p)
		{
			_p.fillAmount = ((!_reversed) ? 1 : 0);
		});
	}

	private IEnumerator knockImpacts(float _duration)
	{
		for (int i = 0; i < knock_particles.Count; i++)
		{
			knock_particles[i].transform.localPosition = starting_positions[i];
			knock_particles[i].transform.localScale = new Vector3(starting_scale, starting_scale, 1f);
			knock_particles[i].color = new Color(1f, 1f, 1f, 0f);
		}
		knock_particles[0].fade(1f, 0.1f, CoroutineExtensions.easeInOutFunc).start(this);
		knock_particles[0].transform.moveTransform(end_positions[0], 0.45f, CoroutineExtensions.easeOutFunc).start(this);
		knock_particles[0].transform.scaleTransform(ending_scale, 0.45f, CoroutineExtensions.easeOutFunc).start(this);
		yield return _duration.wait();
		knock_particles[2].fade(1f, 0.1f, CoroutineExtensions.easeInOutFunc).start(this);
		knock_particles[2].transform.moveTransform(end_positions[2], 0.4f, CoroutineExtensions.easeOutFunc).start(this);
		knock_particles[2].transform.scaleTransform(ending_scale, 0.45f, CoroutineExtensions.easeOutFunc).start(this);
		yield return _duration.wait();
		knock_particles[1].fade(1f, 0.1f, CoroutineExtensions.easeInOutFunc).start(this);
		knock_particles[1].transform.moveTransform(end_positions[1], 0.35f, CoroutineExtensions.easeOutFunc).start(this);
		knock_particles[1].transform.scaleTransform(ending_scale, 0.45f, CoroutineExtensions.easeOutFunc).start(this);
		knock_particles[3].fade(1f, 0.1f, CoroutineExtensions.easeInOutFunc).start(this);
		knock_particles[3].transform.moveTransform(end_positions[3], 0.35f, CoroutineExtensions.easeOutFunc).start(this);
		knock_particles[3].transform.scaleTransform(ending_scale, 0.45f, CoroutineExtensions.easeOutFunc).start(this);
	}

	public void endEarly()
	{
		if (!end_runner.is_running)
		{
			knock_runner.stop();
			StopAllCoroutines();
			List<IEnumerator> list = rotationAnimated(0.3f, _reversed: true).makeListFromItem();
			for (int i = 0; i < knock_particles.Count; i++)
			{
				list.Add(knock_particles[i].transform.moveTransform(starting_positions[i], 0.35f, CoroutineExtensions.easeInOutFunc));
			}
			list.Add(circle.fill(0f, 0.25f, CoroutineExtensions.easeInOutFunc));
			list.Add(group.fade(0f, 0.35f, CoroutineExtensions.easeInOutFunc));
			end_runner.run(list.ToArray());
		}
	}
}
