using System;
using Audio;
using UnityEngine;

namespace Visual;

public class CasinoCardManager : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private RectTransform card_parent;

	[Header("Prefabs")]
	[SerializeField]
	private VisualCasinoCard card_prefab;

	[Header("Settings")]
	[SerializeField]
	private Vector2 card_left_position;

	[SerializeField]
	private Vector2 card_right_position;

	[SerializeField]
	private float card_left_rotation = 2.5f;

	[SerializeField]
	private float card_right_rotation = 2.5f;

	private CasinoCard left;

	private CasinoCard right;

	private VisualCasinoCard left_visual;

	private VisualCasinoCard right_visual;

	public void setUp(CasinoCard _left, CasinoCard _right)
	{
		left = _left;
		right = _right;
		left_visual = createCard(left, card_left_position, card_left_rotation);
		right_visual = createCard(right, card_right_position, card_right_rotation);
		left_visual.setUpSelectables(right_visual.getSelectable(), _is_right: true);
		right_visual.setUpSelectables(left_visual.getSelectable(), _is_right: false);
	}

	public void checkRenew(CasinoCard _left, CasinoCard _right)
	{
		if (_left != left || _right != right)
		{
			AudioHandler.Sfx.playSfx(Sfx.CARD_DECK);
		}
		if (_left != left)
		{
			left = _left;
			left_visual = replaceCard(left_visual, left, card_left_position);
			left_visual.setUpSelectables(right_visual.getSelectable(), _is_right: true);
			right_visual.setUpSelectables(left_visual.getSelectable(), _is_right: false);
		}
		if (_right != right)
		{
			right = _right;
			right_visual = replaceCard(right_visual, right, card_right_position);
			left_visual.setUpSelectables(right_visual.getSelectable(), _is_right: true);
			right_visual.setUpSelectables(left_visual.getSelectable(), _is_right: false);
		}
	}

	private VisualCasinoCard replaceCard(VisualCasinoCard _visual, CasinoCard _card, Vector2 _position)
	{
		_visual.destroyCard();
		return createCard(_card, _position, _visual.transform.localEulerAngles.z);
	}

	private VisualCasinoCard createCard(CasinoCard _card, Vector2 _position, float _rotation)
	{
		VisualCasinoCard visualCasinoCard = UnityEngine.Object.Instantiate(card_prefab, card_parent);
		visualCasinoCard.setUp(_card);
		visualCasinoCard.moveToPosition(_position);
		visualCasinoCard.transform.localEulerAngles = new Vector3(0f, 0f, _rotation);
		return visualCasinoCard;
	}

	public void setUpCardsForSelection(Action<CasinoCardAbilityData> _on_selection)
	{
		left_visual.setUpCardForSelection(_on_selection);
		right_visual.setUpCardForSelection(_on_selection);
		if (GameHandler.instance.using_gamepad)
		{
			left_visual.selectCard();
		}
	}

	public void resetCardSelections()
	{
		left_visual.resetSelectionCallback();
		right_visual.resetSelectionCallback();
	}
}
