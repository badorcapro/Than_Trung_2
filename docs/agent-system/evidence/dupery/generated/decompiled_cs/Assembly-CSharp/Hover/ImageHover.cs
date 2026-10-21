using GRGLib.Coroutines;
using GRGLib.Extensions.String;
using GRGLib.Extensions.Unity;
using GRGLib.Maybe;
using UnityEngine;
using UnityEngine.UI;

namespace Hover;

public class ImageHover : BaseHover
{
	private bool locked_onto_image;

	public Maybe<Image> hovering_image { get; private set; } = new Maybe<Image>();

	public override bool is_locked => locked_onto_image;

	public void setUp(Image _hovering, string _title, string _description, Camera _camera, Vector2 _canvas_size)
	{
		hovering_image = _hovering.maybe();
		text.text = _title.sizeRelative(115).bold() + "\n" + _description;
		base.rect_trans.anchoredPosition = getHoverPosition(_hovering, _camera, _canvas_size);
		fade_runner.run(group.fade(1f, 0.3f, CoroutineExtensions.easeInOutFunc));
	}

	private Vector2 getHoverPosition(Image _image, Camera _camera, Vector2 _canvas_size)
	{
		Vector2 positionToUI = _canvas_size.getPositionToUI(_camera.WorldToScreenPoint(_image.rectTransform.position));
		if (positionToUI.x + base.rect_trans.sizeDelta.x > _canvas_size.x / 2f)
		{
			positionToUI.x = _canvas_size.x / 2f - base.rect_trans.sizeDelta.x - 5f;
		}
		if (positionToUI.y - base.rect_trans.sizeDelta.y < (0f - _canvas_size.y) / 2f)
		{
			positionToUI.y = base.rect_trans.sizeDelta.y - _canvas_size.y / 2f + 5f;
		}
		return positionToUI;
	}

	public void lockSelf()
	{
		locked_onto_image = true;
		displayLock();
	}

	public void unlockSelf()
	{
		locked_onto_image = false;
		displayLock();
	}
}
