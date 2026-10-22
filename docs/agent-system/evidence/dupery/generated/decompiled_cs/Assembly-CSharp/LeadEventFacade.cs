using System;
using GRGLib.Coroutines;
using GRGLib.Extensions.Unity;
using Leads;
using Localisation;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class LeadEventFacade : MonoBehaviour
{
	[SerializeField]
	private CaseQuirksVisualDataSO quirk_data;

	[SerializeField]
	private RoleVisualDataSO role_data;

	[SerializeField]
	private StampVisualDataSO stamps_data;

	[Header("References")]
	[SerializeField]
	private Image icon;

	[SerializeField]
	private TMP_Text event_name;

	[SerializeField]
	private TMP_Text description;

	[SerializeField]
	private TMP_Text extra_event_text;

	[SerializeField]
	private Button button;

	[Header("Settings")]
	[SerializeField]
	private Sprite unknown_sprite;

	[SerializeField]
	private Material invert_colours_mat;

	private LeadEvent lead_event;

	private Action<LeadEvent> on_selected;

	private CoroutineRunner hovering_runner;

	private void Awake()
	{
		hovering_runner = new CoroutineRunner(this);
	}

	public void setUp(LeadEvent _event, System.Random _random, Action<LeadEvent> _on_selected)
	{
		lead_event = _event;
		on_selected = _on_selected;
		event_name.text = _event.name;
		extra_event_text.text = _event.getRandomEventQuoteText(_random).inQuotes();
		description.text = _event.description;
		_event.helpFacade(this);
	}

	public void setUpControllerSupport(Selectable _left, Selectable _right)
	{
		button.setNavigationHorizontal(_left, _right);
	}

	public Selectable getSelectable()
	{
		return button;
	}

	public void setIconAsRole(Roles _role)
	{
		icon.sprite = role_data[_role];
	}

	public void setIconAsQuirk(CaseQuirks _quirk)
	{
		icon.sprite = quirk_data[_quirk];
	}

	public void setStamp(StampType _stamp, bool _fade_icon = true)
	{
		StampFacade stampFacade = stamps_data.createStampWithCusomIcon(new StampReference(_stamp), unknown_sprite, icon.transform, 0.6f);
		stampFacade.setBackgroundMaterial(invert_colours_mat);
		stampFacade.removeIconMaterial();
		stampFacade.transform.localPosition = new Vector3(0f, 0f, 0f);
		if (_fade_icon)
		{
			icon.color = new Color(1f, 1f, 1f, 0f);
		}
	}

	public void onPointerEnter()
	{
		hovering_runner.run(base.transform.scaleTransform(1.06f, 0.35f, CoroutineExtensions.easeInOutFunc));
	}

	public void onPointerExit()
	{
		hovering_runner.run(base.transform.scaleTransform(1f, 0.25f, CoroutineExtensions.easeInOutFunc));
	}

	public void onSelected()
	{
		on_selected(lead_event);
	}

	public TMP_Text getDescriptionText()
	{
		return description;
	}
}
