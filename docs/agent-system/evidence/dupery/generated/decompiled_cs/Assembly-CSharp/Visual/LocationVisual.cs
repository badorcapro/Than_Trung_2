using System;
using GRGLib.Coroutines;
using GRGLib.Maybe;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace Visual;

public class LocationVisual : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private CanvasGroup group;

	[SerializeField]
	private CanvasGroup darken_group;

	[SerializeField]
	private Button location_button;

	[SerializeField]
	private TMP_Text name_text;

	protected LocationData location_data;

	protected LocationTypes visual_location_type;

	protected Action<LocationData> try_use_ability;

	protected Maybe<Action<Vector2Int, LocationTypes>> override_click = new Maybe<Action<Vector2Int, LocationTypes>>();

	private CoroutineRunner focus_runner;

	private CoroutineRunner darken_runner;

	protected virtual void Awake()
	{
		focus_runner = new CoroutineRunner(this);
		darken_runner = new CoroutineRunner(this);
	}

	public void fadeIn(float _duration)
	{
		group.alpha = 0f;
		group.fade(1f, _duration, CoroutineExtensions.easeInOutFunc).start(this);
	}

	public virtual void setUpLocation(LocationData _data, Action<LocationData> _use_ability)
	{
		location_data = _data;
		visual_location_type = _data.visual_location.location_type;
		try_use_ability = _use_ability;
		name_text.text = _data.visual_location.name.ToUpper();
	}

	public virtual void renew(LocationData _data, CaseSnapshot _snap, Action<LocationData, Vector3> _replace_location)
	{
		location_data = _data;
		if (visual_location_type != _data.visual_location.location_type)
		{
			visual_location_type = _data.location_type;
			_replace_location(_data, base.transform.localPosition);
			UnityEngine.Object.Destroy(base.gameObject);
		}
	}

	public virtual void setOverrideClick(Action<Vector2Int, LocationTypes> _override)
	{
		override_click = _override.maybe();
	}

	public virtual void resetOverrideClick()
	{
		override_click = new Maybe<Action<Vector2Int, LocationTypes>>();
	}

	public void resetFocusAndDarken()
	{
		focus(_true: false);
		darken(_true: false);
	}

	public virtual void focus(bool _true = true)
	{
		focus_runner.run(base.transform.scaleTransform(_true ? 1.05f : 1f, 0.35f, CoroutineExtensions.easeInOutFunc));
	}

	public virtual void darken(bool _true = true)
	{
		darken_runner.run(darken_group.fade(_true ? 1 : 0, 0.35f, CoroutineExtensions.easeInOutFunc));
	}

	public bool reveal(Action<LocationData, Vector3> _replace_location)
	{
		if (!location_data.is_location_disguised)
		{
			return false;
		}
		_replace_location(location_data, base.transform.localPosition);
		UnityEngine.Object.Destroy(base.gameObject);
		return true;
	}

	public virtual void tryAbility()
	{
		if (!location_data.has_ability)
		{
			Debug.Log($"This location has no ability to use! {location_data.location_type}");
		}
		else
		{
			try_use_ability(location_data);
		}
	}

	public void onClick()
	{
		if (override_click.is_some)
		{
			override_click.value(location_data.getBoardPosition(), location_data.location_type);
		}
		else
		{
			onClickPastOverride();
		}
	}

	protected virtual void onClickPastOverride()
	{
	}

	public void setAsDisplay(LocationData _data)
	{
		setUpLocation(_data, delegate
		{
		});
		setOverrideClick(delegate
		{
		});
		location_button.enabled = false;
	}
}
