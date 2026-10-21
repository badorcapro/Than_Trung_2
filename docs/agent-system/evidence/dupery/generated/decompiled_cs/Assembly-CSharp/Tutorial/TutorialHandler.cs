using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using GRGLib.Menus;
using Nodes;
using TMPro;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;

namespace Tutorial;

public class TutorialHandler : MenuController
{
	[Header("Tutorial References")]
	[SerializeField]
	private TutorialDataSO tutorial_data_so;

	[SerializeField]
	private GameObject raycast_block;

	[SerializeField]
	private Selectable continue_selectable;

	[SerializeField]
	private Image lieutenant;

	[SerializeField]
	private Image detective;

	[SerializeField]
	private DialogueBox lieutenant_text_box;

	[SerializeField]
	private DialogueBox detective_text_box;

	[SerializeField]
	private RectTransform tutorial_object_parent;

	[SerializeField]
	private RectTransform tutorial_object_parent_above;

	[SerializeField]
	private Image tutorial_background;

	[Header("Settings")]
	[SerializeField]
	private Material background_mat;

	private Material default_background_mat;

	[Header("Debug")]
	[SerializeField]
	private TMP_Text debug_progress_text;

	private TutorialStoryGraphNavigator graph_nav;

	private Action on_end_selection;

	private Maybe<(Func<CaseSnapshot, bool>, Action<CaseSnapshot>)> case_check = new Maybe<(Func<CaseSnapshot, bool>, Action<CaseSnapshot>)>();

	public PlayerInput player_input { get; private set; }

	public bool in_tutorial { get; private set; }

	public RectTransform getTextBoxTransform()
	{
		return lieutenant_text_box.rect_trans;
	}

	private Dictionary<DialogueSpeachers, DialogueBox> getSpeacherBoxes()
	{
		return new Dictionary<DialogueSpeachers, DialogueBox>
		{
			{
				DialogueSpeachers.NARRATOR,
				lieutenant_text_box
			},
			{
				DialogueSpeachers.OTHER,
				detective_text_box
			}
		};
	}

	private Dictionary<DialogueSpeachers, Image> getSpeacherImages()
	{
		return new Dictionary<DialogueSpeachers, Image>
		{
			{
				DialogueSpeachers.NARRATOR,
				lieutenant
			},
			{
				DialogueSpeachers.OTHER,
				detective
			}
		};
	}

	public void setUp(TutorialReferences _references, PlayerInput _player_input, Action _on_end_selection)
	{
		player_input = _player_input;
		_references.background_image = tutorial_background;
		graph_nav = new TutorialStoryGraphNavigator(this, getSpeacherBoxes(), lieutenant_text_box.getTextColour(), getSpeacherImages(), _references, _player_input, tutorial_object_parent, tutorial_object_parent_above, debug_progress_text, endTutorial, continue_selectable);
		on_end_selection = _on_end_selection;
		default_background_mat = tutorial_background.material;
	}

	public void forceSelect()
	{
		continue_selectable.Select();
	}

	public void startTutorialLevel(CaseType _case_type, int _case)
	{
		Maybe<StoryNodeGraph> maybe = tutorial_data_so[_case_type, _case];
		if (maybe.is_some)
		{
			startTutorial(maybe.value);
		}
	}

	public void startTutorial(StoryNodeGraph _tutorial_graph)
	{
		openMenu();
		in_tutorial = true;
		_tutorial_graph.fetchStartNode().progress(graph_nav);
	}

	public void endTutorial()
	{
		in_tutorial = false;
		on_end_selection();
		closeMenu();
	}

	public void disableRaycastBlock()
	{
		raycast_block.gameObject.SetActive(value: false);
	}

	public void enableRaycastBlock()
	{
		raycast_block.gameObject.SetActive(value: true);
	}

	public bool hasBackgroundMaterial()
	{
		return tutorial_background.material == background_mat;
	}

	public void addBackgroundMaterial()
	{
		tutorial_background.material = background_mat;
	}

	public void removeBackgroundMaterial()
	{
		tutorial_background.material = default_background_mat;
	}

	public Image getLieutenantImage()
	{
		return lieutenant;
	}

	public void onClick()
	{
		graph_nav.onClick();
	}

	public bool checkState(CaseSnapshot _snap)
	{
		if (!case_check.is_some)
		{
			return false;
		}
		if (case_check.value.Item1(_snap))
		{
			case_check.value.Item2(_snap);
			case_check = new Maybe<(Func<CaseSnapshot, bool>, Action<CaseSnapshot>)>();
			endWait();
			return true;
		}
		return false;
	}

	public void waitForCaseState(Func<CaseSnapshot, bool> _check, Action<CaseSnapshot> _callback)
	{
		case_check = (_check, _callback).maybe();
		startWait();
	}

	public void startWait()
	{
		in_tutorial = false;
		disableRaycastBlock();
		on_end_selection();
	}

	public void endWait()
	{
		in_tutorial = true;
		enableRaycastBlock();
		continue_selectable.Select();
	}
}
