using System.Collections;
using GRGLib.Coroutines;
using GRGLib.Maybe;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;
using Visual;

public class ScissorsManager : NotesToolManager, IPointerUpHandler, IEventSystemHandler, IPointerDownHandler
{
	[Header("Scissors References")]
	[SerializeField]
	private PenManager pen_manager;

	[SerializeField]
	private StringManager string_manager;

	[SerializeField]
	private Image scissors;

	[SerializeField]
	private RectTransform selected_parent;

	[SerializeField]
	private RectTransform normal_parent;

	[Header("Settings")]
	[SerializeField]
	private float cut_distance = 50f;

	[SerializeField]
	private Sprite normal_sprite;

	[SerializeField]
	private Sprite can_cut_sprite;

	private CoroutineRunner string_cut_runner;

	private Maybe<ConnectionStringBase> to_cut = new Maybe<ConnectionStringBase>();

	protected override Vector3 starting_tool_position => Vector3.zero;

	protected override Vector2 tool_offset
	{
		get
		{
			if (!base.tool_selected)
			{
				return new Vector2(5f, 10f);
			}
			return new Vector2(0f, 0f);
		}
	}

	protected override void Awake()
	{
		base.Awake();
		string_cut_runner = new CoroutineRunner(this);
	}

	protected override bool canSelect()
	{
		if (!base.tool_selected && !pen_manager.tool_selected)
		{
			return !string_manager.tool_selected;
		}
		return false;
	}

	protected override void onToolSelect()
	{
		string_cut_runner.run(checkForClosestString());
		base.transform.SetParent(selected_parent);
	}

	protected override void onToolDeselect()
	{
		string_cut_runner.stop();
		base.transform.SetParent(normal_parent);
	}

	public void OnPointerUp(PointerEventData eventData)
	{
		if (base.tool_selected)
		{
			if (eventData.button == PointerEventData.InputButton.Left && to_cut.is_some)
			{
				tryCutString(to_cut.value);
			}
			if (eventData.button == PointerEventData.InputButton.Right)
			{
				deselectPen();
			}
		}
	}

	public void OnPointerDown(PointerEventData eventData)
	{
	}

	private void tryCutString(ConnectionStringBase _string)
	{
		scissors.sprite = normal_sprite;
		string_manager.removeFromList(_string);
		_string.destroyStringWithScissors();
		to_cut = new Maybe<ConnectionStringBase>();
	}

	private IEnumerator checkForClosestString()
	{
		string_manager.refreshList();
		while (true)
		{
			to_cut = string_manager.getCutableString(getToolPosition(), cut_distance);
			scissors.sprite = (to_cut.is_some ? can_cut_sprite : normal_sprite);
			yield return null;
		}
	}
}
