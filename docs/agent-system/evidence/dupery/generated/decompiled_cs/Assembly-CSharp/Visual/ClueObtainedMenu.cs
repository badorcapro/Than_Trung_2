using GRGLib.Coroutines;
using Lineup;
using TMPro;
using UnityEngine;

namespace Visual;

public class ClueObtainedMenu : MenuBase
{
	[Header("References")]
	[SerializeField]
	private RectTransform clue_trans;

	[SerializeField]
	private TMP_Text clue_text;

	private MultiCoroutineRunner advanced_menuing_runner;

	protected override void Awake()
	{
		base.Awake();
		advanced_menuing_runner = new MultiCoroutineRunner(this);
	}

	public void setUp(LineupClue _clue)
	{
		clue_text.text = _clue.clue_text;
	}

	protected override void onMenuOpening()
	{
		base.onMenuOpening();
		advanced_menuing_runner.run(clue_trans.moveTransform(new Vector3(0f, 100f, 0f), 0.75f, CoroutineExtensions.easeOutBackFunc), clue_trans.rotateTransformSmart(0f, 0.75f, CoroutineExtensions.easeInOutFunc));
	}

	protected override void onMenuClosing()
	{
		base.onMenuClosing();
		advanced_menuing_runner.run(clue_trans.moveTransform(new Vector3(-500f, 1500f, 0f), 0.75f, CoroutineExtensions.easeInBackFunc), clue_trans.rotateTransformSmart(10f, 0.75f, CoroutineExtensions.easeInOutFunc));
	}
}
