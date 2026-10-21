using System;
using GRGLib.Coroutines;
using GRGLocalisation;
using Localisation;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace Visual;

public class CardShufflerVisual : LocationVisual, IAmLocalised
{
	[Header("References")]
	[SerializeField]
	private TMP_Text shuffle_text;

	[SerializeField]
	private CanvasGroup shuffler_closed_group;

	[SerializeField]
	private Image shuffler_gates;

	private int last_cost = -1;

	private bool is_shuffler_open = true;

	private CoroutineRunner shuffler_close_runner;

	private CoroutineRunner shuffler_gates_runner;

	private CoroutineRunner shuffler_text_runner;

	private AssetKey localisation_asset => LocalisationHelper.ui_asset;

	private string loc_shuffle_key => "CardShuffler [shuffle]";

	public override void setUpLocation(LocationData _data, Action<LocationData> _use_ability)
	{
		base.setUpLocation(_data, _use_ability);
		shuffler_close_runner = new CoroutineRunner(this);
		shuffler_gates_runner = new CoroutineRunner(this);
		shuffler_text_runner = new CoroutineRunner(this);
	}

	public override void renew(LocationData _data, CaseSnapshot _snap, Action<LocationData, Vector3> _replace_location)
	{
		base.renew(_data, _snap, _replace_location);
		if (!(_data is CardShuffler cardShuffler))
		{
			Debug.LogError($"Data is not of correct type! Expecting CardShuffler, recieved {_data.location_type}!");
		}
		else if (cardShuffler.is_closed)
		{
			if (is_shuffler_open)
			{
				is_shuffler_open = false;
				shuffler_gates_runner.run(shuffler_gates.fill(1f, 0.4f));
				shuffler_close_runner.run(0.25f.wait(delegate
				{
					shuffler_close_runner.run(shuffler_closed_group.fade(1f, 0.2f));
				}));
			}
		}
		else if (cardShuffler.cost != last_cost)
		{
			string[] array = getShuffleText().Replace("{1}", "#").Split('#');
			shuffler_text_runner.run(shuffle_text.countDown(array[0], array[1], last_cost, cardShuffler.cost, 0.4f));
			last_cost = cardShuffler.cost;
		}
	}

	private string getShuffleText()
	{
		if (GRGLocalisationHandler.needs_translation)
		{
			string _result = "";
			if (GRGLocalisationHandler.instance.translate(localisation_asset, loc_shuffle_key, out _result))
			{
				return _result;
			}
		}
		return shuffleEnglish();
	}

	private string shuffleEnglish()
	{
		return "Redraw a random card for the low price of {1} chips!";
	}
}
