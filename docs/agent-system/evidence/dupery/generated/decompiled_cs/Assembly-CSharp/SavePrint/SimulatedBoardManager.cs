using System.Collections.Generic;
using TMPro;
using UnityEngine;

namespace SavePrint;

public class SimulatedBoardManager : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private List<SimulatedBoardTile> tiles;

	[SerializeField]
	private TMP_Text overview;

	[SerializeField]
	private TMP_Text ratio;

	[SerializeField]
	private TMP_Text explain_tile;

	[SerializeField]
	private TMP_Text overarching;

	private CaseSnapshot snap;

	private void Awake()
	{
		tiles.ForEach(delegate(SimulatedBoardTile _t)
		{
			_t.setEmpty();
		});
		overview.text = "";
		ratio.text = "";
		explain_tile.text = "";
	}

	public void fromString(string _input)
	{
	}

	public void setUp(CaseSnapshot _snapshot, Vector2Int _board_size, List<CaseQuirks> _quirks)
	{
	}

	private void explainTile(Vector2Int _pos)
	{
	}
}
