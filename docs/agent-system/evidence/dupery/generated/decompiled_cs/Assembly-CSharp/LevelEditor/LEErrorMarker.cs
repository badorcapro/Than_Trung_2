using GRGLib.Maybe;
using UnityEngine;

namespace LevelEditor;

public class LEErrorMarker : MenuBase
{
	[SerializeField]
	private LEProblemHighlighter problem_highlighter;

	public Vector2 highlighter_offset;

	public Maybe<string> current_error { get; private set; } = new Maybe<string>();

	public void setReference(LEProblemHighlighter _highlighter)
	{
		problem_highlighter = _highlighter;
	}

	public void openWithError(string _error)
	{
		current_error = _error.maybe();
		openMenu();
	}

	protected override void onMenuClosing()
	{
		current_error = new Maybe<string>();
		base.onMenuClosing();
	}

	public void onHover(bool _start)
	{
		if (_start)
		{
			problem_highlighter.openFromErrorMarker(this);
		}
		else
		{
			problem_highlighter.tryClose(this);
		}
	}
}
