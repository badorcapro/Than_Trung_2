using UnityEngine;
using UnityEngine.UI;

public class StampFacade : MonoBehaviour
{
	public static float scale = 0.4f;

	[Header("References")]
	[SerializeField]
	private CanvasGroup group;

	[SerializeField]
	private Image stamp_image;

	[SerializeField]
	private Image stamp_icon;

	public void setUpStamp(Sprite _image)
	{
		setUpStamp(_image, null, Color.white);
	}

	public void setUpStamp(Sprite _image, float _scale)
	{
		setUpStamp(_image, null, Color.white, _scale);
	}

	public void setUpStamp(Sprite _image, Sprite _icon, Color _icon_colour)
	{
		setUpStamp(_image, _icon, _icon_colour, scale);
	}

	public void setUpStamp(Sprite _image, Sprite _icon, Color _icon_colour, float _scale)
	{
		stamp_image.sprite = _image;
		stamp_image.SetNativeSize();
		stamp_image.rectTransform.sizeDelta = stamp_image.rectTransform.sizeDelta * _scale;
		if (_icon != null)
		{
			stamp_icon.gameObject.SetActive(value: true);
			stamp_icon.sprite = _icon;
			stamp_icon.color = _icon_colour;
		}
		else if (stamp_icon != null)
		{
			stamp_icon.gameObject.SetActive(value: false);
		}
	}

	public void setFaded()
	{
		group.alpha = 0.4f;
	}

	public void setBackgroundMaterial(Material _mat)
	{
		stamp_image.material = _mat;
	}

	public void removeIconMaterial()
	{
		if (!(stamp_icon == null))
		{
			stamp_icon.material = null;
		}
	}
}
