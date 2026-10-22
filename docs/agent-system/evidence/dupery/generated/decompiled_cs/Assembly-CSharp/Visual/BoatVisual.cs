using System;
using GRGLib.Coroutines;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace Visual;

public class BoatVisual : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private TMP_Text fuel_counter;

	[SerializeField]
	private Image mini_board_boat;

	[Header("Settings")]
	[SerializeField]
	private Vector2 tile_offset = new Vector2(50f, 0f);

	[SerializeField]
	private Vector2 board_boat_offset = new Vector2(200f, 100f);

	private Vector2Int last_pos;

	private int last_fuel;

	private CoroutineRunner movement_runner;

	private CoroutineRunner rotation_runner;

	private CoroutineRunner fuel_count_runner;

	private Func<Vector2Int, Vector2> get_true_pos;

	public void setUp(DocksBoat _boat, Func<Vector2Int, Vector2> _get_real_pos)
	{
		fuel_counter.text = _boat.fuel.ToString();
		last_fuel = _boat.fuel;
		last_pos = _boat.position;
		get_true_pos = _get_real_pos;
		base.transform.localPosition = get_true_pos(_boat.position) + tile_offset;
		mini_board_boat.transform.localPosition = get_true_pos(_boat.position) + board_boat_offset;
		mini_board_boat.fade(1f, 0.25f, CoroutineExtensions.easeInOutFunc).start(this);
		movement_runner = new CoroutineRunner(this);
		rotation_runner = new CoroutineRunner(this);
		fuel_count_runner = new CoroutineRunner(this);
	}

	public void renew(DocksBoat _boat)
	{
		fuel_count_runner.run(fuel_counter.countDown(last_fuel, _boat.fuel, 0.5f, CoroutineExtensions.easeInOutFunc));
		movement_runner.run(base.transform.moveTransform(get_true_pos(_boat.position) + tile_offset, 0.65f, CoroutineExtensions.easeInOutFunc));
		mini_board_boat.transform.localPosition = get_true_pos(_boat.position) + board_boat_offset;
		last_pos = _boat.position;
		last_fuel = _boat.fuel;
	}

	public int estimateFuelCost(Vector2Int _position)
	{
		return last_pos.cardinalDistance(_position);
	}
}
