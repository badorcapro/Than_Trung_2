using System.Collections;
using GRGLib.Coroutines;
using GRGLocalisation;
using Localisation;
using TMPro;
using UnityEngine;
using UnityEngine.InputSystem;

namespace Tutorial;

public class TutorialTooltip : MonoBehaviour, IAmLocalised
{
	[Header("References")]
	[SerializeField]
	private CanvasGroup group;

	[SerializeField]
	private TMP_Text text;

	[Header("Settings")]
	[SerializeField]
	private InputAssetPerType input;

	[SerializeField]
	private string tutorial;

	[SerializeField]
	private string localisation_key;

	private CoroutineRunner menuing_runner;

	private PlayerInput player_input;

	private string loc_tuto_key => localisation_key + " [tuto]";

	private AssetKey localisation_asset => LocalisationHelper.ui_asset;

	public void setUpAndStart(PlayerInput _input)
	{
		player_input = _input;
		menuing_runner = new CoroutineRunner(this);
		setToolTipText();
		menuing_runner.run(group.fade(1f, 0.25f, CoroutineExtensions.easeInOutFunc));
		checkInput().start(this);
	}

	private void setToolTipText()
	{
		text.text = checkTransalte().Replace("{1}", input.getText(player_input, _capital_first: true));
	}

	public void fadeOutWithoutDestroy()
	{
		menuing_runner.run(group.fade(0f, 0.25f, CoroutineExtensions.easeInOutFunc));
	}

	public void fadeIn()
	{
		menuing_runner.run(group.fade(1f, 0.25f, CoroutineExtensions.easeInOutFunc));
	}

	public void fadeAndDestroy()
	{
		menuing_runner.run(group.fade(0f, 0.25f, CoroutineExtensions.easeInOutFunc).addCallback(delegate
		{
			Object.Destroy(base.gameObject);
		}));
	}

	private IEnumerator checkInput()
	{
		InputType last_input = player_input.getInputType();
		while (true)
		{
			InputType inputType = player_input.getInputType();
			if (last_input != inputType)
			{
				last_input = inputType;
				setToolTipText();
			}
			yield return null;
		}
	}

	private string checkTransalte()
	{
		if (GRGLocalisationHandler.needs_translation && GRGLocalisationHandler.instance.translate(localisation_asset, loc_tuto_key, out var _result))
		{
			return _result;
		}
		return tutorial;
	}
}
