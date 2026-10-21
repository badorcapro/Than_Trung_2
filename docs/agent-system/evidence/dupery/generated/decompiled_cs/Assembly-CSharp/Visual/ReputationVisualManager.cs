using System.Collections.Generic;
using GRGLib.Coroutines;
using GRGLib.Maybe;
using GRGLocalisation;
using Localisation;
using UnityEngine;

namespace Visual;

public class ReputationVisualManager : MonoBehaviour, IAmLocalised
{
	[Header("References")]
	[SerializeField]
	private RectTransform newspaper_parent;

	[Header("Prefabs")]
	[SerializeField]
	private Newspaper newspaper_prefab;

	[Header("Settings")]
	[SerializeField]
	private float animation_duration = 1.1f;

	[SerializeField]
	private Vector2 starting_news_pos;

	[SerializeField]
	private float starting_rotation;

	[SerializeField]
	private Vector2 end_news_pos;

	[SerializeField]
	private float end_rotation;

	private Queue<Newspaper> newspaper_stack = new Queue<Newspaper>();

	public bool reputation_hidden { get; private set; }

	public int reputation { get; private set; } = -1;

	private string default_headline_english => "DETECTIVE HARD AT WORK!";

	private string loc_headline_default_key => "Headline [default]";

	private AssetKey localisation_asset => LocalisationHelper.ui_asset;

	public void hideReputation(Maybe<string> _headline)
	{
		if (!reputation_hidden)
		{
			reputation_hidden = true;
			addNewspaperToStack(1, _headline.is_some ? _headline.value : getDefaultHeadlineText(), _up: true).hide();
		}
	}

	public void unhideReputation()
	{
		reputation_hidden = false;
	}

	public void setReputation(int _total_reputation, Maybe<string> _headline)
	{
		if (reputation != _total_reputation && !reputation_hidden)
		{
			bool up = _total_reputation > reputation;
			reputation = _total_reputation;
			addNewspaperToStack(reputation, _headline.is_some ? _headline.value : getDefaultHeadlineText(), up);
		}
	}

	private Newspaper addNewspaperToStack(int _rep, string _headline, bool _up)
	{
		Newspaper newspaper = Object.Instantiate(newspaper_prefab, newspaper_parent);
		newspaper.setUp(_rep, _headline, _up);
		if (newspaper_stack.Count > 2)
		{
			Object.Destroy(newspaper_stack.Dequeue().gameObject);
		}
		newspaper_stack.Enqueue(newspaper);
		newspaper.transform.localPosition = starting_news_pos;
		newspaper.transform.localEulerAngles = new Vector3(0f, 0f, starting_rotation);
		newspaper.transform.moveTransform(end_news_pos, animation_duration, CoroutineExtensions.easeOutFunc).start(this);
		newspaper.transform.rotateTransformSmart(end_rotation, animation_duration, CoroutineExtensions.easeOutFunc).start(this);
		newspaper.transform.scaleTransform(1f, animation_duration, CoroutineExtensions.easeOutBounceFunc).start(this);
		return newspaper;
	}

	private string getDefaultHeadlineText()
	{
		if (GRGLocalisationHandler.needs_translation && GRGLocalisationHandler.instance.translate(localisation_asset, loc_headline_default_key, out var _result))
		{
			return _result;
		}
		return default_headline_english;
	}
}
