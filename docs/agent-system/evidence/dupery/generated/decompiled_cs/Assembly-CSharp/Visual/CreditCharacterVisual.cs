using System;
using System.Collections;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using Audio;
using GRGLib.Coroutines;
using GRGLib.Extensions.Unity;
using GRGLib.Maybe;
using GRGLocalisation;
using Localisation;
using TMPro;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

namespace Visual;

public class CreditCharacterVisual : MonoBehaviour, IAmLocalised
{
	[Header("References (Investigated)")]
	[SerializeField]
	private RectTransform jigglered;

	[SerializeField]
	private RectTransform icon_parent;

	[SerializeField]
	private RectTransform death_reference;

	[SerializeField]
	private RectTransform ability_reference;

	[SerializeField]
	private Image card_background;

	[SerializeField]
	private Image icon;

	[SerializeField]
	private TMP_Text character_address;

	[SerializeField]
	private TMP_Text character_name;

	[SerializeField]
	private KnockVisual knock_visual;

	[SerializeField]
	private List<Image> chains;

	[SerializeField]
	private TextBox text_box;

	[SerializeField]
	private GameObject obscured_image;

	[Header("References (Not Investigated)")]
	[SerializeField]
	private CanvasGroup door_group;

	[SerializeField]
	private Image door;

	[SerializeField]
	private TMP_Text door_address;

	[SerializeField]
	private Image ability_focus_image;

	[Header("References (Other)")]
	[SerializeField]
	private CanvasGroup visual_group;

	[SerializeField]
	private Image truth_switch_icon;

	[SerializeField]
	private CharacterSymbolController character_symbol_controller;

	[Header("Prefabs")]
	[SerializeField]
	private CharacterDeathAnimationController death_anim_prefab;

	[SerializeField]
	private CharacterAbilityVisual ability_visual_prefab;

	private bool truth_time;

	private bool showing_truth;

	private Maybe<string> pre_truth = new Maybe<string>();

	private bool dead;

	private bool arrested;

	private bool investigated;

	private bool as_investigated;

	private bool obscured;

	private bool hidden;

	private bool had_disguise;

	private bool is_hovering;

	private RoleData role_data;

	private Maybe<Roles> previous_visual_role = new Maybe<Roles>();

	private RoleVisualDataSO roles_visuals_so;

	private int address;

	private Action<int> on_investigate;

	private Action<int> on_arrest;

	private Maybe<Action<RoleData, int>> override_click = new Maybe<Action<RoleData, int>>();

	private Maybe<CharacterSymbolController> m_symbol_controller = new Maybe<CharacterSymbolController>();

	private CoroutineRunner reveal_fill;

	private MultiCoroutineRunner arrest_runner;

	private CoroutineRunner arrest_bars_runner;

	private CoroutineRunner jiggler_runner;

	private CoroutineRunner background_darken_runner;

	private CoroutineRunner focus_runner;

	private CoroutineRunner focus_loop_runner;

	private CoroutineRunner ability_focus_runner;

	private CoroutineRunner truth_switch;

	private MultiCoroutineRunner hide_runner;

	private bool button_pressed;

	private bool attempting_ability;

	private bool attempting_investigation;

	private string custom_name = "";

	private string current_dialogue = "";

	private Vector3 location_position;

	private Vector3 icon_position;

	private Maybe<CharacterDeathAnimationController> death_controller = new Maybe<CharacterDeathAnimationController>();

	private Maybe<CharacterAbilityVisual> m_ability_visual = new Maybe<CharacterAbilityVisual>();

	private bool ability_available
	{
		get
		{
			if (m_ability_visual.is_some)
			{
				return ability_visual.available;
			}
			return false;
		}
	}

	private RoleData visual_data => role_data.getVisualRole();

	public CharacterSymbolController truth_symbol_controller
	{
		get
		{
			if (!m_symbol_controller.is_some)
			{
				m_symbol_controller = UnityEngine.Object.Instantiate(character_symbol_controller, jigglered).maybe();
			}
			return m_symbol_controller.value;
		}
	}

	private CharacterAbilityVisual ability_visual
	{
		get
		{
			if (!m_ability_visual.is_some)
			{
				m_ability_visual = UnityEngine.Object.Instantiate(ability_visual_prefab, ability_reference).maybe();
			}
			return m_ability_visual.value;
		}
	}

	public Roles visual_role
	{
		get
		{
			if (!arrested)
			{
				return visual_data.role;
			}
			return role_data.reveal_as;
		}
	}

	public bool is_investigated => role_data.getIsInvestigated();

	private AssetKey localisation_asset => LocalisationHelper.general_case_asset;

	private string loc_dead_key => "Role [dead]";

	private void Awake()
	{
		jiggler_runner = new CoroutineRunner(this);
		reveal_fill = new CoroutineRunner(this);
		arrest_bars_runner = new CoroutineRunner(this);
		background_darken_runner = new CoroutineRunner(this);
		focus_runner = new CoroutineRunner(this);
		focus_loop_runner = new CoroutineRunner(this);
		ability_focus_runner = new CoroutineRunner(this);
		arrest_runner = new MultiCoroutineRunner(this);
		hide_runner = new MultiCoroutineRunner(this);
	}

	public void setUp(RoleData _data, string _info, string _name, RoleVisualDataSO _role_visual_so, int _address, Vector3 _normal_position, System.Random _rng)
	{
		address = _address;
		character_address.text = address.ToString();
		door_address.text = _address.ToString();
		door.sprite = _role_visual_so.getRandomDoor(_rng);
		role_data = _data;
		roles_visuals_so = _role_visual_so;
		location_position = _normal_position;
		icon_position = icon_parent.localPosition;
		had_disguise = _data.getDisguise().is_some;
		current_dialogue = _info;
		custom_name = _name;
		renew(_data, _info, _name, _set_up: true);
	}

	public void setUpCallbacks(Action<int> _investigate_callback, Action<int> _arrest_callback, Action<RoleData, int> _ability_callback, Action<int> _on_hover, Action<int> _on_unhover, Action<RoleData, bool> _hover_truth, Action<RoleData> _unhover_truth, Action<RoleData, bool> _change_end_hover_type, Action<Vector2> _create_ripple)
	{
		on_investigate = _investigate_callback;
		on_arrest = _arrest_callback;
	}

	public void setupCreditSoundCallbacks(Action<int> _investigate_callback, Action<int> _arrest_callback)
	{
		on_investigate = _investigate_callback;
		on_arrest = _arrest_callback;
	}

	public void setOverrideCallback(Action<RoleData, int> _override_click_callback)
	{
		override_click = _override_click_callback.maybe();
	}

	public void removeOverrideCallback()
	{
		override_click = new Maybe<Action<RoleData, int>>();
	}

	public void moveToPosition()
	{
		Sfx.CARD.play(0.5f);
		base.transform.moveTransform(location_position, 0.7f, CoroutineExtensions.easeOutBackFunc).start(this);
	}

	public void onHover()
	{
		if (!truth_time && hidden)
		{
			return;
		}
		jiggler_runner.run(jigglered.jiggle());
		Sfx.CHARACTER_HOVER.play(0.8f);
		is_hovering = true;
		if (truth_time)
		{
			if (pre_truth.is_some)
			{
				truth_switch.run(truth_switch_icon.fadeInOutContinuous(1f, 0.7f, 0.5f, 0.5f, CoroutineExtensions.easeInOutFunc));
			}
		}
		else if (!dead && investigated)
		{
			_ = obscured;
		}
	}

	public void onUnHover()
	{
		if (truth_time || !hidden)
		{
			is_hovering = false;
			if (truth_time && pre_truth.is_some)
			{
				truth_switch.run(truth_switch_icon.fade(0f, 0.35f, CoroutineExtensions.easeInOutFunc));
			}
		}
	}

	public void tryInvestigateOrAbility()
	{
		if (truth_time || hidden || button_pressed || dead || override_click.is_some)
		{
			return;
		}
		if (!investigated)
		{
			button_pressed = true;
			Sfx.DOOR_KNOCK.play();
			knock_visual.animateKnock(delegate
			{
				attempting_investigation = true;
				on_investigate(address);
				uncover(current_dialogue, custom_name);
			});
		}
		else if (ability_available)
		{
			button_pressed = true;
			attempting_ability = true;
		}
	}

	public void tryArrest()
	{
		if (!truth_time && !hidden && !arrested && !dead && !button_pressed && !override_click.is_some)
		{
			button_pressed = true;
			Atmo.GATE_CLOSE.playAsSfx(0.85f);
			arrest_runner.run(base.transform.shake(1f, 0.1f, 10f, CoroutineExtensions.easeInOutFunc), base.transform.rotationShake(1f, 0.1f, 5f, CoroutineExtensions.easeInOutFunc), icon_parent.shake(1f, 0.1f, 10f, CoroutineExtensions.easeInOutFunc), icon_parent.scaleTransform(1.1f, 1f, CoroutineExtensions.easeInOutFunc).addCallback(delegate
			{
				on_arrest(address);
				arrest(current_dialogue, custom_name);
				icon_parent.scaleTransform(1f, 1f, CoroutineExtensions.easeInOutFunc).start(this);
				base.transform.moveTransform(location_position, 0.1f, CoroutineExtensions.easeInOutFunc).start(this);
				Atmo.GATE_CLOSE.stopIfPlaying();
				Sfx.GATE_END.play(0.85f);
			}));
		}
	}

	public void onButtonRelease(bool _check_ab = true)
	{
		if (truth_time)
		{
			toggleTruthAndPre();
			return;
		}
		if (override_click.is_some)
		{
			if (_check_ab)
			{
				override_click.value(role_data, address);
			}
			return;
		}
		onLeave();
		if (attempting_ability && ability_available)
		{
			attempting_ability = false;
		}
	}

	public void onPress(PointerEventData _data)
	{
		if (truth_time || button_pressed || override_click.is_some || hidden)
		{
			return;
		}
		if (_data.button == PointerEventData.InputButton.Left)
		{
			if (GameHandler.UniversalInput.shift_down)
			{
				tryArrest();
			}
			else
			{
				tryInvestigateOrAbility();
			}
		}
		else if (_data.button == PointerEventData.InputButton.Right)
		{
			tryArrest();
		}
	}

	public void onLeave()
	{
		button_pressed = false;
		if (knock_visual.is_running)
		{
			knock_visual.endEarly();
		}
		if (arrest_runner.is_running)
		{
			Atmo.GATE_CLOSE.stopIfPlaying();
			base.transform.localEulerAngles = Vector3.zero;
			base.transform.localPosition = location_position;
			icon_parent.localPosition = icon_position;
			arrest_runner.run(icon_parent.scaleTransform(1f, 0.35f, CoroutineExtensions.easeInOutFunc));
		}
	}

	public void onRelease(PointerEventData _data)
	{
		onButtonRelease(_data.button == PointerEventData.InputButton.Left);
	}

	public void renew(RoleData _data, string _info, string _name, bool _set_up = false)
	{
		checkRoleAudio(_data);
		checkRoleAnimation(_data);
		if (_data.getIsHidden() != hidden)
		{
			hide(_data.getIsHidden(), !_set_up);
		}
		if (dead)
		{
			return;
		}
		bool flag = false;
		if (role_data.role != _data.role)
		{
			flag = true;
		}
		role_data = _data;
		flag = flag || had_disguise != _data.getDisguise().is_some || (previous_visual_role.is_some && visual_data.role != previous_visual_role.value);
		previous_visual_role = visual_data.role.maybe();
		had_disguise = _data.getDisguise().is_some;
		if (visual_data.getIsInvestigated() || _data.getIsInvestigated() || as_investigated)
		{
			if (!investigated || flag)
			{
				uncover(_info, _name);
			}
			else
			{
				if (obscured && !_data.getIsObscured())
				{
					if (arrested)
					{
						revealFromArrest(_info, _name);
					}
					else
					{
						uncover(_info, _name);
					}
				}
				if (!_data.getIsDead())
				{
					if (!_data.getIsArrested() && visual_data.getIsObscured() && !obscured)
					{
						uncover(_info, _name);
					}
					if (visual_data.hasInfo)
					{
						tryWriteInfo(_info);
					}
				}
			}
			if (ability_available && (!visual_data.getHasAnyAbility() || visual_data.getIsAbilityExhausted()))
			{
				ability_visual.onUseAbility();
			}
			if (visual_data.getHasAnyAbility() && !visual_data.getIsAbilityExhausted() && !ability_available)
			{
				ability_visual.restoreAbility(visual_data);
			}
		}
		else if (attempting_investigation)
		{
			base.transform.shake(0.15f, 10f).start(this);
		}
		if (!dead && role_data.getIsDead())
		{
			if (!_set_up && !_data.getIsHidden())
			{
				AudioHandler.Sfx.Queuer.queueSfx(Sfx.GUNSHOT, 0.85f);
			}
			kill();
		}
		if (!arrested && role_data.getIsArrested())
		{
			arrest(_info, _name);
		}
		attempting_investigation = false;
	}

	private void checkRoleAudio(RoleData _role)
	{
		if (_role is IHaveAudio haveAudio && haveAudio.play_sfx_immidiate.is_some)
		{
			AudioHandler.Sfx.playSfx(haveAudio.play_sfx_immidiate.value);
			haveAudio.resetWantedSfx();
		}
	}

	private void checkRoleAnimation(RoleData _role)
	{
	}

	private void hide(bool _true, bool _animate = true)
	{
		hidden = _true;
		if (_animate)
		{
			visual_group.interactable = !_true;
			visual_group.blocksRaycasts = !_true;
			hide_runner.run(visual_group.transform.scaleTransform((!_true) ? 1 : 0, 0.95f, CoroutineExtensions.easeOutBackFunc), visual_group.fade((!_true) ? 1 : 0, 0.65f, CoroutineExtensions.easeInOutFunc));
		}
		else
		{
			visual_group.putOn(!_true);
			visual_group.transform.localScale = (_true ? new Vector3(0f, 0f, 1f) : new Vector3(1f, 1f, 1f));
		}
	}

	public void uncover(string _info, string _name)
	{
		uncoverWithData(visual_data, _info, _name);
	}

	private void uncoverWithData(RoleData _data, string _info, string _name, bool _arrested = false, bool _check_true_evil = true)
	{
		uncoverWithData(_data, _info, _name, _data.role, _arrested, _check_true_evil);
	}

	private void uncoverWithData(RoleData _data, string _info, string _name, Roles _custom_reveal, bool _arrested = false, bool _check_true_evil = true)
	{
		investigated = true;
		door_group.fade(0f, 0.15f, CoroutineExtensions.easeInOutFunc).start(this);
		obscured = _data.getIsObscured();
		icon.sprite = roles_visuals_so[_custom_reveal];
		colourIcon(_data, _custom_reveal, _arrested && _check_true_evil);
		icon.gameObject.SetActive(!obscured);
		icon.transform.SetAsFirstSibling();
		character_name.text = ((obscured && !_arrested) ? "?????" : ((_data.role == _custom_reveal) ? _name : _custom_reveal.toStringPlain()));
		character_name.color = ((obscured && !_arrested) ? Color.black : roles_visuals_so[_custom_reveal.getClassificationFromRoleType()].role_text_colour);
		if (_data.getHasAnyAbility())
		{
			ability_visual.onInvestigate(_data);
		}
		else if (_arrested && visual_data.getHasAnyAbility())
		{
			ability_visual.onInvestigate(visual_data);
		}
		obscured_image.SetActive(obscured);
		tryWriteInfo(_info);
	}

	private void revealFromArrest(string _info, string _name)
	{
		if (role_data.reveal_as == role_data.role)
		{
			if (!investigated)
			{
				as_investigated = true;
			}
			uncoverWithData(role_data, _info, _name, _arrested: true);
		}
		else if (visual_data.role == role_data.reveal_as)
		{
			if (!investigated)
			{
				uncoverWithData(visual_data, _info, _name, _arrested: true, _check_true_evil: false);
				as_investigated = true;
			}
		}
		else
		{
			uncoverWithData(role_data, _info, _name, role_data.reveal_as, _arrested: true);
		}
	}

	public void arrest(string _info, string _name)
	{
		arrested = true;
		arrest_bars_runner.run(chains.fill(1f, 0.2f, CoroutineExtensions.easeInOutFunc));
		if (!dead)
		{
			revealFromArrest(_info, _name);
		}
	}

	public void kill()
	{
		dead = true;
		CharacterDeathAnimationController characterDeathAnimationController = UnityEngine.Object.Instantiate(death_anim_prefab, base.transform);
		characterDeathAnimationController.kill(death_reference);
		death_controller = characterDeathAnimationController.maybe();
		character_address.transform.SetAsLastSibling();
		tryWriteInfo(localisation_asset.checkTranslation(loc_dead_key, englishDead));
	}

	private void tryWriteInfo(string _info)
	{
		if (obscured)
		{
			Regex regex = new Regex("[^0-9.,!*?！。！， ]");
			_info = _info.replaceTags("<", ">", (string _t, string _m) => "A", ("sprite", ""));
			_info = _info.removeCommonRichTextTags();
			_info = regex.Replace(_info, "<size=85%>■</size>");
		}
		current_dialogue = _info;
		text_box.writeDialogue(_info);
	}

	public void revealTruth()
	{
		if (truth_time)
		{
			showing_truth = true;
			text_box.writeDialogue(role_data.getTruthString());
			return;
		}
		if (hidden)
		{
			hide(_true: false);
		}
		truth_switch = new CoroutineRunner(this);
		truth_time = true;
		showing_truth = true;
		door_group.alpha = 0f;
		icon.sprite = roles_visuals_so[role_data.role];
		colourIcon(role_data, role_data.role, _test_true_alignment: true);
		truth_switch_icon.color = new Color(icon.color.r, icon.color.g, icon.color.b, 0f);
		icon.transform.SetAsFirstSibling();
		icon.gameObject.SetActive(value: true);
		obscured_image.SetActive(value: false);
		character_name.text = role_data.name;
		character_name.color = roles_visuals_so[role_data.role.getClassificationFromRoleType()].role_text_colour;
		if (role_data.getHasAnyAbility())
		{
			ability_visual.revealAbility();
		}
		if (death_controller.is_some)
		{
			death_controller.value.destroySelf();
			death_controller = new Maybe<CharacterDeathAnimationController>();
		}
		arrest_bars_runner.run(chains.fill(0f, 0.2f, CoroutineExtensions.easeInOutFunc));
		pre_truth = text_box.getWrittenText().maybe();
		if (pre_truth.value == "")
		{
			pre_truth = new Maybe<string>();
		}
		text_box.writeDialogue(role_data.getTruthString());
		if (SettingsHandler.show_truth_symbols)
		{
			truth_symbol_controller.updateSymbols(role_data.getIsArrested(), role_data.getIsTainted(), role_data.getIsDead(), role_data.getIsObscured());
		}
	}

	public void toggleTruthAndPre()
	{
		if (pre_truth.is_some)
		{
			if (!jiggler_runner.is_running)
			{
				jiggler_runner.run(base.transform.jiggle());
			}
			if (showing_truth)
			{
				text_box.writeDialogue(pre_truth.value);
			}
			else
			{
				text_box.writeDialogue(role_data.getTruthString());
			}
			showing_truth = !showing_truth;
		}
	}

	public void toggleTruthSymbols(bool _on)
	{
		if (truth_time && (_on || m_symbol_controller.is_some))
		{
			truth_symbol_controller.gameObject.SetActive(_on);
		}
	}

	private void colourIcon(RoleData _data, Roles _custom_reveal, bool _test_true_alignment)
	{
		if (_test_true_alignment && _custom_reveal == _data.role && _data.getTrueAlignment() != _data.role.getAlignmentFromRoleType())
		{
			icon.color = roles_visuals_so[(_data.getTrueAlignment() == Alignments.EVIL) ? RoleClassifications.UNDERLING : RoleClassifications.INNOCENT].class_colour;
		}
		else
		{
			icon.color = roles_visuals_so[_custom_reveal.getClassificationFromRoleType()].class_colour;
		}
	}

	public void darken(bool _true = true)
	{
		background_darken_runner.run(card_background.fadeToColour(_true ? new Color(0.7f, 0.7f, 0.7f) : Color.white, 0.35f, CoroutineExtensions.easeInOutFunc));
		focus_loop_runner.run(base.transform.scaleTransform(_true ? 0.98f : 1f, 0.3f, CoroutineExtensions.easeInOutFunc));
	}

	public void focus(bool _true = true, bool _loop = false)
	{
		focus_runner.run(card_background.transform.scaleTransform(_true ? 1.03f : 1f, 0.35f, CoroutineExtensions.easeInOutFunc));
		if (_true && _loop)
		{
			focus_loop_runner.run(focusLoopAnimation());
		}
		else
		{
			focus_loop_runner.run(base.transform.scaleTransform(1f, 0.3f, CoroutineExtensions.easeInOutFunc));
		}
	}

	public void abilityFocus(bool _true)
	{
		ability_focus_runner.run(ability_focus_image.fade(_true ? 0.2f : 0f, 0.35f, CoroutineExtensions.easeInOutFunc));
	}

	public void undarkenAndUnfocus()
	{
		darken(_true: false);
		focus(_true: false);
	}

	private IEnumerator focusLoopAnimation()
	{
		while (true)
		{
			yield return base.transform.scaleTransform(1.03f, 0.65f, CoroutineExtensions.easeInOutFunc);
			yield return base.transform.scaleTransform(1.02f, 0.6f, CoroutineExtensions.easeInOutFunc);
			yield return 0.6f.wait();
		}
	}

	private string englishDead()
	{
		return "*Dead*";
	}
}
