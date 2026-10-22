using System;
using System.Collections.Generic;
using GRGLib.Coroutines;
using GRGLib.Extensions.Random;
using UnityEngine;

public class ChipStackController : MonoBehaviour
{
	[SerializeField]
	private GameObject chip;

	[SerializeField]
	private RectTransform stack_rt;

	[SerializeField]
	private int min;

	private Vector2 last_chip_loc = new Vector2(0f, 8.3f);

	private Stack<GameObject> chip_stack = new Stack<GameObject>();

	private System.Random rnd;

	private void Awake()
	{
		rnd = RandomExtensions.freshRandom();
	}

	public void updateStack(int _chip_quant, bool _should_hide)
	{
		if (min >= _chip_quant || _should_hide)
		{
			stack_rt.gameObject.SetActive(value: false);
			return;
		}
		int req_chips = Mathf.Min(_chip_quant - min, 100) / 20;
		balanceStack(req_chips);
		stack_rt.gameObject.SetActive(value: true);
	}

	private void balanceStack(int _req_chips)
	{
		int count = chip_stack.Count;
		if (count == _req_chips)
		{
			return;
		}
		while (count != _req_chips)
		{
			if (count < _req_chips)
			{
				stackChip();
			}
			else
			{
				removeChip();
			}
			count = chip_stack.Count;
		}
		base.transform.shake(0.25f, 5f).start(this);
	}

	private void stackChip()
	{
		GameObject gameObject = UnityEngine.Object.Instantiate(chip);
		gameObject.transform.SetParent(stack_rt, worldPositionStays: false);
		gameObject.GetComponent<RectTransform>().anchoredPosition = new Vector2(last_chip_loc.x + rnd.nextFloat(-20f, 20f), last_chip_loc.y + 15f);
		last_chip_loc = gameObject.GetComponent<RectTransform>().anchoredPosition;
		chip_stack.Push(gameObject);
	}

	private void removeChip()
	{
		if (chip_stack.Count > 0)
		{
			UnityEngine.Object.Destroy(chip_stack.Pop());
		}
		if (chip_stack.Count > 0)
		{
			last_chip_loc = chip_stack.Peek().GetComponent<RectTransform>().anchoredPosition;
		}
		else
		{
			last_chip_loc = new Vector2(0f, 8.3f);
		}
	}
}
