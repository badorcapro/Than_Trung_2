using System;
using System.Collections.Generic;
using System.Linq;
using ControllerSupport;
using GRGLib.Coroutines;
using GRGLib.Extensions.Random;
using Hover;
using Leads;
using Save;
using UnityEngine;
using UnityEngine.InputSystem;

public class LeadEventManager : MonoBehaviour
{
	[SerializeField]
	private RegionsSO regions_data;

	[Header("References")]
	[SerializeField]
	private RectTransform events_parent;

	[SerializeField]
	private LeadFacade lead_to_stamp;

	[SerializeField]
	private CanvasGroup event_group;

	[SerializeField]
	private BaseInputHandler controller_support;

	[SerializeField]
	private ControllerKeySearchHandler controller_key_search;

	[Header("Prefabs")]
	[SerializeField]
	private LeadEventFacade facade_prefab;

	private bool selection_made;

	private MultiCoroutineRunner lead_mover_runner;

	private CoroutineRunner event_fade_runner;

	private List<LeadEventFacade> event_facades = new List<LeadEventFacade>();

	private void Awake()
	{
		lead_mover_runner = new MultiCoroutineRunner(this);
		event_fade_runner = new CoroutineRunner(this);
	}

	private void Start()
	{
		Lead current_lead = GameHandler.State.current_lead.value;
		System.Random random = RandomExtensions.freshRandom();
		if (GameHandler.State.available_event_choices.Count > 0)
		{
			setUp(GameHandler.State.available_event_choices.Select((LeadEventSaveData _s) => LeadEvent.load(_s, current_lead, random)).ToList(), random);
			return;
		}
		LeadProgressionManager leadProgressionManager;
		if (GameHandler.State.current_region != Regions.CUSTOM)
		{
			leadProgressionManager = ((GameHandler.State.current_region != Regions.SYNDICATE) ? GameHandler.State.current_region.getLeadProgressionManager(regions_data) : LeadHelper.getSyndicateProgressionManager(GameHandler.State, regions_data));
		}
		else
		{
			if (!GameHandler.State.custom_progression_manager.is_some)
			{
				Debug.LogError("No custom progression manager set but in custom region!");
			}
			leadProgressionManager = GameHandler.State.custom_progression_manager.value;
		}
		List<LeadEvent> eventChoices = leadProgressionManager.getEventChoices(current_lead, random);
		GameHandler.State.available_event_choices = eventChoices.Select((LeadEvent _e) => _e.toSave()).ToList();
		setUp(eventChoices, random);
		GameHandler.instance.saveGame();
	}

	public void setUp(List<LeadEvent> _events, System.Random _rnd)
	{
		event_facades = new List<LeadEventFacade>();
		for (int i = 0; i < _events.Count; i++)
		{
			LeadEventFacade leadEventFacade = UnityEngine.Object.Instantiate(facade_prefab, events_parent);
			leadEventFacade.setUp(_events[i], _rnd, onEventSelected);
			event_facades.Add(leadEventFacade);
		}
		setUpControllerSupport(event_facades);
	}

	private void setUpControllerSupport(List<LeadEventFacade> _facades)
	{
		for (int i = 0; i < _facades.Count; i++)
		{
			_facades[i].setUpControllerSupport((i == 0) ? null : _facades[i - 1].getSelectable(), (i + 1 < _facades.Count) ? _facades[i + 1].getSelectable() : null);
		}
		if (GameHandler.instance.using_gamepad)
		{
			_facades[0].getSelectable().Select();
		}
	}

	public void onInputDeviceChange(PlayerInput _input)
	{
		if (_input.isUsingGamepad() && !controller_support.isAnythingSelected())
		{
			event_facades[0].getSelectable().Select();
		}
	}

	private void onEventSelected(LeadEvent _event)
	{
		if (!TransitionHandler.instance.is_transitioning && !selection_made)
		{
			selection_made = true;
			Lead current_lead = GameHandler.State.current_lead.value;
			_event.getStampsToFade(current_lead).ForEach(delegate(StampReference _s)
			{
				current_lead.fadeStamp(_s);
			});
			List<StampReference> stamps = _event.getStamps(current_lead);
			if (stamps.Count == 0)
			{
				applyEventAndMoveOn(current_lead, _event);
				return;
			}
			event_fade_runner.run(event_group.fade(0f, 0.75f, CoroutineExtensions.easeInOutFunc));
			lead_to_stamp.setCurrentLead(GameHandler.State.current_lead.value, regions_data[GameHandler.State.current_lead.value.case_type.fromType()].region_name);
			playerStamp(stamps, 0, current_lead, _event);
			lead_mover_runner.run(lead_to_stamp.transform.moveTransform(Vector2.zero, 0.85f, CoroutineExtensions.easeOutFunc), lead_to_stamp.transform.rotateTransformSmart(0f, 0.85f, CoroutineExtensions.easeOutFunc));
		}
	}

	private void playerStamp(List<StampReference> _stamps, int _stamp_id, Lead _lead, LeadEvent _event)
	{
		lead_to_stamp.prepareForStamp(_stamps[_stamp_id], delegate
		{
			if (_stamp_id + 1 >= _stamps.Count)
			{
				applyEventAndMoveOn(_lead, _event);
			}
			else
			{
				playerStamp(_stamps, _stamp_id + 1, _lead, _event);
			}
		});
	}

	private void applyEventAndMoveOn(Lead _lead, LeadEvent _event)
	{
		_lead.applyEvent(_event);
		GameHandler.State.available_event_choices = new List<LeadEventSaveData>();
		GameHandler.instance.moveToScene("StasisScene", _save: true);
	}

	public void controllerFocus(InputAction.CallbackContext _context)
	{
		if (!_context.canceled)
		{
			return;
		}
		if (controller_key_search.is_closed)
		{
			controller_key_search.openMenu();
			controller_key_search.setUpPageKeywordsLinks(event_facades.Select((LeadEventFacade _e) => _e.getDescriptionText()).ToList());
		}
		else
		{
			controller_key_search.closeMenu();
			event_facades[0].getSelectable().Select();
		}
	}
}
