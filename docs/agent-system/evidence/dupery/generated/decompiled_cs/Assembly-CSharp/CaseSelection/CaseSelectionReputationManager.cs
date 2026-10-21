using System.Collections.Generic;
using GRGLib.Coroutines;
using UnityEngine;

namespace CaseSelection;

public class CaseSelectionReputationManager : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private RectTransform clip;

	[Header("Settings")]
	[SerializeField]
	private List<float> clip_positions;

	private CoroutineRunner rep_runner;

	public void setUp()
	{
		rep_runner = new CoroutineRunner(this);
	}

	public void setReputation(int _reputation)
	{
		int index = Mathf.Clamp(_reputation - 1, 0, 5);
		clip.anchoredPosition = new Vector3(clip_positions[index], clip.anchoredPosition.y, 0f);
	}

	public void changeReputation(int _reputation)
	{
		int index = Mathf.Clamp(_reputation - 1, 0, 5);
		rep_runner.run(clip.anchoredMove(new Vector3(clip_positions[index], clip.anchoredPosition.y, 0f), 0.45f, CoroutineExtensions.easeInOutFunc));
	}
}
