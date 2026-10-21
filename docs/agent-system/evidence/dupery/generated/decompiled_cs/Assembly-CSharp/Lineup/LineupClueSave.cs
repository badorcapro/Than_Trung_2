using System;

namespace Lineup;

[Serializable]
public struct LineupClueSave
{
	public ClueElementTypes clue_type;

	public string data;

	public static LineupClue loadClue(LineupClueSave _save)
	{
		return _save.clue_type switch
		{
			ClueElementTypes.AGE => new AgeLineupClue(_save.data), 
			ClueElementTypes.HEIGHT => new HeightLineupClue(_save.data), 
			ClueElementTypes.NAME => new NameLineupClue(_save.data), 
			_ => new SimpleLineupClue(_save.data), 
		};
	}

	public LineupClueSave(ClueElementTypes _type, string _data)
	{
		clue_type = _type;
		data = _data;
	}

	public LineupClue loadClue()
	{
		return loadClue(this);
	}
}
