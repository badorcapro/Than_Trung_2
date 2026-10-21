using System.Collections.Generic;
using GRGLib.Extensions.Random;
using UnityEngine;
using UnityEngine.UI;

public class RandomImageSelector : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private Image image;

	[Header("Settings")]
	[SerializeField]
	private List<Sprite> sprites;

	public void Awake()
	{
		image.sprite = sprites.getRandomElementFromList(RandomExtensions.freshRandom());
	}
}
