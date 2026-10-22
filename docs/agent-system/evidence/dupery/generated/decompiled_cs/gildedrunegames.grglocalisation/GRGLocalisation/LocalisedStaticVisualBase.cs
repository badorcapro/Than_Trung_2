using UnityEngine;

namespace GRGLocalisation;

public abstract class LocalisedStaticVisualBase<T> : MonoBehaviour, ILocalisedSprite
{
	[SerializeField]
	protected T visual;

	[SerializeField]
	protected SpriteAssetKey asset;

	[SerializeField]
	protected string key;

	protected virtual void Start()
	{
		if (GRGLocalisationHandler.needs_translation)
		{
			translateImage();
		}
	}

	protected virtual void translateImage()
	{
		GRGLocalisationHandler.instance.tryTranslate(asset, key, delegate(Sprite _new_sprite)
		{
			setSprite(_new_sprite);
		});
	}

	protected abstract void setSprite(Sprite _sprite);

	protected abstract Sprite getSprite(T _visual);
}
