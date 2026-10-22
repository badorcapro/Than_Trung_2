using GRGLib.Coroutines;
using GRGLib.Extensions.Vector;
using GRGLib.Menus;
using GRGLib.PropertyDrawers;
using TMPro;
using UnityEngine;

namespace Visual;

public class CaseQuirkExplanation : HoverMenu
{
	[Header("References")]
	[SerializeField]
	private TMP_Text explanation_text;

	[Header("Settings")]
	[SerializeField]
	private bool set_pos;

	[SerializeField]
	[ConditionalField("set_pos", false, new object[] { false })]
	private Vector2 hover_offset = new Vector2(0f, 625f);

	[SerializeField]
	[ConditionalField("set_pos")]
	private Vector2 hover_position = new Vector2(0f, 625f);

	[SerializeField]
	[ConditionalField("set_pos")]
	private Vector2 close_position = new Vector2(0f, 625f);

	[SerializeField]
	[ConditionalField("set_pos")]
	private Vector2 rotation_off_on = new Vector2(0f, 5f);

	private CoroutineRunner movement_runner;

	private CoroutineRunner rotation_runner;

	private CoroutineRunner scale_runner;

	public RectTransform rect_trans => base.transform as RectTransform;

	protected override void Awake()
	{
		base.Awake();
		movement_runner = new CoroutineRunner(this);
		rotation_runner = new CoroutineRunner(this);
		scale_runner = new CoroutineRunner(this);
	}

	public void explainText(MonoBehaviour _mono, string _explanation)
	{
		explanation_text.text = _explanation;
		explanation_text.ForceMeshUpdate();
		scale_runner.run(rect_trans.expandSizeDelta(new Vector2(rect_trans.sizeDelta.x, explanation_text.renderedHeight + (explanation_text.transform as RectTransform).offsetMin.y - (explanation_text.transform as RectTransform).offsetMax.y), 0.35f, CoroutineExtensions.easeInOutFunc));
		if (set_pos)
		{
			movement_runner.run(rect_trans.anchoredMove(hover_position, 0.5f, CoroutineExtensions.easeOutBackFunc));
			rotation_runner.run(rect_trans.rotateTransformSmart(rotation_off_on.y, 0.5f, CoroutineExtensions.easeOutBackFunc));
		}
		else
		{
			movement_runner.run(rect_trans.anchoredMove(_mono.transform.localPosition.addVector2(hover_offset), 0.35f, CoroutineExtensions.easeInOutFunc));
		}
		tryOpen(_mono);
	}

	protected override void onMenuClosing()
	{
		if (set_pos)
		{
			movement_runner.run(rect_trans.anchoredMove(close_position, 0.5f, CoroutineExtensions.easeInBackFunc));
			rotation_runner.run(rect_trans.rotateTransformSmart(rotation_off_on.x, 0.5f, CoroutineExtensions.easeInBackFunc));
		}
	}
}
