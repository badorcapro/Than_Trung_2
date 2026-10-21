using System;
using UnityEngine;
using UnityEngine.EventSystems;

namespace LevelEditor;

public class LEBoardLocation : MonoBehaviour
{
	private Action<LEBoardLocation> on_remove;

	private Action<LEBoardLocation> on_change;

	public LocationData facade { get; private set; }

	public void setUp(Vector2Int _pos, Either<LocationTypes, LocationData> _location, LocationVisualDataSO _visual_data, Action<LEBoardLocation> _on_change, Action<LEBoardLocation> _on_remove)
	{
		facade = (_location.is_a ? _location.maybe_a.value.createLocation(_pos, new System.Random()) : _location.maybe_b.value);
		UnityEngine.Object.Instantiate(_visual_data[facade.location_type], base.transform).setAsDisplay(facade);
		on_change = _on_change;
		on_remove = _on_remove;
	}

	public void onPointerUp(PointerEventData _data)
	{
		if (_data.button == PointerEventData.InputButton.Right)
		{
			on_remove(this);
			UnityEngine.Object.Destroy(base.gameObject);
		}
		else if (_data.button == PointerEventData.InputButton.Left)
		{
			on_change(this);
		}
	}
}
