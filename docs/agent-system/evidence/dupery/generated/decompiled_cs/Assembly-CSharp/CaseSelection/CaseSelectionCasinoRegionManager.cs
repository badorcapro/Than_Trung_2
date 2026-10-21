using System;
using ControllerSupport;
using GRGLib.Coroutines;
using GRGLocalisation;
using Localisation;
using TMPro;
using UnityEngine;

namespace CaseSelection;

public class CaseSelectionCasinoRegionManager : CaseSelectionRegionSpecificManager, IAmLocalised
{
	[Header("References")]
	[SerializeField]
	private CaseSelectionHandler handler;

	[SerializeField]
	private CaseSelectionRegionControllerSupport selection_controller_support;

	[SerializeField]
	private CasinoSlotMachine slot_machine;

	[SerializeField]
	private TMP_Text chips;

	[SerializeField]
	private TMP_Text multi;

	private int previous_chips;

	private CoroutineRunner chips_text_runner;

	private AssetKey localisation_asset => LocalisationHelper.misc_asset;

	private string loc_chips_key => "CsSelectionManager [chips]";

	private string loc_multi_key => "CsSelectionManager [multi]";

	private void Awake()
	{
		chips_text_runner = new CoroutineRunner(this);
	}

	public override void setUp(_dep_RegionState _region, CaseSelectionInputHandler _input_handler)
	{
		selection_controller_support.setUp(_input_handler);
		if (!(_region is _dep_CasinoRegionState dep_CasinoRegionState))
		{
			Debug.LogError("Needs a casino region state in the casino region!!!");
			return;
		}
		handler.setUp(_input_handler.getPlayerInput(), delegate
		{
		});
		chips.text = localisation_asset.checkTranslationWithData(loc_chips_key, englishChips, dep_CasinoRegionState.chips);
		previous_chips = dep_CasinoRegionState.chips;
		multi.text = localisation_asset.checkTranslationWithData(loc_multi_key, englishMulti, 1.ToString("0.0"));
		slot_machine.setUp(dep_CasinoRegionState, updateChips, _available: true);
	}

	private void updateChips(int _chips_diff)
	{
		throw new NotImplementedException("AAAA");
	}

	private void setChipsText(int _chips)
	{
		chips_text_runner.run(chips.countdownReplace(localisation_asset.checkTranslation(loc_chips_key, () => englishChips(LocalisationHelper.text_marker_1)), LocalisationHelper.text_marker_1, previous_chips, _chips, 1f, CoroutineExtensions.easeInOutFunc));
		previous_chips = _chips;
	}

	private string englishChips(string _data)
	{
		return "Chips: " + _data + "/1000";
	}

	private string englishMulti(string _data)
	{
		return "Cost Multi: x" + _data;
	}
}
