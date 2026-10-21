using System;
using GRGLib.Coroutines;
using GRGLocalisation;
using Localisation;
using TMPro;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.InputSystem;

namespace LevelEditor;

public class LEBoardSlot : MonoBehaviour, IAmLocalised
{
	[Header("References")]
	[SerializeField]
	private TMP_Text ref_pos_text;

	[SerializeField]
	private CanvasGroup hover_group;

	[SerializeField]
	private TMP_Text helper_text;

	[SerializeField]
	private InputAssetPerType role_input;

	[SerializeField]
	private InputAssetPerType location_input;

	private Action<LEBoardSlot, PointerEventData> on_click;

	private CoroutineRunner hover_runner;

	public Vector2Int grid_position { get; private set; }

	private AssetKey localisation_asset => LocalisationHelper.misc_asset;

	private string loc_input_key => "LE_slot [input]";

	public void setUp(Vector2Int _pos, Action<LEBoardSlot, PointerEventData> _on_click, PlayerInput _input)
	{
		hover_runner = new CoroutineRunner(this);
		grid_position = _pos;
		on_click = _on_click;
		ref_pos_text.text = $"({grid_position.x}, {grid_position.y})";
		onInputChange(_input);
	}

	public void onInputChange(PlayerInput _input)
	{
		helper_text.text = localisation_asset.checkTranslationWithData(loc_input_key, englishInputHelper, role_input.getTextAsset(_input), location_input.getTextAsset(_input));
	}

	private string englishInputHelper(string _d1, string _d2)
	{
		return _d1 + " Add Role.\n" + _d2 + " Add Location.";
	}

	public void onClick(PointerEventData _data)
	{
		on_click(this, _data);
	}

	public void onHover(bool _start)
	{
		hover_runner.run(hover_group.fade(_start ? 1 : 0, 0.15f, CoroutineExtensions.easeInOutFunc));
	}
}
