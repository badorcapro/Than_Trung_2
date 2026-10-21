using UnityEngine;

namespace CaseCreation;

public class BoardMarker<T>
{
	public T data;

	public Vector2Int position;

	public bool locked;

	public BoardMarker(T _data, Vector2Int _pos, bool _locked)
	{
		data = _data;
		position = _pos;
		locked = _locked;
	}
}
