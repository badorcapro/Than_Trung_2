using GRGLib.Coroutines;
using UnityEngine;
using UnityEngine.UI;

public class ColourWheelSegment : MonoBehaviour
{
	[SerializeField]
	private Image image;

	private CoroutineRunner scale_down_runner;

	private CoroutineRunner scale_up_runner;

	private bool set_up;

	public Color color
	{
		get
		{
			return image.color;
		}
		set
		{
			image.color = value;
		}
	}

	private void Awake()
	{
		scale_down_runner = new CoroutineRunner(this);
		scale_up_runner = new CoroutineRunner(this);
		set_up = true;
	}

	public void scaleUp()
	{
		scale_down_runner.stop();
		scale_up_runner.runIfNot(base.transform.scaleTransform(1.05f, 0.35f, CoroutineExtensions.easeOutBackFunc));
	}

	public void scaleDown()
	{
		scale_up_runner.stop();
		scale_down_runner.runIfNot(base.transform.scaleTransform(1f, 0.35f, CoroutineExtensions.easeInBackFunc));
	}

	public void forceReset()
	{
		if (set_up)
		{
			scale_down_runner.stop();
			scale_up_runner.stop();
			base.transform.localScale = new Vector3(1f, 1f, 1f);
		}
	}

	private void Reset()
	{
		image = GetComponent<Image>();
	}
}
