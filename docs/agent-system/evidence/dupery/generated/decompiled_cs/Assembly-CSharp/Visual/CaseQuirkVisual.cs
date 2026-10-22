using System;
using GRGLib.Coroutines;
using Leads;
using Quirks;
using UnityEngine;
using UnityEngine.UI;

namespace Visual;

public class CaseQuirkVisual : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private CanvasGroup group;

	[SerializeField]
	private Image icon;

	[SerializeField]
	private Button quirk_button;

	private CaseQuirks quirk;

	private Action<CaseQuirkVisual> explain_quirk;

	private Action<CaseQuirkVisual> stop_explain_quirk;

	private Action<CaseQuirks> open_codex;

	private CoroutineRunner jiggle_runner;

	public string explain_string { get; private set; } = "";

	private void Awake()
	{
		jiggle_runner = new CoroutineRunner(this);
	}

	public void animateToPosition(Vector2 _target)
	{
		group.fade(1f, 0.35f, CoroutineExtensions.easeInOutFunc).start(this);
		(base.transform as RectTransform).anchoredMove(_target, 0.65f, CoroutineExtensions.easeInOutFunc).start(this);
	}

	public void setUp(CaseQuirkData _quirk, Sprite _icon, Action<CaseQuirkVisual> _explain, Action<CaseQuirkVisual> _stop, Action<CaseQuirks> _open_codex)
	{
		quirk = _quirk.quirk_type;
		icon.sprite = _icon;
		explain_string = "<b>" + _quirk.name + "</b>\n" + _quirk.description;
		explain_quirk = _explain;
		stop_explain_quirk = _stop;
		open_codex = _open_codex;
	}

	public void setUp(Clue _clue, Sprite _icon, Color _icon_colour, Action<CaseQuirkVisual> _explain, Action<CaseQuirkVisual> _stop)
	{
		icon.sprite = _icon;
		icon.color = _icon_colour;
		explain_string = "<b>" + _clue.getName() + "</b>\n" + _clue.getDescription();
		explain_quirk = _explain;
		stop_explain_quirk = _stop;
	}

	public void setUpSelectables(Selectable _left, Selectable _right, Selectable _up)
	{
		Navigation navigation = quirk_button.navigation;
		navigation.selectOnLeft = _left;
		navigation.selectOnRight = _right;
		navigation.selectOnUp = _up;
		quirk_button.navigation = navigation;
	}

	public Selectable getSelectable()
	{
		return quirk_button;
	}

	public void explainQuirk()
	{
		jiggle_runner.run(base.transform.jiggle());
		explain_quirk(this);
	}

	public void stopExplainQuirk()
	{
		stop_explain_quirk(this);
	}

	public void openCodex()
	{
		open_codex(quirk);
	}

	private void Reset()
	{
		icon = GetComponent<Image>();
	}
}
