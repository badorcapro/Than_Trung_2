using System;
using System.Collections;
using Audio;
using GRGLib.Coroutines;
using UnityEngine;

namespace MainMenu;

public class BackgroundClockTower : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private RectTransform hour_hand;

	[SerializeField]
	private RectTransform minute_hand;

	private bool ringing;

	private void Start()
	{
		setTime();
		checkTime().start(this);
	}

	private IEnumerator checkTime()
	{
		while (true)
		{
			yield return 1f.wait();
			setTime();
		}
	}

	private void setTime()
	{
		DateTime now = DateTime.Now;
		int num = (now.Hour * 60 + now.Minute) % 720;
		hour_hand.localEulerAngles = new Vector3(0f, 0f, (90 - num / 2) % 360);
		minute_hand.localEulerAngles = new Vector3(0f, 0f, -(num % 60) * 6);
	}

	public void playClockTowerBell()
	{
		if (!ringing)
		{
			ringing = true;
			AudioHandler.Sfx.playSfx(Sfx.MAIN_MENU_CLOCKTOWER);
			0.25f.wait(delegate
			{
				ringing = false;
			}).start(this);
		}
	}
}
