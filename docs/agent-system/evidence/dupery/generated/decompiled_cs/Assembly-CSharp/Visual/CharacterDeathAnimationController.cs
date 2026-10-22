using System;
using System.Collections;
using System.Collections.Generic;
using GRGLib.Coroutines;
using GRGLib.Extensions.Random;
using GRGLib.Extensions.Vector;
using UnityEngine;
using UnityEngine.UI;

namespace Visual;

public class CharacterDeathAnimationController : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private Image bullet_hole;

	[SerializeField]
	private Image blood_splatter_main;

	[SerializeField]
	private Image blood_splatter_drip;

	[Header("Settings")]
	[SerializeField]
	private List<Sprite> bullet_hole_sprites;

	[SerializeField]
	private List<Sprite> blood_splatter_sprites;

	[SerializeField]
	private List<Sprite> blood_drips_sprites;

	[SerializeField]
	private float blood_splatter_max_diff = 10f;

	[SerializeField]
	private float blood_mat_speed = 0.5f;

	public void kill(RectTransform _ref)
	{
		System.Random rnd = RandomExtensions.freshRandom();
		Vector2 vector = -_ref.sizeDelta / 2f;
		Vector2 vector2 = _ref.sizeDelta / 2f;
		Vector2 vector3 = _ref.transform.localPosition.addVector2(new Vector2(rnd.nextFloat(vector.x, vector2.x), rnd.nextFloat(vector.y, vector2.y)));
		bullet_hole.sprite = bullet_hole_sprites.getRandomElementFromList(rnd);
		bullet_hole.SetNativeSize();
		bullet_hole.transform.localPosition = vector3;
		bullet_hole.enabled = true;
		float num = rnd.nextFloat(-90f, 90f);
		blood_splatter_main.transform.localPosition = vector3 + new Vector2(rnd.nextFloat(0f - blood_splatter_max_diff, blood_splatter_max_diff), rnd.nextFloat(0f - blood_splatter_max_diff, blood_splatter_max_diff));
		blood_splatter_main.sprite = blood_splatter_sprites.getRandomElementFromList(rnd);
		blood_splatter_main.SetNativeSize();
		blood_splatter_main.transform.localEulerAngles = new Vector3(0f, 0f, num);
		blood_splatter_main.transform.localScale = new Vector3(0f, 0f, 0f);
		blood_splatter_main.transform.scaleTransform(1f, 0.25f, CoroutineExtensions.easeOutFunc).start(this);
		blood_splatter_drip.sprite = blood_drips_sprites.getRandomElementFromList(rnd);
		blood_splatter_drip.SetNativeSize();
		blood_splatter_drip.transform.localEulerAngles = new Vector3(0f, 0f, 0f - num);
		blood_splatter_drip.transform.localScale = new Vector3(1f, 0f, 1f);
		blood_splatter_drip.transform.scaleTransform(1f, 3.5f, CoroutineExtensions.easeOutFunc).start(this);
		blood_splatter_main.transform.SetParent(_ref);
		bullet_hole.transform.SetParent(_ref);
	}

	private IEnumerator bloodMaterialTimeAscent(Material _mat)
	{
		float wanted_max_value = _mat.GetFloat("_MaxSplatter");
		wanted_max_value *= wanted_max_value;
		float e = 0f;
		while (e < wanted_max_value)
		{
			e += Time.deltaTime * blood_mat_speed;
			_mat.SetFloat("_AnimationTime", e);
			yield return null;
		}
	}

	public void destroySelf()
	{
		StopAllCoroutines();
		UnityEngine.Object.Destroy(bullet_hole.gameObject);
		UnityEngine.Object.Destroy(blood_splatter_main.gameObject);
		UnityEngine.Object.Destroy(base.gameObject);
	}
}
