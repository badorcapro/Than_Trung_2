using GRGLib.Extensions.Unity;
using GRGLib.PropertyDrawers;
using UnityEngine;
using UnityEngine.UI;

namespace GRGLocalisation;

public class LocalisedStaticImage : LocalisedStaticVisualBase<Image>
{
	public enum ResizeBehaviour
	{
		NONE,
		SET_NATIVE_SIZE,
		RESIZE_ORIGINAL,
		RESIZE_CUSTOM
	}

	[Header("Image Settings")]
	[SerializeField]
	private ResizeBehaviour resize_behaviour = ResizeBehaviour.RESIZE_ORIGINAL;

	[SerializeField]
	[ConditionalField("resize_behaviour", false, new object[] { ResizeBehaviour.RESIZE_CUSTOM })]
	private Vector2 max_size;

	protected override void setSprite(Sprite _sprite)
	{
		visual.sprite = _sprite;
		switch (resize_behaviour)
		{
		case ResizeBehaviour.NONE:
			break;
		case ResizeBehaviour.SET_NATIVE_SIZE:
			visual.SetNativeSize();
			break;
		case ResizeBehaviour.RESIZE_ORIGINAL:
			visual.sizeToFit();
			break;
		case ResizeBehaviour.RESIZE_CUSTOM:
			visual.sizeToFit(max_size);
			break;
		default:
			Debug.LogError($"No resizebehaviour set for {resize_behaviour}!");
			break;
		}
	}

	protected override Sprite getSprite(Image _visual)
	{
		return visual.sprite;
	}

	private void Reset()
	{
		visual = GetComponent<Image>();
		if (!(visual == null) && !(visual.sprite == null))
		{
			key = ((visual.sprite.name.Length < 15) ? visual.sprite.name : visual.sprite.name.Substring(0, 15));
		}
	}
}
