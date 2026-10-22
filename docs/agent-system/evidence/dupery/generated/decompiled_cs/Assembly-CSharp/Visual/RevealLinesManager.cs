using System.Collections.Generic;
using GRGLib.Extensions.Vector;
using GRGLib.Serializable;
using UnityEngine;

namespace Visual;

public class RevealLinesManager : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private RectTransform lines_parent;

	[SerializeField]
	private BoardVisualManager board_manager;

	[Header("Prefabs")]
	[SerializeField]
	private RevealLine line_prefab;

	[Header("Colour Settings")]
	[SerializeField]
	private SerializableDictionary<RevealLineColour, Color> line_colours;

	private List<RevealLine> lines = new List<RevealLine>();

	public void checkRevealLines(RoleData _role, CaseSnapshot _snap)
	{
		_role.getRevealLines(_snap).ForEach(drawLine);
	}

	public void destroyLines()
	{
		lines.ForEach(delegate(RevealLine _l)
		{
			_l.destroyLine();
		});
		lines.Clear();
	}

	private void drawLine(RevealLineSettings _line_settings)
	{
		RevealLine revealLine = Object.Instantiate(line_prefab, lines_parent);
		revealLine.makeLine(board_manager.transform.localPosition.xy() + _line_settings.get_from(board_manager), board_manager.transform.localPosition.xy() + _line_settings.get_to(board_manager), line_colours[_line_settings.colour]);
		lines.Add(revealLine);
	}
}
