using System;
using GRGLib.Coroutines;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class PieSlice : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private Image image;

	[Header("Hover References")]
	[SerializeField]
	private CanvasGroup hover_group;

	[SerializeField]
	private TMP_Text hover_text;

	private MultiCoroutineRunner pie_runner;

	private MultiCoroutineRunner scale_runner;

	private float mid_angle;

	public RectTransform rect_transform => base.transform as RectTransform;

	public string section { get; private set; } = "";

	public bool open { get; private set; } = true;

	public float rotation_end { get; private set; }

	private Vector2 mid_angled_position => new Vector2(Mathf.Sin(mid_angle), Mathf.Cos(mid_angle));

	private void Awake()
	{
		pie_runner = new MultiCoroutineRunner(this);
		scale_runner = new MultiCoroutineRunner(this);
	}

	public void setUp(float _rotation, float _size, Color _colour, string _section, string _data)
	{
		open = true;
		section = _section;
		hover_text.text = _section + ": " + _data;
		rotation_end = ((_rotation == 0f) ? (_size * 360f) : (360f - _rotation + _size * 360f));
		mid_angle = MathF.PI / 180f * (_size * 180f - _rotation);
		pie_runner.run(image.fill(_size, 0.35f, CoroutineExtensions.easeInOutFunc), image.fadeToColour(_colour, 0.35f, CoroutineExtensions.easeInOutFunc), rect_transform.rotateTransformSmart(_rotation, 0.35f, CoroutineExtensions.easeInOutFunc));
		hover_group.transform.SetParent(base.transform.parent);
		hover_group.transform.localEulerAngles = Vector3.zero;
		hover_group.transform.localPosition = new Vector3(Mathf.Sin(mid_angle) * 250f, Mathf.Cos(mid_angle) * 250f, 0f);
	}

	public void close()
	{
		open = false;
		section = "";
		pie_runner.run(image.fill(0f, 0.35f, CoroutineExtensions.easeInOutFunc), rect_transform.rotateTransformSmart(0f, 0.35f, CoroutineExtensions.easeInOutFunc));
		rotation_end = 0f;
	}

	public void onHover()
	{
		if (open)
		{
			hover_group.transform.SetAsLastSibling();
			scale_runner.run(hover_group.fade(1f, 0.35f, CoroutineExtensions.easeInOutFunc), rect_transform.scaleTransform(1.05f, 0.35f, CoroutineExtensions.easeInOutFunc), rect_transform.moveTransform(mid_angled_position * 10f, 0.35f, CoroutineExtensions.easeInOutFunc));
		}
	}

	public void onUnhover()
	{
		if (open)
		{
			scale_runner.run(hover_group.fade(0f, 0.25f, CoroutineExtensions.easeInOutFunc), rect_transform.scaleTransform(1f, 0.25f, CoroutineExtensions.easeInOutFunc), rect_transform.moveTransform(Vector2.zero, 0.25f, CoroutineExtensions.easeInOutFunc));
		}
	}
}
