using System;
using Audio;
using GRGLib.Coroutines;
using UnityEngine;
using UnityEngine.UI;

namespace Visual;

public class NavalMineVisual : LocationVisual
{
	[Header("References")]
	[SerializeField]
	private Image explosion_image;

	private MultiCoroutineRunner explode_runner;

	private bool exploded;

	public override void setUpLocation(LocationData _data, Action<LocationData> _use_ability)
	{
		base.setUpLocation(_data, _use_ability);
		explode_runner = new MultiCoroutineRunner(this);
	}

	public override void renew(LocationData _data, CaseSnapshot _snap, Action<LocationData, Vector3> _replace_location)
	{
		base.renew(_data, _snap, _replace_location);
		if (!(_data is NavalMine navalMine))
		{
			Debug.LogError("Data of visual naval mine is not of NavalMine type!");
		}
		else if (!exploded && navalMine.has_exploded)
		{
			exploded = true;
			AudioHandler.Sfx.playSfx(Sfx.NAVAL_MINE_EXPLOSION);
			explode_runner.run(explosion_image.fade(1f, 0.125f, CoroutineExtensions.easeOutFunc), explosion_image.transform.scaleTransform(1f, 0.5f, CoroutineExtensions.easeOutBackFunc), explosion_image.transform.shake(5f, 0.25f));
		}
	}
}
