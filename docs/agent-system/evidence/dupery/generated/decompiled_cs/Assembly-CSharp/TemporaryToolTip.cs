using System.Collections;
using System.Collections.Generic;
using GRGLib.Coroutines;
using GRGLib.PropertyDrawers;
using GRGLocalisation;
using Localisation;
using TMPro;
using UnityEngine;
using UnityEngine.InputSystem;

public class TemporaryToolTip : MonoBehaviour, IAmLocalised
{
	[Header("References")]
	[SerializeField]
	private CanvasGroup group;

	[SerializeField]
	private TMP_Text text;

	[Header("Settings")]
	[SerializeField]
	private List<InputAssetPerType> input;

	[SerializeField]
	[TextArea(2, 2)]
	private string tooltip;

	[SerializeField]
	private bool force_kbm;

	[SerializeField]
	private string localisation_key;

	[SerializeField]
	private bool colour_sprite;

	[SerializeField]
	[ConditionalField("colour_sprite")]
	private Color colour = new Color(1f, 1f, 1f, 1f);

	private CoroutineRunner menuing_runner;

	private PlayerInput player_input;

	private string loc_tuto_key => localisation_key + " [tooltip]";

	private AssetKey localisation_asset => LocalisationHelper.ui_asset;

	public void setUp(PlayerInput _input)
	{
		player_input = _input;
		menuing_runner = new CoroutineRunner(this);
	}

	public void setUpAndStart(PlayerInput _input)
	{
		player_input = _input;
		menuing_runner = new CoroutineRunner(this);
		setToolTipText();
		menuing_runner.run(group.fade(1f, 0.25f, CoroutineExtensions.easeInOutFunc));
		if (!force_kbm)
		{
			checkInput().start(this);
		}
	}

	private void setToolTipText()
	{
		string text = checkTransalte();
		for (int i = 0; i < input.Count; i++)
		{
			text = text.Replace("{" + (i + 1) + "}", colour_sprite ? input[i].getText((!force_kbm) ? player_input.getInputType() : InputType.KBM, colour, _capital_first: true) : input[i].getText((!force_kbm) ? player_input.getInputType() : InputType.KBM, _capital_first: true));
		}
		this.text.text = text;
	}

	public void fadeAndDestroy()
	{
		menuing_runner.run(group.fade(0f, 0.25f, CoroutineExtensions.easeInOutFunc).addCallback(delegate
		{
			Object.Destroy(base.gameObject);
		}));
	}

	public void open()
	{
		setToolTipText();
		menuing_runner.run(group.fade(1f, 0.25f, CoroutineExtensions.easeInOutFunc));
	}

	public void close()
	{
		if (menuing_runner != null)
		{
			menuing_runner.run(group.fade(0f, 0.25f, CoroutineExtensions.easeInOutFunc));
		}
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
		return tooltip;
	}
}
