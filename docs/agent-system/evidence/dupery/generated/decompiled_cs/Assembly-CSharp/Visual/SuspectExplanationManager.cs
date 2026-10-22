using System;
using System.Collections;
using System.Collections.Generic;
using GRGLib.Coroutines;
using GRGLib.Extensions.String;
using GRGLib.Extensions.Vector;
using GRGLib.Maybe;
using GRGLib.Menus;
using GRGLocalisation;
using Localisation;
using TMPro;
using UnityEngine;
using UnityEngine.InputSystem;

namespace Visual;

public class SuspectExplanationManager : HoverMenu, IAmLocalised
{
	[Serializable]
	public struct MenuingAnimation
	{
		public Vector2 closed_pos;

		public Vector2 open_pos;

		public float closed_rotation;

		public float open_rotation;
	}

	[Header("References")]
	[SerializeField]
	private CanvasGroup inside_group;

	[SerializeField]
	private TMP_Text role_description;

	[SerializeField]
	private SuspectListVisualManager sus_list_vis_man;

	[SerializeField]
	private RectTransform background_trans;

	[SerializeField]
	private RectTransform fake_suspects_parent;

	[Header("Prefabs")]
	[SerializeField]
	private FakeSuspectVisual fake_visual_prefab;

	[Header("Settings")]
	[SerializeField]
	private MenuingAnimation top_anim;

	[SerializeField]
	private MenuingAnimation bottom_anim;

	[SerializeField]
	private Vector2 background_offset = new Vector2(400f, 160f);

	[SerializeField]
	private bool add_tooltip = true;

	[SerializeField]
	private InputAssetPerType codex_input;

	private PlayerInput player_input;

	private MultiCoroutineRunner extra_menuing;

	private CoroutineRunner description_wobble;

	private CoroutineRunner background_runner;

	private CoroutineRunner follow_runner;

	private Maybe<SuspectVisual> previous_suspect = new Maybe<SuspectVisual>();

	private Dictionary<SuspectVisual, Coroutine> close_delays = new Dictionary<SuspectVisual, Coroutine>();

	private Vector2 background_previous_target = new Vector2(0f, 0f);

	private Vector2 target_position;

	private bool open_bottom
	{
		get
		{
			if (previous_suspect.is_some)
			{
				return previous_suspect.value.transform.position.y > 0f;
			}
			return true;
		}
	}

	private string loc_tooltip_key => "Suspect Explain [tooltip]";

	private AssetKey localisation_asset => LocalisationHelper.ui_asset;

	protected override void Awake()
	{
		base.Awake();
		extra_menuing = new MultiCoroutineRunner(this);
		description_wobble = new CoroutineRunner(this);
		background_runner = new CoroutineRunner(this);
		follow_runner = new CoroutineRunner(this);
	}

	public void setUpReferences(PlayerInput _input)
	{
		player_input = _input;
	}

	private Vector2 calculateTargetPosition(Transform _sus_trans)
	{
		return new Vector2(top_anim.open_pos.x, (_sus_trans.localPosition.y + (float)(open_bottom ? (-650) : 600) + (open_bottom ? bottom_anim.open_pos.y : top_anim.open_pos.y)) / 2f);
	}

	public void setUpFakeVisual(SuspectVisual _visual)
	{
		FakeSuspectVisual fake = UnityEngine.Object.Instantiate(fake_visual_prefab, fake_suspects_parent);
		((Action)delegate
		{
			fake.transform.localPosition = _visual.transform.localPosition;
		}).doActionForTime(5f).start(fake);
		_visual.setUpFakeVisual(fake);
	}

	public void explainText(SuspectVisual _suspect, string _explanation)
	{
		if (add_tooltip && SettingsHandler.display_tooltips)
		{
			_explanation = _explanation + "\n" + getTooltipText(codex_input.getText(player_input, Color.black, _capital_first: true)).italics().sizeRelative(85);
		}
		if (previous_suspect.is_some && previous_suspect.value != _suspect)
		{
			previous_suspect.value.fadeSelectedOutline();
		}
		previous_suspect = _suspect.maybe();
		if (base.is_open)
		{
			inside_group.alpha = 1f;
			role_description.text = _explanation;
			role_description.ForceMeshUpdate();
			role_description.transform.localEulerAngles = new Vector3(0f, 0f, -9f);
			description_wobble.run(role_description.transform.rotationShake(0.2f, 2f));
			want_open.Add(_suspect);
			target_position = calculateTargetPosition(_suspect.transform);
		}
		else if (base.current_state == MenuState.OPENING)
		{
			role_description.text = _explanation;
			role_description.ForceMeshUpdate();
			description_wobble.run(role_description.transform.rotationShake(0.2f, 2f));
			want_open.Add(_suspect);
			target_position = calculateTargetPosition(_suspect.transform);
		}
		else
		{
			role_description.text = _explanation;
			role_description.ForceMeshUpdate();
			tryOpen(_suspect);
		}
	}

	public void tryCloseDelay(SuspectVisual _suspect)
	{
		if (close_delays.ContainsKey(_suspect))
		{
			close_delays[_suspect].stop(this);
		}
		close_delays[_suspect] = 0.1f.wait(delegate
		{
			close_delays.Remove(_suspect);
			tryClose(_suspect);
		}).start(this);
	}

	protected override void onMenuOpen()
	{
		base.onMenuOpen();
		follow_runner.run(followSuspect());
	}

	protected override IEnumerator openingAnimation()
	{
		MenuingAnimation menuingAnimation = (open_bottom ? bottom_anim : top_anim);
		target_position = calculateTargetPosition(previous_suspect.value.transform);
		follow_runner.stop();
		extra_menuing.run(inside_group.fade(1f, opening_duration, CoroutineExtensions.easeInOutFunc), base.transform.moveTransformToMovingTarget(() => target_position, opening_duration, CoroutineExtensions.easeInOutFunc), base.transform.rotateTransformSmart(menuingAnimation.open_rotation, opening_duration, CoroutineExtensions.easeInOutFunc), background_trans.moveTransformToMovingTarget(() => previous_suspect.value.transform.localPosition.xy() * -2f + background_offset, opening_duration, CoroutineExtensions.easeInOutFunc));
		yield return opening_duration.wait();
	}

	protected override IEnumerator closingAnimation()
	{
		follow_runner.stop();
		MenuingAnimation menuingAnimation = (open_bottom ? bottom_anim : top_anim);
		extra_menuing.run(inside_group.fade(0f, closing_duration, CoroutineExtensions.easeInOutFunc), base.transform.moveTransform(menuingAnimation.closed_pos, closing_duration, CoroutineExtensions.easeInBackFunc), base.transform.rotateTransformSmart(menuingAnimation.closed_rotation, closing_duration, CoroutineExtensions.easeInBackFunc));
		yield return closing_duration.wait();
	}

	private void moveBackground(SuspectVisual _visual)
	{
		Vector2 vector = _visual.transform.localPosition * -2f;
		if (!(vector == background_previous_target))
		{
			background_previous_target = vector;
			vector += background_offset;
			background_runner.run(background_trans.moveTransform(vector, opening_duration, CoroutineExtensions.easeInOutFunc));
		}
	}

	private IEnumerator followSuspect()
	{
		float speed = 0f;
		float max_speed = 5000f;
		float acceleration = 4000f;
		float decceleration = 5000f;
		float target_y = calculateTargetPosition(previous_suspect.value.transform).y;
		Vector2 background_target = previous_suspect.value.transform.localPosition * -2f;
		background_target += background_offset;
		Roles suspect_type = previous_suspect.value.role_type;
		bool previous_bottom = open_bottom;
		bool animated_background = true;
		while (true)
		{
			if (previous_suspect.value.role_type != suspect_type)
			{
				background_runner.stop();
				suspect_type = previous_suspect.value.role_type;
				target_y = calculateTargetPosition(previous_suspect.value.transform).y;
				background_target = previous_suspect.value.transform.localPosition * -2f;
				background_target += background_offset;
				animated_background = previous_bottom == open_bottom;
				previous_bottom = open_bottom;
				if (!animated_background)
				{
					background_runner.run(background_trans.moveTransform(background_target, opening_duration, CoroutineExtensions.easeInOutFunc));
				}
			}
			float num = target_y - base.transform.localPosition.y;
			if (num > 1f || num < -1f)
			{
				if (Mathf.Abs(num) > speed / 5f)
				{
					speed += acceleration * Time.deltaTime;
					speed = Mathf.Min(speed, max_speed);
				}
				else
				{
					speed -= decceleration * Time.deltaTime;
					speed = Mathf.Max(speed, 1f);
				}
				float num2 = ((num > 0f) ? speed : (0f - speed)) * Time.deltaTime;
				base.transform.localPosition = new Vector3(base.transform.localPosition.x, base.transform.localPosition.y + num2, base.transform.localPosition.z);
				if (animated_background)
				{
					num = Mathf.Abs(target_y - base.transform.localPosition.y);
					Vector2 normalized = (background_target - background_trans.localPosition.xy()).normalized;
					background_trans.localPosition = background_target - normalized * num * 4f;
				}
			}
			yield return null;
		}
	}

	private string getTooltipText(string _input)
	{
		if (GRGLocalisationHandler.needs_translation && GRGLocalisationHandler.instance.translateAndReplace(localisation_asset, loc_tooltip_key, out var _result, _input))
		{
			return _result;
		}
		return tooltipEnglish(_input);
	}

	private string tooltipEnglish(string _data)
	{
		return _data + " for more information.";
	}
}
