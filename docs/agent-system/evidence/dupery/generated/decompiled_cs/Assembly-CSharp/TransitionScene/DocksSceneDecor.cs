using GRGLib.Coroutines;
using UnityEngine;

namespace TransitionScene;

public class DocksSceneDecor : TransitionSceneDecor
{
	[Header("References")]
	[SerializeField]
	private RectTransform background_trans;

	public override void setUp()
	{
		background_trans.scaleTransform(1f, 10f, (float _f) => _f).start(this);
	}
}
