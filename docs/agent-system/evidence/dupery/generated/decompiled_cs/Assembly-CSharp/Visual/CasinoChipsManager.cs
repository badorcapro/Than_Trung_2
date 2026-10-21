using System.Collections.Generic;
using Audio;
using GRGLib.Coroutines;
using GRGLocalisation;
using Localisation;
using TMPro;
using UnityEngine;

namespace Visual;

public class CasinoChipsManager : MonoBehaviour, IAmLocalised
{
	[Header("References")]
	[SerializeField]
	private TMP_Text chips_text;

	[SerializeField]
	private TMP_Text money_text;

	[Header("Optional References")]
	[SerializeField]
	private TMP_Text last_text;

	[SerializeField]
	private RectTransform last_text_popup;

	[SerializeField]
	private Vector2 last_text_popup_destination;

	[SerializeField]
	private Color gain_colour;

	[SerializeField]
	private Color lose_colour;

	[Header("Prefabs")]
	[SerializeField]
	private CasinoChipsChangeMarker chips_change_prefab;

	[Header("Chip stacks")]
	[SerializeField]
	private List<ChipStackController> chip_stacks = new List<ChipStackController>();

	private int previous_chips;

	private int previous_last;

	private bool previous_hidden;

	private CoroutineRunner countdown_runner;

	private CoroutineRunner last_countdown_runner;

	private bool is_poped_up;

	private AssetKey localisation_asset => LocalisationHelper.general_case_asset;

	private void Awake()
	{
		countdown_runner = new CoroutineRunner(this);
		last_countdown_runner = new CoroutineRunner(this);
	}

	public void setUp()
	{
		chips_text.text = GameHandler.Text.getKeywordAloneCap(Keywords.CHIPS);
	}

	public void revealTruth()
	{
		setChips(previous_chips, _hidden: false);
	}

	public void setChips(int _chips, bool _hidden, bool _animate = true)
	{
		if (_chips == previous_chips && previous_hidden == _hidden)
		{
			displayChange(0);
		}
		previous_hidden = _hidden;
		chip_stacks.ForEach(delegate(ChipStackController _c)
		{
			_c.updateStack(_chips, _hidden);
		});
		if (_hidden)
		{
			money_text.text = "???";
			if (_animate)
			{
				displayChange(_chips - previous_chips);
			}
			previous_chips = _chips;
		}
		else if (_animate && _chips != previous_chips)
		{
			countdown_runner.run(money_text.countDown("x", "", previous_chips, _chips, Mathf.Min((float)Mathf.Abs(previous_chips - _chips) * 0.2f, 1f), CoroutineExtensions.easeInOutFunc));
			displayChange(_chips - previous_chips);
			previous_chips = _chips;
		}
		else
		{
			money_text.text = "x" + _chips;
			previous_chips = _chips;
		}
	}

	private void displayChange(int _diff)
	{
		if (last_text == null)
		{
			return;
		}
		last_text.color = ((_diff > 0) ? gain_colour : ((_diff == 0) ? Color.white : lose_colour));
		if (_diff != previous_last)
		{
			string before = ((_diff > 0 && previous_last >= 0) ? "+" : "");
			last_countdown_runner.run(last_text.countDown(before, TextHelper.chips_sprite_link_white.addColourToSpriteLinks(last_text.color), previous_last, _diff, Mathf.Min((float)Mathf.Abs(previous_last - _diff) * 0.1f, 0.5f), (float _f) => _f).addCallback(delegate
			{
				if (_diff > 0 && last_text.text.Length > 0 && last_text.text[0] != '+')
				{
					last_text.text = "+" + last_text.text;
				}
			}));
		}
		if (!is_poped_up && _diff != 0)
		{
			is_poped_up = true;
			last_text_popup.moveTransform(last_text_popup_destination, 0.45f, CoroutineExtensions.getCustomEaseOutBackFunc(1.1f)).start(this);
		}
		last_text.transform.shake(0.25f, 3f).start(this);
		previous_last = _diff;
		if (Mathf.Abs(_diff) > 3)
		{
			if (_diff > 0)
			{
				AudioHandler.Sfx.playSfx(Sfx.CHIPS_UP, 0.6f);
			}
			else
			{
				AudioHandler.Sfx.playSfx(Sfx.CHIPS_DOWN, 0.6f);
			}
		}
	}
}
