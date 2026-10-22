using System;
using GRGLib.Coroutines;
using GRGLib.Extensions.Unity;
using GRGLib.Maybe;
using UnityEngine;
using UnityEngine.UI;

namespace Visual;

public class VisualCasinoCard : MonoBehaviour
{
	[SerializeField]
	private CasinoCardsVisualDataSO cards_data;

	[Header("References")]
	[SerializeField]
	private CanvasGroup group;

	[SerializeField]
	private Image card_image;

	[SerializeField]
	private Selectable card_selectable;

	[SerializeField]
	private GameObject face_down_parent;

	[SerializeField]
	private Image card_contour;

	[Header("Settings")]
	[SerializeField]
	private Color selected;

	private Maybe<Action<CasinoCardAbilityData>> on_select = new Maybe<Action<CasinoCardAbilityData>>();

	private CasinoCard card;

	private CoroutineRunner highlight_runner;

	private CoroutineRunner contour_runner;

	public void setUp(CasinoCard _card)
	{
		highlight_runner = new CoroutineRunner(this);
		contour_runner = new CoroutineRunner(this);
		if (_card.face_up)
		{
			if (_card.smudged)
			{
				card_image.sprite = cards_data.getJokerSprite();
			}
			else
			{
				card_image.sprite = cards_data[_card];
			}
		}
		else
		{
			face_down_parent.SetActive(value: true);
		}
		card = _card;
	}

	public void setUpSelectables(Selectable _selectable, bool _is_right)
	{
		if (_is_right)
		{
			card_selectable.setNavigationRight(_selectable);
		}
		else
		{
			card_selectable.setNavigationLeft(_selectable);
		}
	}

	public Selectable getSelectable()
	{
		return card_selectable;
	}

	public void selectCard()
	{
		card_selectable.Select();
	}

	public void moveToPosition(Vector2 _position)
	{
		base.transform.moveTransform(_position, 0.35f, CoroutineExtensions.easeInOutFunc).start(this);
	}

	public void destroyCard()
	{
		group.fade(0f, 0.5f, CoroutineExtensions.easeInOutFunc).addCallback(delegate
		{
			UnityEngine.Object.Destroy(base.gameObject);
		}).start(this);
	}

	public void setUpCardForSelection(Action<CasinoCardAbilityData> _on_selection)
	{
		on_select = _on_selection.maybe();
		card_selectable.enabled = true;
		card_selectable.interactable = true;
		highlight_runner.run(base.transform.scaleTransform(1.05f, 0.45f, CoroutineExtensions.easeInOutFunc));
	}

	public void resetSelectionCallback()
	{
		on_select = new Maybe<Action<CasinoCardAbilityData>>();
		card_selectable.interactable = false;
		card_selectable.enabled = false;
		highlight_runner.run(base.transform.scaleTransform(1f, 0.15f, CoroutineExtensions.easeInOutFunc));
	}

	public void onClick()
	{
		if (on_select.is_some)
		{
			on_select.value(new CasinoCardAbilityData(card));
		}
	}

	public void cardContourSelected()
	{
		cardContour(selected);
	}

	public void cardContourUnselected()
	{
		cardContour(new Color(1f, 1f, 1f, 0f));
	}

	private void cardContour(Color _colour)
	{
		contour_runner.run(card_contour.fadeToColour(_colour, 0.35f, CoroutineExtensions.easeInOutFunc));
	}
}
