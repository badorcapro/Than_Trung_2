using System;
using System.Collections;
using GRGLib.Coroutines;
using GRGLib.Extensions.Numbers;
using GRGLib.Extensions.Random;
using GRGLib.Serializable;
using GRGLocalisation;
using Localisation;
using TMPro;
using UnityEngine;

namespace Visual;

public class TimeVisualManager : MonoBehaviour, IAmLocalised
{
	[Header("References")]
	[SerializeField]
	private TMP_Text title_text;

	[SerializeField]
	private TMP_Text time_passed;

	private int current_hours_spent;

	private CoroutineRunner time_string_runner;

	private System.Random random;

	[SerializeField]
	private RectTransform hour_hand;

	[SerializeField]
	private RectTransform min_hand;

	[SerializeField]
	private SerializableDictionary<int, float> hour_pos = new SerializableDictionary<int, float>();

	private CoroutineRunner hour_runner;

	private CoroutineRunner min_runner;

	private string offsetString => "\n    ";

	private string loc_time_passed_key => "Time [pass]";

	private AssetKey localisation_asset => LocalisationHelper.ui_asset;

	private void Awake()
	{
		hour_runner = new CoroutineRunner(this);
		min_runner = new CoroutineRunner(this);
		random = RandomExtensions.freshRandom();
		time_string_runner = new CoroutineRunner(this);
	}

	private void Start()
	{
		string text = localisation_asset.checkTranslation(loc_time_passed_key, getTimePassEnglish, _check_keywords: false);
		title_text.text = text.Replace(LocalisationHelper.text_marker_1, "").Replace("{h}", offsetString);
	}

	public void progressTime(int _total_hours_spent)
	{
		progressMinuteNeedle(_total_hours_spent - current_hours_spent);
		progressHourNeedle(IntegerExtension.modNoNegative(_total_hours_spent, 12));
		time_string_runner.run(time_passed.countDown("", "", current_hours_spent, _total_hours_spent, 0.4f, CoroutineExtensions.easeInOutFunc));
		current_hours_spent = _total_hours_spent;
	}

	private void progressMinuteNeedle(int _hours_passed)
	{
		float num = random.nextFloat(-360f, 0f);
		if (min_hand.transform.localEulerAngles.z < 0f)
		{
			num -= 360f;
		}
		min_runner.run(min_hand.transform.rotateTransformDirection(num, 1f, _clockwise: true, CoroutineExtensions.easeInOutFunc).addCallback(delegate
		{
			min_runner.run(rotateContinuous(min_hand, -0.1f));
		}));
	}

	private void progressHourNeedle(int _hours_12)
	{
		float num = hour_pos[_hours_12];
		if (num - hour_hand.transform.localEulerAngles.z < -360f)
		{
			num += 360f;
		}
		hour_runner.run(hour_hand.transform.rotateTransformDirection(num, 1f, _clockwise: true, CoroutineExtensions.easeInOutFunc));
	}

	private IEnumerator rotateContinuous(Transform _trans, float _speed)
	{
		while (true)
		{
			_trans.localEulerAngles += new Vector3(0f, 0f, _speed * Time.deltaTime);
			yield return null;
		}
	}

	private string getTimePassEnglish()
	{
		return "Hours{h}Passed";
	}
}
