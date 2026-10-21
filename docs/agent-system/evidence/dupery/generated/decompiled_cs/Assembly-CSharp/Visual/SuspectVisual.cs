using System;
using System.Collections;
using Audio;
using GRGLib.Coroutines;
using GRGLib.Extensions.Vector;
using GRGLib.Maybe;
using GRGLib.UI;
using TMPro;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

namespace Visual;

public class SuspectVisual : MonoBehaviour, IPointerEnterHandler, IEventSystemHandler, IPointerExitHandler
{
	[Header("References")]
	[SerializeField]
	private RectTransform icon_background;

	[SerializeField]
	private Image icon;

	[SerializeField]
	private GameObject from_object;

	[SerializeField]
	private TMP_Text character_name;

	[SerializeField]
	private TMP_Text character_class;

	[SerializeField]
	private Image selected_outline;

	[SerializeField]
	private AdvancedButton button;

	private SuspectExplanationManager explanation_manager;

	private RoleData role;

	private CoroutineRunner explaining_role;

	private CoroutineRunner role_animation_runner;

	private string classification_name;

	private bool in_range;

	private bool selected;

	private Action<SuspectVisual> on_select;

	private Action<SuspectVisual> on_deselect;

	private Action<Roles> try_open_codex;

	private Action<SuspectVisual> cycle_cross_out;

	public Func<CaseSnapshot> get_case_snap;

	private Maybe<Action<Roles>> override_callback = new Maybe<Action<Roles>>();

	public RectTransform rect_trans => base.transform as RectTransform;

	public int visual_indent { get; private set; }

	public bool indented => visual_indent > 0;

	public Roles role_type => role.role;

	public bool getInRange()
	{
		return in_range;
	}

	private void Awake()
	{
		explaining_role = new CoroutineRunner(this);
	}

	public void setUp(RoleData _role, RoleVisualDataSO _roles_visual_so, SuspectExplanationManager _exp_manager, int _indent, Func<CaseSnapshot> _get_snap)
	{
		if (_role is IHaveAnimation)
		{
			role_animation_runner = new CoroutineRunner(this);
		}
		role = _role;
		classification_name = role.role.getClassificationFromRoleType().toString() + " | " + role.role.getAlignmentFromRoleType().toStringCap();
		explanation_manager = _exp_manager;
		icon.sprite = _roles_visual_so[_role.role];
		icon.color = _roles_visual_so[_role.role.getClassificationFromRoleType()].class_colour;
		character_name.text = _role.name;
		character_class.text = _role.role.getClassificationFromRoleType().toStringPlain();
		get_case_snap = _get_snap;
		visual_indent = _indent;
		if (_indent == 1)
		{
			icon_background.localPosition = icon_background.localPosition.addX(80f);
			character_name.transform.localPosition = character_name.transform.localPosition.addX(40f);
			character_name.rectTransform.sizeDelta = character_name.rectTransform.sizeDelta - new Vector2(80f, 0f);
			from_object.SetActive(value: true);
		}
		else
		{
			from_object.SetActive(value: false);
		}
	}

	public void setUpCrossOutCallback(Action<SuspectVisual> _cycle_lines)
	{
		cycle_cross_out = _cycle_lines;
	}

	public void setUpSize(float _size)
	{
		Vector2 sizeDelta = rect_trans.sizeDelta;
		rect_trans.sizeDelta = sizeDelta * _size;
	}

	public void setUpFakeVisual(FakeSuspectVisual _fake)
	{
		_fake.setUp(character_name.text, icon, selected_outline);
	}

	public void setUpCallbacks(Action<SuspectVisual> _on_select, Action<SuspectVisual> _on_deselect, Action<Roles> _try_open_codex)
	{
		on_select = _on_select;
		on_deselect = _on_deselect;
		try_open_codex = _try_open_codex;
	}

	public Selectable getSelectable()
	{
		return button;
	}

	public void setUpSelectables(Selectable _left, Selectable _up, Selectable _down)
	{
		Navigation navigation = button.navigation;
		navigation.selectOnLeft = _left;
		navigation.selectOnUp = _up;
		navigation.selectOnDown = _down;
		button.navigation = navigation;
	}

	public void onHover()
	{
		explainRole();
		AudioHandler.Sfx.playSfx(Sfx.SUSPECT_HOVER);
	}

	public void onUnhover()
	{
		explanation_manager.tryCloseDelay(this);
		fadeSelectedOutline();
	}

	public void onSelect()
	{
		if (!selected)
		{
			on_select(this);
			AudioHandler.Sfx.playSfx(Sfx.SUSPECT_HOVER, 0.75f);
			selected = true;
			explainRole();
		}
	}

	public void onDeselect()
	{
		if (selected)
		{
			explanation_manager.tryCloseDelay(this);
			on_deselect(this);
			selected = false;
			fadeSelectedOutline();
		}
	}

	private void explainRole()
	{
		fadeSelectedOutline(_on: true);
		if (!override_callback.is_some)
		{
			explanation_manager.explainText(this, "<size=125%><b>" + role.name + "</b></size>\n<size=90%><b>" + classification_name + "</b></size>\n" + role.getCaseDescription(get_case_snap()));
		}
	}

	public void onPointerUp(PointerEventData _event_data)
	{
		if (_event_data.button == PointerEventData.InputButton.Left)
		{
			openCodexOfRole();
		}
		else if (_event_data.button == PointerEventData.InputButton.Right)
		{
			cycleLines();
		}
	}

	public void openCodexOfRole()
	{
		if (override_callback.is_some)
		{
			override_callback.value(role_type);
		}
		else
		{
			try_open_codex(role_type);
		}
	}

	public void cycleLines()
	{
		cycle_cross_out(this);
	}

	public void fadeSelectedOutline(bool _on = false)
	{
		explaining_role.run(selected_outline.fade(_on ? 1f : (selected ? 0.5f : 0f), 0.35f, CoroutineExtensions.easeInOutFunc));
	}

	public void OnPointerEnter(PointerEventData eventData)
	{
		in_range = true;
	}

	public void OnPointerExit(PointerEventData eventData)
	{
		in_range = false;
	}

	public void checkRoleAnimation(IHaveAnimation _role_animation_data)
	{
		if (_role_animation_data.play_animation_immediate.is_some)
		{
			if (_role_animation_data.play_animation_immediate.value == IHaveAnimation.RoleAnimations.JUDGE_SUSPECT_SHAKE)
			{
				role_animation_runner.run(shakeContinuous());
			}
		}
		else if (_role_animation_data.stop_animation_immediate)
		{
			role_animation_runner.stop();
			icon.rectTransform.anchoredPosition = new Vector2(0f, 0f);
		}
	}

	private IEnumerator shakeContinuous()
	{
		while (true)
		{
			yield return icon.transform.shake(1f, 1f);
		}
	}

	public void setUpOverrideCallback(Action<Roles> _over)
	{
		override_callback = _over.maybe();
	}

	public void resetCallback()
	{
		override_callback = new Maybe<Action<Roles>>();
	}
}
