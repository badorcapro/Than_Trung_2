using GRGLib.Coroutines;
using GRGLib.Extensions.Vector;
using UnityEngine;
using UnityEngine.UI;

namespace Visual;

public class ConnectionString : ConnectionStringBase
{
	[Header("References")]
	[SerializeField]
	private Image string_image;

	private Vector2 anchor_position => is_base_string ? rect_trans.localPosition : starting_pin.value.rect_trans.localPosition;

	private RectTransform rect_trans => base.transform as RectTransform;

	public override void setStringColour(int _colour_index, Color _colour)
	{
		Image image = string_image;
		colour_index = _colour_index;
		Color color2 = (image.color = _colour);
	}

	public override Color getStringColour()
	{
		return string_image.color;
	}

	protected override void retractString(bool _destroy = true)
	{
		rect_trans.expandSizeDelta(new Vector2(1f, rect_trans.sizeDelta.y), 0.35f, CoroutineExtensions.easeInOutFunc).addCallback(delegate
		{
			if (_destroy)
			{
				Object.Destroy(base.gameObject);
			}
		}).start(this);
	}

	private void stringToPosition(Vector2 _position)
	{
		Vector2 vector = anchor_position - _position;
		rect_trans.sizeDelta = new Vector2(vector.magnitude, rect_trans.sizeDelta.y);
		float num = vector.normalized.toDegrees();
		rect_trans.localEulerAngles = new Vector3(0f, 0f, 180f + num);
	}

	public override void recalculateString()
	{
		rect_trans.localPosition = starting_pin.value.transform.localPosition;
		stringToPosition(ending_pin.value.transform.localPosition);
	}

	public override void setStringStartPosition(Vector2 _pos)
	{
		rect_trans.localPosition = _pos;
	}

	public override void setStringEndPosition(Vector2 _pos)
	{
		stringToPosition(_pos);
	}
}
