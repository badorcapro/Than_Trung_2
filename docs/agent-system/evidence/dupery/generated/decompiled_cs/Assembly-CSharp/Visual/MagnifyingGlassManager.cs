using System;
using GRGLib.Coroutines;
using GRGLib.Extensions.String;
using GRGLib.Maybe;
using TMPro;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.InputSystem;

namespace Visual;

public class MagnifyingGlassManager : MonoBehaviour, IPointerExitHandler, IEventSystemHandler, IPointerEnterHandler
{
	public enum MenuState
	{
		CLOSED,
		CLOSING,
		OPENING,
		OPEN
	}

	[Serializable]
	public struct MagnifyingGlassMenuingAnimation
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

	[SerializeField]
	private PlayerInput player_input;

	[Header("Prefabs")]
	[SerializeField]
	private FakeSuspectVisual fake_visual_prefab;

	[Header("Settings")]
	[SerializeField]
	private float opening_duration = 0.5f;

	[SerializeField]
	private float closing_duration = 0.35f;

	[SerializeField]
	private MagnifyingGlassMenuingAnimation top_anim;

	[SerializeField]
	private MagnifyingGlassMenuingAnimation bottom_anim;

	[SerializeField]
	private Vector2 background_offset = new Vector2(400f, 160f);

	[SerializeField]
	private InputAssetPerType codex_input;

	private Maybe<MagnifyingGlassMenuingAnimation> open_with = new Maybe<MagnifyingGlassMenuingAnimation>();

	private Maybe<SuspectVisual> current_suspect = new Maybe<SuspectVisual>();

	private MultiCoroutineRunner menuing_runner;

	private CoroutineRunner background_runner;

	private Vector2 background_previous_target = new Vector2(0f, 0f);

	private MenuState menu_state;

	private bool pointer_in_range;

	private bool open_bottom;

	private Action close_callback;

	private bool is_open => menu_state == MenuState.OPEN;

	private bool is_openning => menu_state == MenuState.OPENING;

	private bool is_closing => menu_state == MenuState.CLOSING;

	private void Awake()
	{
		menuing_runner = new MultiCoroutineRunner(this);
		background_runner = new CoroutineRunner(this);
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

	public bool explain(SuspectVisual _suspect, string _description)
	{
		_description = _description + "\n" + (codex_input.getText(player_input, _capital_first: true) + " for more information.").italics();
		if (is_closing)
		{
			return false;
		}
		if (current_suspect.is_some && current_suspect.value != _suspect)
		{
			current_suspect.value.fadeSelectedOutline();
		}
		moveBackground(_suspect);
		if (is_open || is_openning)
		{
			if (_suspect.transform.position.y > 0.4f != open_bottom)
			{
				if (current_suspect.is_some && current_suspect.value == _suspect)
				{
					stopExplain();
					return false;
				}
				close(delegate
				{
					explain(_suspect, _description);
				});
				return true;
			}
			current_suspect = _suspect.maybe();
			role_description.text = _description;
			role_description.transform.rotationShake(0.2f, 2f).start(this);
			return true;
		}
		current_suspect = _suspect.maybe();
		open_bottom = _suspect.transform.position.y > 0.4f;
		inside_group.alpha = 0f;
		open(open_bottom ? bottom_anim : top_anim, delegate
		{
			role_description.text = _description;
			role_description.transform.eulerAngles = new Vector3(0f, 0f, 0f);
			menuing_runner.run(inside_group.fade(1f, 0.25f, CoroutineExtensions.easeInOutFunc));
		});
		return true;
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

	public void stopExplain()
	{
		if (is_open || is_openning)
		{
			close(delegate
			{
			});
		}
	}

	private void open(MagnifyingGlassMenuingAnimation _settings, Action _callback)
	{
		open_with = _settings.maybe();
		base.transform.localPosition = _settings.closed_pos;
		base.transform.localEulerAngles = new Vector3(base.transform.localEulerAngles.x, base.transform.localEulerAngles.y, _settings.closed_rotation);
		inside_group.alpha = 0f;
		menu_state = MenuState.OPENING;
		menuing_runner.run(base.transform.moveTransform(_settings.open_pos, opening_duration, CoroutineExtensions.easeInOutFunc), base.transform.rotateTransformSmart(_settings.open_rotation, opening_duration, CoroutineExtensions.easeInOutFunc).addCallback(delegate
		{
			menu_state = MenuState.OPEN;
			_callback();
		}));
	}

	private void close(Action _callback)
	{
		if (current_suspect.is_some)
		{
			current_suspect.value.fadeSelectedOutline();
		}
		if (menu_state == MenuState.CLOSED)
		{
			_callback();
			return;
		}
		close_callback = _callback;
		if (!is_closing || !menuing_runner.is_running)
		{
			MagnifyingGlassMenuingAnimation value = open_with.value;
			menu_state = MenuState.CLOSING;
			menuing_runner.run(inside_group.fade(0f, closing_duration, CoroutineExtensions.easeInOutFunc), base.transform.moveTransform(value.closed_pos, closing_duration, CoroutineExtensions.easeInBackFunc), base.transform.rotateTransformSmart(value.closed_rotation, closing_duration, CoroutineExtensions.easeInBackFunc).addCallback(delegate
			{
				menu_state = MenuState.CLOSED;
				current_suspect = new Maybe<SuspectVisual>();
				close_callback();
			}));
		}
	}

	public void OnPointerEnter(PointerEventData eventData)
	{
		pointer_in_range = true;
	}

	public void OnPointerExit(PointerEventData eventData)
	{
		pointer_in_range = false;
	}

	public void OnPointerDown(InputAction.CallbackContext _context)
	{
		if (_context.performed)
		{
			if (!pointer_in_range && is_open && !sus_list_vis_man.getIsPointerOverSuspect())
			{
				close(delegate
				{
				});
			}
			else if (!pointer_in_range && is_open && sus_list_vis_man.getIsPointerOverSuspect() && sus_list_vis_man.getIsSuspectVisualWithPointerOverThem().value == current_suspect.value)
			{
				close(delegate
				{
				});
			}
		}
	}
}
