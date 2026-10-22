using System;
using System.Collections;
using GRGLib.Coroutines;
using GRGLib.Extensions.Random;
using UnityEngine;

public class CreditIconSpinner : MonoBehaviour
{
	private System.Random rand;

	private void Start()
	{
		rand = RandomExtensions.freshRandom();
		StartCoroutine(creditIconSpinAnim());
	}

	private IEnumerator creditIconSpinAnim()
	{
		yield return rand.nextFloat(0f, 8f).wait();
		float starting_rot = base.transform.eulerAngles.z;
		float num;
		if (!(starting_rot > 180f))
		{
			num = starting_rot;
		}
		else
		{
			float num2 = starting_rot - 360f;
			num = num2;
		}
		starting_rot = num;
		float diff = ((rand.Next(0, 2) == 1) ? 15 : (-15));
		while (true)
		{
			yield return base.transform.rotateTransformSmart(starting_rot + diff, 7f, CoroutineExtensions.easeInOutFunc);
			yield return base.transform.rotateTransformSmart(starting_rot - diff, 7f, CoroutineExtensions.easeInOutFunc);
		}
	}
}
